//
//  LPBaseCompositionBuilder.m
//  iVideo
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMediaItem.h"
#import "LPBaseCompositionBuilder.h"

@interface LPBaseCompositionBuilder ()
@property (nonatomic, strong) LPTimeline *timeline;
@property (nonatomic, strong) AVMutableComposition *composition;
@end

@implementation LPBaseCompositionBuilder
+ (LPComposition *)buildCompositionWithTimeline:(LPTimeline *)timeline {
    LPBaseCompositionBuilder *builder = [[self alloc] init];
    return [builder buildCompositionWithTimeline:timeline];
}

- (LPComposition *)buildCompositionWithTimeline:(LPTimeline *)timeline {
    _timeline = timeline;
    
    self.composition = [AVMutableComposition composition];
    [self addCompositionTrackOfType:AVMediaTypeVideo
                     withMediaItems:self.timeline.videos];
    [self addCompositionTrackOfType:AVMediaTypeAudio
                     withMediaItems:self.timeline.videos];
    
    return [LPComposition compositionWithComposition:self.composition];
}

- (void)addCompositionTrackOfType:(NSString *)mediaType
                   withMediaItems:(NSArray *)mediaItems {
    
    if (!LPIsEmpty(mediaItems)) {                                           // 1
        
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        
        AVMutableCompositionTrack *compositionTrack =                       // 2
        [self.composition addMutableTrackWithMediaType:mediaType
                                      preferredTrackID:trackID];
        // Set insert cursor to 0
        CMTime cursorTime = kCMTimeZero;                                    // 3
        
        for (LPMediaItem *item in mediaItems) {
            
            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline,             // 4
                                      !=,
                                      kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }
            
            AVAssetTrack *assetTrack =                                      // 5
            [[item.asset tracksWithMediaType:mediaType] firstObject];
//            NSLog(@"%@ - %ld - %ld", item.asset, [item.asset tracksWithMediaType:mediaType].count, [item.asset tracksWithMediaType:AVMediaTypeAudio].count);
            
            
            [compositionTrack insertTimeRange:item.trimmedTimeRange                // 6
                                      ofTrack:assetTrack
                                       atTime:cursorTime
                                        error:nil];
            
            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.trimmedTimeRange.duration);    // 7
        }
    }
}

@end
