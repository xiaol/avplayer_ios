//
//  LPFunctions.h
//  iVideo
//
//  Created by apple on 16/2/9.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#ifndef LPFunctions_h
#define LPFunctions_h

static const CGSize LP480pVideoSize = {720.0f, 480.0f};
static const CGSize LP720pVideoSize = {1280.0f, 720.0f};
static const CGSize LP1080pVideoSize = {1920.0f, 1080.0f};

static const CGRect LP480pVideoRect = {{0.0f, 0.0f}, {720.0f, 480.0f}};
static const CGRect LP720pVideoRect = {{0.0f, 0.0f}, {1280.0f, 720.0f}};
static const CGRect Lp1080pVideoRect = {{0.0f, 0.0f}, {1920.0f, 1080.f}};

typedef struct LPScaleRange {
    CGFloat start;
    CGFloat end;
} LPScaleRange;

typedef NS_ENUM(NSUInteger, LPMovieSize) {
    LPMovieSize1080P,
    LPMovieSize720P,
    LPMovieSize480P
};

static const LPScaleRange LPDefaultScaleRange = {0.2, 0.8};

static inline CMTimeRange LPTimeRangeFromScaleRange(CMTimeRange originalTimeRange, LPScaleRange scaleRange) {
    CMTimeRange newTimeRange = kCMTimeRangeInvalid;
    CGFloat startScale = scaleRange.start;
    CGFloat endScale = scaleRange.end;
    if (startScale < endScale) {
        CGFloat originalDuration = CMTimeGetSeconds(originalTimeRange.duration);
        CGFloat duration = originalDuration * (endScale - startScale);
        CGFloat start = CMTimeGetSeconds(originalTimeRange.start) + startScale * originalDuration;
        newTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, NSEC_PER_SEC), CMTimeMakeWithSeconds(duration, NSEC_PER_SEC));
    }
    return newTimeRange;
}

static inline BOOL LPIsEmpty (id object) {
    return object == nil ||
    object == [NSNull null] ||
    ([object isKindOfClass:[NSString class]] && [object length] == 0) ||
    ([object respondsToSelector:@selector(count)] && [object count] == 0);
}

static inline CGRect LPCropImageRectAspectRatio (CGRect sourceRect, CGRect displayRect) {
    CGFloat sourceRatio = sourceRect.size.width / sourceRect.size.height;
    CGFloat displayRatio = displayRect.size.width / displayRect.size.height;
    
    if (sourceRatio == displayRatio) return sourceRect;

    CGRect resultRect = sourceRect;
    
    // 按照displayRatio做裁剪
    if (sourceRatio > displayRatio) { // 裁两侧
        CGFloat width = resultRect.size.height * displayRatio;
        resultRect.origin.x += (resultRect.size.width - width) / 2.0;
        resultRect.size.width = width;
    } else {
        CGFloat height = resultRect.size.width / displayRatio;
        resultRect.origin.y += (resultRect.size.height - height) / 2.0;
        resultRect.size.height = height;
    }
    return resultRect;
}

#endif
