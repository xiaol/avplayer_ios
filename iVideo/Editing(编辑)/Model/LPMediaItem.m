//
//  LPMediaItem.m
//  iVideo
//
//  Created by apple on 16/2/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMediaItem.h"

static NSString * const AssetTracksKey = @"tracks";
static NSString * const AssetDurationKey = @"duration";
static NSString * const AssetTransformKey = @"preferredTransform";
static NSString * const AssetCommonMetadataKey = @"commonMetadata";

@interface LPMediaItem ()
@end

@implementation LPMediaItem

@synthesize title = _title;

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        _filename = [[[url URLByDeletingPathExtension] lastPathComponent] copy];
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @(YES)};
        _asset = [AVURLAsset URLAssetWithURL:url
                                     options:options];
        _trimmedTimeRange = kCMTimeRangeInvalid;
        _startTimeInTimeline = kCMTimeInvalid;
        _timeRange = kCMTimeRangeInvalid;
    }
    return self;
}

- (NSString *)title {
    if (!_title) {
        for (AVMetadataItem *item in self.asset.commonMetadata) {
            if ([item.commonKey isEqualToString:AssetCommonMetadataKey]) {
                _title = item.stringValue;
                break;
            }
        }
    }
    if (!_title) {
        _title = self.filename;
    }
    return _title;
}

- (AVPlayerItem *)playerItem {
    return [AVPlayerItem playerItemWithAsset:self.asset];
}

- (void)prepareWithCompletion:(LPMediaPreparationCompletionHandler)completionHandler {
    NSArray *keys = @[AssetCommonMetadataKey, AssetDurationKey, AssetTracksKey];
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:AssetTracksKey error:nil];
        AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:AssetDurationKey error:nil];
//        AVKeyValueStatus transformStatus = [self.asset statusOfValueForKey:AssetTransformKey error:nil];
        _prepared = (tracksStatus == AVKeyValueStatusLoaded)
        && (durationStatus == AVKeyValueStatusLoaded);
        if (self.prepared) {
            self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
            if (CMTIMERANGE_IS_INVALID(self.trimmedTimeRange)) {
                self.trimmedTimeRange = LPTimeRangeFromScaleRange(self.timeRange, LPDefaultScaleRange);
            }
            [self performCompletionHandler:completionHandler];
        } else {
            if (completionHandler) {
                completionHandler(NO);
            }
        }
    }];
}

- (void)performCompletionHandler:(LPMediaPreparationCompletionHandler)completionHandler {
    if (completionHandler) {
        completionHandler(self.prepared);
    }
}

//- (BOOL)isTrimmed {
//    if (!self.prepared) {
//        return NO;
//    }
//    return CMTIME_COMPARE_INLINE(self.timeRange.duration, <, self.asset.duration);
//}

- (NSString *)mediaType {
    return nil;
}

#pragma mark - override isEqual: & hash
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (!object || ![object isKindOfClass:self.class]) {
        return NO;
    }
    return [self.url isEqual:[object url]];
}

// 相同的对象一定具有相同的hash值
- (NSUInteger)hash {
    return [self.url hash];
}

@end
