//
//  LPCameraController.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//  捕捉业务控制器

#import <Foundation/Foundation.h>
#import "LPImageTarget.h"

@class LPCameraController;
/**
 *  将配置的错误信息发送给代理
 */
@protocol LPCameraControllerDelegate <NSObject>
@optional
- (void)cameraController:(LPCameraController *)cameraController deviceConfigurationFailedWithError:(NSError *)error;
- (void)cameraController:(LPCameraController *)cameraController mediaCaptureFailedWithError:(NSError *)error;
- (void)cameraController:(LPCameraController *)cameraController assetLibraryWriteFailedWithError:(NSError *)error;

- (void)cameraController:(LPCameraController *)cameraController rampedZoomValue:(CGFloat)value;

- (void)cameraController:(LPCameraController *)cameraController didDetectFaces:(NSArray *)faces;
@end


@interface LPCameraController : NSObject
@property (nonatomic, weak) id<LPCameraControllerDelegate> delegate;
@property (nonatomic, weak) id<LPImageTarget> imageTarget;
@property (nonatomic, strong) AVCaptureSession *session;

// session configuration
- (BOOL)setupSessionWithError:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// device support
- (BOOL)switchCamera;
- (BOOL)canSwitchCamera;

@property (nonatomic, assign, readonly) NSUInteger cameraCount;
@property (nonatomic, assign, readonly) BOOL cameraHasTorch;
@property (nonatomic, assign, readonly) BOOL cameraHasFlash;
@property (nonatomic, assign, readonly) BOOL cameraSupportsFocus;
@property (nonatomic, assign, readonly) BOOL cameraSupportsExpose;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

// tap methods
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
//- (void)resetFocusAndExposeModes;

// media capture methods
- (void)captureStillImage;
- (void)startRecording;
- (void)stopRecording;
- (CMTime)recordDuration;
@property (nonatomic, getter = isRecording) BOOL recording;

// zoom methods
- (BOOL)cameraSupportsZoom;
- (void)setZoomValue:(CGFloat)zoomValue; // 手势放缩
- (void)rampZoomToValue:(CGFloat)zoomValue; // 按钮放缩
- (void)cancelZoom;

// high FPS methods
- (BOOL)cameraSupportsHighFrameRateCapture;
- (BOOL)enableHighFrameRateCapture;
@end
