//
//  UICollectionView+Additions.m
//  iVideo
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "UICollectionView+Additions.h"

@implementation UICollectionView (Additions)

- (void)setContentOffsetX:(CGFloat)offsetX animated:(BOOL)animated {
    if (self.contentSize.width <= self.bounds.size.width) {
        return;
    }
    if (CGRectGetWidth(self.bounds) + offsetX < self.contentSize.width) {
        [self setContentOffset:CGPointMake(offsetX, 0.f) animated:animated];
    } else {
        [self setContentOffset:CGPointMake(self.contentSize.width - self.bounds.size.width, 0.f) animated:animated];
    }
}

- (void)adjustOutsideCellFrame:(CGRect)frame animated:(BOOL)animated {
    CGFloat minBoundsX = CGRectGetMinX(self.bounds);
    CGFloat maxBoundsX = CGRectGetMaxX(self.bounds);
    CGFloat minFrameX = CGRectGetMinX(frame);
    CGFloat maxFrameX = CGRectGetMaxX(frame);
    if (minBoundsX > minFrameX) {
        CGFloat offsetX = self.contentOffset.x + minFrameX - minBoundsX;
        [self setContentOffset:CGPointMake(offsetX, 0.f) animated:animated];
    } else if (maxBoundsX < maxFrameX) {
        CGFloat offsetX = self.contentOffset.x + maxFrameX - maxBoundsX;
        [self setContentOffset:CGPointMake(offsetX, 0.f) animated:animated];
    }
}

@end
