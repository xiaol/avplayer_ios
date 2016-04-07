//
//  LPEditViewController.m
//  iVideo
//
//  Created by apple on 16/2/16.
//  Copyright © 2016年 lvpin. All rights reserved.
//  资源数组与过渡数组不相关(因资源会被手动排序与删除)

#import "LPEditViewController.h"
#import "LPRangeSlider.h"
#import "LPMediaItemCell.h"
#import "LPLineLayout.h"
#import "LPVideoTransition.h"
#import "LPEditNotification.h"
#import "LPVideoLibraryViewController.h"
#import "LPTimeline.h"
#import "LPVideoItem.h"
#import "LPAudioItem.h"
#import "LPVideoTransition.h"
#import "LPLineTransitionDecoration.h"
#import "LPCompositionBuilder.h"
#import "LPPlaybackView.h"
#import "LPPlayController.h"
#import "LPPlayControl.h"
#import "Aspects.h"
#import "UICollectionView+Additions.h"
#import "LPMusicLibraryViewController.h"
#import "LPSubtitleViewController.h"
#import "LPFilterViewController.h"

static NSString *LPMediaItemCVReuseID = @"media.item.cv.reuse.id";

@interface LPEditViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, LPLineLayoutDelegate, LPLineLayoutDataSource, LPMediaItemCellDelegate, LPPlayControllerDelegate, LPPlayControlDelegate>

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) UIButton *outputBtn;
@property (nonatomic, strong) LPRangeSlider *clipSlider;
@property (nonatomic, strong) LPPlaybackView *playbackView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LPPlayControl *playControl;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

// play controller
@property (nonatomic, strong) LPPlayController *playController;

// models
@property (nonatomic, strong) LPTimeline *timeline;
@property (nonatomic, strong) NSMutableArray *transitions;
@property (nonatomic, assign) NSUInteger videoCount;

// processing
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, strong) NSIndexPath *processingIndexPath;
@property (nonatomic, assign) BOOL playingBeforeClipping;
@property (nonatomic, assign) BOOL playingBeforeAdding;
@property (nonatomic, assign) BOOL playingBeforeRemoving;
@property (nonatomic, assign) BOOL playingBeforeMoving;
@property (nonatomic, assign) BOOL playingBeforeTransitionChange;
@property (nonatomic, assign) NSUInteger fromMovingItem;
@property (nonatomic, assign) NSUInteger transitionItem;

@property (nonatomic, strong) LPComposition *composition;

@end

@implementation LPEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    NSArray *names = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
//    for (NSString *name in names) {
//        NSLog(@"滤波器名称 --- %@", name);
//        CIFilter *filter = [CIFilter filterWithName:name];
//        for (NSString *inputKey in filter.inputKeys) {
//            NSLog(@"参数:%@", inputKey);
//        }
//    }
    
    

    
    self.playController = [[LPPlayController alloc] init];
    self.playController.delegate = self;
    self.timeline = [[LPTimeline alloc] init];

    [self setupSubviews];
    [self toggleOffControl:self];
    
    [noteCenter addObserver:self selector:@selector(transitionTypeChanged:) name:LPTransitionTypeChangedNotification object:nil];
    
    [self hooks];
}

- (void)dealloc {
    [noteCenter removeObserver:self];
}

- (void)setupSubviews {
    [self setupHeader];
    [self setupPlaybackView];
    [self setupClipSlider];
    [self setupBgView];
    [self setupCollectionView];
    [self setupPlayControl];
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] init];
    header.x = 0;
    header.y = 0;
    header.width = self.view.width;
    header.height = 64;
    header.backgroundColor = [UIColor colorFromHexString:@"f7f7f8"];
    [self.view addSubview:header];
    self.header = header;
    
    NSInteger btnCount = 4;
    CGFloat btnY = 20.f;
    CGFloat padding = 10.f;
    CGFloat spacing = 10.f;
    CGFloat btnW = (self.view.width - padding * 2 - (btnCount - 1) * spacing) / btnCount;
    CGFloat btnH = header.height - btnY;
    NSArray *titles = @[@"主页", @"视频", @"音乐", @"输出"];
    NSMutableArray *btns = [NSMutableArray array];
    SEL sels[6] = {@selector(backBtnClicked), @selector(addBtnClicked), @selector(musicBtnClicked), @selector(outputBtnClicked)};
    for (NSInteger i = 0; i < btnCount; i++) {
        UIButton *btn = [self createTopButtonWithTitle:titles[i] titleColor:[UIColor colorFromHexString:@"3e4452"] font:[UIFont boldSystemFontOfSize:16] image:(i == 0 ? [UIImage imageNamed:@"返回"] : nil)];
        [btn addTarget:self action:sels[i] forControlEvents:UIControlEventTouchUpInside];
        btn.x = padding + i * (btnW + spacing);
        btn.y = btnY;
        btn.width = btnW;
        btn.height = btnH;
        [header addSubview:btn];
        [btns addObject:btn];
        if (i > 1 && i < btnCount) {
            btn.enabled = NO;
        }
        btn.toleranceEventInterval = .5f;
    }
    self.musicBtn = btns[2];
    self.outputBtn = btns[3];
    
    CGFloat dividerY = CGRectGetHeight(header.bounds) - 0.5f;
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, dividerY, self.view.width, 0.5f)];
    divider.backgroundColor = [UIColor colorFromHexString:@"adadad"];
    [header addSubview:divider];
}

- (UIButton *)createTopButtonWithTitle:(NSString *)title
                            titleColor:(UIColor *)titleColor
                                  font:(UIFont *)font
                                 image:(UIImage *)image {
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor colorFromHexString:@"b6b6b6"] forState:UIControlStateDisabled];
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btn.imageEdgeInsets = UIEdgeInsetsMake(13, 0, 13, 10);
    }
    return btn;
}

- (void)setupPlaybackView {
//    LPPlaybackView *playbackView = [[LPPlaybackView alloc] init];
    CGFloat padding = 0.f;
    if (iPhone6 || iPhone5) {
        padding = 29.f;
    } else if (iPhone6Plus) {
        padding = 46.f;
    }
    LPPlaybackView *playbackView = self.playController.view;
    playbackView.width = ScreenWidth;
    playbackView.height = PlaybackViewHeight;
    playbackView.x = 0;
    playbackView.y = CGRectGetMaxY(self.header.frame) + padding;
    [self.view addSubview:playbackView];
    self.playbackView = playbackView;
    
}

- (void)setupClipSlider {
    CGFloat padding = 29.f;
    if (iPhone6Plus) {
        padding = 46.f;
    } else if (iPhone4) {
        padding = 0.f;
    }
    CGFloat height = 60.f;
    if (iPhone4) {
        height = 45.f;
    }
    
    CGRect sliderF = CGRectMake(0, CGRectGetMaxY(self.playbackView.frame) + padding, self.view.width, height);
    LPRangeSlider *slider = [[LPRangeSlider alloc] initWithFrame:sliderF];
    slider.tolerance = 2.f;
    [slider addTarget:self action:@selector(clipSliderDidStartTracking:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(clipSliderTracking:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(clipSliderDidEndTracking:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:slider];
    self.clipSlider = slider;
}

- (void)setupBgView {
    UIView *bg = [[UIView alloc] init];
    bg.x = 0;
    bg.y = CGRectGetMaxY(self.clipSlider.frame);
    bg.width = self.view.width;
    bg.height = self.view.height - bg.y;
    bg.backgroundColor = [UIColor colorFromHexString:@"3e4452"];
    [self.view addSubview:bg];
    self.bgView = bg;
}

- (void)setupCollectionView {
    LPLineLayout *layout = [[LPLineLayout alloc] init];
    
    CGFloat spacing = 10.f;
    CGFloat sectionInset = 15.f;
    CGFloat itemW = 100.f;
    if (iPhone6Plus) {
        itemW = 120.f;
    } else if (iPhone5) {
        itemW = 90.f;
    } else if (iPhone4) {
        itemW = 65.f;
    }
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(0, sectionInset, 0, sectionInset);
    layout.itemSize = CGSizeMake(itemW, itemW);
    
    CGFloat padding = 40.f;
    if (iPhone5) {
        padding = 23.f;
    } else if (iPhone6Plus) {
        padding = 33.f;
    } else if (iPhone4) {
        padding = 13.f;
    }
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, padding, self.view.bounds.size.width, itemW) collectionViewLayout:layout];
    [cv registerClass:[LPMediaItemCell class] forCellWithReuseIdentifier:LPMediaItemCVReuseID];
    cv.dataSource = self;
    cv.delegate = self;
    cv.showsHorizontalScrollIndicator = NO;
    cv.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:cv];
    self.collectionView = cv;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = cv.center;
    [cv addSubview:indicator];
    self.indicator = indicator;
}

- (void)setupPlayControl {
    CGFloat y = CGRectGetMaxY(self.collectionView.frame);
    CGFloat h = self.bgView.height - y;
    LPPlayControl *playControl = [[LPPlayControl alloc] initWithFrame:CGRectMake(0.f, y, self.bgView.width, h)];
    [self.bgView addSubview:playControl];
    playControl.delegate = self;
    self.playControl = playControl;
}

#pragma mark - hooks into ADD, REMOVE and EXCHANGE
- (void)hooks {
    // ** 任何用户操作(增删移)均需更新playItem **
    void (^block)(id<AspectInfo> obj) = ^(id<AspectInfo> obj) {
        self.composition = [self currentComposition];
        self.playControl.duration = CMTimeGetSeconds([_composition duration]);
        __weak typeof(self) wself = self;
        [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
            if (completed) {
                [wself toggleOnControl:wself];
            }
        }];
    };
#pragma mark - 1. ADD HOOK
    __block BOOL initialize = NO;
    __block NSTimeInterval playingTimeBeforeAdding = 0;
    // 1.1 在添加按钮点击时加入前置hook, 1记录添加前有无视频资源以及是否正在播放, 如正在播放则暂停播放, 2记录先前播放位置
    [self aspect_hookSelector:@selector(addBtnClicked)
                  withOptions:AspectPositionBefore
                   usingBlock:^(id<AspectInfo> obj) {
                       [self toggleOffControl:self];
                       initialize = (self.timeline.videos.count == 0);
                       if (initialize) {
                           [self.indicator startAnimating];
                       }
                       if (!initialize && self.playController.playing) { // 如添加视频前正在播放
                           self.playingBeforeAdding = YES;
                           [self.playController pause];
                           [self.playControl pause];
                       } else {
                           self.playingBeforeAdding = NO;
                       }
                       playingTimeBeforeAdding = self.currentTime;
                   } error:NULL];
    
    // 1.2 在添加视频数组时加入后置hook, 完成必要工作(更新playerItem然后load)后: 1跳转播放至之前记录时刻, 2如之前播放则继续播放, 3校正cell位置
    [self.timeline aspect_hookSelector:@selector(addVideos:)
                           withOptions:0
                            usingBlock:^(id<AspectInfo> obj) {
                                self.composition = [self currentComposition];
                                self.playControl.duration = CMTimeGetSeconds([_composition duration]);
                                __weak typeof(self) wself = self;
                                if (initialize) { // 添加前无视频
                                    self.processingIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                                    [self.playbackView prepareForPlaying];
                                }
                                [self.collectionView reloadData];
                                
                                [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
                                    if (completed) {
                                        [wself.indicator stopAnimating];
                                        if (initialize) {
                                            [wself.playbackView startPlaying];
                                        }
                                        [wself.playController jumpedToTime:playingTimeBeforeAdding];
                                        if (wself.playingBeforeAdding) { // 添加前正在播放
                                            [wself.collectionView scrollToItemAtIndexPath:wself.processingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                                            [wself.playController play];
                                            [wself.playControl play];
                                        }
                                        [wself toggleOnControl:wself];
                                    }
                                }];
                            } error:NULL];
    
    
#pragma mark - 2. REMOVE HOOK
    // 2.1 删除前检查是否播放
    __block NSUInteger removedItem = 0;
    __block NSTimeInterval playingTimeAfterRemoving = 0;
    [self.timeline aspect_hookSelector:@selector(removeVideoAtIndex:)
                           withOptions:AspectPositionBefore
                            usingBlock:^(id<AspectInfo> obj) {
                                [self toggleOffControl:self];
                                removedItem = self.processingIndexPath.item;
                                if (self.timeline.videos.count > 1 && self.playController.playing) {
                                    self.playingBeforeRemoving = YES;
                                } else {
                                    self.playingBeforeRemoving = NO;
                                }
                                [self.playController pause];
                            } error:NULL];
    
    // 2.2 在删除视频时加入后置hook, 完成必要工作后: 1选中ip移动 2跳转播放至下一个cell的开头(如被删除的是最后一个, 则跳转到上一个开头) 3 slider.progress和duration改变 4是否继续播放
    [self.timeline aspect_hookSelector:@selector(removeVideoAtIndex:)
                           withOptions:0
                            usingBlock:^(id<AspectInfo> obj) {
                                if (self.timeline.videos.count == 0) { // 数组被清空
                                    self.musicBtn.enabled = self.outputBtn.enabled = NO;
                                    self.processingIndexPath = nil;
                                    self.currentTime = 0;
                                    self.playControl.duration = 0;
                                    self.playControl.progress = 0;
                                    [self.playControl pause];
                                    [self.playController loadPlayerItem:nil completion:nil];
                                } else {
                                    self.composition = [self currentComposition];
                                    self.playControl.duration = CMTimeGetSeconds([_composition duration]);
                                    NSUInteger currentItem = MIN(self.timeline.videos.count - 1, removedItem);
                                    self.processingIndexPath = [NSIndexPath indexPathForItem:currentItem inSection:0];
                                    __weak typeof(self) wself = self;
                                    [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
                                        if (completed) {
                                            // 播放跳转 (注意更新self.currentTime)
                                            playingTimeAfterRemoving = CMTimeGetSeconds([wself.timeline.passThroughRanges[currentItem] CMTimeRangeValue].start);
                                            wself.currentTime = playingTimeAfterRemoving;
                                            [wself.playController jumpedToTime:playingTimeAfterRemoving];
                                            wself.playControl.progress = playingTimeAfterRemoving;
                                            if (self.playingBeforeRemoving) {
                                                [wself.playController play];
                                            }
                                            [wself toggleOnControl:wself];
                                        }
                                    }];
                                }
                            } error:NULL];
    
#pragma mark - 3. EXCHANGE HOOK
    [self aspect_hookSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)
                  withOptions:AspectPositionBefore
                   usingBlock:^(id<AspectInfo> obj) {
                       [self toggleOffControl:self];
                       self.playingBeforeMoving = self.playController.playing;
                       [self.playController pause];
                       [self.playControl pause];
                   } error:NULL];
    [self aspect_hookSelector:@selector(updateCurrentTimeWithIncrement:)
                  withOptions:0
                   usingBlock:^(id<AspectInfo> obj) {
                       self.composition = [self currentComposition];
                       __weak typeof(self) wself = self;
                       [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
                           if (completed) {
                               [wself.playController jumpedToTime:wself.currentTime];
                               wself.playControl.progress = wself.currentTime;
                               if (wself.playingBeforeMoving) {
                                   [wself.collectionView scrollToItemAtIndexPath:wself.processingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                                   [wself.playController play];
                                   [wself.playControl play];
                               }
                               [wself toggleOnControl:wself];
                           }
                       }];
                   } error:NULL];

#pragma mark - 4. TRANSITION HOOK

    // 改变过渡效果
    [self aspect_hookSelector:@selector(transitionTypeChanged:)
                  withOptions:AspectPositionBefore
                   usingBlock:^(id<AspectInfo> obj) {
                       self.playingBeforeTransitionChange = self.playController.playing;
                       [self toggleOffControl:self];
                       [self.playController pause];
                   }
                        error:NULL];
    [self aspect_hookSelector:@selector(transitionTypeChanged:)
                  withOptions:0
                   usingBlock:^(id<AspectInfo> obj) {
                       self.composition = [self currentComposition];
                       __weak typeof(self) wself = self;
                       NSTimeInterval currentTime = CMTimeGetSeconds(CMTimeRangeGetEnd([self.timeline.passThroughRanges[self.transitionItem] CMTimeRangeValue])) - 0.6f;
                       self.processingIndexPath = [NSIndexPath indexPathForItem:self.transitionItem inSection:0];
                       self.currentTime = currentTime;
                       self.playControl.duration = CMTimeGetSeconds([_composition duration]);
                       self.playControl.progress = currentTime;
                       [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
                           if (completed) {
                               [wself.playController jumpedToTime:currentTime];

                               if (wself.playingBeforeTransitionChange) {
                                   [wself.collectionView scrollToItemAtIndexPath:wself.processingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                                   [wself.playController play];
                                   [wself.playControl play];
                               }
                               [wself toggleOnControl:wself];
                           }
                       }];
                   } error:NULL];
}

#pragma mark - clipping
- (void)clipSliderDidStartTracking:(LPRangeSlider *)slider {
    // 1. 记录剪辑前是否处于播放态
    self.playingBeforeClipping = self.playController.playing;
    
    // 2. 更新播放控制器的状态(正在处理剪辑)
    self.playController.ignoreTimeObserving = YES;
    
    // 3. 暂停slider
    [self.playControl pause];
    
    // 4. 更新player的playerItem为当前asset
    NSUInteger item = self.processingIndexPath.item;
    LPVideoItem *video = self.timeline.videos[item];
    NSValue *startValue = self.timeline.passThroughRanges[item];
    if (item > 0) {
        startValue = self.timeline.transitionRanges[item - 1];
    }
    NSTimeInterval sliderProgressStart = CMTimeGetSeconds([startValue CMTimeRangeValue].start);
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:video.asset];
    [self toggleOffControl:self];
    __weak typeof(self) wself = self;
    [self.playController loadPlayerItem:playerItem completion:^(BOOL completed) {
        // 4.1 player跳转到当前按下时刻
        if (slider.highlightedKnob == LPRangeSliderHighlightedLowerKnob) {
            [wself.playController jumpedToTime:CMTimeGetSeconds(video.trimmedTimeRange.start)];
        } else {
            [wself.playController jumpedToTime:CMTimeGetSeconds(CMTimeRangeGetEnd(video.trimmedTimeRange))];
        }
        wself.playControl.progress = sliderProgressStart;
        [wself toggleOnControl:wself];
    }];
}

- (void)clipSliderTracking:(LPRangeSlider *)slider {
    // 1. 跳转播放控制器
    [self.playController scrubbedToTime:slider.touchValue];
    
    // 2. 显示器展示当前时刻
    if (slider.beyondTolerance) {
        self.playbackView.text = @"不能少于2秒";
    } else {
        self.playbackView.text = [NSString stringWithFormat:@"%.1fs", slider.touchValue];
    }
    
    // 3. 更新总体slider的显示 (两端的拖动实际是对应两个transition区域的拖动, 改变的只是pass区域的duration, 以及之后各区域的start)
    NSUInteger item = self.processingIndexPath.item;
    NSTimeInterval newVideoDuration =  slider.upperValue - slider.lowerValue;
    LPVideoItem *video = self.timeline.videos[item];
    self.playControl.duration = CMTimeGetSeconds(self.timeline.duration) + newVideoDuration - CMTimeGetSeconds(video.trimmedTimeRange.duration);
}

- (void)clipSliderDidEndTracking:(LPRangeSlider *)slider {
    NSUInteger item = self.processingIndexPath.item;
    [self.playbackView hideTime];
    LPVideoItem *video = self.timeline.videos[item];
    // 1. 更新video的trimmedRange
    CMTime start = CMTimeMakeWithSeconds(slider.lowerValue, NSEC_PER_SEC);
    CMTime duration = CMTimeMakeWithSeconds(slider.upperValue - slider.lowerValue, NSEC_PER_SEC);
    video.trimmedTimeRange = CMTimeRangeMake(start, duration);
    // 2. 更新timeline的ranges数组
    [self.timeline updateRangesWithVideoDuration:video.trimmedTimeRange.duration atIndex:item];
    // 3. 更新thumbnail
    [video updateThumbnail];
    // 4. 生成新的组合, 更新player的playerItem为新组合
    [self toggleOffControl:self];
    self.composition = [self currentComposition];
    self.playController.ignoreTimeObserving = NO;
    __weak typeof(self) wself = self;
    NSValue *startValue = self.timeline.passThroughRanges[item];
//    if (item > 0) {
//        startValue = self.timeline.transitionRanges[item - 1];
//    }
    NSTimeInterval passStart = CMTimeGetSeconds([startValue CMTimeRangeValue].start);
    [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
        if (completed) {
            // 3.1 跳转到开头
            wself.playControl.progress = passStart;
            [wself.playController jumpedToTime:passStart];
//            // 3.2 刷新cv
            [wself.collectionView reloadData];
            // 3.3 检查是否继续播放
            if (wself.playingBeforeClipping) {
                [wself.playControl play];
                [wself.playController play];
            }
            // 3.4 打开用户开关
            [wself toggleOnControl:wself];
        }
    }];
}

#pragma mark - update processing video/cell

// 用户点击cell, 或播放/拖拽到cell时调用
- (void)setProcessingIndexPath:(NSIndexPath *)processingIndexPath {
    
    NSUInteger item = processingIndexPath.item;
    
    LPMediaItemCell *processingCell = (LPMediaItemCell *)[self.collectionView cellForItemAtIndexPath:processingIndexPath];
    if (_processingIndexPath && _processingIndexPath.item == processingIndexPath.item && !processingCell.selected) return;
    
    _processingIndexPath = processingIndexPath;

    // 1. 更新clipSlider的边界值和最值
    LPVideoItem *video = self.timeline.videos[item];
    self.clipSlider.maximumValue = CMTimeGetSeconds(video.asset.duration);
    self.clipSlider.lowerValue = CMTimeGetSeconds(video.trimmedTimeRange.start);
    self.clipSlider.upperValue = CMTimeGetSeconds(CMTimeRangeGetEnd(video.trimmedTimeRange));
    
    // 2. reload cv 更新cell视图选中状态
    [self.collectionView reloadData];
    
    // 3. cv滚动到合适位置
    if (!processingCell.selected) { // 播放中自行选中 或 拖拽slider自行选中
        // 调整contentOffset
//        NSUInteger item = processingIndexPath.item;
//        CGFloat offsetX = (item == 0) ? 0.f : ((ItemWidth + ItemSpacing) * item + SectionInset);
//        [self.collectionView setContentOffsetX:offsetX animated:YES];
        [self.collectionView scrollToItemAtIndexPath:processingIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    } else { // 手动选中
        // 调整越界情况时的contentOffset
        CGFloat leftPadding = 6;
        CGFloat rightPadding = 6;
        if (item == 0) {
            leftPadding = 8;
        } else if (item == self.timeline.videos.count - 1) {
            rightPadding = 8;
        }
        CGRect frame = CGRectMake(processingCell.x - leftPadding, processingCell.y, processingCell.width + leftPadding + rightPadding, processingCell.height);
        [self.collectionView adjustOutsideCellFrame:frame animated:YES];
    }
}

#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.timeline.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LPMediaItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LPMediaItemCVReuseID
                                                                      forIndexPath:indexPath];
    cell.delegate = self;
    LPVideoItem *video = self.timeline.videos[indexPath.item];
    cell.thumbnail = video.thumbnail;
    cell.text = [NSString stringWithFormat:@"%.1fs", CMTimeGetSeconds(video.trimmedTimeRange.duration)];
    if (self.processingIndexPath && indexPath.item == self.processingIndexPath.item) {
        cell.processing = YES;
    } else {
        cell.processing = NO;
    }
    
    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 选中一个cell时, 暂停播放
    [self.playController pause];
    [self.playControl pause];
    CMTimeRange range = [self.timeline.passThroughRanges[indexPath.item] CMTimeRangeValue];
    [self.playController jumpedToTime:CMTimeGetSeconds(range.start)];
    self.playControl.progress = CMTimeGetSeconds(range.start);
    self.processingIndexPath = indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - collection view layout delegate
- (LPVideoTransitionType)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)layout
              transitionTypeAtIndexPath:(NSIndexPath *)indexPath {
    LPVideoTransition *trans = self.timeline.transitions[indexPath.item];
    return trans.type;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    self.fromMovingItem = indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSLog(@"%ld will --> %ld", fromIndexPath.item, toIndexPath.item);
//    [self.timeline exchangeVideoAtIndex:fromIndexPath.item withVideoAtIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//    NSLog(@"%ld did --> %ld", fromIndexPath.item, toIndexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger toMovingItem = indexPath.item;
    if (self.fromMovingItem == toMovingItem) {
        [self toggleOnControl:self];
        return;
    }
    [self.timeline moveVideoAtIndex:self.fromMovingItem toIndex:indexPath.item];

    NSUInteger processingItem = self.processingIndexPath.item;
    // 随着选中cell的移动, currentTime随之改变, 播放器跳转至currentTime
    NSTimeInterval increment = 0;
    if (self.fromMovingItem == processingItem) { // 拖动选中的cell,
        self.processingIndexPath = indexPath;
        if (self.fromMovingItem < toMovingItem) {
            for (NSInteger i = self.fromMovingItem + 1; i <= toMovingItem; i ++) {
                CMTimeRange pr = [self.timeline.passThroughRanges[i - 1] CMTimeRangeValue];
                CMTimeRange tr = [self.timeline.transitionRanges[i - 1] CMTimeRangeValue];
                increment += CMTimeGetSeconds(CMTimeAdd(pr.duration, tr.duration));
            }
        } else {
            for (NSInteger i = toMovingItem; i < self.fromMovingItem; i ++) {
                CMTimeRange pr = [self.timeline.passThroughRanges[i + 1] CMTimeRangeValue];
                CMTimeRange tr = [self.timeline.transitionRanges[i] CMTimeRangeValue];
                increment -= CMTimeGetSeconds(CMTimeAdd(pr.duration, tr.duration));
            }
        }
    } else if (self.fromMovingItem < toMovingItem
               && processingItem > self.fromMovingItem && processingItem <= toMovingItem) { // 选中ip位于移动区间
        self.processingIndexPath = [NSIndexPath indexPathForItem:self.processingIndexPath.item - 1 inSection:0];
        CMTimeRange fromPassRange = [self.timeline.passThroughRanges[toMovingItem] CMTimeRangeValue];
        CMTimeRange previousTransitionRange = kCMTimeRangeZero;
        if (self.processingIndexPath.item > 0) {
            previousTransitionRange = [self.timeline.transitionRanges[self.processingIndexPath.item - 1] CMTimeRangeValue];
        }
        increment = - CMTimeGetSeconds(CMTimeAdd(fromPassRange.duration, previousTransitionRange.duration));
    } else if (self.fromMovingItem > toMovingItem
               && processingItem < self.fromMovingItem && processingItem >= toMovingItem) { // 选中ip位于移动区间
        self.processingIndexPath = [NSIndexPath indexPathForItem:self.processingIndexPath.item + 1 inSection:0];
        CMTimeRange fromPassRange = [self.timeline.passThroughRanges[toMovingItem] CMTimeRangeValue];
        CMTimeRange processingTransitionRange = [self.timeline.transitionRanges[self.processingIndexPath.item] CMTimeRangeValue];
        increment = CMTimeGetSeconds(CMTimeAdd(fromPassRange.duration, processingTransitionRange.duration));
    } else {
        [self.collectionView reloadData];
    }
    [self updateCurrentTimeWithIncrement:increment];
}

- (void)updateCurrentTimeWithIncrement:(NSTimeInterval)increment {
//    NSLog(@"%.1f --- %.1f", self.currentTime, self.currentTime + increment);
    self.currentTime += increment;
}

#pragma mark - media item cell delegate
- (void)mediaItemCellDidClickDeleteButton:(LPMediaItemCell *)mediaItemCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:mediaItemCell];
    [self.timeline removeVideoAtIndex:indexPath.item];
    // cv layout bug
    LPVideoTransition *trans = [LPVideoTransition videoTransition];
    BOOL noneTrans = YES;
    if (self.timeline.transitions.count > 1) {
        trans = self.timeline.transitions[0];
        noneTrans = NO;
    }
    NSDictionary *info = @{LPDeleteIndexPathKey : indexPath,
                           LPDeleteFirstTypeKey : @(trans.type),
                           LPDeleteNoneTransitionKey : @(noneTrans)};
    [noteCenter postNotificationName:LPDeleteItemNotification object:nil userInfo:info];
    LPLineLayout *layout = (LPLineLayout *)self.collectionView.collectionViewLayout;
    [layout invalidateLayout]; // reload layout
    [self.collectionView reloadData];
}

#pragma mark - NOTE: transition type changed & video count changed
- (void)transitionTypeChanged:(NSNotification *)note {
    NSDictionary *info = note.userInfo;
    NSUInteger item = [info[LPTransitionItemKey] unsignedIntegerValue];
    self.transitionItem = item;
    [self.timeline changeTransitionTypeAtIndex:item];
    
    LPLineLayout *layout = (LPLineLayout *)self.collectionView.collectionViewLayout;
    [layout invalidateLayout]; // reload layout
}

#pragma mark - pop vc
- (void)backBtnClicked {
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - add videos & default transitions
- (void)addBtnClicked {
    LPVideoLibraryViewController *vl = [[LPVideoLibraryViewController alloc] init];
    [vl videosSelectedCompletion:^(NSArray *videoItems) {
        if (!videoItems) {
            if (self.timeline.videos.count > 0) {
                [self toggleOnControl:self];
            }
            [self.indicator stopAnimating];
        } else {
            __block NSInteger count = 0;
            [self.indicator stopAnimating];
            for (LPVideoItem *video in videoItems) {
                [video prepareWithCompletion:^(BOOL completed) {
                    count = count + 1;
                    if (count == videoItems.count) {
                        dispatch_async(MAIN_QUEUE, ^{
                            [self.timeline addVideos:videoItems];
                            self.musicBtn.enabled = self.outputBtn.enabled = YES;
                        });
                    }
                }];
            }
        }
     }];
    [self presentViewController:vl animated:YES completion:^{
        
    }];
}

#pragma mark - current composition
- (LPComposition *)currentComposition {
    return [LPCompositionBuilder buildCompositionWithTimeline:self.timeline];
}

#pragma mark - play control delegate 
- (void)playControlDidBeginPlaying:(LPPlayControl *)playControl {
    [self.collectionView scrollToItemAtIndexPath:self.processingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.playController play];
}

- (void)playControlDidPausePlaying:(LPPlayControl *)playControl {
    [self.playController pause];
}

- (void)playControlDidStartScrubbing:(LPPlayControl *)playControl {
    [self.playController scrubbingDidStart];
}

- (void)playControlDidEndScrubbing:(LPPlayControl *)playControl {
    [self.playController scrubbingDidEnd];
}

- (void)playControl:(LPPlayControl *)playControl scrubbedToTime:(NSTimeInterval)time {
    [self.playController scrubbedToTime:time];
    
    // 滚动cv, 更新选中的cell
    for (NSUInteger i = 0; i < self.timeline.passThroughRanges.count; i++) {
        CMTimeRange passRange = [self.timeline.passThroughRanges[i] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(passRange, CMTimeMakeWithSeconds(time, NSEC_PER_SEC))) {
            self.processingIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            break;
        }
    }
}

#pragma mark - play controller delegate
- (void)playController:(LPPlayController *)playController currentPlayingTime:(NSTimeInterval)currentPlayingTime duration:(NSTimeInterval)duration {
    self.currentTime = currentPlayingTime;
    self.playControl.progress = currentPlayingTime;
    self.playControl.duration = duration;
    // 滚动cv, 更新选中的cell
    for (NSUInteger i = 0; i < self.timeline.passThroughRanges.count; i++) {
        CMTimeRange passRange = [self.timeline.passThroughRanges[i] CMTimeRangeValue];
        CMTimeRange unionRange = passRange;
        if (i > 0) {
            CMTimeRange transitionRange = [self.timeline.transitionRanges[i - 1] CMTimeRangeValue];
            unionRange = CMTimeRangeGetUnion(transitionRange, passRange);
        }
        CMTime currentTime = CMTimeMakeWithSeconds(currentPlayingTime, NSEC_PER_SEC);
        if (CMTimeRangeContainsTime(passRange, currentTime)) {
            self.processingIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            break;
        }
    }
    // 滚动刻度光标
}

- (void)playControllerDidCompletePlaying:(LPPlayController *)playController {
    [self.playControl complete];
    self.processingIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
}

#pragma mark - play control & clip slider toggle
- (void)toggleOnControl:(id)target {
    [target playControl].userInteractionEnabled = [target clipSlider].userInteractionEnabled = YES;
}

- (void)toggleOffControl:(id)target {
    [target playControl].userInteractionEnabled = [target clipSlider].userInteractionEnabled = NO;
}

#pragma mark - add music
- (void)musicBtnClicked {
    [self.playController pause];
    [self.playControl pause];
    LPMusicLibraryViewController *musicVc = [[LPMusicLibraryViewController alloc] init];
    
    [musicVc musicSelectCompletion:^(LPAudioItem *music) {
        if (music) {
            [self toggleOffControl:self];
            self.timeline.musics = [NSMutableArray arrayWithArray:@[music]];
            [self.playController stop];
            self.composition = [self currentComposition];
            [self.playbackView prepareForPlaying];
            __weak typeof(self) wself = self;
            [self.playController loadPlayerItem:[_composition makePlayerItem] completion:^(BOOL completed) {
                if (completed) {
                    [self.playbackView startPlaying];
                    
                    [self.playController play];
                    [self.playControl play];
                    
                    [wself toggleOnControl:wself];
                }
            }];
        }
    }];
    
    [self presentViewController:musicVc animated:YES completion:^{
        
    }];
}

#pragma mark - add subtitle
- (void)subtitleBtnClicked {
    LPSubtitleViewController *subtitleVc = [[LPSubtitleViewController alloc] init];
    subtitleVc.videos = self.timeline.videos;
    [self presentViewController:subtitleVc animated:YES completion:^{
        
    }];
}

#pragma mark - export composition
- (void)outputBtnClicked {
    [self.playController pause];
    [self.playControl pause];
    
    LPFilterViewController *filterVc = [[LPFilterViewController alloc] init];
    filterVc.composition = self.composition;
    LPVideoItem *video = self.timeline.videos[0];
    filterVc.thumbnail = [CIImage imageWithCGImage:video.thumbnail.CGImage];
    filterVc.asset = video.asset;
    [self.navigationController pushViewController:filterVc animated:YES];
}
@end
