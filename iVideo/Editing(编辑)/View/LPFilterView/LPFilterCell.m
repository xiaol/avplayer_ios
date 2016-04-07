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
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) UILabel *label;
@end

@implementation LPFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorFromHexString:@"3e4452"];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.numberOfLines = 0;
        [self.contentView addSubview:label];
        self.label = label;
        
        self.context = [CIContext contextWithOptions:nil];
    }
    return self;
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
    self.imageView.height = self.height * 0.8;
    
    self.label.x = 0;
    self.label.y = self.height * 0.8;
    self.label.width = self.width;
    self.label.height = self.height - self.label.y;
}

- (void)setFilterGraph:(LPFilterGraph *)filterGraph {
    _filterGraph = filterGraph;
    
    self.label.text = filterGraph.effectName;
    dispatch_async(GLOBAL_QUEUE, ^{
        CGImageRef cgimage = [self.context createCGImage:filterGraph.outputImage fromRect:filterGraph.extent];
        dispatch_async(MAIN_QUEUE, ^{
            self.imageView.image = [UIImage imageWithCGImage:cgimage];
            CGImageRelease(cgimage);
        });
    });
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.label.textColor = [UIColor colorFromHexString:@"8c97ff"];
    } else {
        self.label.textColor = [UIColor colorFromHexString:@"3e4452"];
    }
}

@end
