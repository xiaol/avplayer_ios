//
//  LPMusicLibraryViewController.m
//  iVideo
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMusicLibraryViewController.h"
#import "LPTabBar.h"
#import "LPAudioItem.h"
#import "LPPlayController.h"
#import "LPPlayableRangeSlider.h"

@interface LPMusicLibraryViewController () <LPTabBarDelegate, UITableViewDataSource, UITableViewDelegate, LPPlayControllerDelegate>

@property (nonatomic, strong) LPAudioItem *selectedMusic;

@property (nonatomic, strong) NSArray *tabTitles;
@property (nonatomic, assign) NSInteger selectedItem;

@property (nonatomic, strong) LPTabBar *tabBar;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *songs;
@property (nonatomic, strong) NSMutableArray *artistCollections;
@property (nonatomic, strong) NSMutableArray *genreCollections;

@property (nonatomic, strong) NSMutableArray *localMusics;
@property (nonatomic, strong) NSMutableArray *offsets;

@property (nonatomic, strong) LPPlayController *playController;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) UILabel *lowerLabel;
@property (nonatomic, strong) UILabel *upperLabel;
@property (nonatomic, strong) LPPlayableRangeSlider *slider;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *importBtn;
@property (nonatomic, strong) UILabel *songLabel;
@property (nonatomic, assign) BOOL playingBeforeClipping;

@property (nonatomic, copy) LPMusicSelectCompletionHandler completionHandler;

@property (nonatomic, assign) BOOL firstTimePlaying;
@end

@implementation LPMusicLibraryViewController

- (NSMutableArray *)songs {
    if (_songs == nil) {
        _songs = [NSMutableArray array];
    }
    return _songs;
}

- (NSMutableArray *)artistCollections {
    if (_artistCollections == nil) {
        _artistCollections = [NSMutableArray array];
    }
    return _artistCollections;
}

- (NSMutableArray *)genreCollections {
    if (_genreCollections == nil) {
        _genreCollections = [NSMutableArray array];
    }
    return _genreCollections;
}

- (NSMutableArray *)offsets {
    if (_offsets == nil) {
        _offsets = [NSMutableArray array];
        for (NSInteger i = 0; i < self.tabTitles.count; i ++) {
            [_offsets addObject:[NSValue valueWithCGPoint:CGPointZero]];
        }
    }
    return _offsets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabTitles = @[@"歌曲", @"歌手", @"风格", @"默认"];
    
    self.playController = [[LPPlayController alloc] init];
    self.playController.delegate = self;
    
    [self setupSubviews];
    [self loadMusic];
    
    _firstTimePlaying = YES;
}

- (void)loadMusic {
    NSMutableArray *musics = [NSMutableArray array];
    for (NSInteger i = 0; i < 6; i ++) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"0%ld", i + 1] withExtension:@"mp3"];
        LPAudioItem *music = [[LPAudioItem alloc] initWithURL:url];
//        music.filename = [NSString stringWithFormat:@"%ld", i + 1];
        [musics addObject:music];
    }
    self.localMusics = musics;
    
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
    
    self.songs = [songsQuery items].mutableCopy;
    self.artistCollections = [artistsQuery collections].mutableCopy;
    self.genreCollections = [genresQuery collections].mutableCopy;
        
    [self.tableView reloadData];
}

- (void)musicSelectCompletion:(LPMusicSelectCompletionHandler)completion {
    self.completionHandler = completion;
}

- (void)setupSubviews {
    [self setupHeader];
    [self setupTabBar];
    [self setupPlayView];
    [self setupTableView];
}

- (void)setupTabBar {
    LPTabBar *bar = [[LPTabBar alloc] init];
    bar.x = 0;
    bar.width = self.view.width;
    bar.height = 50;
    bar.y = self.view.height - 50;
    
    for (NSInteger i = 0; i < 4; i ++) {
        [bar addTabBarButtonWithTitle:self.tabTitles[i]];
    }
    bar.delegate = self;
    [self.view addSubview:bar];
    self.tabBar = bar;
}

- (void)setupPlayView {
    UIView *playView = [[UIView alloc] init];
    playView.x = 0;
    playView.width = self.view.width;
    playView.height = self.view.height * .2f;
    playView.y = self.header.height;
    playView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:playView belowSubview:self.header];
    self.playView = playView;
    
    UIButton *playBtn = [[UIButton alloc] init];
    playBtn.x = 0;
    playBtn.y = 0;
    playBtn.width = 60;
    playBtn.height = 60;
    [playView addSubview:playBtn];
    [playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn = playBtn;
    
    UILabel *songLabel = [[UILabel alloc] init];
    songLabel.x = 60.f;
    songLabel.y = 0;
    songLabel.width = self.view.width - 60.f;
    songLabel.height = playBtn.height;
    [playView addSubview:songLabel];
    songLabel.font = [UIFont boldSystemFontOfSize:16];
    songLabel.textColor = [UIColor whiteColor];
    [playView addSubview:songLabel];
    self.songLabel = songLabel;
    
    CGRect rect = CGRectMake(20.f, (playView.height - playBtn.height - 30.f) / 2.f + playBtn.height, self.view.width - 40.f, 30.f);
    LPPlayableRangeSlider *slider = [[LPPlayableRangeSlider alloc] initWithFrame:rect];
    slider.lowerValue = slider.minimumValue;
    slider.upperValue = slider.maximumValue;
    [playView addSubview:slider];
    [slider addTarget:self action:@selector(startTracking:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(tracking:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(endTracking:) forControlEvents:UIControlEventTouchUpInside];
    self.slider = slider;
    
    UILabel *lowerLabel = [[UILabel alloc] init];
    lowerLabel.font = [UIFont systemFontOfSize:14];
    lowerLabel.textColor = [UIColor whiteColor];
    lowerLabel.x = 20.f;
    lowerLabel.width = rect.size.width / 2.f;
    lowerLabel.height = 25.f;
    lowerLabel.y = CGRectGetMinY(rect) - 25.f;
    lowerLabel.textAlignment = NSTextAlignmentLeft;
    [playView addSubview:lowerLabel];
    self.lowerLabel = lowerLabel;
    
    UILabel *upperLabel = [[UILabel alloc] init];
    upperLabel.font = [UIFont systemFontOfSize:14];
    upperLabel.textColor = [UIColor whiteColor];
    upperLabel.x = CGRectGetMaxX(lowerLabel.frame);
    upperLabel.width = rect.size.width / 2.f;
    upperLabel.height = 25.f;
    upperLabel.y = CGRectGetMinY(rect) - 25.f;
    upperLabel.textAlignment = NSTextAlignmentRight;
    [playView addSubview:upperLabel];
    self.upperLabel = upperLabel;
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
    label.text = @"我的音乐";
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
    
    UIButton *importBtn = [[UIButton alloc] init];
    importBtn.x = header.width - 60;
    importBtn.y = 20.f;
    importBtn.height = 44;
    importBtn.width = 60;
    [importBtn addTarget:self action:@selector(importBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [importBtn setTitle:@"导入" forState:UIControlStateNormal];
    [importBtn setTitleColor:[UIColor colorFromHexString:@"8c97ff"] forState:UIControlStateNormal];
    importBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [header addSubview:importBtn];
    importBtn.hidden = YES;
    self.importBtn = importBtn;
    
    UIView *divider = [[UIView alloc] init];
    divider.x = 0;
    divider.height = .5f;
    divider.width = self.view.width;
    divider.y = CGRectGetHeight(header.frame) - .5f;
    [header addSubview:divider];
    divider.backgroundColor = [UIColor colorFromHexString:@"adadad"];
}

- (void)setupTableView {
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tv.x = 0;
    tv.y = self.header.height;
    tv.width = self.view.width;
    tv.height = self.view.height - self.header.height - self.tabBar.height;
    [self.view insertSubview:tv aboveSubview:self.playView];
    self.tableView = tv;
    
    tv.dataSource = self;
    tv.delegate = self;
}

- (void)cancelBtnClick:(UIButton *)sender {
    sender.enabled = NO;
    
    [self.playController stop];
    self.playController = nil;
    if (self.completionHandler) {
        self.completionHandler(nil);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)importBtnClick:(UIButton *)sender {
    sender.enabled = NO;
    
    CMTime trimmedStart = CMTimeMakeWithSeconds(self.slider.lowerValue, NSEC_PER_SEC);
    CMTime trimmedDuration = CMTimeMakeWithSeconds(self.slider.upperValue - self.slider.lowerValue, NSEC_PER_SEC);
    self.selectedMusic.trimmedTimeRange = CMTimeRangeMake(trimmedStart, trimmedDuration);
    
    [self.playController stop];
    self.playController = nil;
    
    if (self.completionHandler) {
        self.completionHandler(self.selectedMusic);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.playController play];
    } else {
        [self.playController pause];
    }
}

#pragma mark - clipping music
- (void)startTracking:(LPPlayableRangeSlider *)slider {
    // 1. 记录播放态 并暂停
    self.playingBeforeClipping = self.playController.playing;
    [self.playController pause];
    // 2. UI同步
    self.playBtn.selected = NO;
    self.playBtn.enabled = NO;
    self.tableView.allowsSelection = NO;
}

- (void)tracking:(LPPlayableRangeSlider *)slider {
    [self updateTimeLabels];
}

- (void)endTracking:(LPPlayableRangeSlider *)slider {
    if (slider.valueChanged) {
        slider.playingValue = MIN(slider.playingValue, slider.upperValue);
        slider.playingValue = MAX(slider.lowerValue, slider.playingValue);
        // 1. 如果拖动lowerKnob, 重新播放; 2. 如果拖动upperKnob, 越界则重新播放, 不越界则继续播放
        if (slider.highlightedKnob == LPRangeSliderHighlightedLowerKnob) {
            slider.playingValue = slider.lowerValue;
            
            [self.playController jumpedToTime:slider.lowerValue];
            
        } else if (slider.playingValue == slider.upperValue) {
            [slider reset];
            [self.playController jumpedToTime:slider.lowerValue];
        }
    }
    if (self.playingBeforeClipping) {
        [self.playController play];
        self.playBtn.selected = YES;
    }
    self.playBtn.enabled = YES;
    self.tableView.allowsSelection = YES;
}

#pragma mark - tab bar delegate
- (void)tabBar:(LPTabBar *)tabBar didSelectButtonFrom:(NSInteger)from to:(NSInteger)to {
    self.selectedItem = to;

    if (from == to) return;
    
    self.offsets[from] = [NSValue valueWithCGPoint:self.tableView.contentOffset];
    [self.tableView reloadData];
    [self.tableView setContentOffset:[self.offsets[to] CGPointValue]];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self rowCountAtSectionIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"music.cell.id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSArray *texts = [self textAtIndexPath:indexPath];
    cell.textLabel.text = texts.firstObject;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.text = texts.lastObject;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self viewForSectionHeaderAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.selectedItem == 0 || self.selectedItem == 3) {
        return 0.f;
    }
    return 24.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LPAudioItem *item = [self audioItemWithIndexPath:indexPath];
    self.songLabel.text = item.title;
    tableView.allowsSelection = NO;
    __weak typeof(self) wself = self;
    self.playBtn.selected = NO;

    [item prepareWithCompletion:^(BOOL completed) {
        if (!completed) return;
        dispatch_async(MAIN_QUEUE, ^{
            item.trimmedTimeRange = item.timeRange;
            
            self.slider.maximumValue = CMTimeGetSeconds(item.asset.duration);
            self.slider.minimumValue = CMTimeGetSeconds(item.timeRange.start);
            self.slider.upperValue = self.slider.maximumValue;
            self.slider.lowerValue = self.slider.minimumValue;
            [self updateTimeLabels];
        });
        
        [self.playController loadPlayerItem:[AVPlayerItem playerItemWithAsset:item.asset] completion:^(BOOL completed) {
            if (completed) {
                if (wself.firstTimePlaying) {
                    wself.firstTimePlaying = NO;
                    [UIView animateWithDuration:.3f animations:^{
                        wself.tableView.y = CGRectGetMaxY(wself.playView.frame);
                        wself.tableView.height -= wself.playView.height;
                    } completion:^(BOOL finished) {
                        wself.importBtn.hidden = NO;
                    }];
                }
                
                wself.playBtn.selected = YES;
                [wself.playController play];
                
                wself.selectedMusic = item;
                
                tableView.allowsSelection = YES;
                wself.importBtn.userInteractionEnabled = YES;
            }
        }];
    }];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.slider.upperValue = self.slider.maximumValue;
    self.slider.lowerValue = self.slider.minimumValue;
    self.slider.playingValue = self.slider.lowerValue;
    
    self.importBtn.userInteractionEnabled = NO;
}

#pragma mark - play controller delegate
- (void)playController:(LPPlayController *)playController currentPlayingTime:(NSTimeInterval)currentPlayingTime duration:(NSTimeInterval)duration {
    if (currentPlayingTime <= self.slider.upperValue) {
        self.currentTime = currentPlayingTime;
        self.slider.playingValue = currentPlayingTime;
    } else {
        [self.slider reset];
        [self.playController pause];
        [self.playController jumpedToTime:self.slider.lowerValue];
    }
}

- (void)playControllerDidCompletePlaying:(LPPlayController *)playController {
    [self.slider reset];
    self.playBtn.selected = NO;
}

#pragma mark - private helpers
- (NSArray *)textAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = @"";
    NSString *detailText = @"";
    switch (self.selectedItem) {
        case 0: {
            MPMediaItem *item = self.songs[indexPath.row];
            text = item.title;
            detailText = item.artist;
        } break;
        case 1: {
            MPMediaItemCollection *collection = self.artistCollections[indexPath.section];
            MPMediaItem *item = collection.items[indexPath.row];
            text = item.title;
            detailText = item.albumTitle;
        } break;
        case 2: {
            MPMediaItemCollection *collection = self.genreCollections[indexPath.section];
            MPMediaItem *item = collection.items[indexPath.row];
            text = item.title;
            detailText = item.artist;
        } break;
        case 3: {
            LPAudioItem *item = self.localMusics[indexPath.row];
            text = item.filename;
            detailText = @"";
        } break;
        default:
            break;
    }
    if (LPIsEmpty(text)) {
        text = @"";
    }
    if (LPIsEmpty(detailText)) {
        detailText = @"";
    }
    return @[text, detailText];
}

- (NSInteger)sectionCount {
    NSInteger sectionCount = 0;
    switch (self.selectedItem) {
        case 1:
            sectionCount = self.artistCollections.count;
            break;
        case 2:
            sectionCount = self.genreCollections.count;
            break;
        default:
            sectionCount = 1;
            break;
    }
    return sectionCount;
}

- (NSInteger)rowCountAtSectionIndex:(NSInteger)index {
    NSInteger rowCount = 0;
    switch (self.selectedItem) {
        case 0:
            rowCount = self.songs.count;
            break;
        case 1: {
            MPMediaItemCollection *collection = self.artistCollections[index];
            rowCount = collection.count;
        } break;
        case 2: {
            MPMediaItemCollection *collection = self.genreCollections[index];
            rowCount = collection.count;
        } break;
        case 3: {
            rowCount = self.localMusics.count;
        } break;
        default:
            break;
    }
    return rowCount;
}

- (UIView *)viewForSectionHeaderAtIndex:(NSInteger)index {
    if (self.selectedItem == 0 || self.selectedItem == 3) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.backgroundColor = [UIColor colorFromHexString:@"eeeeee"];
    if (self.selectedItem == 1) {
        MPMediaItemCollection *collection = self.artistCollections[index];
        label.text = [NSString stringWithFormat:@" %@", collection.representativeItem.artist];
    } else {
        MPMediaItemCollection *collection = self.genreCollections[index];
        label.text = [NSString stringWithFormat:@" %@", collection.representativeItem.genre];
    }
    return label;
}

- (LPAudioItem *)audioItemWithIndexPath:(NSIndexPath *)indexPath {
    LPAudioItem *audioItem = nil;
    switch (self.selectedItem) {
        case 0: {
            MPMediaItem *item = self.songs[indexPath.row];
            audioItem = [[LPAudioItem alloc] initWithURL:item.assetURL];
            audioItem.title = item.title;
        } break;
        case 1: {
            MPMediaItemCollection *collection = self.artistCollections[indexPath.section];
            MPMediaItem *item = collection.items[indexPath.row];
            audioItem = [[LPAudioItem alloc] initWithURL:item.assetURL];
            audioItem.title = item.title;
        } break;
        case 2: {
            MPMediaItemCollection *collection = self.genreCollections[indexPath.section];
            MPMediaItem *item = collection.items[indexPath.row];
            audioItem = [[LPAudioItem alloc] initWithURL:item.assetURL];
            audioItem.title = item.title;
        } break;
        case 3: {
            audioItem = self.localMusics[indexPath.row];
        } break;
        default:
            break;
    }
    return audioItem;
}

- (void)updateTimeLabels {
    self.lowerLabel.text = [self formattingTimeInterval:self.slider.lowerValue];
    self.upperLabel.text = [self formattingTimeInterval:self.slider.upperValue];
}

- (NSString *)formattingTimeInterval:(float)timeInterval {
    NSInteger minute = timeInterval / 60;
    NSInteger seconds = (NSInteger)roundf(timeInterval) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", minute, seconds];
}

@end
