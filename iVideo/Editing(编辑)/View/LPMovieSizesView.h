//
//  LPMovieSizesView.h
//  iVideo
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LPMovieSizeSelectionHandler)(NSInteger movieSizeNumber);

@interface LPMovieSizesView : UIView

- (instancetype)initWithPadding:(CGFloat)padding
             availableSizeCount:(NSInteger)count
               selectionHandler:(LPMovieSizeSelectionHandler)handler;

@end
