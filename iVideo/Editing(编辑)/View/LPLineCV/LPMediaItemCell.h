//
//  LPMediaItemCell.h
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPMediaItemCell;

@protocol LPMediaItemCellDelegate <NSObject>

- (void)mediaItemCellDidClickDeleteButton:(LPMediaItemCell *)mediaItemCell;

@end

@interface LPMediaItemCell : UICollectionViewCell

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, assign) BOOL processing;

@property (nonatomic, weak) id<LPMediaItemCellDelegate> delegate;

@end
