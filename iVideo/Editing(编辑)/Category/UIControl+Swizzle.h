//
//  UIControl+Swizzle.h
//  iVideo
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Swizzle)

@property (nonatomic, assign) NSTimeInterval toleranceEventInterval;

@end
