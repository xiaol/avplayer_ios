//
//  LPPlaybackView.m
//  iVideo
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPPlaybackView.h"

@interface LPPlaybackView ()
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIView *hud;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL prepared;
@end

@implementation LPPlaybackView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor darkGrayColor];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.75];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:20];
        _label.alpha = 0.f;
        _label.clipsToBounds = YES;
        [self addSubview:_label];
        
        _hud = [[UIView alloc] init];
        _hud.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:_hud];
        _hud.hidden = YES;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_hud addSubview:_indicator];
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)self.layer player];
}

- (void)setPlayer:(AVPlayer *)player {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
//    layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [layer setPlayer:player];
}

- (void)setText:(NSString *)text {
    _text = text;
    self.label.alpha = 1.f;
    self.label.text = text;
}

- (void)hideTime {
    [UIView animateWithDuration:.5f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.label.alpha = 0.f;
                     } completion:nil];
}

- (void)prepareForPlaying {
//    if (!self.prepared) {
        [self.indicator startAnimating];
        self.hud.hidden = NO;
//    }
    
    self.prepared = YES;
}

- (void)startPlaying {
    if (self.prepared) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            self.hud.hidden = YES;
        });
        self.prepared = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.center = CGPointMake(self.width / 2.f, self.height / 2.f);
    self.label.width = self.width / 3.2f;
    self.label.height = self.height / 3.2f;
    self.label.layer.cornerRadius = self.label.height / 4.f;
    
    self.hud.frame = self.bounds;
    self.indicator.center = self.hud.center;
}

@end
