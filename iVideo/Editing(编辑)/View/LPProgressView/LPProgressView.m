//
//  LPProgressView.m
//  iVideo
//
//  Created by apple on 16/3/30.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPProgressView.h"

@interface LPProgressView ()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *arcLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, assign) CGRect trackRect;

@end

@implementation LPProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 20.f;
        containerView.layer.masksToBounds = YES;
        [self addSubview:containerView];
        self.containerView = containerView;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textColor = [UIColor colorFromHexString:@"b6b6b6"];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"0%";
        [self addSubview:label];
        self.label = label;
        
        _trackWidth = 4.f;
        _trackColor = [UIColor colorFromHexString:@"ebebeb"];
        _trackHighlightedColor = [UIColor colorFromHexString:@"ff187a"];
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:circleLayer];
        self.circleLayer = circleLayer;
   
        CAShapeLayer *arcLayer = [CAShapeLayer layer];
        arcLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:arcLayer];
        self.arcLayer = arcLayer;
        arcLayer.lineCap = kCALineJoinRound;
        arcLayer.strokeEnd = 0;
        

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(id)[UIColor colorFromHexString:@"ff187a"].CGColor,
                                 (id)[UIColor colorFromHexString:@"3e4452"].CGColor];
        [self.layer addSublayer:gradientLayer];
        self.gradientLayer = gradientLayer;
        
        
        [gradientLayer setMask:arcLayer];
    }
    return self;
}

- (void)setPercent:(CGFloat)percent {
    _percent = percent;
    
    self.label.text = [NSString stringWithFormat:@"%.f %@", roundf(percent * 100), @"%"];
    self.arcLayer.strokeEnd = percent;
}

//- (void)setFontSize:(CGFloat)fontSize {
//    _fontSize = fontSize;
//    self.label.font = [UIFont systemFontOfSize:fontSize];
//}
//
//- (void)setTextColor:(UIColor *)textColor {
//    _textColor = textColor;
//    self.label.textColor = textColor;
//}
//
//- (void)setTrackColor:(UIColor *)trackColor {
//    _trackColor = trackColor;
//    self.circleLayer.strokeColor = trackColor.CGColor;
//}
//
//- (void)setTrackHighlightedColor:(UIColor *)trackHighlightedColor {
//    _trackHighlightedColor = trackHighlightedColor;
//    [self.arcLayer setNeedsDisplay];
//}
//
//- (void)setTrackWidth:(CGFloat)trackWidth {
//    _trackWidth = trackWidth;
//    
//    [self setNeedsLayout];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    CGRect rect = CGRectInset(self.bounds, (self.width - self.circleDiameter) / 2.f, (self.height - self.circleDiameter) / 2.f);
    self.trackRect = rect;
    
    self.label.frame = rect;
    
    
    CGFloat radius = rect.size.width / 2.f;
    CGPoint center = CGPointMake(radius, radius);
    
    self.circleLayer.frame = rect;
    self.circleLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:- M_PI_2
                                                         endAngle:M_PI * 2 - M_PI_2
                                                        clockwise:YES].CGPath;
    self.circleLayer.lineWidth = self.trackWidth;
    self.circleLayer.strokeColor = self.trackColor.CGColor;
    
    self.gradientLayer.frame = CGRectInset(rect, - self.trackWidth / 2.f, - self.trackWidth / 2.f);
    
    // mask(arcLayer)以gradientLayer为坐标系
    CGRect arcRect = CGRectInset(self.gradientLayer.bounds, self.trackWidth / 2.f, self.trackWidth / 2.f);
    self.arcLayer.frame = arcRect;
    self.arcLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:- M_PI_2
                                                      endAngle:M_PI * 2 - M_PI_2
                                                     clockwise:YES].CGPath;
    self.arcLayer.lineWidth = self.trackWidth;
    self.arcLayer.strokeColor = [UIColor whiteColor].CGColor;
}

@end
