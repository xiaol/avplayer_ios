//
//  LPPlayerController.h
//  iVideo
//
//  Created by apple on 16/1/27.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPPlayback.h"

@class LPPlayController;

typedef void(^LPPlayerItemLoadCompletion)(BOOL completed);

@protocol LPPlayControllerDelegate <NSObject>

@optional
// 回调vc (缘起)

- (void)playController:(LPPlayController *)playController
    currentPlayingTime:(NSTimeInterval)currentPlayingTime
              duration:(NSTimeInterval)duration;

//- (void)playController:(LPPlayController *)playController
//    currentClippingTime:(NSTimeInterval)currentClippingTime
//              duration:(NSTimeInterval)duration;

- (void)playControllerDidCompletePlaying:(LPPlayController *)playController;

@end

@interface LPPlayController : NSObject

- (void)loadPlayerItem:(AVPlayerItem *)playerItem completion:(LPPlayerItemLoadCompletion)completionHandler;

- (void)play;
- (void)stop;
- (void)pause;

// transport view (PlayControl)发生变化时的对应动作 (vc指定, 终端)
- (void)jumpedToTime:(NSTimeInterval)time;
- (void)scrubbingDidStart;
- (void)scrubbingDidEnd;
- (void)scrubbedToTime:(NSTimeInterval)time;

- (void)jumpedToCMTime:(CMTime)time;


@property (nonatomic, strong) id<LPPlayback> view;

@property (nonatomic, assign) BOOL appendingItems;
@property (nonatomic, assign) BOOL deleteItem;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) NSTimeInterval observeInterval;

@property (nonatomic, assign) BOOL ignoreTimeObserving;
@property (nonatomic, assign) BOOL ignorePlayback;

@property (nonatomic, weak) id<LPPlayControllerDelegate> delegate;


- (void)invalidate;

@end
