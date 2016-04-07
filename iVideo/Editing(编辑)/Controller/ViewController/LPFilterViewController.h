//
//  LPFilterViewController.h
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPComposition.h"

@interface LPFilterViewController : UIViewController

@property (nonatomic, strong) LPComposition *composition;

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) CIImage *thumbnail;

@end
