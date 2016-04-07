//
//  LPTrackLayer.m
//  iVideo
//
//  Created by apple on 16/2/15.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPTrackLayer.h"

@implementation LPTrackLayer

- (void)drawInContext:(CGContextRef)ctx {
    // fill (bg) track
    CGContextSetFillColorWithColor(ctx, self.slider.trackColor.CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    // fill highlighted range
    CGContextSetFillColorWithColor(ctx, self.slider.trackHighlightColor.CGColor);
    float start = [self.slider positionForValue:self.slider.lowerValue] - 5;
    float end = [self.slider positionForValue:self.slider.upperValue] + 5;
    CGContextFillRect(ctx, CGRectMake(start, 0, end - start, self.bounds.size.height));
}

@end
