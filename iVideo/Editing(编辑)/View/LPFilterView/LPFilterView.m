//
//  LPFilterView.m
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPFilterView.h"

@interface LPFilterView ()
@property (nonatomic, assign) CGRect drawableBounds;
@end

@implementation LPFilterView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    if (self = [super initWithFrame:frame context:context]) {
        self.backgroundColor = [UIColor blackColor];
        self.enableSetNeedsDisplay = NO;
        self.frame = frame;
        
        [self bindDrawable];
//        self.drawableBounds = (CGRect){CGPointZero, {self.drawableWidth, self.drawableHeight}};
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;

    }
    return self;
}

- (void)setFilterGraph:(LPFilterGraph *)filterGraph {
    [self bindDrawable];                                    // 绑定(隐式开启)一个帧缓存(frameBuffer: 接收渲染结果(2D pixel data)的缓冲区)
    CIImage *outputImage = [filterGraph outputImage];
    CGRect fromRect = LPCropImageRectAspectRatio(filterGraph.inputImage.extent, self.drawableBounds);
    [self.ciContext drawImage:outputImage
                       inRect:self.drawableBounds
                     fromRect:fromRect];
    [self display];
}
@end
