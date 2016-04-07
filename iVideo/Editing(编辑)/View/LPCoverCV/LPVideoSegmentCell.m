//
//  LPVideoSegmentCell.m
//  iVideo
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPVideoSegmentCell.h"

@interface LPVideoSegmentCell ()
@property (nonatomic, strong) CALayer *imageLayer;
@end

@implementation LPVideoSegmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CALayer *imageLayer = [CALayer layer];
        imageLayer.backgroundColor = [UIColor blackColor].CGColor;
        imageLayer.contentsScale = [UIScreen mainScreen].scale;
        imageLayer.masksToBounds = YES;
        imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        [self.contentView.layer addSublayer:imageLayer];
        self.imageLayer = imageLayer;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageLayer.contents = (id)image.CGImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageLayer.frame = self.contentView.layer.bounds;
}
@end
