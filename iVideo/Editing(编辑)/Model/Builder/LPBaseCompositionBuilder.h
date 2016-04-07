//
//  LPBaseCompositionBuilder.h
//  iVideo
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPComposition.h"
#import "LPTimeline.h"

@interface LPBaseCompositionBuilder : NSObject

+ (LPComposition *)buildCompositionWithTimeline:(LPTimeline *)timeline;

@end
