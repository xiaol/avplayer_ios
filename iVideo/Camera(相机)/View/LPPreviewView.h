//
//  LPPreviewView.h
//  iVideo
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "LPImageTarget.h"

@interface LPPreviewView : GLKView <LPImageTarget>
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) CIContext *ciContext;
@end
