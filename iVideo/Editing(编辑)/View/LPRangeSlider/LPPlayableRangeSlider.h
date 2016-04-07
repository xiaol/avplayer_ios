//
//  LPPlayableRangeSlider.h
//  iVideo
//
//  Created by apple on 16/3/17.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPRangeSlider.h"

@interface LPPlayableRangeSlider : LPRangeSlider

- (void)reset;

@property (nonatomic, assign) float playingValue;

@end
