//
//  LPPlayControl.h
//  iVideo
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPPlayControl;

@protocol LPPlayControlDelegate <NSObject>

- (void)playControlDidStartScrubbing:(LPPlayControl *)playControl;
- (void)playControlDidEndScrubbing:(LPPlayControl *)playControl;
- (void)playControl:(LPPlayControl *)playControl scrubbedToTime:(NSTimeInterval)time;
- (void)playControl:(LPPlayControl *)playControl jumpedToTime:(NSTimeInterval)time;

- (void)playControlDidBeginPlaying:(LPPlayControl *)playControl;
- (void)playControlDidPausePlaying:(LPPlayControl *)playControl;
- (void)playControlDidStopPlaying:(LPPlayControl *)playControl;
- (void)playControlWillPlayFullScreen:(LPPlayControl *)playControl;

@end

@interface LPPlayControl : UIView

@property (nonatomic, weak) id<LPPlayControlDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval progress;

// vc控制方法
- (void)pause;
- (void)play;
// ...
- (void)complete;
@end
