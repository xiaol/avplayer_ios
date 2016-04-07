//
//  UIButton+Additions.h
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionHandler) ();

@interface UIButton (Additions)
// 扩张的边界大小
@property (nonatomic, assign) CGFloat enlargedEdge;
// 设置四个边界扩充的大小
- (void)setEnlargedEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

// 将target-action改造为block
- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionHandler)action;

@end
