//
//  LPCameraModeView.m
//  iVideo
//
//  Created by apple on 16/1/22.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCameraModeView.h"

#define CAMERA_BUTTON_DEFAULT_FRAME CGRectMake(0.0f, 0.0f, 68.0f, 68.0f)

static const CGFloat CaptureButtonWidth = 68.0f;
static const CGFloat CaptureButtonHeight = 68.0f;
static const CGFloat ModeTextWidth = 60.0f;

static const NSString * LPCaptureButtonSelectedContext;

@interface LPCameraModeView ()
@property (nonatomic, strong) LPCaptureButton *captureBtn;
@property (nonatomic, assign) BOOL maxRight;
@property (nonatomic, assign) BOOL maxLeft;
@property (nonatomic, strong) CATextLayer *videoLayer;
@property (nonatomic, strong) CATextLayer *photoLayer;
@property (nonatomic, strong) UIView *modeContainer;
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, assign) CGFloat videoStrWidth;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftGR;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightGR;
@end

@implementation LPCameraModeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.maxRight = YES;
        self.mode = LPCameraModeVideo;
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        self.foregroundColor = [UIColor colorWithRed:1.000 green:0.734 blue:0.006 alpha:1.000];
        CGSize size = [@"视频" sizeWithAttributes:[self fontAttributes]];
        self.videoStrWidth = size.width;
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.videoLayer = [self textLayerWithString:@"视频"];
    self.videoLayer.foregroundColor = [UIColor whiteColor].CGColor;
    self.videoLayer.frame = CGRectMake(0.0f, 0.0f, ModeTextWidth, 20.0f);
    self.photoLayer = [self textLayerWithString:@"照片"];
    self.photoLayer.foregroundColor = [UIColor whiteColor].CGColor;
    self.photoLayer.frame = CGRectMake(ModeTextWidth, 0.0f, ModeTextWidth, 20.0f);
    self.modeContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 120.f, 20.0f)];
    self.modeContainer.backgroundColor = [UIColor clearColor];
    [self.modeContainer.layer addSublayer:self.videoLayer];
    [self.modeContainer.layer addSublayer:self.photoLayer];
    [self addSubview:self.modeContainer];
    
    self.captureBtn = [LPCaptureButton captureButtonWithFrame:CGRectMake(0, 0, CaptureButtonWidth, CaptureButtonHeight) cameraMode:LPCameraModeVideo];
    self.captureBtn.center = CGPointMake(self.width / 2.0f, self.height / 2.0f);
    self.captureBtn.y = self.height - 8.0f - CaptureButtonHeight;
    [self addSubview:self.captureBtn];
    [self.captureBtn addTarget:self action:@selector(handleCaptureStart:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.captureBtn addObserver:self
                      forKeyPath:@"selected"
                         options:0
                         context:&LPCaptureButtonSelectedContext];
    
    self.thumbnailBtn = [[UIButton alloc] initWithFrame:CGRectMake(40.0f, 45.0f, 45.0f, 45.0f)];
    self.thumbnailBtn.layer.cornerRadius = 3.0f;
    [self addSubview:self.thumbnailBtn];
    [self.thumbnailBtn addTarget:self action:@selector(handelThumbnailClick) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *leftSwipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    leftSwipeGR.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *rightSwipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    [self addGestureRecognizer:leftSwipeGR];
    [self addGestureRecognizer:rightSwipeGR];
    self.leftGR = leftSwipeGR;
    self.rightGR = rightSwipeGR;
}

- (void)switchMode:(UISwipeGestureRecognizer *)gr {
    if (gr.direction == UISwipeGestureRecognizerDirectionLeft && !self.maxLeft) {
        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.modeContainer.x -= ModeTextWidth;
                         } completion:^(BOOL finished) {
                             self.mode = LPCameraModePhoto;
                             self.maxLeft = YES;
                             self.maxRight = NO;
                         }];
    } else if (gr.direction == UISwipeGestureRecognizerDirectionRight && !self.maxRight) {
        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.modeContainer.x += ModeTextWidth;
                         } completion:^(BOOL finished) {
                             self.mode = LPCameraModeVideo;
                             self.maxLeft = NO;
                             self.maxRight = YES;
                         }];
    }
}

- (void)setMode:(LPCameraMode)mode {
    if (_mode != mode) {
        _mode = mode;
        
        if (mode == LPCameraModePhoto) {
            self.captureBtn.selected = NO;
            self.captureBtn.mode = LPCameraModePhoto;
            self.layer.backgroundColor = [UIColor blackColor].CGColor;
        } else {
            self.captureBtn.mode = LPCameraModeVideo;
            self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CATextLayer *)textLayerWithString:(NSString *)string {
    CATextLayer *layer = [CATextLayer layer];
    layer.string = [[NSAttributedString alloc] initWithString:string attributes:[self fontAttributes]];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

- (NSDictionary *)fontAttributes {
    return @{NSFontAttributeName : [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16.0f],
             NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.modeContainer.x = CGRectGetMidX(self.bounds) - self.videoStrWidth / 2.0f;
}

- (void)drawRect:(CGRect)rect { // 画黄色小圆点
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.foregroundColor.CGColor);
    CGRect circleF = CGRectMake(CGRectGetMidX(self.bounds) - 3.0f, 2.0f, 6.0f, 6.0f);
    CGContextFillEllipseInRect(ctx, circleF);
}

- (void)handleCaptureStart:(UIButton *)sender {
    if (self.mode == LPCameraModeVideo) {
        sender.selected = !sender.selected; // 执行自定义按钮相应动画
    }
    if (self.captureStartHandler) {
        self.captureStartHandler();
    }
}

- (void)handelThumbnailClick {
    if (self.thumbnailClickHandler) {
        self.thumbnailClickHandler();
    }
}

// 录制视频时, 模式不可左右滑动
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (context == &LPCaptureButtonSelectedContext) {
        if (self.captureBtn.selected && self.mode == LPCameraModeVideo) {
            self.leftGR.enabled = NO;
            self.rightGR.enabled = NO;
        } else {
            self.leftGR.enabled = YES;
            self.rightGR.enabled = YES;
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
@end
