//
//  LPTimeline.m
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPTimeline.h"
#import "LPVideoTransition.h"
#import "LPEditNotification.h"
#import "LPVideoItem.h"
#import "LPVideoTransition.h"

static const CMTime LPDefaultTransitionDuration = {1, 1, 1, 0};

@implementation LPTimeline

- (NSMutableArray *)videos {
    if (_videos == nil) {
        _videos = [NSMutableArray array];
    }
    return _videos;
}

- (NSMutableArray *)transitions {
    if (_transitions == nil) {
        _transitions = [NSMutableArray array];
    }
    return _transitions;
}

- (NSMutableArray *)voices {
    if (_voices == nil) {
        _voices = [NSMutableArray array];
    }
    return _voices;
}

- (NSMutableArray *)musics {
    if (_musics == nil) {
        _musics = [NSMutableArray array];
    }
    return _musics;
}

- (NSMutableArray *)passThroughRanges {
    if (_passThroughRanges == nil) {
        _passThroughRanges = [NSMutableArray array];
    }
    return _passThroughRanges;
}

- (NSMutableArray *)transitionRanges {
    if (_transitionRanges == nil) {
        _transitionRanges = [NSMutableArray array];
    }
    return _transitionRanges;
}

- (void)addVideos:(NSArray *)videos {
    if (videos.count == 0) return;
    
    [self.videos addObjectsFromArray:videos];
    
    CMTimeRange lastPassRange = [self.passThroughRanges.lastObject CMTimeRangeValue];
    CMTime cursor = kCMTimeZero;
    if (!CMTIMERANGE_IS_INVALID(lastPassRange)) {
        cursor = CMTimeRangeGetEnd(lastPassRange);
    }
    for (NSInteger i = 0; i < videos.count; i++) { // 默认无过渡效果
        LPVideoTransition *transition = [LPVideoTransition videoTransition];
        [self.transitions addObject:transition];
        LPVideoItem *video = videos[i];
        video.startTransition = transition;
        video.endTransition = transition;
        
        // 计算ranges
        CMTime duration = video.trimmedTimeRange.duration;
        CMTimeRange passRange = CMTimeRangeMake(cursor, duration);
        cursor = CMTimeAdd(cursor, duration);
        [self.passThroughRanges addObject:[NSValue valueWithCMTimeRange:passRange]];
        [self.transitionRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(cursor, kCMTimeZero)]];
    }
}

- (void)removeVideoAtIndex:(NSInteger)index {
    if (index == self.videos.count - 1) {
        [self.transitionRanges removeObjectAtIndex:index];
        [self.passThroughRanges removeObjectAtIndex:index];
        if (index > 0) {
            LPVideoTransition *lastTran = self.transitions[index - 1];
            lastTran.type = LPVideoTransitionTypeNone;
            LPVideoItem *video = self.videos[index - 1];
            video.endTransition = lastTran;
        }
    } else {
        CMTime cursor = kCMTimeZero;
        if (index > 0) {
            cursor = CMTimeRangeGetEnd([self.transitionRanges[index - 1] CMTimeRangeValue]);
        }
        [self.passThroughRanges removeObjectAtIndex:index];
        [self.transitionRanges removeObjectAtIndex:index];
        for (NSUInteger i = index; i < self.videos.count - 1; i++) {
            CMTimeRange passRange = [self.passThroughRanges[i] CMTimeRangeValue];
            passRange.start = cursor;
            self.passThroughRanges[i] = [NSValue valueWithCMTimeRange:passRange];
            
            cursor = CMTimeRangeGetEnd(passRange);
            
            CMTimeRange transitionRange = [self.transitionRanges[i] CMTimeRangeValue];
            transitionRange.start = cursor;
            self.transitionRanges[i] = [NSValue valueWithCMTimeRange:transitionRange];
            
            cursor = CMTimeRangeGetEnd(transitionRange);
        }
    }
    [self.transitions removeObjectAtIndex:index];
    [self.videos removeObjectAtIndex:index];
    
    if (self.videos.count == 0) {
        return;
    };
    if (self.videos.count == index) {
        return;
    }
    LPVideoItem *video = self.videos[index];
    if (index == 0) {
        video.startTransition = [LPVideoTransition videoTransition];
    } else {
        video.startTransition = self.transitions[index - 1];
    }
}

- (void)exchangeVideoAtIndex:(NSInteger)idx1 withVideoAtIndex:(NSInteger)idx2 { // 只影响两者之间的数组
    if (idx1 == idx2) return;
    
    LPVideoItem *video1 = self.videos[idx1];
    LPVideoItem *video2 = self.videos[idx2];
    video1.startTransition = [LPVideoTransition videoTransitionWithType:video2.startTransition.type];
    video1.endTransition = [LPVideoTransition videoTransitionWithType:video2.endTransition.type];
    video2.startTransition = [LPVideoTransition videoTransitionWithType:video1.startTransition.type];
    video2.endTransition = [LPVideoTransition videoTransitionWithType:video1.endTransition.type];
    
    NSInteger fromIndex = MIN(idx1, idx2);
    NSInteger toIndex = MAX(idx1, idx2);
    
    CMTimeRange fromPassRange = [self.passThroughRanges[fromIndex] CMTimeRangeValue];
    CMTimeRange toPassRange = [self.passThroughRanges[toIndex] CMTimeRangeValue];
    CMTime fromDuration = toPassRange.duration;
    CMTime toDuration = fromPassRange.duration;
    CMTime cursor = fromPassRange.start;
    
    for (NSInteger i = fromIndex; i <= toIndex; i ++) {
        CMTimeRange pr = [self.passThroughRanges[i] CMTimeRangeValue];
        pr.start = cursor;
        if (i == fromIndex) {
            pr.duration = fromDuration;
        } else if (i == toIndex) {
            pr.duration = toDuration;
        }
        self.passThroughRanges[i] = [NSValue valueWithCMTimeRange:pr];
        cursor = CMTimeRangeGetEnd(pr);
        
        CMTimeRange tr = [self.transitionRanges[i] CMTimeRangeValue];
        tr.start = cursor;
        self.transitionRanges[i] = [NSValue valueWithCMTimeRange:tr];
        cursor = CMTimeRangeGetEnd(tr);
    }

    [self.videos exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)moveVideoAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx {
    if (fromIdx == toIdx) return;
    
    if (fromIdx < toIdx) {
        for (NSInteger i = fromIdx; i < toIdx; i ++) {
            [self exchangeVideoAtIndex:i withVideoAtIndex:i + 1];
        }
    } else {
        for (NSInteger i = fromIdx; i > toIdx; i --) {
            [self exchangeVideoAtIndex:i withVideoAtIndex:i - 1];
        }
    }
}

- (void)changeTransitionTypeAtIndex:(NSInteger)index {
    LPVideoTransition *transition = self.transitions[index];
    transition.type = 1 - transition.type;
    self.transitions[index] = transition;
    
    LPVideoItem *video = self.videos[index];
    video.endTransition = transition;
    if (index < self.videos.count - 1) {
        LPVideoItem *nextVideo = self.videos[index + 1];
        nextVideo.startTransition = transition;
    }
    
    if (transition.type == LPVideoTransitionTypeDissolve) {
        CMTimeRange currentPassThrounghRange = [self.passThroughRanges[index] CMTimeRangeValue];
        currentPassThrounghRange.duration = CMTimeSubtract(currentPassThrounghRange.duration, LPDefaultTransitionDuration);
        self.passThroughRanges[index] = [NSValue valueWithCMTimeRange:currentPassThrounghRange];
        CMTime cusor = CMTimeRangeGetEnd(currentPassThrounghRange);
        
        CMTimeRange transitionRange = [self.transitionRanges[index] CMTimeRangeValue];
        transitionRange.start = cusor;
        transitionRange.duration = LPDefaultTransitionDuration;
        self.transitionRanges[index] = [NSValue valueWithCMTimeRange:transitionRange];
        cusor = CMTimeRangeGetEnd(transitionRange);
        
        for (NSInteger i = index + 1; i < self.videos.count; i ++) {
            CMTimeRange passRange =[self.passThroughRanges[i] CMTimeRangeValue];
            passRange.start = cusor;
            if (i == index + 1) {
                passRange.duration = CMTimeSubtract(passRange.duration, LPDefaultTransitionDuration);
            }
            self.passThroughRanges[i] = [NSValue valueWithCMTimeRange:passRange];
            cusor = CMTimeRangeGetEnd(passRange);
            
            CMTimeRange transitionRange =[self.transitionRanges[i] CMTimeRangeValue];
            transitionRange.start = cusor;
            self.transitionRanges[i] = [NSValue valueWithCMTimeRange:transitionRange];
            cusor = CMTimeRangeGetEnd(transitionRange);
        }
        
        cusor = kCMTimeZero;
        
    } else if (transition.type == LPVideoTransitionTypeNone) {
        CMTimeRange currentPassThrounghRange = [self.passThroughRanges[index] CMTimeRangeValue];
        currentPassThrounghRange.duration = CMTimeAdd(currentPassThrounghRange.duration, LPDefaultTransitionDuration);
        self.passThroughRanges[index] = [NSValue valueWithCMTimeRange:currentPassThrounghRange];
        CMTime cusor = CMTimeRangeGetEnd(currentPassThrounghRange);
        
        CMTimeRange transitionRange = [self.transitionRanges[index] CMTimeRangeValue];
        transitionRange.start = cusor;
        transitionRange.duration = kCMTimeZero;
        self.transitionRanges[index] = [NSValue valueWithCMTimeRange:transitionRange];
        cusor = CMTimeRangeGetEnd(transitionRange);
        
        for (NSInteger i = index + 1; i < self.videos.count; i ++) {
            CMTimeRange passRange = [self.passThroughRanges[i] CMTimeRangeValue];
            passRange.start = cusor;
            if (i == index + 1) {
                passRange.duration = CMTimeAdd(passRange.duration, LPDefaultTransitionDuration);
            }
            self.passThroughRanges[i] = [NSValue valueWithCMTimeRange:passRange];
            cusor = CMTimeRangeGetEnd(passRange);
            
            CMTimeRange transitionRange = [self.transitionRanges[i] CMTimeRangeValue];
            transitionRange.start = cusor;
            self.transitionRanges[i] = [NSValue valueWithCMTimeRange:transitionRange];
            cusor = CMTimeRangeGetEnd(transitionRange);
        }
        
        cusor = kCMTimeZero;
    }
}

- (void)updateRangesWithVideoDuration:(CMTime)duration atIndex:(NSUInteger)index {
    // 只需计算出新的passRange, 然后更新其后所有range的start
    
    // 1. 计算新的直通区域和过渡区域的range
    CMTime transitionDuration = [self.transitionRanges[index] CMTimeRangeValue].duration;
    CMTime passDuration = CMTimeSubtract(duration, transitionDuration);
    if (index > 0) {
        CMTime previousTransitionDuration = [self.transitionRanges[index - 1] CMTimeRangeValue].duration;
        passDuration = CMTimeSubtract(passDuration, previousTransitionDuration);
    }
    CMTimeRange passRange = [self.passThroughRanges[index] CMTimeRangeValue];
//    CMTime increment = CMTimeSubtract(passDuration, passRange.duration); // 直通区域增量
    passRange.duration = passDuration;
    self.passThroughRanges[index] = [NSValue valueWithCMTimeRange:passRange];
    
    CMTimeRange transitionRange = [self.transitionRanges[index] CMTimeRangeValue];
    transitionRange.start = CMTimeRangeGetEnd(passRange);
    self.transitionRanges[index] = [NSValue valueWithCMTimeRange:transitionRange];
    
    CMTime cursor = CMTimeRangeGetEnd(transitionRange);
    
    // 2. 更新后面所有range
    for (NSUInteger i = index + 1; i < self.videos.count; i ++) {
        CMTimeRange nextPassRange = [self.passThroughRanges[i] CMTimeRangeValue];
        nextPassRange.start = cursor;
        self.passThroughRanges[i] = [NSValue valueWithCMTimeRange:nextPassRange];
        cursor = CMTimeRangeGetEnd(nextPassRange);
        
        CMTimeRange nextTransitionRange = [self.transitionRanges[i] CMTimeRangeValue];
        nextTransitionRange.start = cursor;
        self.transitionRanges[i] = [NSValue valueWithCMTimeRange:nextTransitionRange];
        cursor = CMTimeRangeGetEnd(nextTransitionRange);
    }
}

- (CMTime)duration {
    CMTime duration = kCMTimeZero;
    for (NSUInteger i = 0; i < self.videos.count; i ++) {
        CMTimeRange passRange = [self.passThroughRanges[i] CMTimeRangeValue];
        CMTimeRange transitionRange = [self.transitionRanges[i] CMTimeRangeValue];
        duration = CMTimeAdd(duration, passRange.duration);
        if(i == self.videos.count - 1) break;
        duration = CMTimeAdd(duration, transitionRange.duration);
    }
    return duration;
}

@end
