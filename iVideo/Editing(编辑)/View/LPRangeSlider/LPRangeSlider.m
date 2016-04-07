//
//  LPRangeSlider.m
//  iVideo
//
//  Created by apple on 16/2/15.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPRangeSlider.h"
#import "LPTrackLayer.h"

NSString * const LPRangeSliderStartTrackingWithTouchNotification = @"range.slider.did.start";
NSString * const LPRangeSliderFinishTrackingWithTouchNotification = @"range.slider.did.finish";
NSString * const LPRangeSliderFinishTouchValueKey = @"end.touch.position";

@interface LPRangeSlider ()
@property (nonatomic, strong) UIImageView *upperKnob;
@property (nonatomic, strong) UIImageView *lowerKnob;

@property (nonatomic, strong) LPTrackLayer *trackLayer;
@property (nonatomic, assign) CGPoint touchOrigin;
@property (nonatomic, assign) float trackLength;
@property (nonatomic, assign) float knobWidth;
@property (nonatomic, assign) float originValue;
@end

@implementation LPRangeSlider

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, REDRAW) \
@synthesize PROPERTY = _##PROPERTY; \
- (void)SETTER:(TYPE)PROPERTY { \
    if (_##PROPERTY != PROPERTY) { \
        _##PROPERTY = PROPERTY; \
        [self REDRAW]; \
    } \
}

GENERATE_SETTER(trackHighlightColor, UIColor *, setTrackHighlightColor, redraw);
GENERATE_SETTER(trackColor, UIColor *, setTrackColor, redraw);

GENERATE_SETTER(lowerValue, float, setLowerValue, setSubviewFrames);
GENERATE_SETTER(upperValue, float, setUpperValue, setSubviewFrames);
GENERATE_SETTER(maximumValue, float, setMaximumValue, setSubviewFrames);
GENERATE_SETTER(minimumValue, float, setMinimumValue, setSubviewFrames);

- (void)redraw { // re-draw track layer
    [_trackLayer setNeedsDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // preset properties
        _trackHighlightColor = [UIColor colorFromHexString:@"#8c97ff"];
        _trackColor = [UIColor colorFromHexString:@"dadada"];
        _maximumValue = 1.0;
        _minimumValue = 0.0;
        _tolerance = 0.f;
        _lowerValue = LPDefaultScaleRange.start;
        _upperValue = LPDefaultScaleRange.end;
        // initialize track layer
        _trackLayer = [LPTrackLayer layer];
        _trackLayer.slider = self;
        _trackLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_trackLayer];
        // initialize 2 knobs
        _lowerKnob = [[UIImageView alloc] init];
        _lowerKnob.image = [UIImage imageNamed:@"左拉"];
        [self addSubview:_lowerKnob];
        _upperKnob = [[UIImageView alloc] init];
        _upperKnob.image = [UIImage imageNamed:@"右拉"];
        [self addSubview:_upperKnob];
        _upperKnob.layer.shadowOffset = _lowerKnob.layer.shadowOffset = CGSizeMake(0, 0);
        _upperKnob.layer.shadowRadius = _lowerKnob.layer.shadowRadius = 0.5;
        _upperKnob.layer.shadowOpacity = _lowerKnob.layer.shadowOpacity = 0.2;
        // set frames
        [self setSubviewFrames];
    }
    return self;
}

- (void)setSubviewFrames{
    _trackLayer.frame = self.bounds;
    [_trackLayer setNeedsDisplay];
    
    _knobWidth = self.bounds.size.height / 3.0f;
    _trackLength = self.bounds.size.width - _knobWidth * 2; // 内部总长度

    float lowerKnobMaxX = [self positionForValue:_lowerValue];
    float upperKnobMinX = [self positionForValue:_upperValue];
    _lowerKnob.frame = CGRectMake(lowerKnobMaxX - _knobWidth, 0, _knobWidth, self.bounds.size.height);
    _upperKnob.frame = CGRectMake(upperKnobMinX, 0, _knobWidth, self.bounds.size.height);
}

- (float)positionForValue:(float)value {
    return self.trackLength * (value - self.minimumValue) / (self.maximumValue - self.minimumValue) + self.knobWidth;
}

- (float)valueForPosition:(float)position {
    return (position - self.knobWidth) / self.trackLength * (self.maximumValue - self.minimumValue) + self.minimumValue;
}

#pragma mark - override uicontrol's touch methods
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.touchOrigin = [touch locationInView:self];
    
    float highlightedLength = CGRectGetMinX(self.upperKnob.frame) - CGRectGetMaxX(self.lowerKnob.frame);
    
    CGRect lowerEnlargedRect = self.lowerKnob.frame;
    float originLowerX = lowerEnlargedRect.origin.x;
    lowerEnlargedRect.origin.x -= 30;
    lowerEnlargedRect.origin.x = MAX(lowerEnlargedRect.origin.x, 0);
    lowerEnlargedRect.size.width += originLowerX - lowerEnlargedRect.origin.x;
    lowerEnlargedRect.size.width += highlightedLength * 0.4;
    
    CGRect upperEnlargedRect = self.upperKnob.frame;
    upperEnlargedRect.size.width += 30;
    upperEnlargedRect.size.width = MIN(upperEnlargedRect.size.width, self.bounds.size.width - upperEnlargedRect.origin.x);
    float originUpperX = upperEnlargedRect.origin.x;
    upperEnlargedRect.origin.x -= highlightedLength * 0.4;
    upperEnlargedRect.size.width += originUpperX - upperEnlargedRect.origin.x;
    
    if (CGRectContainsPoint(lowerEnlargedRect, self.touchOrigin)) {
        self.lowerKnob.highlighted = YES;
        self.highlightedKnob = LPRangeSliderHighlightedLowerKnob;
        self.touchValue = self.lowerValue;
        [noteCenter postNotificationName:LPRangeSliderStartTrackingWithTouchNotification object:self];
    }
    if (CGRectContainsPoint(upperEnlargedRect, self.touchOrigin)) {
        self.upperKnob.highlighted = YES;
        self.highlightedKnob = LPRangeSliderHighlightedUpperKnob;
        self.touchValue = self.upperValue;
        [noteCenter postNotificationName:LPRangeSliderStartTrackingWithTouchNotification object:self];
    }
    self.originValue = self.touchValue;
    
    return self.lowerKnob.isHighlighted || self.upperKnob.isHighlighted;
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint currentPoint = [touch locationInView:self];
    float deltaX = currentPoint.x - self.touchOrigin.x;
    float deltaValue = (self.maximumValue - self.minimumValue) * deltaX / self.trackLength;
    self.touchOrigin = currentPoint;
    
    if (self.lowerKnob.isHighlighted) {
        self.lowerValue += deltaValue;
        self.lowerValue = MIN(MAX(self.lowerValue, self.minimumValue), self.upperValue);
        self.beyondTolerance = (self.upperValue - self.lowerValue <= self.tolerance);
        self.lowerValue = MIN(self.lowerValue, self.upperValue - self.tolerance);
        self.touchValue = self.lowerValue;
    }
    
    if (self.upperKnob.isHighlighted) {
        self.upperValue += deltaValue;
        self.upperValue = MIN(MAX(self.upperValue, self.lowerValue), self.maximumValue);
        self.beyondTolerance = (self.upperValue - self.lowerValue <= self.tolerance);
        self.upperValue = MIN(MAX(self.upperValue, self.lowerValue + self.tolerance), self.maximumValue);
        self.touchValue = self.upperValue;
    }
    
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self setSubviewFrames]; // 重新计算knob.frame, 重绘trackLayer
    
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.valueChanged = (self.originValue != self.touchValue);
    
    self.lowerKnob.highlighted = self.upperKnob.highlighted = NO;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    NSDictionary *info = @{LPRangeSliderFinishTouchValueKey : @(self.touchValue)};
    [noteCenter postNotificationName:LPRangeSliderFinishTrackingWithTouchNotification
                              object:self
                            userInfo:info];
}

@end
