//
//  LPBasePlaybackView.m
//  iVideo
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LPPlayback.h"

@interface LPPlaybackView : UIView <LPPlayback>
@property (nonatomic, copy) NSString *text;

- (void)hideTime;

@end
