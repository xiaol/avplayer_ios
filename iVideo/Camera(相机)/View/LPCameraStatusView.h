//
//  LPCameraStatusView.h
//  iVideo
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPCaptureButton.h"

typedef void (^LPCameraSwapHandler)();

@interface LPCameraStatusView : UIView
@property (nonatomic, strong) UILabel *elapsedTimeLabel;
@property (nonatomic, strong) UIButton *swapButton;
@property (nonatomic, copy) LPCameraSwapHandler cameraSwapHandler;

- (void)changeWithMode:(LPCameraMode)mode;
@end
