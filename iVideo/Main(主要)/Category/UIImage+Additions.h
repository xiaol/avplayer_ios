//
//  UIImage+Additions.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
+ (UIImage *)resizableImage:(NSString *)name;
+ (UIImage *)resizedImageWithName:(NSString *)name top:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
+ (UIImage *)resizedImageWithName:(NSString *)name;
+ (UIImage *)resizableImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top;
+ (instancetype)captureWithView:(UIView *)view;
- (UIColor *)averageColor;
+ (UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
+ (UIImage *)circleImageWithImage:(UIImage *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (instancetype)circleImage;
+ (instancetype)circleImageWithImage:(UIImage *)image;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end
