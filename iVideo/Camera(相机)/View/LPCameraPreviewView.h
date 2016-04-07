//
//  LPCameraPreviewView.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//  当前拍摄内容的实时预览视图, 建立在AVCaptureVideoPreviewLayer上

#import <UIKit/UIKit.h>

@class LPCameraPreviewView;

@protocol LPCameraPreviewViewDelegate <NSObject>

@optional
- (void)preview:(LPCameraPreviewView *)preview tappedToFocusAtPoint:(CGPoint)focusPoint;
- (void)preview:(LPCameraPreviewView *)preview tappedToExposeAtPoint:(CGPoint)exposePoint;
- (void)previewTappedToResetFocusAndExposure:(LPCameraPreviewView *)preview;
@end

@interface LPCameraPreviewView : UIView
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) id<LPCameraPreviewViewDelegate> delegate;
@property (nonatomic, assign) BOOL tapToFocusEnabled;
@property (nonatomic, assign) BOOL tapToExposeEnabled;

// vc calls it in delegate methods
- (void)showFaces:(NSArray *)faces;
@end
