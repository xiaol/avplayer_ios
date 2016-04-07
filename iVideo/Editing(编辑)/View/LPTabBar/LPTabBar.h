//
//  LPTabBar.h
//  iVideo
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPTabBar;

@protocol LPTabBarDelegate <NSObject>

@optional

- (void)tabBar:(LPTabBar *)tabBar didSelectButtonFrom:(NSInteger)from to:(NSInteger)to;

@end


@interface LPTabBar : UIView

- (void)addTabBarButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id<LPTabBarDelegate> delegate;

@end
