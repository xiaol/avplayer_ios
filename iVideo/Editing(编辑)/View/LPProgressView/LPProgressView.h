//
//  LPProgressView.h
//  iVideo
//
//  Created by apple on 16/3/30.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPProgressView : UIView

@property (nonatomic, assign) CGFloat circleDiameter;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *trackHighlightedColor;

@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) CGFloat trackWidth;

@end
