//
//  LPMediaItem.h
//  iVideo
//
//  Created by apple on 16/2/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LPMediaPreparationCompletionHandler)(BOOL completed);

@interface LPMediaItem : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign, readonly) BOOL prepared;
@property (nonatomic, copy) NSString *mediaType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filename;

@property (nonatomic, assign) CMTimeRange timeRange;

@property (nonatomic, assign) CMTime startTimeInTimeline; // music & voice
@property (nonatomic, assign) CMTimeRange trimmedTimeRange;

//@property (nonatomic, assign, getter = isTrimmed) BOOL trimmed;

- (instancetype)initWithURL:(NSURL *)url;
- (void)prepareWithCompletion:(LPMediaPreparationCompletionHandler)completionHandler;
- (AVPlayerItem *)playerItem;

- (void)performCompletionHandler:(LPMediaPreparationCompletionHandler)completionHandler;

@end
