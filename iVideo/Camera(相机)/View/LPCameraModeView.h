//
//  LPCameraModeView.h
//  iVideo
//
//  Created by apple on 16/1/22.
//  Copyright © 2016年 lvpin. All rights reserved.
//  相机拍摄控制子视图

#import <UIKit/UIKit.h>
#import "LPCaptureButton.h"

typedef void (^LPThumbnailClickHandler)();
typedef void (^LPCaptureStartHandler)();

@interface LPCameraModeView : UIControl

@property (nonatomic, assign) LPCameraMode mode;
@property (nonatomic, strong) UIButton *thumbnailBtn;
@property (nonatomic, copy) LPThumbnailClickHandler thumbnailClickHandler;
@property (nonatomic, copy) LPCaptureStartHandler captureStartHandler;

@end
