//
//  LPMediaItemCell.m
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMediaItemCell.h"

@interface LPMediaItemCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *currentHUD;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIView *blackHUD;
@end

@implementation LPMediaItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UIView *blackHUD = [[UIView alloc] init];
        blackHUD.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
        [self.contentView addSubview:blackHUD];
        self.blackHUD = blackHUD;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:18];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        self.label = label;
        
        UIView *currentHUD = [[UIView alloc] init];
        currentHUD.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:currentHUD];
        self.currentHUD = currentHUD;
        
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.lineWidth = 2;
        borderLayer.strokeColor = [UIColor colorFromHexString:@"ff187a"].CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        [currentHUD.layer addSublayer:borderLayer];
        self.borderLayer = borderLayer;
        
        UIButton *deleteBtn = [[UIButton alloc] init];
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
        deleteBtn.enlargedEdge = 5.f;
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [currentHUD addSubview:deleteBtn];
        self.deleteBtn = deleteBtn;
    }
    return self;
}

- (void)setProcessing:(BOOL)processing {
    _processing = processing;
    
    self.currentHUD.hidden = !processing;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.label.text = text;
}

- (void)setThumbnail:(UIImage *)thumbnail {
    _thumbnail = thumbnail;
    
    self.imageView.image = thumbnail;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.blackHUD.frame = self.bounds;
    self.label.frame = self.bounds;
    
    self.currentHUD.frame = self.bounds;
    self.borderLayer.path = [UIBezierPath bezierPathWithRect:CGRectInset(self.currentHUD.bounds, 1.f, 1.f)].CGPath;
    self.deleteBtn.frame = CGRectMake(self.currentHUD.width - 22.f, 2.f, 20, 20);
}

- (void)deleteBtnClicked {
    if ([self.delegate respondsToSelector:@selector(mediaItemCellDidClickDeleteButton:)]) {
        [self.delegate mediaItemCellDidClickDeleteButton:self];
    }
}

@end
