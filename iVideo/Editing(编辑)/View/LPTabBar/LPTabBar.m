//
//  LPTabBar.m
//  iVideo
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPTabBar.h"

@interface LPTabBar ()
@property (nonatomic, weak) UIButton *selectedBtn;
@property (nonatomic, strong) NSMutableArray *btns;
@property (nonatomic, strong) UIView *divider;
@end

@implementation LPTabBar

- (NSMutableArray *)btns {
    if (_btns == nil) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorFromHexString:@"f7f7f8"];
        UIView *divider = [[UIView alloc] init];
        divider.backgroundColor = [UIColor colorFromHexString:@"adadad"];
        [self addSubview:divider];
        self.divider = divider;
    }
    return self;
}

- (void)addTabBarButtonWithTitle:(NSString *)title {
    UIButton *btn = [[UIButton alloc] init];
    [self addSubview:btn];
    
    [self.btns addObject:btn];
    
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn setTitleColor:[UIColor colorFromHexString:@"3e4452"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorFromHexString:@"8c97ff"] forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.btns.count == 1) {
        [self btnClick:btn];
    }
}

- (void)btnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectButtonFrom:to:)]) {
        [self.delegate tabBar:self didSelectButtonFrom:self.selectedBtn.tag to:btn.tag];
    }
    
    self.selectedBtn.selected = NO;
    btn.selected = YES;
    self.selectedBtn = btn;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.divider.x = 0;
    self.divider.y = 0;
    self.divider.width = self.width;
    self.divider.height = .5f;
    
    CGFloat w = self.width / self.btns.count;
    for (NSInteger i = 0; i < self.btns.count; i++) {
        UIButton *btn = self.btns[i];
        btn.tag = i;
        btn.x = i * w;
        btn.y = CGRectGetMaxY(self.divider.frame);
        btn.width = w;
        btn.height = self.height - self.divider.height;
    }
}

@end
