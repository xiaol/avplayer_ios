//
//  LPPlayableRangeSlider.m
//  iVideo
//
//  Created by apple on 16/3/17.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPPlayableRangeSlider.h"

@interface LPPlayableRangeSlider ()

@property (nonatomic, strong) CAShapeLayer *whitelineLayer;
@property (nonatomic, assign) float lastTime;

@end

@implementation LPPlayableRangeSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.frame = CGRectMake(0.f, 0.f, 1.f, self.height);
        layer.path = [UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
        [self.layer addSublayer:layer];
        self.whitelineLayer = layer;
    }
    return self;
}

- (void)reset {
    self.playingValue = self.lowerValue;
}

- (void)setPlayingValue:(float)playingValue {
    if (playingValue == _playingValue) return;
    _playingValue = playingValue;
    CGFloat startX = [self positionForValue:playingValue];
    self.whitelineLayer.position = CGPointMake(startX, self.height / 2.f);
}
@end
