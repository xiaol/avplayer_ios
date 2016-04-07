//
//  NSMutableAttributedString+Additions.m
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "NSMutableAttributedString+Additions.h"

@implementation NSMutableAttributedString (Additions)
- (CGFloat)lineHeight {
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
}

- (CGSize)sizeWithConstraintSize:(CGSize)maxSize {
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

- (CGFloat)heightWithConstraintWidth:(CGFloat)width {
    return [self sizeWithConstraintSize:CGSizeMake(width, MAXFLOAT)].height;
}

- (BOOL)isMoreThanOneLineConstraintToWidth:(CGFloat)width {
    return [self sizeWithConstraintSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].width > width ;
}

@end
