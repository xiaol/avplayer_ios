//
//  LPRangeSlider.h
//  iVideo
//
//  Created by apple on 16/2/15.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const LPRangeSliderStartTrackingWithTouchNotification;
extern NSString * const LPRangeSliderFinishTrackingWithTouchNotification;
extern NSString * const LPRangeSliderFinishTouchValueKey;

typedef NS_ENUM (NSUInteger, LPRangeSliderHighlightedKnob) {
    LPRangeSliderHighlightedLowerKnob,
    LPRangeSliderHighlightedUpperKnob
};

@interface LPRangeSlider : UIControl

@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float upperValue;
@property (nonatomic, assign) float lowerValue;
@property (nonatomic, assign) float touchValue;

@property (nonatomic, assign) float tolerance;
@property (nonatomic, assign) BOOL beyondTolerance;
@property (nonatomic, assign) BOOL valueChanged;

@property (nonatomic, strong) UIImage *upperKnobImage;
@property (nonatomic, strong) UIImage *lowerKnobImage;

@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *trackHighlightColor;

@property (nonatomic, assign) LPRangeSliderHighlightedKnob highlightedKnob;

- (float)positionForValue:(float)value;
- (float)valueForPosition:(float)position;

@end
