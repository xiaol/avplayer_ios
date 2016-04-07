//
//  LPImageTarget.h
//  iVideo
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol LPImageTarget <NSObject>

- (void)setImage:(CIImage *)image;

@end
