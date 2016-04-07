//
//  LPLineTransitionDecoration.h
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPVideoTransition.h"

@interface LPLineTransitionDecoration : UICollectionReusableView
@property (nonatomic, strong) UIImageView *transitionView;
- (UIImage *)imageWithTransitionType:(LPVideoTransitionType)type;
@end
