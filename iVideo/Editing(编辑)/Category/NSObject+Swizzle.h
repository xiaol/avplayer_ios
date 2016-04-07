//
//  NSObject+Swizzle.h
//  iVideo
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

/**
 *  cast original selector to a new IMP, and return original IMP
 *
 *  @param selector  original sel
 *  @param imp       new imp
 *
 *  @return          original imp
 */
+ (IMP)swizzleInstanceSelector:(SEL)selector
                        withIMP:(IMP)imp;

@end
