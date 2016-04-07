//
//  LPMovieEncoder.m
//  iVideo
//
//  Created by apple on 16/3/28.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMovieEncoder.h"
#import "NSFileManager+Additions.h"
#import "LPContextManager.h"
//#import <libkern/OSAtomic.h>

@interface LPMovieEncoder ()

@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetWriter *writer;

@property (nonatomic, strong) AVAssetReaderAudioMixOutput *audioMixOutput;
@property (nonatomic, strong) AVAssetReaderVideoCompositionOutput *videoCompositionOutput;

@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;

@property (nonatomic, strong) dispatch_queue_t mainProcessingQueue;
@property (nonatomic, strong) dispatch_queue_t audioProcessingQueue;
@property (nonatomic, strong) dispatch_queue_t videoProcessingQueue;
@property (nonatomic, strong) dispatch_group_t dispatchGroup;

@property (nonatomic, strong) LPFilterGraph *filterGraph;

@property (nonatomic, strong) AVComposition *composition;
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong) AVVideoComposition *videoComposition;

@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign) BOOL audioFinished;
@property (nonatomic, assign) BOOL videoFinished;

@property (nonatomic, weak) CIContext *ciContext;
@property (nonatomic, assign) CGColorSpaceRef colorSpace;

@property (nonatomic, copy) LPEncodeSuccessHandler successHandler;
@property (nonatomic, copy) LPEncodeFailureHandler failureHandler;
@property (nonatomic, copy) LPEncodeProgressHandler progressHandler;

@property (nonatomic, assign) LPMovieSize movieSize;
@property (nonatomic, assign) CMTime movieDuration;

@end

@implementation LPMovieEncoder

- (instancetype)initWithComposition:(LPComposition *)composition
                        filterGraph:(LPFilterGraph *)filterGraph
                          movieSize:(LPMovieSize)movieSize {
    if (self = [super init]) {
        _filterGraph = filterGraph;
        
        // initial setup (queue)
        _mainProcessingQueue = dispatch_queue_create("main processing q", NULL);
        _audioProcessingQueue = dispatch_queue_create("audio processing q", NULL);
        _videoProcessingQueue = dispatch_queue_create("video processing q", NULL);
        
        _composition = composition.composition;
        _audioMix = composition.audioMix;
        _videoComposition = composition.videoComposition;
        _movieSize = movieSize;
        _movieDuration = composition.timeRange.duration;
        _outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"composition.m4v"]];
        
        _ciContext = [LPContextManager defaultManager].ciContext;
    }
    return self;
}

- (void)startEncodingWithSuccess:(LPEncodeSuccessHandler)successHandler
                         failure:(LPEncodeFailureHandler)failureHandler
                        progress:(LPEncodeProgressHandler)progressHandler {
    dispatch_async(self.mainProcessingQueue, ^{
        if (self.cancelled) return;
        
        self.successHandler = successHandler;
        self.failureHandler = failureHandler;
        self.progressHandler = progressHandler;
        
        BOOL success = YES;
        NSError *error = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:self.outputURL.path]) {
            success = [fm removeItemAtPath:self.outputURL.path error:&error];
        }
        if (success) {
            success = [self setupReaderAndWriter:&error];
        }
        if (success) {
            success = [self startReaderAndWriter:&error];
        }
        if (!success) {
            [self encodingDidFinishSuccess:success error:error];
        }
    });
}

- (BOOL)setupReaderAndWriter:(NSError **)outError {
    // 1. initialize reader & writer
    self.reader = [AVAssetReader assetReaderWithAsset:self.composition error:outError];
    BOOL success = (self.reader != nil);
    if (success) {
        self.writer = [AVAssetWriter assetWriterWithURL:self.outputURL
                                               fileType:AVFileTypeQuickTimeMovie
                                                  error:outError];
        success = (self.writer != nil);
    }
    
    if (success) {
        NSArray *audioTracks = [self.composition tracksWithMediaType:AVMediaTypeAudio];
        NSArray *videoTracks = [self.composition tracksWithMediaType:AVMediaTypeVideo];
        // 2. initialize audio reader and configure its output & input
        if (audioTracks.count > 0) {
            NSDictionary *decompressAudioSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM)};
            self.audioMixOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks
                                                                                          audioSettings:decompressAudioSettings];
            self.audioMixOutput.audioMix = self.audioMix;
            [self.reader addOutput:self.audioMixOutput];
            
        
            AudioChannelLayout stereo = {kAudioChannelLayoutTag_Stereo, 0, 0};
            NSData *stereoData = [NSData dataWithBytes:&stereo length:offsetof(AudioChannelLayout, mChannelDescriptions)];
            NSDictionary *compressAudioSettings = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                    AVEncoderBitRateKey : @(128000),
                                                    AVSampleRateKey : @(44100),
                                                    AVChannelLayoutKey : stereoData,
                                                    AVNumberOfChannelsKey : @(2)};
            self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                 outputSettings:compressAudioSettings];
            self.audioInput.expectsMediaDataInRealTime = NO;
            [self.writer addInput:self.audioInput];
        }
        // 2. initialize video reader and configure its output & input
        if (videoTracks.count > 0) {
            NSDictionary *decompressVideoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
            self.videoCompositionOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks
                                                                                                                  videoSettings:decompressVideoSettings];
            self.videoCompositionOutput.videoComposition = self.videoComposition;
            [self.reader addOutput:self.videoCompositionOutput];
            
            
            NSDictionary *compressVideoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                                    AVVideoWidthKey : @([self movieWidth]),
                                                    AVVideoHeightKey : @([self movieHeight]),
                                                    };
            self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                 outputSettings:compressVideoSettings];
            self.videoInput.expectsMediaDataInRealTime = NO;
            // initialize adaptor
            NSDictionary *pixelBufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
                                                    (id)kCVPixelBufferWidthKey : @([self movieWidth]),
                                                    (id)kCVPixelBufferHeightKey : @([self movieHeight]),
                                                    (id)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue};
            self.adaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.videoInput
                                                                      sourcePixelBufferAttributes:pixelBufferAttributes];
            
            if ([self.writer canAddInput:self.videoInput]) {
                [self.writer addInput:self.videoInput];
            }
        }
    }
    return success;
}

- (BOOL)startReaderAndWriter:(NSError **)outError {
    BOOL success = YES;
    // 1. start reading and writing
    success = [self.reader startReading];
    if (!success) {
        *outError = self.reader.error;
    }
    if (success) {
        success = [self.writer startWriting];
        if (!success) {
            *outError = self.writer.error;
        }
    }
    if (success) {
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        self.dispatchGroup = dispatch_group_create();
        [self.writer startSessionAtSourceTime:kCMTimeZero];
        self.audioFinished = NO;
        self.videoFinished = NO;
        
        // 2. writing audio data
        if (self.audioInput) {
            dispatch_group_enter(self.dispatchGroup);
            [self.audioInput requestMediaDataWhenReadyOnQueue:self.audioProcessingQueue
                                                   usingBlock:^{
                                                       if (self.audioFinished) return;
                                                       
                                                       BOOL completedOrFailed = NO;
                                                       if ([self.audioInput isReadyForMoreMediaData] && !completedOrFailed) {
                                                           CMSampleBufferRef sb = [self.audioMixOutput copyNextSampleBuffer];
                                                           if (sb != NULL) {
                                                               BOOL success = [self.audioInput appendSampleBuffer:sb];
                                                               CFRelease(sb);
                                                               sb = NULL;
                                                               completedOrFailed = !success;
                                                           } else {
                                                               completedOrFailed = YES;
                                                           }
                                                       }
                                                       if (completedOrFailed) {
                                                           BOOL oldFinished = self.audioFinished;
                                                           self.audioFinished = YES;
                                                           if (oldFinished == NO) {
                                                               [self.audioInput markAsFinished];
                                                           }
                                                           dispatch_group_leave(self.dispatchGroup);
                                                       }
                                                   }];
        }
        
        // 3. writing audio data (filter processing)
        if (self.videoInput) {
            dispatch_group_enter(self.dispatchGroup);
            [self.videoInput requestMediaDataWhenReadyOnQueue:self.videoProcessingQueue
                                                   usingBlock:^{
                                                       if (self.videoFinished) return;
                                                       
                                                       BOOL completedOrFailed = NO;
                                                       if ([self.videoInput isReadyForMoreMediaData] && !completedOrFailed) {
                                                           CMSampleBufferRef sb = [self.videoCompositionOutput copyNextSampleBuffer];
                                                           if (sb != NULL) {
                                                               CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sb);

                                                               CVPixelBufferRef pixelBufferOut = NULL;
                                                               CVPixelBufferPoolRef pixelBufferPool = self.adaptor.pixelBufferPool;
                                                               OSStatus err = CVPixelBufferPoolCreatePixelBuffer(NULL,
                                                                                                                 pixelBufferPool,
                                                                                                                 &pixelBufferOut);
                                                               if (err) {
                                                                   NSLog(@"pixel buffer create error!!!");
                                                                   // ...
                                                               }
                                                               
                                                               CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sb);
                                                               NSParameterAssert(imageBuffer);
                                                               CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                                                               self.filterGraph.inputImage = sourceImage;
                                                               CIImage *filteredImage = self.filterGraph.outputImage;
                                                              
                                                               [self.ciContext render:filteredImage
                                                                      toCVPixelBuffer:pixelBufferOut
                                                                               bounds:sourceImage.extent
                                                                           colorSpace:self.colorSpace];
                                                               BOOL success = [self.adaptor appendPixelBuffer:pixelBufferOut withPresentationTime:timestamp];
                                                            
                                                               CVPixelBufferRelease(pixelBufferOut);
                                                               CFRelease(sb);
                                                               sb = NULL;
                                                               completedOrFailed = !success;
                                                               
                                                               if (self.progressHandler) {
                                                                   dispatch_async(MAIN_QUEUE, ^{
                                                                        self.progressHandler(CMTimeGetSeconds(timestamp) / CMTimeGetSeconds(self.movieDuration));
                                                                   });
                                                               }
                                                           } else {
                                                               completedOrFailed = YES;
                                                           }
                                                       }
                                                       if (completedOrFailed) {
                                                           BOOL oldFinished = self.videoFinished;
                                                           self.videoFinished = YES;
                                                           if (oldFinished == NO) {
                                                               NSLog(@"video writing marked as finished!");
                                                               [self.videoInput markAsFinished];
                                                           }
                                                           dispatch_group_leave(self.dispatchGroup);
                                                       }
                                                   }];
        }
        
        // 4. set up finish notification
        dispatch_group_notify(self.dispatchGroup, self.mainProcessingQueue, ^{
            if (self.colorSpace) {
                CGColorSpaceRelease(self.colorSpace);
            }
            BOOL finalSuccess = YES;
            NSError *error = nil;
            if (self.cancelled) {
                [self.reader cancelReading];
                [self.writer cancelWriting];
            } else {
                if (self.reader.status == AVAssetReaderStatusFailed) {
                    finalSuccess = NO;
                    error = self.reader.error;
                }
                if (finalSuccess) {
                    [self.writer finishWritingWithCompletionHandler:^{
                        [self encodingDidFinishSuccess:YES error:nil];
                    }];
                }
            }
        });
    }
    return success;
}

- (void)encodingDidFinishSuccess:(BOOL)success error:(NSError *)error {
    if (!success) {
        [self.reader cancelReading];
        [self.writer cancelWriting];
        dispatch_async(MAIN_QUEUE, ^{
            if (self.failureHandler) {
                self.failureHandler(error);
            }
        });
    } else {
        _cancelled = NO;
        self.audioFinished = NO;
        self.videoFinished = NO;
        dispatch_async(MAIN_QUEUE, ^{
            if (self.successHandler) {
                self.successHandler(self.outputURL);
            }
        });
    }
}

- (void)cancelEncoding {
    
    dispatch_async(self.mainProcessingQueue, ^{
        if (self.audioInput) {
            dispatch_async(self.audioProcessingQueue, ^{
                BOOL oldFinished = self.audioFinished;
                self.audioFinished = YES;
                if (oldFinished == NO) {
                    [self.audioInput markAsFinished];
                }
                dispatch_group_leave(self.dispatchGroup);
            });
        }
        
        if (self.videoInput) {
            dispatch_async(self.videoProcessingQueue, ^{
                BOOL oldFinished = self.videoFinished;
                self.videoFinished = YES;
                if (oldFinished == NO) {
                    [self.videoInput markAsFinished];
                }
                dispatch_group_leave(self.dispatchGroup);
            });
        }
        
        _cancelled = YES;
    });
}

- (CGFloat)movieWidth {
    switch (self.movieSize) {
        case LPMovieSize480P:
            return LP480pVideoSize.width;
        case LPMovieSize720P:
            return LP720pVideoSize.width;
        default:
            return LP1080pVideoSize.width;
    }
}

- (CGFloat)movieHeight {
    switch (self.movieSize) {
        case LPMovieSize480P:
            return LP480pVideoSize.height;
        case LPMovieSize720P:
            return LP720pVideoSize.height;
        default:
            return LP1080pVideoSize.height;
    }
}
@end
