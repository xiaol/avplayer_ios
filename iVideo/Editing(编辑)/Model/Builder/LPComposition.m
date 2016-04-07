//
//  LPBaseComposition.m
//  iVideo
//
//  Created by apple on 16/1/29.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPComposition.h"

@implementation LPComposition

- (instancetype)initWithComposition:(AVComposition *)composition
                   videoComposition:(AVVideoComposition *)videoComposition
                           audioMix:(AVAudioMix *)audioMix
                          timeRange:(CMTimeRange)timeRange
                               size:(LPMovieSize)size {
    if (self = [super init]) {
        _composition = composition;
        _videoComposition = videoComposition;
        _audioMix = audioMix;
        _timeRange = timeRange;
        _size = size;
    }
    return self;
}

+ (instancetype)compositionWithComposition:(AVComposition *)composition
                          videoComposition:(AVVideoComposition *)videoComposition
                                  audioMix:(AVAudioMix *)audioMix
                                 timeRange:(CMTimeRange)timeRange
                                      size:(LPMovieSize)size {
    return [[self alloc] initWithComposition:composition videoComposition:videoComposition audioMix:audioMix timeRange:timeRange size:size];
}

- (AVPlayerItem *)makePlayerItem {
    NSArray *keys = @[
                      @"tracks",
                      @"duration",
                      @"commonMetadata",
                      ];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy] automaticallyLoadedAssetKeys:keys];
    playerItem.audioMix = self.audioMix;
    playerItem.videoComposition = self.videoComposition;
    return playerItem;
}

- (AVAssetExportSession *)exportSession {
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:[self.composition copy]
                                             presetName:AVAssetExportPresetHighestQuality];
    session.audioMix = self.audioMix;
    session.videoComposition = self.videoComposition;
    return session;
    
}

- (CMTime)duration {
    return self.composition.duration;
}

+ (instancetype)compositionWithComposition:(AVComposition *)composition {
    return [[self alloc] initWithComposition:composition];
}

- (instancetype)initWithComposition:(AVComposition *)composition {
    if (self = [super init]) {
        _composition = composition;
    }
    return self;
}

@end
