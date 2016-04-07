//
//  LPFilterView.h
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "LPFilterGraph.h"

@interface LPFilterView : GLKView

@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) LPFilterGraph *filterGraph;

@end
