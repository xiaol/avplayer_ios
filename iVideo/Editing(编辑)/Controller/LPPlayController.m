//
//  LPPlayerController.m
//  iVideo
//
//  Created by apple on 16/1/27.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPPlayController.h"

static const NSString *LPPlayerItemStatusContext;

@interface LPPlayController ()
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id<LPPlayback> playbackView;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) float lastRate;

@property (nonatomic, copy) LPPlayerItemLoadCompletion completionHandler;

@property (nonatomic, assign) NSTimeInterval pastTime;

@end

@implementation LPPlayController

- (id<LPPlayback>)view {
    return self.playbackView;
}

- (void)setView:(id<LPPlayback>)view {
    self.playbackView = view;
}

- (instancetype)init {
    if (self = [super init]) {
        _observeInterval = .1f;
    }
    return self;
}

- (void)loadPlayerItem:(AVPlayerItem *)playerItem completion:(LPPlayerItemLoadCompletion)completionHandler {
    self.pastTime = - 1.f;
    if (!playerItem) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        return;
    }
    
    self.playerItem = playerItem;
    
    self.completionHandler = completionHandler;
    
    if (!self.player) { // 初次加载
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        if(self.playbackView) {
            [self.playbackView setPlayer:self.player];
            [self.playbackView prepareForPlaying];
        }
    } else {
        if (self.timeObserver) { // 清空之前的监听器
            [self.player removeTimeObserver:self.timeObserver];
            self.timeObserver = nil;
        }
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:0
                         context:&LPPlayerItemStatusContext];
    
    [noteCenter addObserver:self
                   selector:@selector(playerItemDidReachEnd)
                       name:AVPlayerItemDidPlayToEndTimeNotification
                     object:self.playerItem];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (context == &LPPlayerItemStatusContext) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        dispatch_async(MAIN_QUEUE, ^{
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                // 1. add time observer
                [self addTimeObserver];
                
//                // 2. play
//                if (self.appendingItems) { // 添加视频后
//                    self.deleteItem = NO;
//                    // 跳到之前播放时刻
//                    [self jumpedToTime:self.currentTime];
//                    // 暂停播放
//                    self.player.rate = 0.f;
//                    // 通知代理更新slider
//                    [self.delegate playController:self
//                               currentPlayingTime:self.currentTime
//                                         duration:CMTimeGetSeconds(self.playerItem.duration)];
//                } else if (self.deleteItem) {
//                    self.appendingItems = NO;
//                    // ...
//                } else {
//                    [self stop];
//                }
                
                
                if (self.completionHandler) {
                    self.completionHandler(YES);
                }
                
                if (self.playbackView) {
                    [self.playbackView startPlaying];
                }

            } else {
                
                if (self.completionHandler) {
                    self.completionHandler(NO);
                }
                // alert view (Addition)...
            }
            
        });
        
    }
}

- (void)addTimeObserver {
    if (self.ignoreTimeObserving) return;
    
    CMTime interval = CMTimeMakeWithSeconds(self.observeInterval, NSEC_PER_SEC);
    __weak typeof(self) wself = self;
    self.timeObserver =
    [self.player addPeriodicTimeObserverForInterval:interval
                                              queue:MAIN_QUEUE
                                         usingBlock:^(CMTime time) {
                                             NSTimeInterval currentTime = CMTimeGetSeconds(time);
                                             NSTimeInterval duration = CMTimeGetSeconds(wself.playerItem.duration);
                                             if ([wself.delegate respondsToSelector:@selector(playController:currentPlayingTime:duration:)] &&  currentTime >= self.pastTime) {
                                                    [wself.delegate playController:wself
                                                                currentPlayingTime:currentTime
                                                                        duration:duration];
                                             }
                                         }];
}

- (void)playerItemDidReachEnd {
    self.pastTime = 0.f;
    __weak typeof(self) wself = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if ([wself.delegate respondsToSelector:@selector(playControllerDidCompletePlaying:)]) {
            [wself.delegate playControllerDidCompletePlaying:wself];
        }
    }];
}

- (void)play {
    [self.player play];
}

- (void)stop {
    self.player.rate = 0.f;
    [self playerItemDidReachEnd];
}

- (void)pause {
    [self.player pause];
    self.lastRate = self.player.rate;
}

- (void)jumpedToTime:(NSTimeInterval)time {
    self.pastTime = time;
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)jumpedToCMTime:(CMTime)time {
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)scrubbingDidStart {
    self.lastRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)scrubbedToTime:(NSTimeInterval)time {
    self.pastTime = time;
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
}

- (void)scrubbingDidEnd {
    [self addTimeObserver];
    if (self.lastRate > 0.0f) {
        [self.player play];
    }
}

- (BOOL)playing {
    return self.player.rate > 0.0f;
}

- (void)setIgnorePlayback:(BOOL)ignorePlayback {
    if (ignorePlayback) {
        self.playbackView = nil;
    }
}

- (void)invalidate {
    [self stop];
    if (self.timeObserver) { // 清空之前的监听器
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    self.playerItem = nil;
    [noteCenter removeObserver:self];
    self.player = nil;
}

@end
