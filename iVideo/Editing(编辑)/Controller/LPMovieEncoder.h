//
//  LPMovieEncoder.h
//  iVideo
//
//  Created by apple on 16/3/28.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPFilterGraph.h"
#import "LPComposition.h"

typedef void(^LPEncodeSuccessHandler)(NSURL *movieURL);
typedef void(^LPEncodeFailureHandler)(NSError *error);
typedef void(^LPEncodeProgressHandler)(CGFloat percent);

// re-encode movie with filter graph
@interface LPMovieEncoder : NSObject

/**
 *  initialize a movie encoder
 */
- (instancetype)initWithComposition:(LPComposition *)composition
                        filterGraph:(LPFilterGraph *)filterGraph
                          movieSize:(LPMovieSize)movieSize;
/**
 *  start encoding with callbacks
 */
- (void)startEncodingWithSuccess:(LPEncodeSuccessHandler)successHandler
                         failure:(LPEncodeFailureHandler)failureHandler
                        progress:(LPEncodeProgressHandler)progressHandler;

@property (nonatomic, assign, readonly) BOOL cancelled;

- (void)cancelEncoding;

@end
