//
//  LPCaptureButton.m
//  iVideo
//
//  Created by apple on 16/1/22.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#define LINE_WIDTH 6.0f

#import "LPCaptureButton.h"

@interface LPCaptureButton ()
@property (nonatomic, strong) CALayer *circleLayer; // 内部圆形
@end

@implementation LPCaptureButton

+ (instancetype)captureButtonWithFrame:(CGRect)frame cameraMode:(LPCameraMode)mode {
    return  [[self alloc] initWithFrame:frame cameraMode:mode];
}

- (instancetype)initWithFrame:(CGRect)frame cameraMode:(LPCameraMode)mode{
    if (self = [super initWithFrame:frame]) {
        _mode = mode;
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor clearColor];
        UIColor *circleColor = (self.mode == LPCameraModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = circleColor.CGColor;
        layer.bounds = CGRectInset(self.bounds, 8.0f, 8.0f);
        layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        layer.cornerRadius = layer.bounds.size.width / 2.0f;
        [self.layer addSublayer:layer];
        self.circleLayer = layer;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = 0.2f;
    if (highlighted) {
        anim.toValue = @0.0f;
    } else {
        anim.toValue = @1.0f;
    }
    self.circleLayer.opacity = [anim.toValue floatValue];
    [self.circleLayer addAnimation:anim forKey:@"fadeAnimation"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if(self.mode == LPCameraModeVideo) {
        [CATransaction disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        if (selected) { // 录制时, 按钮缩小, 边角半径改变
            scaleAnimation.toValue = @0.6f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 4.0f);
        } else {
            scaleAnimation.toValue = @1.0f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 2.0f);
        }
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = @[scaleAnimation, radiusAnimation];
        animGroup.beginTime = CACurrentMediaTime() + 0.2f;
        animGroup.duration = 0.35f;
        animGroup.removedOnCompletion = NO;
        animGroup.fillMode = kCAFillModeForwards;

        [self.circleLayer addAnimation:animGroup forKey:@"scaleAndRadiusAnimation"];
    }
}

- (void)setMode:(LPCameraMode)mode {
    if (_mode != mode) {
        _mode = mode;
        UIColor *color = (mode == LPCameraModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
        self.circleLayer.backgroundColor = color.CGColor;
    }
}

- (void)drawRect:(CGRect)rect { // 外层圆环
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, LINE_WIDTH);
    CGRect insetRect = CGRectInset(rect, LINE_WIDTH / 2.0f, LINE_WIDTH / 2.0f);
    CGContextStrokeEllipseInRect(ctx, insetRect);
}

@end
