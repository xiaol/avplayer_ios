//
//  LPContextManager.h
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPContextManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, strong, readonly) EAGLContext *glContext;
@property (nonatomic, strong, readonly) CIContext *ciContext;

@end
