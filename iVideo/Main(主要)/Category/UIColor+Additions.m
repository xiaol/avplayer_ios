//
//  UIColor+Additions.m
//  iVideo
//
//  Created by apple on 16/1/13.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)
+ (instancetype)colorFromHexString:(NSString *)hexString {
    return [UIColor colorFromHexString:hexString alpha:1.0];
}

+ (instancetype)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    if (!hexString) {
        return [UIColor blackColor];
    }
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

@end
