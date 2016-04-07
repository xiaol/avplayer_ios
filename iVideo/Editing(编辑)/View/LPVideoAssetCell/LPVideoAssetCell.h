//
//  LPVideoAssetCell.h
//  iVideo
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPVideoAssetCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) NSUInteger selectedNumber;

@end
