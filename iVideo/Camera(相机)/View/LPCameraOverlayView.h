//
//  LPCameraOverlayView.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPCameraModeView.h"
#import "LPCameraStatusView.h"

@interface LPCameraOverlayView : UIView

@property (nonatomic, strong) LPCameraModeView *modeView;
@property (nonatomic, strong) LPCameraStatusView *statusView;

+ (instancetype)overlayViewWithFrame:(CGRect)frame
                 captureStartHandler:(LPCaptureStartHandler)captureStartHandler
                   cameraSwapHandler:(LPCameraSwapHandler)cameraSwapHandler
               thumbnailClickHandler:(LPThumbnailClickHandler)thumbnailClickHandler;
- (instancetype)initWithFrame:(CGRect)frame
          captureStartHandler:(LPCaptureStartHandler)captureStartHandler
            cameraSwapHandler:(LPCameraSwapHandler)cameraSwapHandler
        thumbnailClickHandler:(LPThumbnailClickHandler)thumbnailClickHandler;

@end
