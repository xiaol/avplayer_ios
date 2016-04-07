//
//  LPArcLayer.m
//  iVideo
//
//  Created by apple on 16/3/30.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPArcLayer.h"

@implementation LPArcLayer
- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetStrokeColorWithColor(ctx, self.progressView.trackHighlightedColor.CGColor);
    CGContextSetLineWidth(ctx, self.progressView.trackWidth);
    CGContextAddArc(ctx, self.position.x, self.position.y, self.bounds.size.width / 2.f, 0.f, M_PI * 2 * self.progressView.percent, 1);
    CGContextStrokePath(ctx);
}
@end
