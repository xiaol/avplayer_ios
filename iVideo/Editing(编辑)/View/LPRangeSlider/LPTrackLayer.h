//
//  LPTrackLayer.h
//  iVideo
//
//  Created by apple on 16/2/15.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LPRangeSlider.h"

@interface LPTrackLayer : CALayer
@property (nonatomic, weak) LPRangeSlider *slider;
@end
