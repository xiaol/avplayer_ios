//
//  UICollectionView+Additions.h
//  iVideo
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Additions)
// 在不越界的前提下调整offset
- (void)setContentOffsetX:(CGFloat)offsetX animated:(BOOL)animated;
// 检查cell是否出界, 如是调整offset
- (void)adjustOutsideCellFrame:(CGRect)frame animated:(BOOL)animated;

@end
