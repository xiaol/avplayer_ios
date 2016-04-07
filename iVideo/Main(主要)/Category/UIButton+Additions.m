//
//  UIButton+Additions.m
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

static char topEdgeKey;
static char leftEdgeKey;
static char bottomEdgeKey;
static char rightEdgeKey;

static char actionKey;

// 合成存取方法
- (void)setEnlargedEdge:(CGFloat)enlargedEdge {
    [self setEnlargedEdgeWithTop:enlargedEdge left:enlargedEdge bottom:enlargedEdge right:enlargedEdge];
}

- (CGFloat)enlargedEdge {
    return [(NSNumber *)objc_getAssociatedObject(self, &topEdgeKey) floatValue];
}

// 设置扩充边界
- (void)setEnlargedEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right {
    objc_setAssociatedObject(self, &topEdgeKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &leftEdgeKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &bottomEdgeKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &rightEdgeKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 获得当前的响应rect
- (CGRect)enlargedRect {
    NSNumber *topEdge = objc_getAssociatedObject(self, &topEdgeKey);
    NSNumber *leftEdge = objc_getAssociatedObject(self, &leftEdgeKey);
    NSNumber *bottomEdge = objc_getAssociatedObject(self, &bottomEdgeKey);
    NSNumber *rightEdge = objc_getAssociatedObject(self, &rightEdgeKey);
    if (topEdge && leftEdge && bottomEdge && rightEdge) {
        CGRect enlargedRect = CGRectMake(self.bounds.origin.x - leftEdge.floatValue, self.bounds.origin.y - topEdge.floatValue, self.width + leftEdge.floatValue + rightEdge.floatValue, self.height + topEdge.floatValue + bottomEdge.floatValue);
        return enlargedRect;
    } else {
        return self.bounds;
    }
}

// 系统方法重载
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.alpha <= 0.01 || !self.userInteractionEnabled || self.hidden) {
        return nil;
    }
    
    CGRect enlargedRect = [self enlargedRect];
    //    if (CGRectEqualToRect(enlargedRect, self.bounds)) {
    //        return [super hitTest:point withEvent:event];
    //    }
    return CGRectContainsPoint(enlargedRect, point) ? self : nil;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    CGRect enlargedRect = [self enlargedRect];
//    if (CGRectEqualToRect(enlargedRect, self.bounds))
//    {
//        return [super pointInside:point withEvent:event];
//    }
//    return CGRectContainsPoint(enlargedRect, point) ? YES : NO;
//}


- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionHandler)action {
    objc_setAssociatedObject(self, &actionKey, action, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callAction) forControlEvents:event];
}

- (void)callAction {
    ActionHandler block = (ActionHandler)objc_getAssociatedObject(self, &actionKey);
    if (block) {
        block();
    }
}
@end
