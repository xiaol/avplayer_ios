//
//  LPSubtitleViewController.m
//  iVideo
//
//  Created by apple on 16/3/20.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPSubtitleViewController.h"
#import "LPPlayController.h"
#import "LPCoverLayout.h"
#import "LPVideoSegmentCell.h"
#import "LPVideoItem.h"
#import "LPPlaybackView.h"

static NSString *LPVideoSegmentCellReuseID = @"video.segment.cell.reuse.id";

@interface LPSubtitleViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LPPlayControllerDelegate>

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) LPPlayController *playController;
@property (nonatomic, strong) LPPlaybackView *playbackView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger playingItem;
@end

@implementation LPSubtitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.playController = [[LPPlayController alloc] init];
    self.playController.delegate = self;
    
    [self setupSubviews];
    
    [self prepareToPlayVideoItem:0];
}

- (void)setupSubviews {
    [self setupHeader];
    [self setupCollectionView];
    [self setupSubtitleView];
    [self setupSlider];
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] init];
    header.x = 0;
    header.y = 0;
    header.width = self.view.width;
    header.height = 64.f;
    [self.view addSubview:header];
    self.header = header;
    header.backgroundColor = [UIColor colorFromHexString:@"f7f7f8"];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = 0;
    label.y = 20;
    label.width = header.width;
    label.height = 44;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = @"添加字幕";
    label.textColor = [UIColor colorFromHexString:@"0b0b0b"];
    label.backgroundColor = [UIColor clearColor];
    [header addSubview:label];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.x = 0;
    cancelBtn.y = 20.f;
    cancelBtn.height = 44;
    cancelBtn.width = 60;
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorFromHexString:@"8c97ff"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [header addSubview:cancelBtn];
    
    UIButton *confirmBtn = [[UIButton alloc] init];
    confirmBtn.x = header.width - 60;
    confirmBtn.y = 20.f;
    confirmBtn.height = 44;
    confirmBtn.width = 60;
    [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor colorFromHexString:@"8c97ff"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [header addSubview:confirmBtn];
//    confirmBtn.hidden = YES;
    self.confirmBtn = confirmBtn;
    
    UIView *divider = [[UIView alloc] init];
    divider.x = 0;
    divider.height = .5f;
    divider.width = self.view.width;
    divider.y = CGRectGetHeight(header.frame) - .5f;
    [header addSubview:divider];
    divider.backgroundColor = [UIColor colorFromHexString:@"adadad"];
}

- (void)setupSubtitleView {
    
}

- (void)setupSlider {
    
}

- (void)setupCollectionView {
    LPCoverLayout *layout = [[LPCoverLayout alloc] init];
    layout.minimumInteritemSpacing = 0.f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat w = self.view.width * 0.7;
    CGFloat h = floor(w * ScreenWidth / ScreenHeight);
    layout.itemSize = CGSizeMake(w, h);
    CGFloat padding = (self.view.width - w) / 2;
    layout.sectionInset = UIEdgeInsetsMake(0, padding, 0, padding);

    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.header.frame), self.view.width, h * 1.5) collectionViewLayout:layout];
    [cv registerClass:[LPVideoSegmentCell class] forCellWithReuseIdentifier:LPVideoSegmentCellReuseID];
    cv.dataSource = self;
    cv.delegate = self;
    cv.showsHorizontalScrollIndicator = NO;
    cv.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cv];
    self.collectionView = cv;
    cv.scrollEnabled = NO;
    
    LPPlaybackView *playback = self.playController.view;
//    playback.backgroundColor = [UIColor greenColor];
    playback.x = padding;
    playback.y = (cv.height - h) / 2 + cv.y;
    playback.size = layout.itemSize;
    playback.transform = CGAffineTransformMakeScale(1 + layout.scaleFactor, 1 + layout.scaleFactor);
    self.playController.view = playback;
    [self.view addSubview:playback];
    self.playbackView = playback;
    [self.view bringSubviewToFront:playback];
}

- (void)cancelBtnClick:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)confirmBtnClick:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    
}

#pragma mark - prepare to play
- (void)prepareToPlayVideoItem:(NSInteger)item {
    self.playingItem = item;
    LPVideoItem *video = self.videos[item];
    __weak typeof(self) wself = self;
    [self.playController loadPlayerItem:[AVPlayerItem playerItemWithAsset:video.asset] completion:^(BOOL completed) {
        if (completed) {
//            [wself.playController jumpedToTime:CMTimeGetSeconds(video.passThroughRange.start)];
            [wself.playController play];
        }
    }];
}

#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LPVideoSegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LPVideoSegmentCellReuseID forIndexPath:indexPath];
    LPVideoItem *video = self.videos[indexPath.item];
    cell.image = video.thumbnail;
    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.playbackView.hidden = YES;
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self prepareToPlayVideoItem:indexPath.item];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self showPlaybackView];
}

- (void)showPlaybackView {
    self.playbackView.hidden = NO;
}

#pragma mark - play controller delegate
- (void)playController:(LPPlayController *)playController currentPlayingTime:(NSTimeInterval)currentPlayingTime duration:(NSTimeInterval)duration {
    LPVideoItem *video = self.videos[self.playingItem];
    if (currentPlayingTime >= CMTimeGetSeconds(CMTimeRangeGetEnd(video.passThroughRange))) {
        [self.playController pause];
        [self.playController jumpedToTime:CMTimeGetSeconds(video.passThroughRange.start)];
    }
}
@end
