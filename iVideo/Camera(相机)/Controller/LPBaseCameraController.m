//
//  LPCameraController.m
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPBaseCameraController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LPAssetsLibrary.h"
#import "NSFileManager+Additions.h"
#import "LPError.h"
#import "AVCaptureDevice+HighFrameRate.h"
#import "LPCameraNotification.h"

// 凡对焦, 曝光, 闪光灯, 手电筒的模式处理 和 实时缩放因子设置 均需加锁 !!!

static const CGFloat LPZoomRate = 1.0f;

// zoom KVO contexts
static const NSString * LPRampingVideoZoomContext;
static const NSString * LPVideoZoomFactorContext;

@interface LPBaseCameraController () <AVCaptureFileOutputRecordingDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, weak)   AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;   // movie output
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;  // still image output
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput; // face metadata output
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) LPAssetsLibrary *library;
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@end

@implementation LPBaseCameraController

- (instancetype)init {
    if (self = [super init]) {
        _library = [[LPAssetsLibrary alloc] init];
        _videoQueue = dispatch_queue_create("com.ivideo.video.queue", NULL);
    }
    return self;
}

#pragma mark - session configuration (会话设置, 启动与停止)
- (BOOL)setupSessionWithError:(NSError **)error {
    // 1. 初始化会话
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 2. 获取输入设备(摄像头 + 麦克风), 设置输入, 并为会话添加此输入
    if (![self setupSessionInputsWithError:error]) {
        NO;
    }
    
    // 3. 设置输出
    if (![self setupSessionOutputsWithError:error]) {
        NO;
    }
    
    return YES;
}

- (BOOL)setupSessionInputsWithError:(NSError **)error {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 2.1 视频输入
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.session canAddInput:videoInput]) {
            [self.session addInput:videoInput];
            self.videoInput = videoInput;
        } else {
            NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to add video input!"};
            *error = [NSError errorWithDomain:LPCameraErrorDomain
                                         code:LPCameraErrorCodeFailedToAddInput
                                     userInfo:info];
            return NO;
        }
    } else {
        return NO;
    }
    // 2.2 音频输入
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioDevice) {
        if ([self.session canAddInput:audioInput]) {
            [self.session addInput:audioInput];
        } else {
            NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to add audio input!"};
            *error = [NSError errorWithDomain:LPCameraErrorDomain
                                         code:LPCameraErrorCodeFailedToAddInput
                                     userInfo:info];
            return NO;
        }
    } else {
        return NO;
    }
    
    // 2.3 观察缩放相关属性, 以通知vc(delegate)调整相关UI
    [[self activeCamera] addObserver:self forKeyPath:@"videoZoomFactor" options:0 context:&LPVideoZoomFactorContext];
    [[self activeCamera] addObserver:self forKeyPath:@"rampingVideoZoom" options:0 context:&LPRampingVideoZoomContext];
    
    return YES;
}

- (BOOL)setupSessionOutputsWithError:(NSError **)error {
    // 3.1 图像输出
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    } else {
        NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to add still image output!"};
        *error = [NSError errorWithDomain:LPCameraErrorDomain
                                     code:LPCameraErrorCodeFailedToAddOutput
                                 userInfo:info];
        return NO;
    }
    // 3.2 视频输出
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:self.movieOutput]) {
        [self.session addOutput:self.movieOutput];
    } else {
        NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to add video output!"};
        *error = [NSError errorWithDomain:LPCameraErrorDomain
                                     code:LPCameraErrorCodeFailedToAddOutput
                                 userInfo:info];
        return NO;
    }
    // 3.3 人脸输出
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace]; // 指定output元数据类型
        [self.metadataOutput setMetadataObjectsDelegate:self
                                                  queue:MAIN_QUEUE];
    } else {
        NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to add video output!"};
        *error = [NSError errorWithDomain:LPCameraErrorDomain
                                     code:LPCameraErrorCodeFailedToAddOutput
                                 userInfo:info];
    }
    
    return YES;
}

// "插线板"接上电源
- (void)startSession {
    dispatch_async(self.videoQueue, ^{
        if (![self.session isRunning]) {
            [self.session startRunning];
        }
    });
}
// "插线板"断电
- (void)stopSession {
    dispatch_async(self.videoQueue, ^{
        if (![self.session isRunning]) {
                [self.session stopRunning];
        }
    });
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(cameraController:didDetectFaces:)]) {
        [self.delegate cameraController:self didDetectFaces:metadataObjects];
    }
}

#pragma mark - device switch (摄像头切换)
// 当前激活的摄像头
- (AVCaptureDevice *)activeCamera {
    return self.videoInput.device;
}
// 系统摄像头个数
- (NSUInteger)cameraCount {
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}
// 是否可以切换摄像头
- (BOOL)canSwitchCamera {
    return [self cameraCount] > 1;
}
// 根据位置锁定摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
// 切换目标(即当前未激活的摄像头)
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *activeCamera = [self activeCamera];
    if ([self cameraCount] > 1) {
        if (activeCamera.position == AVCaptureDevicePositionBack) {
            return [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else if (activeCamera.position == AVCaptureDevicePositionFront) {
            return [self cameraWithPosition:AVCaptureDevicePositionBack];
        } else {
            NSLog(@"position unspecified as system hardware is unspecified!!");
            return nil;
        }
    }
    return nil;
}
// 切换摄像头及session相关处理
- (BOOL)switchCamera {
    if (![self canSwitchCamera]) {
        return NO;
    }
    // 1. 获取未激活摄像头,并创建新的输入
    NSError *error;
    AVCaptureDevice *inactiveCamera = [self inactiveCamera];
    AVCaptureDeviceInput *inactiveVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:inactiveCamera error:&error];
    if (inactiveVideoInput) {
        // 2. 开启原始配置, 更新会话的视频输入
        [self.session beginConfiguration];
        [self.session removeInput:self.videoInput];
        if ([self.session canAddInput:inactiveVideoInput]) {
            [self.session addInput:inactiveVideoInput];
            self.videoInput = inactiveVideoInput;
        } else { // 如果新的输入无法添加, 还是重新添加原来的...
            [self.session addInput:self.videoInput];
        }
        [self.session commitConfiguration];
    } else {
        [self handleFailedDeviceConfigurationWithError:error];
        return NO;
    }
    return YES;
}

#pragma mark - high frame rate methods
- (BOOL)cameraSupportsHighFrameRateCapture {
    return [[self activeCamera] supportsHighFrameRateCapture];
}

- (BOOL)enableHighFrameRateCapture {
    NSError *error;
    BOOL enabled = [[self activeCamera] enableHighFrameRateCaptureWithError:&error];
    if (!enabled) {
        [self handleFailedDeviceConfigurationWithError:error];
    }
    return enabled;
}

#pragma mark - zoom methods
- (BOOL)cameraSupportsZoom {
    return [self activeCamera].activeFormat.videoMaxZoomFactor > 1.0f;
}

- (CGFloat)maxZoomFactor {
    return MIN([self activeCamera].activeFormat.videoMaxZoomFactor, 4.0f);
}

// zoom value from slider (连续性控制 属性: videoZoomFactor)
- (void)setZoomValue:(CGFloat)zoomValue {
    if ([self activeCamera].isRampingVideoZoom) return;
    
    NSError *error;
    if ([[self activeCamera] lockForConfiguration:&error]) {
        CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue); // zoomValue : (0, 1) 以幂级数拟线性增长
        [self activeCamera].videoZoomFactor = zoomFactor;
        [[self activeCamera] unlockForConfiguration];
    } else {
        [self handleFailedDeviceConfigurationWithError:error];
    }
}

// 有时间段缩放 (阶段性控制 属性: rampingZoomFactor)
- (void)rampZoomToValue:(CGFloat)zoomValue {
    CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
    NSError *error;
    if ([[self activeCamera] lockForConfiguration:&error]) {
        [[self activeCamera] rampToVideoZoomFactor:zoomFactor withRate:LPZoomRate];
        [[self activeCamera] unlockForConfiguration];
    } else {
        [self handleFailedDeviceConfigurationWithError:error];
    }
}

// 取消缩放
- (void)cancelZoom {
    NSError *error;
    if ([[self activeCamera] lockForConfiguration:&error]) {
        [[self activeCamera] cancelVideoZoomRamp];
        [[self activeCamera] unlockForConfiguration];
    } else {
        [self handleFailedDeviceConfigurationWithError:error];
    }
}

#pragma mark - focus methods
// 设备是否支持对焦
- (BOOL)cameraSupportsFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}
// 自动对焦处理 (在vc中调用, 用以实现preview的相关代理方法(单击屏幕设置焦点))
- (void)focusAtPoint:(CGPoint)point { // point:已转换坐标系的点
    AVCaptureDevice *camera = [self activeCamera];
    if (camera.isFocusPointOfInterestSupported && [camera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) { // 是否支持对焦和自动滚对焦
        NSError *error;
        if ([camera lockForConfiguration:&error]) { // 加锁
            camera.focusPointOfInterest = point; // 设置焦点
            camera.focusMode = AVCaptureFocusModeAutoFocus; // 设置对焦模式(此模式自动设置好一个值后自动锁定(focusMode = AVCaptureFocusModeLocked))
            [camera unlockForConfiguration]; // 解锁
        } else {
            [self handleFailedDeviceConfigurationWithError:error];
        }
    }
}

#pragma mark - expose methods
// 设备是否支持曝光
- (BOOL)cameraSupportsExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}
// KVO context pointer for observing adjustingExposure ivar
static const NSString * LPCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *camera = [self activeCamera];
    if (camera.isExposurePointOfInterestSupported && [camera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) { // 此模式不会锁定
        NSError *error;
        if ([camera lockForConfiguration:&error]) { // 加配置锁
            camera.exposurePointOfInterest = point;
            camera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([camera isExposureModeSupported:AVCaptureExposureModeLocked]) { // 如相机支持曝光锁定模式, 通过KVO监听相机adjustingExposure属性的方式在其mode改变后改为AVCaptureExposureModeLocked锁定模式!
                [camera addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:0
                            context:&LPCameraAdjustingExposureContext];
            }
            [camera unlockForConfiguration]; // 解配置锁
        } else {
            [self handleFailedDeviceConfigurationWithError:error];
        }
    }
}

#pragma mark - KVO notification
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (context == &LPCameraAdjustingExposureContext) {
        AVCaptureDevice *camera = (AVCaptureDevice *)object;
        if (!camera.isAdjustingExposure &&
            [camera isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&LPCameraAdjustingExposureContext];
            dispatch_async(MAIN_QUEUE, ^{
                NSError *error;
                if ([camera lockForConfiguration:&error]) {
                    camera.exposureMode = AVCaptureExposureModeLocked;
                    [camera unlockForConfiguration];
                } else {
                    [self handleFailedDeviceConfigurationWithError:error];
                }
            });
        }
    } else if (context == &LPVideoZoomFactorContext) {
        [self updateZoomDelegate];
    } else if (context == &LPRampingVideoZoomContext) {
        [self updateZoomDelegate];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)updateZoomDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:rampedZoomValue:)]) {
        CGFloat currentZoomFactor = [self activeCamera].videoZoomFactor;
        CGFloat maxZoomFactor = [self maxZoomFactor];
        CGFloat value = log(currentZoomFactor) / log(maxZoomFactor);
        [self.delegate cameraController:self rampedZoomValue:value];
    }
}

#pragma mark - reset focus & expose modes
- (void)resetFocusAndExposeModes {
    AVCaptureDevice *camera = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [camera isFocusPointOfInterestSupported] && [camera isFocusModeSupported:focusMode];
    BOOL canResetExpose = [camera isExposurePointOfInterestSupported] && [camera isExposureModeSupported:exposureMode];
    CGPoint center = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([camera lockForConfiguration:&error]) {
        if (canResetFocus) {
            camera.focusMode = focusMode;
            camera.focusPointOfInterest = center;
        }
        if (canResetExpose) {
            camera.exposureMode = exposureMode;
            camera.exposurePointOfInterest = center;
        }
        [camera unlockForConfiguration];
    } else {
        [self handleFailedDeviceConfigurationWithError:error];
    }
}

#pragma mark - flash & torch modes
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *camera = [self activeCamera];
    if (camera.flashMode != flashMode && [camera isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([camera lockForConfiguration:&error]) {
            camera.flashMode = flashMode;
            [camera unlockForConfiguration];
        } else {
            [self handleFailedDeviceConfigurationWithError:error];
        }
    }
}

- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *camera = [self activeCamera];
    if (camera.torchMode != torchMode && [camera isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([camera lockForConfiguration:&error]) {
            camera.torchMode = torchMode;
            [camera unlockForConfiguration];
        } else {
            [self handleFailedDeviceConfigurationWithError:error];
        }
    }
}

#pragma mark - current orientation (private)
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

#pragma mark - thumbnail note posting
- (void)postThumbnailNotificationWithImage:(UIImage *)image {
    dispatch_async(MAIN_QUEUE, ^{
        [noteCenter postNotificationName:LPThumbnailDidCreateNotification object:image];
    });
}

#pragma mark - image capture
- (void)captureStillImage {
    dispatch_async(self.videoQueue, ^{
        // 1. 从输出中获取连接
        AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // 2. 根据当前设备的方向设置连接的方向
        if (connection.isVideoOrientationSupported) {
            connection.videoOrientation = [self currentVideoOrientation];
        }
        
        // 3. 拍照
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                      completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) { // main thread block
                        if (imageDataSampleBuffer != NULL) {
                        // 1. 从sampleBuffer中将图片数据读出来
                        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        UIImage *image = [UIImage imageWithData:imageData];
                        // 2. 将图像存入相册
                        [self.library writeImage:image
                                        success:^(UIImage *image) {
                                            [self postThumbnailNotificationWithImage:image];
                                        }
                                        failure:^(NSError *error) {
                                            // 写入失败处理
                                            NSLog(@"Writing Failure With ERROR: %@", error.localizedDescription);
                                        }];
                        } else {
                            NSLog(@"NULL sampleBuffer error: %@", [error localizedDescription]);
                        }
        }];
    });
}

#pragma mark - video capture 
- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

- (CMTime)recordDuration {
    return self.movieOutput.recordedDuration;
}

- (void)startRecording {
    dispatch_async(self.videoQueue, ^{
        if (self.isRecording) return;
        // 1. 获取连接并设置方向
        AVCaptureConnection *connection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        // 2. 设置连接
        // 2.1 视频方向
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = [self currentVideoOrientation];
        }
        // 2.2 稳定拍摄
        if ([connection isVideoStabilizationSupported]) {
            if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
                connection.enablesVideoStabilizationWhenAvailable = YES; // 视频稳定可以提升质量
            } else {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        // 3 平滑相机的对焦 (加锁)
        AVCaptureDevice *camera = [self activeCamera];
        if (camera.isSmoothAutoFocusSupported) { // 平滑对焦:当摄像头移动时会自动尝试快速对焦, 应设为平滑对焦降低对焦速率
            NSError *error;
            if ([camera lockForConfiguration:&error]) {
                camera.smoothAutoFocusEnabled = YES;
                [camera unlockForConfiguration];
            } else {
                dispatch_async(MAIN_QUEUE, ^{
                    [self handleFailedDeviceConfigurationWithError:error];
                });
            }
        }
        // 4. 生成唯一输出URL
        self.outputURL = [self uniqueVideoURL];
        // 5. 开始录制
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL
                                      recordingDelegate:self];
    });
}

- (void)stopRecording {
    [self.movieOutput stopRecording];
}

- (NSURL *)uniqueVideoURL {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dirPath = [fileMgr temporaryFileDirectoryWithTemplateString:@"cameraRecording.XXXXXX"];
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"camera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate 
// 获取最终文件, 写入Camera Roll
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections error:(NSError *)error {
    if (!error) {
        // 写入AL
        [self.library writeVideoAtURL:self.outputURL.copy
                              success:^(UIImage *image) {
                                  [self postThumbnailNotificationWithImage:image];
                              }
                              failure:^(NSError *error) {
                                  dispatch_async(MAIN_QUEUE, ^{
                                      [self handleFailedALWritingWithError:error];
                                  });
                              }];
    } else {
        dispatch_async(MAIN_QUEUE, ^{
            [self handleFailedMediaCaptureWithError:error];
        });
    }
    self.outputURL = nil;
}

#pragma mark - call delegate to handle failures
- (void)handleFailedDeviceConfigurationWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:deviceConfigurationFailedWithError:)]) {
        [self.delegate cameraController:self deviceConfigurationFailedWithError:error];
    }
}

- (void)handleFailedMediaCaptureWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:mediaCaptureFailedWithError:)]) {
        [self.delegate cameraController:self mediaCaptureFailedWithError:error];
    }
}

- (void)handleFailedALWritingWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:assetLibraryWriteFailedWithError:)]) {
        [self.delegate cameraController:self assetLibraryWriteFailedWithError:error];
    }
}
@end
