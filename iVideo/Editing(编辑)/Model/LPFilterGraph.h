//
//  LPFilterGraph.h
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPFilterGraph : NSObject

+ (instancetype)filterGraphWithFilterNames:(NSArray *)filterNames;

+ (instancetype)filterGraphWithFilterNames:(NSArray *)filterNames
                                inputImage:(CIImage *)inputImage
                      inputAttributesArray:(NSArray *)inputAttributesArray;
/**
 *  首个输入图像
 */
@property (nonatomic, strong) CIImage *inputImage;
/**
 *  输入参数字典数组 (inputImage除外)
 */
@property (nonatomic, strong) NSArray *inputAttributesArray;

@property (nonatomic, assign, readonly) CGRect extent;

@property (nonatomic, weak, readonly) CIImage *outputImage;

@property (nonatomic, assign, readonly) BOOL nonFilters;

@property (nonatomic, copy) NSString *effectName;

@end
