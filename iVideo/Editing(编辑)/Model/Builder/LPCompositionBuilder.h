//
//  LPCompositionBuilder.h
//  iVideo
//
//  Created by apple on 16/2/21.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPComposition.h"
#import "LPTimeline.h"

@interface LPCompositionBuilder : NSObject

+ (LPComposition *)buildCompositionWithTimeline:(LPTimeline *)timeline;

@end
