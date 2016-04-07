//
//  LPVideoLibraryViewController.m
//  iVideo
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPVideoLibraryViewController.h"
#import "LPVideoItem.h"
#import "LPAssetsLibrary.h"
#import "LPVideoAssetCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LPEditViewController.h"

static NSString * LPVideoAssetCellReuseID = @"collectAlbumCell";

@interface LPVideoLibraryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *header;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LPAssetsLibrary *library;
@property (nonatomic, strong) NSNumber *preparedCount;
@property (nonatomic, assign) NSUInteger videoCount;

@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;

@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, copy) LPVideoSelectCompletionHandler selectedCompletion;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation LPVideoLibraryViewController

- (void)viewDidAppear:(BOOL)animated {
//    [self.library readAllVideoAssetsWithSuccess:^(NSArray *videos) {
//        [self.indicator stopAnimating];
//        self.videos = [NSMutableArray arrayWithArray:videos];
//        [self.collectionView reloadData];
//    } failure:^(NSError *error) {
//        // ...
//    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.library = [[LPAssetsLibrary alloc] init];
    
    [self setupHeader];
    
    CGFloat spacing = 3.f;
    CGFloat padding = 3.f;
    CGFloat itemW = (self.view.bounds.size.width - spacing * 2) / 3.f;
    CGFloat itemH = itemW * 12 / 16.f;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(padding, 0, 0, 0);
    layout.minimumInteritemSpacing = spacing;
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.minimumLineSpacing = spacing;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat y = CGRectGetMaxY(self.header.frame);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, self.view.width, self.view.height - y) collectionViewLayout:layout];
    [self.collectionView registerClass:[LPVideoAssetCell class] forCellWithReuseIdentifier:LPVideoAssetCellReuseID];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.allowsMultipleSelection = YES;
    [self.view addSubview:self.collectionView];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
//    [self.indicator startAnimating];
    
    dispatch_async(GLOBAL_QUEUE, ^{
        [self.library readAllVideoAssetsWithSuccess:^(NSArray *videos) {
            dispatch_async(MAIN_QUEUE, ^{
//                [self.indicator stopAnimating];
                self.videos = [NSMutableArray arrayWithArray:videos];
                [self.collectionView reloadData];
            });
        } failure:^(NSError *error) {
            // ...
        }];
    });
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    header.backgroundColor = [UIColor colorFromHexString:@"f7f7f8"];
    [self.view addSubview:header];
    self.header = header;
    
    CGFloat dividerY = CGRectGetHeight(header.bounds) - 0.5f;
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, dividerY, self.view.width, 0.5f)];
    divider.backgroundColor = [UIColor colorFromHexString:@"adadad"];
    [header addSubview:divider];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = 0;
    label.y = 20;
    label.width = header.width;
    label.height = 44;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = @"我的视频";
    label.textColor = [UIColor colorFromHexString:@"0b0b0b"];
    label.backgroundColor = [UIColor clearColor];
    [header addSubview:label];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.x = 0;
    cancelBtn.y = 20;
    cancelBtn.width = 60;
    cancelBtn.height = 44;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorFromHexString:@"8c97ff"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [[UIButton alloc] init];
    confirmBtn.width = 60;
    confirmBtn.height = 44;
    confirmBtn.y = 20;
    confirmBtn.x = header.width - 60;
    [confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor colorFromHexString:@"8c97ff"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    confirmBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:confirmBtn];
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn = confirmBtn;
    confirmBtn.hidden = YES;
}

- (void)cancelBtnClicked {
    if (self.selectedCompletion) {
        self.selectedCompletion(nil);
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)confirmBtnClicked {
    if (self.selectedCompletion) {
        NSMutableArray *videos = [NSMutableArray array];
        for (NSIndexPath *indexPath in self.selectedIndexPaths) {
            [videos addObject:self.videos[indexPath.item]];
        }
        self.selectedCompletion(videos.copy);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSMutableArray *)videos {
    if (_videos == nil) {
        _videos = [NSMutableArray array];
    }
    return _videos;
}

- (NSMutableArray *)selectedIndexPaths {
    if (_selectedIndexPaths == nil) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return _selectedIndexPaths;
}

- (void)videosSelectedCompletion:(LPVideoSelectCompletionHandler)completion {
    self.selectedCompletion = completion;
}

#pragma mark - cv data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LPVideoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LPVideoAssetCellReuseID
                                                                       forIndexPath:indexPath];
    LPVideoItem *video = self.videos[indexPath.item];
    cell.duration = (NSUInteger)CMTimeGetSeconds(video.duration);
    cell.image = video.thumbnail;
    cell.selectedNumber = 0;
    for (NSIndexPath *ip in self.selectedIndexPaths) {
        if (ip.item == indexPath.item) {
            cell.selectedNumber = [self.selectedIndexPaths indexOfObject:ip] + 1;
            break;
        }
    }
    return cell;
}

#pragma mark - cv delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LPVideoAssetCell *cell = (LPVideoAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
    BOOL contains = NO;
    NSUInteger containsIndex = 0;
    for (NSIndexPath *ip in self.selectedIndexPaths) {
        if (ip.item == indexPath.item) {
            contains = YES;
            containsIndex = [self.selectedIndexPaths indexOfObject:ip];
            break;
        }
    }
    if (!contains) {
        [self.selectedIndexPaths addObject:indexPath];
        cell.selectedNumber = self.selectedIndexPaths.count;
    } else {
        [self.selectedIndexPaths removeObjectAtIndex:containsIndex];
        [collectionView reloadData];
    }
    self.confirmBtn.hidden = (self.selectedIndexPaths.count == 0);
}

@end
