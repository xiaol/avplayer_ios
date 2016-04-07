//
//  LPTimeline.h
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LPTrack) {
    LPVideoTrack = 0,
    LPVoiceTrack,
    LPMusicTrack
};

@interface LPTimeline : NSObject
/**
 *  videoItem array
 */
@property (nonatomic, strong) NSMutableArray *videos;
/**
 *  transition array
 */
@property (nonatomic, strong) NSMutableArray *transitions;
/**
 *  audioItem array
 */
@property (nonatomic, strong) NSMutableArray *voices;
/**
 *  audioItem array
 */
@property (nonatomic, strong) NSMutableArray *musics;


- (void)addVideos:(NSArray *)videos;
- (void)removeVideoAtIndex:(NSInteger)index;
- (void)changeTransitionTypeAtIndex:(NSInteger)index;
- (void)exchangeVideoAtIndex:(NSInteger)idx1 withVideoAtIndex:(NSInteger)idx2;
- (void)moveVideoAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;

@property (nonatomic, strong) NSMutableArray *passThroughRanges;
@property (nonatomic, strong) NSMutableArray *transitionRanges;
- (void)updateRangesWithVideoDuration:(CMTime)duration atIndex:(NSUInteger)index;

- (CMTime)duration;

@end
