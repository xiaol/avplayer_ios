//
//  LPCaptureButton.h
//  iVideo
//
//  Created by apple on 16/1/22.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LPCameraMode) {
    LPCameraModeVideo = 0,
    LPCameraModePhoto
};

@interface LPCaptureButton : UIButton

+ (instancetype)captureButtonWithFrame:(CGRect)frame cameraMode:(LPCameraMode)mode;

@property (nonatomic, assign) LPCameraMode mode;

@end
