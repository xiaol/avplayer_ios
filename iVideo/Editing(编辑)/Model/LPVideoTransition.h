//
//  LPVideoTransition.h
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LPVideoTransitionType) {
    LPVideoTransitionTypeNone = 0,
    LPVideoTransitionTypeDissolve,
    LPVideoTransitionTypePush,
    LPVideoTransitionTypeWipe
};

typedef NS_ENUM(NSUInteger, LPVideoTransitionPushDirection) {
    LPVideoTransitionPushDirectionLeft,
    LPVideoTransitionPushDirectionRight,
    LPVideoTransitionPushDirectionTop,
    LPVideoTransitionPushDirectionBottom,
    LPVideoTransitionPushDirectionInvalid = INT_MAX
};

@interface LPVideoTransition : NSObject

+ (instancetype)videoTransition;
+ (instancetype)videoTransitionWithType:(LPVideoTransitionType)type;

@property (nonatomic, assign) LPVideoTransitionType type;
@property (nonatomic, assign) LPVideoTransitionPushDirection direction;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) CMTimeRange timeRange;

+ (instancetype)dissolveTransitionWithDuration:(CMTime)duration;
+ (instancetype)pushTransitionWithDuration:(CMTime)duration direction:(LPVideoTransitionPushDirection)direction;

+ (instancetype)dissolveTransition;
@end
