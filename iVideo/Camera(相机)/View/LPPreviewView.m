//
//  LPPreviewView.m
//  iVideo
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPPreviewView.h"
#import "LPCameraNotification.h"

@interface LPPreviewView ()
@property (nonatomic, assign) CGRect drawableBounds;
@end

@implementation LPPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    if (self = [super initWithFrame:frame context:context]) {
        self.enableSetNeedsDisplay = NO;
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        
        [self bindDrawable];
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
        
        [noteCenter addObserver:self
                       selector:@selector(filterChanged:)
                           name:LPFilterSelectionDidChangeNotification
                         object:nil];
    }
    return self;
}

- (void)dealloc {
    [noteCenter removeObserver:self];
}

- (void)filterChanged:(NSNotification *)note {
    self.filter = note.object;
}

- (void)setImage:(CIImage *)image {
    [self bindDrawable];
    
    CIImage *filteredImage = nil;
    if (self.filter) { // 如有滤镜, 对图像做滤波
        [self.filter setValue:image forKey:kCIInputImageKey];
        filteredImage = self.filter.outputImage;
    }

    if (!filteredImage) { // 无滤镜
        filteredImage = image;
    }
    
    CGRect clippedRect = [self clippedAspectRectFromRect:image.extent
                                                  toRect:self.drawableBounds];
    [self.ciContext drawImage:filteredImage
                       inRect:self.drawableBounds
                     fromRect:clippedRect];
    [self display];
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

- (CGRect)clippedAspectRectFromRect:(CGRect)fromRect toRect:(CGRect)toRect {
    CGFloat fromRatio = fromRect.size.width / fromRect.size.height;
    CGFloat toRatio = toRect.size.width / toRect.size.height;
    
    CGRect drawRect = fromRect;
    
    if (fromRatio > toRatio) {
        CGFloat scaledWidth = drawRect.size.height * toRatio;
        drawRect.origin.x += (drawRect.size.width - scaledWidth) / 2.0;
        drawRect.size.width = scaledWidth;
    } else {
        CGFloat scaledHeight = drawRect.size.width / toRatio;
        drawRect.origin.y += (drawRect.size.height - scaledHeight) / 2.0;
        drawRect.size.height = scaledHeight;
    }
    return drawRect;
}
@end
