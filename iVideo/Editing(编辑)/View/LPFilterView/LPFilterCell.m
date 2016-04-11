//
//  LPFilterCell.m
//  iVideo
//
//  Created by apple on 16/3/24.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPFilterCell.h"
#import "LPFilterGraph.h"

@interface LPFilterCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *hud;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@end

@implementation LPFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UIView *hud = [[UIView alloc] init];
        hud.backgroundColor = [UIColor colorWithWhite:0.f alpha:.3f];
        [self.contentView addSubview:hud];
        self.hud = hud;
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.numberOfLines = 0;
        [self.contentView addSubview:label];
        self.label = label;
        
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.lineWidth = 2;
        borderLayer.strokeColor = [UIColor colorFromHexString:@"ff187a"].CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.hidden = YES;
        [self.contentView.layer addSublayer:borderLayer];
        self.borderLayer = borderLayer;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.hud.frame = self.bounds;
    self.label.frame = self.bounds;
    self.borderLayer.path = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, 1.f, 1.f)].CGPath;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.label.text = text;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = image;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.borderLayer.hidden = !selected;
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView {
    
}

@end
