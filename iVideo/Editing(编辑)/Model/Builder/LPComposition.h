//
//  LPBaseComposition.h
//  iVideo
//
//  Created by apple on 16/1/29.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPComposition : NSObject

@property (nonatomic, strong, readonly) AVComposition *composition;
@property (nonatomic, strong, readonly) AVVideoComposition *videoComposition;
@property (nonatomic, strong, readonly) AVAudioMix *audioMix;

+ (instancetype)compositionWithComposition:(AVComposition *)composition
                          videoComposition:(AVVideoComposition *)videoComposition
                                  audioMix:(AVAudioMix *)audioMix
                                 timeRange:(CMTimeRange)timeRange
                                      size:(LPMovieSize)size;
- (instancetype)initWithComposition:(AVComposition *)composition
                   videoComposition:(AVVideoComposition *)videoComposition
                           audioMix:(AVAudioMix *)audioMix
                          timeRange:(CMTimeRange)timeRange
                               size:(LPMovieSize)size;

- (AVPlayerItem *)makePlayerItem;
- (AVAssetExportSession *)exportSession;

- (CMTime)duration;

@property (nonatomic, assign, readonly) CMTimeRange timeRange;
@property (nonatomic, assign, readonly) LPMovieSize size;

+ (instancetype)compositionWithComposition:(AVComposition *)composition;

- (instancetype)initWithComposition:(AVComposition *)composition;

@end
