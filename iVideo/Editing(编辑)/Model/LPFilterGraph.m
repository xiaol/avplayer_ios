//
//  LPFilterGraph.m
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPFilterGraph.h"

@interface LPFilterGraph ()
/**
 *  filter数组
 */
@property (nonatomic, strong) NSArray *filters;
@end

@implementation LPFilterGraph

+ (instancetype)filterGraphWithFilterNames:(NSArray *)filterNames {
    return [self filterGraphWithFilterNames:filterNames
                                 inputImage:nil
                       inputAttributesArray:nil];
}

+ (instancetype)filterGraphWithFilterNames:(NSArray *)filterNames
                                inputImage:(CIImage *)inputImage
                      inputAttributesArray:(NSArray *)inputAttributesArray {
    LPFilterGraph *fg = [[LPFilterGraph alloc] init];
    NSMutableArray *filterArray = [NSMutableArray array];
    
    if (filterNames) {
        for (NSString *name in filterNames) {
            CIFilter *filter = [CIFilter filterWithName:name];
            [filterArray addObject:filter];
        }
    }
    
    fg.inputImage = inputImage;
    if (inputAttributesArray) {
        for (NSInteger i = 0; i < inputAttributesArray.count; i ++) {
            CIFilter *filter = filterArray[i];
            
            NSDictionary *dict = inputAttributesArray[i];
            for (NSString *key in dict) {
                [filter setValue:dict[key] forKey:key];
            }
        }
    }
    fg.filters = filterArray;
    return fg;
}

- (void)setInputAttributesArray:(NSArray *)inputAttributesArray {
    for (NSInteger i = 0; i < inputAttributesArray.count; i ++) {
        CIFilter *filter = self.filters[i];
        
        NSDictionary *dict = inputAttributesArray[i];
        for (NSString *key in dict) {
            [filter setValue:dict[key] forKey:key];
        }
    }
}

- (CGRect)extent {
    return self.inputImage.extent;
}

- (BOOL)nonFilters {
    return self.filters.count;
}

- (CIImage *)outputImage {
    if (self.filters.count == 0) {
        return self.inputImage;
    }
    CIFilter *filter = self.filters[0];
    [filter setValue:self.inputImage forKey:kCIInputImageKey];
    for (NSInteger i = 1; i < self.filters.count; i ++) {
        filter = self.filters[i];
        CIFilter *preFilter = self.filters[i - 1];
        [filter setValue:preFilter.outputImage forKey:kCIInputImageKey];
    }
    return filter.outputImage;
}
@end
