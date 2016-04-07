//
//  LPMovieWriter.h
//  iVideo
//
//  Created by apple on 16/1/19.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LPWritingCompletionHandler)(NSURL *outputURL);

@interface LPMovieWriter : NSObject
// 初始化
+ (instancetype)movieWriterWithVideoSettings:(NSDictionary *)videoSettings
                               audioSettings:(NSDictionary *)audioSettings
                               dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
                        audioSettings:(NSDictionary *)audioSettings
                        dispatchQueue:(dispatch_queue_t)dispatchQueue;

// 开始和结束输出
- (void)startWriting;
- (void)stopWritingWithCompletion:(LPWritingCompletionHandler)completionHandler;

// 单帧处理
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

// 状态属性
@property (nonatomic, assign, getter=isWriting) BOOL writing;
@end
