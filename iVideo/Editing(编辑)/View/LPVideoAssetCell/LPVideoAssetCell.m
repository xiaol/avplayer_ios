//
//  LPVideoAssetCell.m
//  iVideo
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPVideoAssetCell.h"

@interface LPVideoAssetCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *hud;
@property (nonatomic, strong) UILabel *noLabel;

@end

@implementation LPVideoAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
        _durationLabel.font = [UIFont systemFontOfSize:11];
        _durationLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_durationLabel];
        
        _hud = [[UIView alloc] init];
        _hud.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
        [self.contentView addSubview:_hud];
        _hud.hidden = YES;
        
        _noLabel = [[UILabel alloc] init];
        _noLabel.textAlignment = NSTextAlignmentCenter;
        _noLabel.textColor = [UIColor whiteColor];
        _noLabel.backgroundColor = [UIColor colorFromHexString:@"8c97ff"];
        _noLabel.clipsToBounds = YES;
        [self.contentView addSubview:_noLabel];
        _noLabel.hidden = YES;
    }
    return self;
}

- (void)setDuration:(NSUInteger)duration {
    _duration = duration;
    self.durationLabel.text = [NSString stringWithFormat:@"%ld:%02ld", duration / 60, duration % 60];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imgView.image = image;
}

- (void)setSelectedNumber:(NSUInteger)selectedNumber {
    if (selectedNumber > 0) {
        self.noLabel.text = [NSString stringWithFormat:@"%ld", selectedNumber];
        [UIView animateWithDuration:0.1f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.hud.hidden = NO;
                             self.noLabel.hidden = NO;
                         } completion:nil];
    } else {
        self.hud.hidden = YES;
        self.noLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imgView.frame = self.bounds;
    self.durationLabel.x = 0;
    self.durationLabel.height = self.height / 6;
    self.durationLabel.width = self.width;
    self.durationLabel.y = self.height - self.durationLabel.height;
    
    self.hud.frame = self.bounds;
    
    self.noLabel.width = self.height / 3;
    self.noLabel.height = self.noLabel.width;
    self.noLabel.x = (self.width - self.noLabel.width) / 2;
    self.noLabel.y = (self.height - self.noLabel.height) / 2;
    self.noLabel.layer.cornerRadius = self.noLabel.width / 2;
}

@end
