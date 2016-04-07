//
//  LPVideoInstructionHelper.h
//  iVideo
//
//  Created by apple on 16/3/13.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPVideoTransition.h"

@interface LPVideoInstructionHelper : NSObject

@property (nonatomic, strong) AVMutableVideoCompositionInstruction *compostionInstruction;
@property (nonatomic, assign) BOOL singleLayer;

// double layers
@property (nonatomic, strong) LPVideoTransition *transition;
@property (nonatomic, assign) NSUInteger fromVideoIndex;
@property (nonatomic, assign) NSUInteger toVideoIndex;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
@property (nonatomic, assign) CGAffineTransform fromLayerTransform;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *toLayerInstruction;
@property (nonatomic, assign) CGAffineTransform toLayerTransform;

@end
