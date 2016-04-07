//
//  LPLineLayoutAttributes.m
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPLineLayoutAttributes.h"

@implementation LPLineLayoutAttributes
+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath {
    LPLineLayoutAttributes *attributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    return attributes;
}
@end
