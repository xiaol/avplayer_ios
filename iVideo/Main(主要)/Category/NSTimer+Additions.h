//
//  NSTimer+Additions.h
//  iVideo
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LPFireHandler)();

@interface NSTimer (Additions)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)interval firing:(LPFireHandler)handler;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeating:(BOOL)repeating firing:(LPFireHandler)handler;

@end
