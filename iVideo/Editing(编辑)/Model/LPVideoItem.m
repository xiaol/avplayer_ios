//
//  LPVideoItem.m
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPVideoItem.h"

static const CMTime LPDefaultTransitionDuration = {1, 1, 1, 0};

@interface LPVideoItem ()
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@end

@implementation LPVideoItem

+ (instancetype)videoItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithURL:url]) {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
        _imageGenerator.maximumSize = CGSizeMake(300.f, 0.f);
        _imageGenerator.appliesPreferredTrackTransform = YES; // 保证缩略图方向正确
    }
    return self;
}

- (void)performCompletionHandler:(LPMediaPreparationCompletionHandler)completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self generateInitialThumbnailWithCompletion:completionHandler];
    });
}

// 加载完成后生成预设图片
- (void)generateInitialThumbnailWithCompletion:(LPMediaPreparationCompletionHandler)completionHandler {
    CMTime presetStart = kCMTimeZero;
    if (!CMTIMERANGE_IS_INVALID(self.trimmedTimeRange)) {
        presetStart = self.trimmedTimeRange.start;
    }
    CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:presetStart actualTime:NULL error:nil];
    self.thumbnail = [UIImage imageWithCGImage:imageRef];
    dispatch_async(MAIN_QUEUE, ^{
        if (completionHandler) {
            completionHandler(YES);
        }
    });
}

- (NSString *)mediaType {
    return AVMediaTypeVideo;
}

- (void)updateThumbnail {
    CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:self.trimmedTimeRange.start actualTime:NULL error:nil];
    self.thumbnail = [UIImage imageWithCGImage:imageRef];
}

- (CMTimeRange)passThroughRange {
    if (self.startTransition.type == LPVideoTransitionTypeNone && self.endTransition.type == LPVideoTransitionTypeNone) return self.trimmedTimeRange;
    CMTime start = self.trimmedTimeRange.start;
    CMTime duration = self.trimmedTimeRange.duration;
    if (self.startTransition.type != LPVideoTransitionTypeNone) {
        start = CMTimeAdd(start, LPDefaultTransitionDuration);
        duration = CMTimeSubtract(duration, LPDefaultTransitionDuration);
    }
    if (self.endTransition.type != LPVideoTransitionTypeNone) {
        duration = CMTimeSubtract(duration, LPDefaultTransitionDuration);
    }
    return CMTimeRangeMake(start, duration);
}
@end
