//
//  LPAudioItem.m
//  iVideo
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPAudioItem.h"

@implementation LPAudioItem

+ (instancetype)audioItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (NSString *)mediaType {
    return AVMediaTypeAudio;
}

@end
