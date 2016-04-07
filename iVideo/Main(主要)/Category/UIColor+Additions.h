//
//  UIColor+Additions.h
//  iVideo
//
//  Created by apple on 16/1/13.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)
+ (instancetype)colorFromHexString:(NSString *)hexString;
+ (instancetype)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha;
@end
