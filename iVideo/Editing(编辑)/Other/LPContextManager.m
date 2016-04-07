//
//  LPContextManager.m
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPContextManager.h"

@implementation LPContextManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static LPContextManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _ciContext = [CIContext contextWithEAGLContext:_glContext]; // 关联两个上下文
    }
    return self;
}

@end
