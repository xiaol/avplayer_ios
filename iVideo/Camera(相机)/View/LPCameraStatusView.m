//
//  LPCameraStatusView.m
//  iVideo
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCameraStatusView.h"

@implementation LPCameraStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        _elapsedTimeLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _elapsedTimeLabel.textAlignment = NSTextAlignmentCenter;
        _elapsedTimeLabel.textColor = [UIColor whiteColor];
        _elapsedTimeLabel.backgroundColor = [UIColor clearColor];
        _elapsedTimeLabel.font = [UIFont systemFontOfSize:18.0f];
        _elapsedTimeLabel.text = @"00:00:00";
        [self addSubview:_elapsedTimeLabel];
        
        _swapButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 56.0f, 0.0f, 56.0f, self.height)];
        [_swapButton setImage:[UIImage imageNamed:@"CameraFlip"] forState:UIControlStateNormal];
        [_swapButton addTarget:self action:@selector(handleCameraSwap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_swapButton];
    }
    return self;
}

- (void)handleCameraSwap {
    if (self.cameraSwapHandler) {
        self.cameraSwapHandler();
    }
}

- (void)changeWithMode:(LPCameraMode)mode {
    BOOL isPhotoMode = mode == LPCameraModePhoto;
    UIColor *bgColor = isPhotoMode ? [UIColor blackColor] : [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.layer.backgroundColor = bgColor.CGColor;
    self.elapsedTimeLabel.layer.opacity = isPhotoMode ? 0.0f : 1.0f;
}

@end
