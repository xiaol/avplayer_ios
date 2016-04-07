//
//  NSTimer+Additions.m
//  iVideo
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "NSTimer+Additions.h"

@implementation NSTimer (Additions)

+ (void)executeFireHandler:(NSTimer *)timer {
    LPFireHandler handler = [timer userInfo];
    handler();
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)interval firing:(LPFireHandler)handler {
    return [self scheduledTimerWithTimeInterval:interval repeating:NO firing:handler];
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeating:(BOOL)repeating firing:(LPFireHandler)handler {
    id block = [handler copy];
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(executeFireHandler:) userInfo:block repeats:repeating];
}
@end
