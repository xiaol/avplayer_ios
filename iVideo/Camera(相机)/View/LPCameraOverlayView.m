//
//  LPCameraOverlayView.m
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCameraOverlayView.h"

@interface LPCameraOverlayView ()
@end

@implementation LPCameraOverlayView
+ (instancetype)overlayViewWithFrame:(CGRect)frame
                 captureStartHandler:(LPCaptureStartHandler)captureStartHandler
                   cameraSwapHandler:(LPCameraSwapHandler)cameraSwapHandler
               thumbnailClickHandler:(LPThumbnailClickHandler)thumbnailClickHandler {
    return [[self alloc] initWithFrame:frame captureStartHandler:captureStartHandler cameraSwapHandler:cameraSwapHandler thumbnailClickHandler:thumbnailClickHandler];
}

- (instancetype)initWithFrame:(CGRect)frame
          captureStartHandler:(LPCaptureStartHandler)captureStartHandler
            cameraSwapHandler:(LPCameraSwapHandler)cameraSwapHandler
        thumbnailClickHandler:(LPThumbnailClickHandler)thumbnailClickHandler {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.statusView = [[LPCameraStatusView alloc] initWithFrame:CGRectMake(0, 0, self.width, 48.0f)];
        [self addSubview:self.statusView];
        
        self.modeView = [[LPCameraModeView alloc] initWithFrame:CGRectMake(0, self.height - 110.0f, self.width, 110.0f)];
        [self addSubview:self.modeView];
        [self.modeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.statusView.cameraSwapHandler = cameraSwapHandler;
        self.modeView.captureStartHandler = captureStartHandler;
        self.modeView.thumbnailClickHandler = thumbnailClickHandler;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.statusView pointInside:[self convertPoint:point toView:self.statusView] withEvent:event] ||
        [self.modeView pointInside:[self convertPoint:point toView:self.modeView] withEvent:event]) {
        return YES;
    }
    return NO;
}

// 改变模式, statusView做相应变化(modeView的变化已经自封装)
- (void)modeChanged:(LPCameraModeView *)modeView {
    [self.statusView changeWithMode:modeView.mode];
}

@end
