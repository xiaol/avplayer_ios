//
//  LPCompositionBuilder.m
//  iVideo
//
//  Created by apple on 16/2/21.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCompositionBuilder.h"
#import "LPComposition.h"
#import "LPVideoItem.h"
#import "LPTransitionInstructionHelper.h"
#import "LPAudioItem.h"
#import "LPVideoInstructionHelper.h"

static const CMTime LPDefaultTransitionDuration = {1, 1, 1, 0};

@interface LPCompositionBuilder ()
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, weak) AVMutableCompositionTrack *musicTrack;
@property (nonatomic, weak) AVMutableCompositionTrack *audioTrack;
@property (nonatomic, strong) LPTimeline *timeline;

@property (nonatomic, strong) NSMutableArray *transforms;
@property (nonatomic, strong) NSMutableArray *sizes;

@property (nonatomic, assign) CMTimeRange compositionRange;
@end

@implementation LPCompositionBuilder

+ (LPComposition *)buildCompositionWithTimeline:(LPTimeline *)timeline {
    LPCompositionBuilder *builder = [[self alloc] init];
    return [builder buildCompositionWithTimeline:timeline];
}

- (LPComposition *)buildCompositionWithTimeline:(LPTimeline *)timeline {
    _timeline = timeline;
    
    self.transforms = [NSMutableArray array];
    self.sizes = [NSMutableArray array];
    
    self.composition = [AVMutableComposition composition];
    
    // 1. 创建轨道及其内容
    [self createCompositionTracks];
    
    // 2. 创建视频组合说明
    AVVideoComposition *videoCompositon = [self createVideoComposition];
    // 3. 创建混音
//    AVAudioMix *audioMix = [self createAudioMix];
    AVAudioMix *audioMix = [self createAudioMix];
        
    return [LPComposition compositionWithComposition:self.composition
                                    videoComposition:videoCompositon
                                            audioMix:audioMix
                                           timeRange:self.compositionRange
                                                size:[self normalizedMovieSize]];
}

// 创建各个轨道及其内容
- (void)createCompositionTracks {
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
    // 1. A-B模式视频轨道 与 附带音频轨道
    AVMutableCompositionTrack *trackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                      preferredTrackID:trackID];
    NSMutableArray *videoTracks = [NSMutableArray arrayWithObject:trackA];
    if (self.timeline.videos.count > 1) {
        AVMutableCompositionTrack *trackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                          preferredTrackID:trackID];
        [videoTracks addObject:trackB];
    }
    
    CMTime cursor = kCMTimeZero;
    CMTime transitionDuration = kCMTimeZero;
    
    NSArray *videos = self.timeline.videos;
    
    for (NSUInteger i = 0; i < videos.count; i++) {
        // insert video item into current track
        NSUInteger trackIndex = i % 2;
        LPVideoItem *item = videos[i];
        AVMutableCompositionTrack *videoTrack = videoTracks[trackIndex];
        AVAssetTrack *assetVideoTrack = [item.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        [videoTrack insertTimeRange:item.trimmedTimeRange
                       ofTrack:assetVideoTrack
                        atTime:cursor error:nil];
        
        [self.transforms addObject:[NSValue valueWithCGAffineTransform:assetVideoTrack.preferredTransform]];
        [self.sizes addObject:[NSValue valueWithCGSize:assetVideoTrack.naturalSize]];
        
        // 依据是否有过渡更新cursor
        LPVideoTransition *transition = self.timeline.transitions[i];
        if (transition.type != LPVideoTransitionTypeNone) {
            transitionDuration = LPDefaultTransitionDuration;
        } else {
            transitionDuration = kCMTimeZero;
        }
        
        cursor = CMTimeAdd(cursor, item.trimmedTimeRange.duration);
        if (i == videos.count - 1) {
            self.compositionRange = CMTimeRangeMake(kCMTimeZero, cursor);
        }
        cursor = CMTimeSubtract(cursor, transitionDuration);
    }
    
    // 2. 添加视频原声轨道
    self.audioTrack = [self addAudioTrackWithVideos:videos];
    
    // 3. 添加录音和音乐轨道
    [self addCompositionTrackOfMediaType:AVMediaTypeAudio
                          withMediaItems:self.timeline.voices];
    self.musicTrack = [self addCompositionTrackOfMediaType:AVMediaTypeAudio
                                            withMediaItems:self.timeline.musics];
}

- (AVMutableCompositionTrack *)addAudioTrackWithVideos:(NSArray *)videos {
    AVMutableCompositionTrack *audioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                          preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime cursor = kCMTimeZero;
    CMTime start = kCMTimeZero;
    CMTime duration = kCMTimeZero;
    for (NSInteger i = 0; i < videos.count; i++) {
        LPVideoItem *video = videos[i];
        AVAssetTrack *assetAudioTrack = [video.asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        start = video.trimmedTimeRange.start;
        duration = video.trimmedTimeRange.duration;
        if (video.startTransition.type != LPVideoTransitionTypeNone) {
            cursor = CMTimeAdd(cursor, LPDefaultTransitionDuration);
            start = CMTimeAdd(start, LPDefaultTransitionDuration);
            duration = CMTimeSubtract(duration, LPDefaultTransitionDuration);
        }
        if (video.endTransition.type != LPVideoTransitionTypeNone) {
            duration = CMTimeSubtract(duration, LPDefaultTransitionDuration);
        }
        [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                            ofTrack:assetAudioTrack
                             atTime:cursor error:nil];
        cursor = CMTimeAdd(cursor, duration);
    }
    return audioTrack;
}

// 创建视频组合说明
- (AVVideoComposition *)createVideoComposition {
    // 1. 根据先前创建的composition自动生成其videoComposition
    AVVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    // 2. 根据videoComposition生成helper数组
    NSArray *helpers = [self instructionHelpersInVideoComposition:videoComposition];
//    NSArray *helpers = [self transitionInstructionHelpersInVideoComposition:videoComposition];
    // 3. 设置过渡
    for (LPVideoInstructionHelper *helper in helpers) {
        CMTimeRange timeRange = helper.compostionInstruction.timeRange;
        AVMutableVideoCompositionLayerInstruction *fromLayerInstruction = helper.fromLayerInstruction;
        [fromLayerInstruction setTransform:helper.fromLayerTransform atTime:timeRange.start];
        if (helper.singleLayer) {
            helper.compostionInstruction.layerInstructions = @[fromLayerInstruction];
            continue;
        }

        AVMutableVideoCompositionLayerInstruction *toLayerInstruction = helper.toLayerInstruction;
        LPVideoTransitionType transitionType = helper.transition.type;
        [toLayerInstruction setTransform:helper.toLayerTransform atTime:timeRange.start];

        if (transitionType == LPVideoTransitionTypeDissolve) {
            [fromLayerInstruction setOpacityRampFromStartOpacity:1.0f toEndOpacity:0.0f timeRange:timeRange];
        }
        if (transitionType == LPVideoTransitionTypePush) {
            CGFloat videoWitdh = videoComposition.renderSize.width;
            CGAffineTransform fromLayerDestTransform = CGAffineTransformMakeTranslation(- videoWitdh, 0.0f);
            CGAffineTransform toLayerStartTransform = CGAffineTransformMakeTranslation(videoWitdh, 0.0f);
            [fromLayerInstruction setTransformRampFromStartTransform:CGAffineTransformIdentity
                                                      toEndTransform:fromLayerDestTransform
                                                           timeRange:timeRange];
            [toLayerInstruction setTransformRampFromStartTransform:toLayerStartTransform
                                                    toEndTransform:CGAffineTransformIdentity
                                                         timeRange:timeRange];
        }
        if (transitionType == LPVideoTransitionTypeWipe) {
            CGFloat videoWidth = videoComposition.renderSize.width;
            CGFloat videoHeight = videoComposition.renderSize.height;
            
            CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
            CGRect endRect = CGRectMake(0.0f, videoHeight, videoWidth, 0.0f);
            
            [fromLayerInstruction setCropRectangleRampFromStartCropRectangle:startRect
                                                          toEndCropRectangle:endRect
                                                                   timeRange:timeRange];
        }
        helper.compostionInstruction.layerInstructions = @[fromLayerInstruction, toLayerInstruction];
    }
    return videoComposition;
}

// 创建混音
- (AVAudioMix *)createAudioMix {
    NSArray *items = self.timeline.musics;
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioParam = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.audioTrack];
    [audioParam setVolume:1.0 atTime:self.compositionRange.start];
    if (items.count == 0 || CMTimeGetSeconds(self.compositionRange.duration) <= 7.f) {
        audioMix.inputParameters = @[audioParam];
    } else {
        AVMutableAudioMixInputParameters *musicParam = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.musicTrack];
        float lowVolume = 0.f;
        float normalVolume = 1.f;
        CMTime rampDuration = CMTimeMakeWithSeconds(3.f, NSEC_PER_SEC);
        CMTimeRange startRange = CMTimeRangeMake(self.compositionRange.start, rampDuration);
        CMTimeRange endRange = CMTimeRangeMake(CMTimeSubtract(CMTimeRangeGetEnd(self.compositionRange), rampDuration), rampDuration);
        [musicParam setVolumeRampFromStartVolume:lowVolume toEndVolume:normalVolume timeRange:startRange];
        [musicParam setVolumeRampFromStartVolume:normalVolume toEndVolume:lowVolume timeRange:endRange];
        audioMix.inputParameters = @[audioParam, musicParam];
    }
    return audioMix;
}

#pragma mark - private methods
// 将type类型的mediaItems加入新轨道
- (AVMutableCompositionTrack *)addCompositionTrackOfMediaType:(NSString *)mediaType withMediaItems:(NSArray *)mediaItems {
    if (LPIsEmpty(mediaItems)) return nil;
    
    AVMutableCompositionTrack *track = [self.composition addMutableTrackWithMediaType:mediaType
                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime cursor = kCMTimeZero;
    CMTime compositionEnd = CMTimeRangeGetEnd(self.compositionRange);
    
    NSMutableArray *medias = [NSMutableArray arrayWithArray:mediaItems];
    LPMediaItem *media = medias[0];
    CMTime durationSum = kCMTimeZero;
    for (LPMediaItem *item in mediaItems) {
        durationSum = CMTimeAdd(durationSum, item.trimmedTimeRange.duration);
    }
    
    if (CMTIME_COMPARE_INLINE(durationSum, <, self.compositionRange.duration)) {
        for (NSInteger k = 0; ; k++) {
            durationSum = CMTimeAdd(durationSum, media.trimmedTimeRange.duration);
            [medias addObject:media];
            if (CMTIME_COMPARE_INLINE(durationSum, >=, self.compositionRange.duration)) {
                break;
            }
        }
    }
    
    for (NSInteger i = 0; i < medias.count; i ++) {
        LPMediaItem *item = medias[i];
        AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType].firstObject;
        if (i == 0 && CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
            cursor = item.startTimeInTimeline;
        }
        CMTime itemEnd = CMTimeAdd(cursor, item.trimmedTimeRange.duration);
        CMTime itemDuration = item.trimmedTimeRange.duration;
        if (CMTIME_COMPARE_INLINE(itemEnd, >=, compositionEnd)) {
            itemDuration = CMTimeSubtract(compositionEnd, cursor);
            [track insertTimeRange:CMTimeRangeMake(item.trimmedTimeRange.start, itemDuration)
                           ofTrack:assetTrack
                            atTime:cursor error:nil];
            break;
        }
        [track insertTimeRange:item.trimmedTimeRange
                       ofTrack:assetTrack
                        atTime:cursor error:nil];
        cursor = CMTimeAdd(cursor, item.trimmedTimeRange.duration);
    }
    return track;
}

- (NSArray *)instructionHelpersInVideoComposition:(AVVideoComposition *)videoComposition {
    NSMutableArray *helpers = [NSMutableArray array];
    NSUInteger layerIndex = 0;
    NSArray *instructions = videoComposition.instructions;
    
    NSInteger k = 0;
    for (NSInteger i = 0; i < instructions.count; i ++) {
        AVMutableVideoCompositionInstruction *instruction = instructions[i];
        if (instruction.layerInstructions.count == 1) {
            LPVideoInstructionHelper *helper = [LPVideoInstructionHelper new];
            helper.transition = nil;
            helper.compostionInstruction = instruction;
            helper.singleLayer = YES;
            helper.fromLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions.firstObject;
            helper.fromVideoIndex = k;
            helper.fromLayerTransform = [self
                                         normalizedTransformFromPreferredTransform:[self.transforms[k] CGAffineTransformValue]
                                         naturalSize:[self.sizes[k] CGSizeValue]];
            [helpers addObject:helper];
            
            k ++;
        } else if (instruction.layerInstructions.count == 2) {
            layerIndex = (k - 1) % 2;
            LPVideoInstructionHelper *helper = [LPVideoInstructionHelper new];
            helper.transition = self.timeline.transitions[k - 1];
            helper.compostionInstruction = instruction;
            helper.singleLayer = NO;
            helper.fromVideoIndex = k - 1;
            helper.fromLayerTransform = [self
                                         normalizedTransformFromPreferredTransform:[self.transforms[k - 1] CGAffineTransformValue]
                                         naturalSize:[self.sizes[k - 1] CGSizeValue]];
            helper.toLayerTransform = [self
                                       normalizedTransformFromPreferredTransform:[self.transforms[k] CGAffineTransformValue]
                                       naturalSize:[self.sizes[k] CGSizeValue]];
            helper.fromLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions[layerIndex];
            helper.toLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions[1 - layerIndex];
            [helpers addObject:helper];
        }
    }
    return helpers;
}

- (CGAffineTransform)normalizedTransformFromPreferredTransform:(CGAffineTransform)preferredTransform
                                                   naturalSize:(CGSize)naturalSize {
    if (preferredTransform.a == 0 && preferredTransform.d == 0) { // 竖拍
//        CGFloat ratio = PlaybackViewHeight / ScreenWidth;
//        CGAffineTransform scaleFactor = CGAffineTransformMakeScale(ratio, ratio);
        CGFloat translation = (naturalSize.width - naturalSize.height) / 2;
        CGAffineTransform translationFactor = CGAffineTransformMakeTranslation(translation, 0.f);
        return CGAffineTransformConcat(preferredTransform, translationFactor);
    } else {                                                      // 横拍
        return preferredTransform;
    }
}

// 创建helper数组, (helper.compostionInstruction --> a videoComposition.instructions)
// 选出所有过渡区(ex. index = 1, 3, 5, ...)compostionInstruction及其layerInstruction, 据此创建helper
- (NSArray *)transitionInstructionHelpersInVideoComposition:(AVVideoComposition *)videoComposition {
    NSMutableArray *helpers = [NSMutableArray array];
    NSUInteger layerIndex = 0;
    NSArray *instructions = videoComposition.instructions;
    NSInteger k = 0;
    for (NSInteger i = 0; i < instructions.count; i ++) { // 遍历所有instruction
        AVMutableVideoCompositionInstruction *instruction = instructions[i];
        if (instruction.layerInstructions.count == 2) {
            LPTransitionInstructionHelper *helper = [[LPTransitionInstructionHelper alloc] init];
            for (NSInteger j = k; j < self.timeline.transitions.count; j ++) {
                LPVideoTransition *trans = self.timeline.transitions[j];
                if (trans.type != LPVideoTransitionTypeNone) {
                    layerIndex = j % 2;

                    helper.transition = trans;
                    helper.compostionInstruction = instruction;
                    helper.fromLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions[layerIndex];
                    helper.toLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions[1 - layerIndex];
                    
                    [helpers addObject:helper];
                    
                    k ++;
                    
                    break;
                }
            }
        }
    }
    return helpers;
}

- (LPMovieSize)normalizedMovieSize {
    CGFloat width = LP1080pVideoSize.width;
    CGFloat minW = width;
    for (NSInteger i = 0; i < self.sizes.count; i ++) {
        CGSize size = [self.sizes[i] CGSizeValue];
        if (size.width < width) {
            minW = size.width;
        }
    }
    if (minW <= LP480pVideoSize.width) {
        return LPMovieSize480P;
    } else if (minW <=  LP720pVideoSize.width) {
        return LPMovieSize720P;
    } else {
        return LPMovieSize1080P;
    }
}
@end
