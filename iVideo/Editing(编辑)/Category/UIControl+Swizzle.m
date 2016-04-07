//
//  UIControl+Swizzle.m
//  iVideo
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "UIControl+Swizzle.h"

static char toleranceEventIntervalKey;
static char lastEventTimeKey;

typedef void (* voidIMP) (id, SEL, SEL, id, UIEvent *);
static voidIMP originalSendActions = NULL;


@implementation UIControl (Swizzle)

static void mySendActions(id self, SEL _cmd, SEL action, id target, UIEvent *event) {
    if ([[NSDate date] timeIntervalSince1970] - [self lastEventTime] < [self toleranceEventInterval])
        return;
    
    [self setLastEventTime:[[NSDate date] timeIntervalSince1970]];
    NSAssert(originalSendActions, @"Original sendAction method not found!");
    originalSendActions(self, _cmd, action, target, event);
}

+ (void)swizzleSendActions {    
    NSAssert(!originalSendActions, @"Only call swizzle once!");
    originalSendActions = (voidIMP)[self swizzleInstanceSelector:@selector(sendAction:to:forEvent:)
                                                        withIMP:(IMP)mySendActions];
}

+ (void)load {
    [self swizzleSendActions];
}

- (void)setLastEventTime:(NSTimeInterval)lastEventTime {
    objc_setAssociatedObject(self, &lastEventTimeKey, @(lastEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)lastEventTime {
    return [objc_getAssociatedObject(self, &lastEventTimeKey) doubleValue];
}

- (void)setToleranceEventInterval:(NSTimeInterval)toleranceEventInterval {
    NSAssert(toleranceEventInterval >= 0.f, @"Tolerance interval must be positive!");
    objc_setAssociatedObject(self, &toleranceEventIntervalKey, @(toleranceEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)toleranceEventInterval {
    return [objc_getAssociatedObject(self, &toleranceEventIntervalKey) doubleValue];
}

@end
