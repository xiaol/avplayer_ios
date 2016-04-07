//
//  LPVideoItem.h
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMediaItem.h"
#import "LPVideoTransition.h"

typedef NS_ENUM(NSUInteger, LPVideoOrientation) {
    LPVideoOrientationHorizontal,
    LPVideoOrientationVertical
};

@interface LPVideoItem : LPMediaItem

+ (instancetype)videoItemWithURL:(NSURL *)url;

/**
 *  显示在源视频片段列表的缩略图(kCMTimeZero)
 */
@property (nonatomic, strong) UIImage *thumbnail;
- (void)updateThumbnail;

@property (nonatomic, assign) LPVideoOrientation orientation;
@property (nonatomic, assign) CMTime duration;

@property (nonatomic, strong) LPVideoTransition *startTransition;
@property (nonatomic, strong) LPVideoTransition *endTransition;

@property (nonatomic, assign) CMTimeRange passThroughRange;
@property (nonatomic, assign) CMTimeRange startTransitionRange;
@property (nonatomic, assign) CMTimeRange endTransitionRange;
@end


