//
//  NSString+Additions.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

- (CGFloat)heightForLineWithFont:(UIFont *)font;

- (NSMutableAttributedString *)attributedString;

- (NSMutableAttributedString *)attributedStringWithFont:(UIFont *)font;

- (NSMutableAttributedString *)attributedStringWithFont:(UIFont *)font color:(UIColor *)color lineSpacing:(CGFloat)lineSpacing;
- (NSMutableAttributedString *)attributedStringWithFont:(UIFont *)font color:(UIColor *)color lineSpacing:(CGFloat)lineSpacing characterSpacing:(CGFloat)spacing firstLineSpacing:(CGFloat)firstSpacing;

- (BOOL)isMoreThanOneLineConstraintToWidth:(CGFloat)width withFont:(UIFont *)font;

// 判断是否为空
- (BOOL)isBlank;

+ (instancetype)stringFromIntValue:(int)intValue;
+ (instancetype)stringFromIntegerValue:(NSInteger)integerValue;
+ (instancetype)stringFromUIntegerValue:(NSUInteger)uIntValue;
+ (instancetype)stringFromBOOLValue:(BOOL)boolValue;
+ (instancetype)stringFromNowDate;
+ (instancetype)absoluteStringFromNowDate;

- (instancetype)stringByTrimmingWhitespaceAndNewline;
- (instancetype)stringByTrimmingNewline;
- (instancetype)stringByTrimmingString:(NSString *)string;
- (instancetype)absoluteDateString;

- (instancetype)stringByBase64Encoding;
- (instancetype)stringByBase64Decoding;

// 获取时间戳
- (double)timestampWithDateFormat:(NSString *)dateFormat;
@end
