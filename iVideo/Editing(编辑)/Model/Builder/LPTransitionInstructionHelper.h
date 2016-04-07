//
//  LPTransitionInstruction.h
//  iVideo
//
//  Created by apple on 16/2/22.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPVideoTransition.h"

@interface LPTransitionInstructionHelper : NSObject

@property (nonatomic, strong) LPVideoTransition *transition;
@property (nonatomic, strong) AVMutableVideoCompositionInstruction *compostionInstruction;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *toLayerInstruction;

@end
