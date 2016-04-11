//
//  LPPlayControl.m
//  iVideo
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPPlayControl.h"

static const CGFloat top = 0.f;

@interface LPPlayControl ()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, assign) BOOL playing;

@end

@implementation LPPlayControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *progressLabel = [[UILabel alloc] init];
        progressLabel.font = [UIFont systemFontOfSize:12];
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.text = @"00:00";
        [self addSubview:progressLabel];
        self.progressLabel = progressLabel;
        
        UIButton *toggleBtn = [[UIButton alloc] init];
        [toggleBtn setBackgroundImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        [toggleBtn setBackgroundImage:[UIImage imageNamed:@"播放"] forState:UIControlStateSelected];
        [toggleBtn addTarget:self action:@selector(toggleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        toggleBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:toggleBtn];
        self.toggleBtn = toggleBtn;
        toggleBtn.enlargedEdge = 5.f;
        
        UIButton *fullScreenBtn = [[UIButton alloc] init];
        [fullScreenBtn setBackgroundImage:[UIImage imageNamed:@"全屏"] forState:UIControlStateNormal];
        fullScreenBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:fullScreenBtn];
        self.fullScreenBtn = fullScreenBtn;
        [fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
        fullScreenBtn.enlargedEdge = 5.f;
        
        UILabel *durationLabel = [[UILabel alloc] init];
        durationLabel.font = [UIFont systemFontOfSize:12];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = NSTextAlignmentCenter;
        durationLabel.text = @"00:00";
        [self addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        UISlider *slider = [[UISlider alloc] init];
        slider.userInteractionEnabled = YES;
        [slider setThumbImage:[UIImage imageNamed:@"播放滑块"] forState:UIControlStateNormal];
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.minimumTrackTintColor = [UIColor colorFromHexString:@"ff187a"];
        [self addSubview:slider];
        [slider addTarget:self action:@selector(sliderTracking:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderDidStartTracking:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpInside];
        self.slider = slider;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLabel.x = 8;
    self.progressLabel.y = 0;
    self.progressLabel.width = 35;
    self.progressLabel.height = self.height;

    self.toggleBtn.x = CGRectGetMaxX(self.progressLabel.frame) + 6;
    self.toggleBtn.y = 0;
    self.toggleBtn.width = 25;
    self.toggleBtn.height = self.height;
    
    CGFloat fullScreenW = 16.f;
    self.fullScreenBtn.y = (self.height - fullScreenW) / 2.f;
    self.fullScreenBtn.width = fullScreenW;
    self.fullScreenBtn.height = fullScreenW;
    self.fullScreenBtn.x = self.width - 8 - self.fullScreenBtn.width;

    self.durationLabel.width = 35;
    self.durationLabel.height = self.height;
    self.durationLabel.y = 0;
    self.durationLabel.x = CGRectGetMinX(self.fullScreenBtn.frame) - 10 - self.durationLabel.width;

    self.slider.x = CGRectGetMaxX(self.toggleBtn.frame) + 8;
    self.slider.height = 18;
    self.slider.y = (self.height - self.slider.height) / 2.f;
    self.slider.width = CGRectGetMinX(self.durationLabel.frame) - self.slider.x - 8;
}

- (void)fullScreenBtnClick {
    [self.delegate playControlWillPlayFullScreen:self];
}

- (void)sliderTracking:(UISlider *)slider {
//    NSLog(@"%@ %f", NSStringFromSelector(_cmd), slider.value);
    // 1. info view
    
    // 2. label text
    self.progress = slider.value;
    
    // 3. call delegate
    [self.delegate playControl:self scrubbedToTime:slider.value];
}

- (void)sliderDidStartTracking:(UISlider *)slider {
    [self.delegate playControlDidStartScrubbing:self];
}

- (void)sliderDidEndTracking:(UISlider *)slider {
    [self.delegate playControlDidEndScrubbing:self];
}

- (void)toggleBtnClicked {
    self.playing = !self.playing;
    self.toggleBtn.selected = !self.toggleBtn.selected;
    if (!self.delegate) return;
    if (self.toggleBtn.selected) {
        [self.delegate playControlDidBeginPlaying:self];
    } else {
        [self.delegate playControlDidPausePlaying:self];
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    self.durationLabel.text = [self formattingTimeInterval:duration];
    self.slider.maximumValue = duration;
}

- (void)setProgress:(NSTimeInterval)progress {
    self.progressLabel.text = [self formattingTimeInterval:progress];
    self.slider.value = progress;
}

- (NSString *)formattingTimeInterval:(NSTimeInterval)timeInterval {
    NSInteger minute = (NSInteger)timeInterval / 60;
    return [NSString stringWithFormat:@"%02ld:%02.f", minute, timeInterval - minute * 60];
}

- (void)complete {
    self.slider.value = 0.0f;
    self.toggleBtn.selected = NO;
}

- (void)pause {
    self.toggleBtn.selected = NO;
}

- (void)play {
    self.toggleBtn.selected = YES;
}
@end
