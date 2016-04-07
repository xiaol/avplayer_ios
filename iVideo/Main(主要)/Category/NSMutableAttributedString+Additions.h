//
//  NSMutableAttributedString+Additions.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (Additions)
- (CGFloat)lineHeight;
- (CGSize)sizeWithConstraintSize:(CGSize)maxSize;
- (CGFloat)heightWithConstraintWidth:(CGFloat)width;
- (BOOL)isMoreThanOneLineConstraintToWidth:(CGFloat)width;

@end
