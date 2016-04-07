//
//  NSObject+Swizzle.m
//  iVideo
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "NSObject+Swizzle.h"

@implementation NSObject (Swizzle)

+ (IMP)swizzleInstanceSelector:(SEL)sel
                       withIMP:(IMP)imp {
    Method originalMethod = class_getInstanceMethod([self class], sel);
    IMP originalIMP = method_getImplementation(originalMethod);
    if (!class_addMethod(self, sel, imp, method_getTypeEncoding(originalMethod))) {
        method_setImplementation(originalMethod, imp);
    }
    return originalIMP;
}

@end
