//
//  LPAssetsLibrary.h
//  iVideo
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LPAssetsLibraryReadingVideoAssetsSuccessHandler)(NSArray *videos);
typedef void(^LPAssetsLibraryReadingVideoAssetsFailureHandler)(NSError *error);
typedef void(^LPAssetsLibraryWritingSuccessHandler)(UIImage *image);
typedef void(^LPAssetsLibraryWritingFailureHandler)(NSError *error);

@interface LPAssetsLibrary : NSObject

- (void)readAllVideoAssetsWithSuccess:(LPAssetsLibraryReadingVideoAssetsSuccessHandler)successHandler
                              failure:(LPAssetsLibraryReadingVideoAssetsFailureHandler)failureHandler;

- (void)writeImage:(UIImage *)image
           success:(LPAssetsLibraryWritingSuccessHandler)successHandler
           failure:(LPAssetsLibraryWritingFailureHandler)failureHandler;

- (void)writeVideoAtURL:(NSURL *)videoURL
                success:(LPAssetsLibraryWritingSuccessHandler)successHandler
                failure:(LPAssetsLibraryWritingFailureHandler)failureHandler;
@end
