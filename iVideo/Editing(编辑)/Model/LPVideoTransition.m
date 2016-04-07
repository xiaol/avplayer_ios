//
//  LPVideoTransition.m
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPVideoTransition.h"

static const CMTime LPDefaultTransitionDuration = {1, 1, 1, 0};

@implementation LPVideoTransition

+ (instancetype)videoTransition {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _type = LPVideoTransitionTypeNone;
        _timeRange = kCMTimeRangeInvalid;
    }
    return self;
}

+ (instancetype)videoTransitionWithType:(LPVideoTransitionType)type {
    LPVideoTransition *transition = [[self alloc] init];
    transition.type = type;
    return transition;
}

- (void)setDirection:(LPVideoTransitionPushDirection)direction {
    if (self.type == LPVideoTransitionTypePush) {
        _direction = direction;
    } else {
        _direction = LPVideoTransitionPushDirectionInvalid;
        NSLog(@"video transition type error!");
    }
}

+ (instancetype)dissolveTransition {
    LPVideoTransition *trans = [self videoTransition];
    trans.type = LPVideoTransitionTypeDissolve;
    return trans;
}

+ (instancetype)dissolveTransitionWithDuration:(CMTime)duration {
    LPVideoTransition *trans = [self videoTransition];
    trans.type = LPVideoTransitionTypeDissolve;
    trans.duration = duration;
    return trans;
}

+ (instancetype)pushTransitionWithDuration:(CMTime)duration direction:(LPVideoTransitionPushDirection)direction {
    LPVideoTransition *trans = [self videoTransition];
    trans.type = LPVideoTransitionTypePush;
    trans.direction = direction;
    trans.duration = duration;
    return trans;
}

@end
