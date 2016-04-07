//
//  LPMovieWriter.m
//  iVideo
//
//  Created by apple on 16/1/19.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMovieWriter.h"
#import "LPCameraNotification.h"
#import "LPContextManager.h"
#import "NSFileManager+Additions.h"

@interface LPMovieWriter ()
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInput *audioWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic, weak)   CIContext *ciContext;
@property (nonatomic, assign) CGColorSpaceRef colorSpace;
@property (nonatomic, strong) CIFilter *activeFilter;

@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, strong) NSDictionary *audioSettings;

@property (nonatomic, assign) BOOL firstSample;
@end

@implementation LPMovieWriter

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
                        audioSettings:(NSDictionary *)audioSettings
                        dispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (self = [super init]) {
        _videoSettings = videoSettings;
        _audioSettings = audioSettings;
        _dispatchQueue = dispatchQueue;
        
        _ciContext = [LPContextManager defaultManager].ciContext;
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        
        _firstSample = YES;
        
        [noteCenter addObserver:self
                       selector:@selector(filterChanged:)
                           name:LPFilterSelectionDidChangeNotification
                         object:nil];
    }
    return self;
}

+ (instancetype)movieWriterWithVideoSettings:(NSDictionary *)videoSettings
                               audioSettings:(NSDictionary *)audioSettings
                               dispatchQueue:(dispatch_queue_t)dispatchQueue {
    return [[self alloc] initWithVideoSettings:videoSettings
                                 audioSettings:audioSettings
                                 dispatchQueue:dispatchQueue];
}

- (void)dealloc {
    CGColorSpaceRelease(self.colorSpace);
    [noteCenter removeObserver:self];
}

- (void)filterChanged:(NSNotification *)note {
    self.activeFilter = [note.object copy];
}

- (void)startWriting {
    dispatch_async(self.dispatchQueue, ^{
        // 1. 创建assetWriter
        NSError *error = nil;
        NSString *fileType = AVFileTypeQuickTimeMovie;
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self uniqueOutputURL]
                                                    fileType:fileType
                                                       error:&error];
        if (!self.assetWriter || error) {
            NSLog(@"Cannot create asset writer: %@", error);
            return;
        }
        
        // 2. 配置assetWriterInput
        self.videoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                               outputSettings:self.videoSettings];
        self.videoWriterInput.expectsMediaDataInRealTime = YES;
        self.videoWriterInput.transform = [self transformForDeviceOrientation:[UIDevice currentDevice].orientation];
        NSDictionary *attributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (id)kCVPixelBufferWidthKey : self.videoSettings[AVVideoWidthKey],
                                     (id)kCVPixelBufferHeightKey : self.videoSettings[AVVideoHeightKey],
                                     (id)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue};
        self.pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.videoWriterInput
                                                                             sourcePixelBufferAttributes:attributes];
        if ([self.assetWriter canAddInput:self.videoWriterInput]) {
            [self.assetWriter addInput:self.videoWriterInput];
        } else {
            NSLog(@"Unable to add asset writer video input");
        }
        
        
        self.audioWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                               outputSettings:self.audioSettings];
        self.audioWriterInput.expectsMediaDataInRealTime = YES;
        if ([self.assetWriter canAddInput:self.audioWriterInput]) {
            [self.assetWriter addInput:self.audioWriterInput];
        } else {
            NSLog(@"Unable to add asset writer audio input");
        }
        
        self.writing = YES;
        self.firstSample = YES;
    });
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self.isWriting) {
        return;
    }
    
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    if (mediaType == kCMMediaType_Video) {
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if (self.firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp]; // 在开启写会话 (only once)
            } else {
                NSLog(@"Failed to start writing!");
            }
            self.firstSample = NO;
        }
        // 从adaptor的帧缓存池中创建输出帧缓存
        CVPixelBufferRef outputRenderBuffer = NULL;
        CVPixelBufferPoolRef pixelBufferPool = self.pixelBufferAdaptor.pixelBufferPool;
        CVReturn error = CVPixelBufferPoolCreatePixelBuffer(NULL,
                                                            pixelBufferPool,
                                                            &outputRenderBuffer);
        if (error) { // kCVReturnSuccess is 0
            NSLog(@"Unable to obtain a pixel buffer from the pool");
        }
        
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *srcImage = [CIImage imageWithCVPixelBuffer:imageBuffer
                                                    options:nil];
        CIImage *filteredImage = nil;
        if (self.activeFilter) {
            [self.activeFilter setValue:srcImage forKey:kCIInputImageKey];
            filteredImage = self.activeFilter.outputImage;
        }
        if (!filteredImage) {
            filteredImage = srcImage;
        }
        [self.ciContext render:filteredImage
               toCVPixelBuffer:outputRenderBuffer
                        bounds:filteredImage.extent
                    colorSpace:self.colorSpace];
        
        if (self.videoWriterInput.readyForMoreMediaData) {
            if (![self.pixelBufferAdaptor appendPixelBuffer:outputRenderBuffer
                                       withPresentationTime:timestamp]) {
                NSLog(@"Failed to appending pixel buffer");
            }
        }
        CVPixelBufferRelease(outputRenderBuffer);
    } else if (!self.firstSample && mediaType == kCMMediaType_Audio) {
        if (self.audioWriterInput.isReadyForMoreMediaData) {
            if (![self.audioWriterInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"Failed to appending audio sample buffer");
            }
        }
    }
}

- (void)stopWritingWithCompletion:(LPWritingCompletionHandler)completionHandler {
    self.writing = NO;
    dispatch_async(self.dispatchQueue, ^{
        [self.assetWriter finishWritingWithCompletionHandler:^{
            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_async(MAIN_QUEUE, ^{
                    if (completionHandler) {
                        completionHandler(self.assetWriter.outputURL);
                    }
                });
            }
        }];
    });
}

#pragma mark - private methods
// 生成唯一输出URL
- (NSURL *)uniqueOutputURL {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dirPath = [fileMgr temporaryFileDirectoryWithTemplateString:@"cameraRecording.XXXXXX"];
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"camera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (CGAffineTransform)transformForDeviceOrientation:(UIDeviceOrientation)orientation{
    CGAffineTransform transform;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(- M_PI_2);
        default:
            transform = CGAffineTransformIdentity;
            break;
    }
    return transform;
}
@end
