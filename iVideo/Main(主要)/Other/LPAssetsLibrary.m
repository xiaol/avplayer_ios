//
//  LPAssetsLibrary.m
//  iVideo
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPAssetsLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LPVideoItem.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

static NSString * const NewAlbumName = @"iVideo";

@interface LPAssetsLibrary ()
@property (nonatomic, strong) ALAssetsLibrary *library;
@end

@implementation LPAssetsLibrary

- (instancetype)init {
    if (self = [super init]) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void)readAllVideoAssetsWithSuccess:(LPAssetsLibraryReadingVideoAssetsSuccessHandler)successHandler
                              failure:(LPAssetsLibraryReadingVideoAssetsFailureHandler)failureHandler {
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                                    NSMutableArray *videos = [NSMutableArray array];
                                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                        NSURL *url = [[result defaultRepresentation] url];
                                        LPVideoItem *video = [[LPVideoItem alloc] initWithURL:url];
                                        video.thumbnail = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                                        CGSize size = video.thumbnail.size;
                                        video.orientation = (size.width > size.height) ? LPVideoOrientationHorizontal : LPVideoOrientationVertical;
                                        video.duration = [[result valueForProperty:ALAssetPropertyDuration] CMTimeValue];
                                        NSTimeInterval duration = CMTimeGetSeconds(video.duration);
                                        if (duration > 2.f && duration <= 60.f * 5) { // 限制时间
                                            [videos addObject:video];
                                        }
                                        if (index == 0 && successHandler) {
                                            successHandler(videos);
                                        }
                                    }];
                                    
                                } failureBlock:^(NSError *error) {
                                    if (failureHandler) {
                                        failureHandler(error);
                                    }
                                }];
}

- (void)writeImage:(UIImage *)image
           success:(LPAssetsLibraryWritingSuccessHandler)successHandler
           failure:(LPAssetsLibraryWritingFailureHandler)failureHandler {
                [self.library writeImageToSavedPhotosAlbum:image.CGImage
                         orientation:(NSUInteger)image.imageOrientation
                     completionBlock:^(NSURL *assetURL, NSError *error) {
                         if (!error) {
                             if (successHandler) {
                                 successHandler(image);
                             }
                         } else {
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }
                     }];
}

- (void)writeVideoAtURL:(NSURL *)videoURL
                success:(LPAssetsLibraryWritingSuccessHandler)successHandler
                failure:(LPAssetsLibraryWritingFailureHandler)failureHandler {
    [self createAlbum];
    if ([self.library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) { // 检查视频可否被写入
        [self.library saveVideo:videoURL
                        toAlbum:NewAlbumName
                     completion:^(NSURL *assetURL, NSError *error) {
                         if (!error) {
                             dispatch_async(GLOBAL_QUEUE, ^{
                                 AVAsset *asset = [AVAsset assetWithURL:videoURL];
                                 AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                                 generator.maximumSize = CGSizeMake(100.0f, 0.0f);
                                 generator.appliesPreferredTrackTransform = YES; // 保证缩略图方向正确
                                 CGImageRef imgRef = [generator copyCGImageAtTime:kCMTimeZero
                                                                       actualTime:NULL
                                                                            error:nil];
                                 UIImage *image = [UIImage imageWithCGImage:imgRef];
                                 CGImageRelease(imgRef);
                                 dispatch_async(MAIN_QUEUE, ^{
                                     if (successHandler) {
                                         successHandler(image);
                                     }
                                 });
                             });
                         } else {
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }
                     } failure:^(NSError *error) {
                         if (failureHandler) {
                             failureHandler(error);
                         }
                     }];
    }
}

- (void)createAlbum {
    NSMutableArray *groups = [NSMutableArray array];
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if (group) {
                                        [groups addObject:group];
                                    } else {
                                        BOOL exist = NO;
                                        for (ALAssetsGroup *group in groups) {
                                            if ([[group valueForProperty:ALAssetsGroupPropertyName]
                                                 isEqualToString:NewAlbumName]) {
                                                exist = YES;
                                                break;
                                            }
                                        }
                                        if (!exist) {
                                            [self.library addAssetsGroupAlbumWithName:NewAlbumName
                                                                          resultBlock:^(ALAssetsGroup *group) {
                                                                              [groups addObject:group];
                                                                          } failureBlock:^(NSError *error) {
                                                                              dispatch_async(MAIN_QUEUE, ^{
                                                                                   [UIAlertView alertViewShowWithTitle:@"存储失败" message:@"请打开 设置-隐私-照片 来进行设置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitle:nil];
                                                                              });
                                                                          }];
                                        }
                                    }
                                } failureBlock:nil];
}
@end
