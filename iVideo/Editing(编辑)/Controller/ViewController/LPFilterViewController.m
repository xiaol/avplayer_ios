//
//  LPFilterViewController.m
//  iVideo
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 lvpin. All rights reserved.

//  所有滤镜名称:
//  CIAccordionFoldTransition  CIAdditionCompositing  CIAffineClamp  CIAffineTile  CIAffineTransform  CIAreaAverage  CIAreaHistogram  CIAreaMaximum  CIAreaMaximumAlpha  CIAreaMinimum  CIAreaMinimumAlpha  CIAztecCodeGenerator  CIBarsSwipeTransition  CIBlendWithAlphaMask  CIBlendWithMask  CIBloom  CIBoxBlur  CIBumpDistortion  CIBumpDistortionLinear  CICheckerboardGenerator  CICircleSplashDistortion  CICircularScreen  CICircularWrap  CICMYKHalftone  CICode128BarcodeGenerator  CIColorBlendMode  CIColorBurnBlendMode  CIColorClamp  CIColorControls  CIColorCrossPolynomial  CIColorCube  CIColorCubeWithColorSpace  CIColorDodgeBlendMode  CIColorInvert  CIColorMap  CIColorMatrix  CIColorMonochrome  CIColorPolynomial  CIColorPosterize  CIColumnAverage  CIComicEffect  CIConstantColorGenerator  CIConvolution3X3  CIConvolution5X5  CIConvolution7X7  CIConvolution9Horizontal  CIConvolution9Vertical  CICopyMachineTransition  CICrop  CICrystallize  CIDarkenBlendMode  CIDepthOfField  CIDifferenceBlendMode  CIDiscBlur  CIDisintegrateWithMaskTransition  CIDisplacementDistortion  CIDissolveTransition  CIDivideBlendMode  CIDotScreen  CIDroste  CIEdges  CIEdgeWork  CIEightfoldReflectedTile  CIExclusionBlendMode  CIExposureAdjust  CIFalseColor  CIFlashTransition  CIFourfoldReflectedTile  CIFourfoldRotatedTile  CIFourfoldTranslatedTile  CIGammaAdjust  CIGaussianBlur  CIGaussianGradient  CIGlassDistortion  CIGlassLozenge  CIGlideReflectedTile  CIGloom  CIHardLightBlendMode  CIHatchedScreen  CIHeightFieldFromMask  CIHexagonalPixellate  CIHighlightShadowAdjust  CIHistogramDisplayFilter  CIHoleDistortion  CIHueAdjust  CIHueBlendMode  CIKaleidoscope  CILanczosScaleTransform  CILenticularHaloGenerator  CILightenBlendMode  CILightTunnel  CILinearBurnBlendMode  CILinearDodgeBlendMode  CILinearGradient  CILinearToSRGBToneCurve  CILineOverlay  CILineScreen  CILuminosityBlendMode  CIMaskToAlpha  CIMaximumComponent  CIMaximumCompositing  CIMedianFilter  CIMinimumComponent  CIMinimumCompositing  CIModTransition  CIMotionBlur  CIMultiplyBlendMode  CIMultiplyCompositing  CINoiseReduction  CIOpTile  CIOverlayBlendMode  CIPageCurlTransition  CIPageCurlWithShadowTransition  CIParallelogramTile  CIPDF417BarcodeGenerator  CIPerspectiveCorrection  CIPerspectiveTile  CIPerspectiveTransform  CIPerspectiveTransformWithExtent  CIPhotoEffectChrome  CIPhotoEffectFade  CIPhotoEffectInstant  CIPhotoEffectMono  CIPhotoEffectNoir  CIPhotoEffectProcess  CIPhotoEffectTonal  CIPhotoEffectTransfer  CIPinchDistortion  CIPinLightBlendMode  CIPixellate  CIPointillize  CIQRCodeGenerator  CIRadialGradient  CIRandomGenerator  CIRippleTransition  CIRowAverage  CISaturationBlendMode  CIScreenBlendMode  CISepiaTone  CIShadedMaterial  CISharpenLuminance  CISixfoldReflectedTile  CISixfoldRotatedTile  CISmoothLinearGradient  CISoftLightBlendMode  CISourceAtopCompositing  CISourceInCompositing  CISourceOutCompositing  CISourceOverCompositing  CISpotColor  CISpotLight  CISRGBToneCurveToLinear  CIStarShineGenerator  CIStraightenFilter  CIStretchCrop  CIStripesGenerator  CISubtractBlendMode  CISunbeamsGenerator  CISwipeTransition  CITemperatureAndTint  CIToneCurve  CITorusLensDistortion  CITriangleKaleidoscope  CITriangleTile  CITwelvefoldReflectedTile  CITwirlDistortion  CIUnsharpMask  CIVibrance  CIVignette  CIVignetteEffect  CIVortexDistortion  CIWhitePointAdjust  CIZoomBlur

#import "LPFilterViewController.h"
#import "LPFilterView.h"
#import "LPFilterGraph.h"
#import "LPFilterCell.h"
#import "LPPlayController.h"
#import "LPContextManager.h"
#import "LPMovieEncoder.h"
#import "LPAssetsLibrary.h"
#import "LPProgressView.h"
#import "LPMovieSizesView.h"

static const CGFloat itemPadding = 10.f;
static const CGFloat sectionPadding = 22.f;

static NSString *LPFilterCellReuseID = @"filter.cell.reuse.id";

@interface LPFilterViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LPPlayControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) LPPlayController *playController;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic, strong) LPFilterView *filterView;
@property (nonatomic, strong) LPProgressView *progressView;
@property (nonatomic, strong) UIView *hud;
@property (nonatomic, strong) LPMovieSizesView *movieSizesView;
@property (nonatomic, strong) UIButton *exportBtn;

@property (nonatomic, strong) NSArray *filterGraphs;

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) LPFilterView *playView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) LPFilterGraph *selectedFilterGraph;

@property (nonatomic, assign) BOOL encoding;

@property (nonatomic, strong) LPMovieEncoder *encoder;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) CIContext *context;

@property (nonatomic, assign) LPMovieSize selectedMovieSize;

@end

@implementation LPFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.context = [CIContext contextWithOptions:nil];
    self.selectedMovieSize = self.composition.size;
   
    [self setupFilterGraphs];
    [self setupSubviews];
    [self setupPlayController];
    [self setupDisplayLink];
    
    [self filterImages];
}

- (void)setupFilterGraphs {
    LPFilterGraph *fg1 = [LPFilterGraph filterGraphWithFilterNames:nil
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:nil];
    fg1.effectName = @"无";
    
    
    NSArray *names2 = @[@"CIColorMonochrome", @"CIVignette"];
    NSDictionary *dict21 = @{kCIInputColorKey : [CIColor colorWithRed:.76 green:.65 blue:.54]};
    NSDictionary *dict22 = @{kCIInputRadiusKey : @(1.75),
                            kCIInputIntensityKey : @(1.0)};
    LPFilterGraph *fg2 = [LPFilterGraph filterGraphWithFilterNames:names2
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:@[dict21, dict22]];
    fg2.effectName = @"怀旧";
    
    
    LPFilterGraph *fg3 = [LPFilterGraph filterGraphWithFilterNames:@[@"CIPhotoEffectFade"]
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:nil];
    fg3.effectName = @"褪色";
    
    
    
    NSDictionary *dict4 = @{kCIInputRadiusKey : @(8.0)};
    LPFilterGraph *fg4 = [LPFilterGraph filterGraphWithFilterNames:@[@"CIGaussianBlur"]
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:@[dict4]];
    fg4.effectName = @"朦胧";
    
    
    
    LPFilterGraph *fg5 = [LPFilterGraph filterGraphWithFilterNames:@[@"CIPhotoEffectNoir"]
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:nil];
    fg5.effectName = @"悲情";
    
    
    
    LPFilterGraph *fg6 = [LPFilterGraph filterGraphWithFilterNames:@[@"CIPhotoEffectInstant"]
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:nil];
    fg6.effectName = @"片刻";
    
    
    
    LPFilterGraph *fg7 = [LPFilterGraph filterGraphWithFilterNames:@[@"CIPhotoEffectTransfer"]
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:nil];
    fg7.effectName = @"温暖";
    
    NSDictionary *dict8 = @{@"inputIntensity" : @(0.5), kCIInputRadiusKey : @(12)};
    LPFilterGraph *fg8 = [LPFilterGraph filterGraphWithFilterNames:@[@"CIBloom"]
                                                        inputImage:self.thumbnail.copy
                                              inputAttributesArray:@[dict8]];
    fg8.effectName = @"光晕";
    

    
    self.filterGraphs = @[fg1, fg2, fg3, fg4, fg5, fg6, fg7, fg8];
    self.selectedFilterGraph = fg1;
}

- (void)setupSubviews {
    [self setupHeader];
    [self setupPlayView];
    [self setupCollectionView];
    [self setupMovieSizesView];
    [self setupExportBtn];
    [self setupHUD];
    [self setupProgressView];
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
    label.text = @"添加滤镜";
    label.textColor = [UIColor colorFromHexString:@"0b0b0b"];
    label.backgroundColor = [UIColor clearColor];
    [header addSubview:label];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.x = 0;
    cancelBtn.y = 20.f;
    cancelBtn.height = 44;
    cancelBtn.width = 60;
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
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
    confirmBtn.hidden = YES;
    self.confirmBtn = confirmBtn;
    
    UIView *divider = [[UIView alloc] init];
    divider.x = 0;
    divider.height = .5f;
    divider.width = self.view.width;
    divider.y = CGRectGetHeight(header.frame) - .5f;
    [header addSubview:divider];
    divider.backgroundColor = [UIColor colorFromHexString:@"adadad"];
}

- (void)setupPlayView {
    EAGLContext *ctx = [LPContextManager defaultManager].glContext;
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.header.frame), ScreenWidth, ScreenWidth * ScreenWidth / ScreenHeight);
    LPFilterView *playView = [[LPFilterView alloc] initWithFrame:frame context:ctx];
    playView.ciContext = [LPContextManager defaultManager].ciContext;
    [self.view addSubview:playView];
    self.playView = playView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playViewTapped:)];
    [playView addGestureRecognizer:tap];
}

- (void)setupProgressView {
    CGFloat width = 120.f;
    CGFloat diameter = 70;
    if (iPhone4 || iPhone5) {
        width = 100;
        diameter = 60;
    }
    LPProgressView *progressView = [[LPProgressView alloc] init];
    progressView.circleDiameter = diameter;
    progressView.bounds = CGRectMake(0, 0, width, width);
    progressView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view addSubview:progressView];
    self.progressView = progressView;
    progressView.alpha = 0;
}

- (void)setupHUD {
    UIView *hud = [[UIView alloc] init];
    hud.backgroundColor = [UIColor colorWithWhite:0.f alpha:.3f];
    hud.x = 0;
    hud.y = CGRectGetMaxY(self.header.frame);
    hud.width = self.view.width;
    hud.height = self.view.height - hud.y;
    [self.view addSubview:hud];
    hud.alpha = 0;
    self.hud = hud;
}

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = 125.f;
    CGFloat itemH = 80.f;
    if (iPhone6Plus) {
        itemW = 160;
        itemH = 110;
    } else if (iPhone4 || iPhone5) {
        itemW = 90;
        itemH = 58;
    }
    layout.itemSize = (CGSize){itemW, itemH};
    layout.minimumInteritemSpacing = itemPadding;
    layout.minimumLineSpacing = itemPadding;
    layout.sectionInset = UIEdgeInsetsMake(0, sectionPadding, 0, sectionPadding);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat labelPadding = 20.f;
    if (iPhone4) {
        labelPadding = 7.f;
    }
    
    CGFloat labelY = CGRectGetMaxY(self.playView.frame) + labelPadding;
    CGFloat labelX = sectionPadding;
    CGFloat labelW = self.view.width - 2 * sectionPadding;
    CGFloat labelH = 20.f;
    UILabel *label = [[UILabel alloc] init];
    label.text = @"选择滤镜";
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(labelX, labelY, labelW, labelH);
    label.textColor = ThemeColor;
    [self.view addSubview:label];
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [cv registerClass:[LPFilterCell class] forCellWithReuseIdentifier:LPFilterCellReuseID];
    cv.x = 0;
    cv.y = CGRectGetMaxY(label.frame) + labelPadding;
    cv.height = itemH;
    cv.width = self.view.width;
    cv.backgroundColor = [UIColor clearColor];
    cv.dataSource = self;
    cv.delegate = self;
    cv.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:cv];
    self.collectionView = cv;
}

- (void)setupMovieSizesView {
    CGFloat deltaY = 20.f;
    if (iPhone4) {
        deltaY = 7.f;
    }
    CGFloat labelY = CGRectGetMaxY(self.collectionView.frame) + deltaY;
    
    CGFloat width = self.view.width - 2 * sectionPadding;
    CGFloat labelH = 20.f;
    UILabel *label = [[UILabel alloc] init];
    label.text = @"选择分辨率";
    label.textColor = ThemeColor;
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(sectionPadding, labelY, width, labelH);
    [self.view addSubview:label];
    
    CGFloat sizeViewH = 60.f;
    if (iPhone6) {
        sizeViewH = 50.f;
    } else if (iPhone5) {
        sizeViewH = 40;
    } else if (iPhone4) {
        sizeViewH = 35.f;
    }
    CGFloat padding = 14.f;
    if (iPhone6Plus) {
        padding = 17.f;
    }
    
    NSUInteger count = 0;
    switch (self.composition.size) {
        case LPMovieSize1080P:
            count = 3;
            break;
        case LPMovieSize720P:
            count = 2;
            break;
        case LPMovieSize480P:
            count = 1;
            break;
        default:
            break;
    }
    
    __weak typeof(self) wself = self;
    LPMovieSizesView *movieSizesView = [[LPMovieSizesView alloc] initWithPadding:padding availableSizeCount:count selectionHandler:^(NSInteger movieSizeNumber) {
        if (movieSizeNumber == 0) {
            wself.selectedMovieSize = LPMovieSize480P;
        } else if (movieSizeNumber == 1) {
            wself.selectedMovieSize = LPMovieSize720P;
        } else if (movieSizeNumber == 2) {
            wself.selectedMovieSize = LPMovieSize1080P;
        }
    }];
    movieSizesView.x = sectionPadding;
    movieSizesView.y = CGRectGetMaxY(label.frame) + deltaY;
    movieSizesView.width = self.view.width - 2 * sectionPadding;
    movieSizesView.height = sizeViewH;
    [self.view addSubview:movieSizesView];
    self.movieSizesView = movieSizesView;
}

- (void)setupExportBtn {
    UIButton *btn = [[UIButton alloc] init];
    CGFloat btnH = 50;
    if (iPhone5) {
        btnH = 40;
    }
    CGFloat btnX = sectionPadding;
    CGFloat btnW = self.view.width - 2 * btnX;
    CGFloat btnY = (self.view.height + CGRectGetMaxY(self.movieSizesView.frame) - btnH) / 2.f;
    
    btn.layer.cornerRadius = 5.f;
    btn.clipsToBounds = YES;
    [btn setTitle:@"导出" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:ThemeColor size:CGSizeMake(btnW, btnH)]
                   forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"b6b6b6"] size:CGSizeMake(btnW, btnH)]
                   forState:UIControlStateSelected];
    btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [self.view addSubview:btn];
    self.exportBtn = btn;
    
    [btn addTarget:self action:@selector(exportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupPlayController {
    LPPlayController *playController = [[LPPlayController alloc] init];
    playController.ignoreTimeObserving = YES;
    playController.ignorePlayback = YES;
    playController.delegate = self;
    self.playController = playController;
    AVPlayerItem *playerItem = [self.composition makePlayerItem];
    
    NSDictionary *attributs = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    AVPlayerItemVideoOutput *videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:attributs];
    [playerItem addOutput:videoOutput];
    self.videoOutput = videoOutput;
    
    __weak typeof(self) wself = self;
    [playController loadPlayerItem:playerItem completion:^(BOOL completed) {
        [wself.playController play];
    }];
    self.playController = playController;
}

- (void)cancelBtnClick:(UIButton *)sender {    
    if (self.encoding) {
        [self.encoder pauseEncoding];
        [UIAlertView alertViewShowWithTitle:nil
                                    message:@"您当前有未完成的作品, 返回上一级将会中止作品生成"
                                   delegate:self
                          cancelButtonTitle:@"取消"
                           otherButtonTitle:@"确定"];
    } else {
        [self pop];
    }
}

- (void)pop {
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.playController invalidate];
    self.playController = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmBtnClick:(UIButton *)sender {
    // ...
}

- (void)exportBtnClick:(UIButton *)sender {
    sender.enabled = NO;
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.playController invalidate];
    self.playController = nil;
    
    self.encoding = YES;
    
    self.encoder = [[LPMovieEncoder alloc] initWithComposition:self.composition
                                                              filterGraph:self.selectedFilterGraph
                                                                movieSize:self.selectedMovieSize];
    __weak typeof(self) wself = self;
    [self.encoder startEncodingWithSuccess:^(NSURL *movieURL) {
        LPAssetsLibrary *library = [[LPAssetsLibrary alloc] init];
        [library writeVideoAtURL:movieURL success:^(UIImage *image) {
            NSLog(@"写入相册成功!");
            [UIAlertView alertViewShowWithTitle:@"制作成功!" message:@"已保存至相册" delegate:self cancelButtonTitle:@"好的" otherButtonTitle:@"查看"];
        } failure:^(NSError *error) {
            NSLog(@"写入相册失败!");
        }];
        wself.encoding = NO;
    } failure:^(NSError *error) {
        NSLog(@"编码失败 --- %@", error.description);
        wself.encoding = NO;
    } progress:^(CGFloat percent) {
        wself.progressView.percent = percent;
    }];
}

- (void)setEncoding:(BOOL)encoding {
    _encoding = encoding;
    [UIView animateWithDuration:.3f
                     animations:^{
                         self.progressView.alpha = encoding;
                         self.hud.alpha = encoding;
                     }];
}

- (void)setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshPlayView:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = displayLink;
}

- (void)filterImages {
    dispatch_async(GLOBAL_QUEUE, ^{
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 0; i < self.filterGraphs.count; ++ i) {
            LPFilterGraph *filterGraph = self.filterGraphs[i];
            CGImageRef cgimage = [self.context createCGImage:filterGraph.outputImage
                                                    fromRect:filterGraph.extent];
            [array addObject:[UIImage imageWithCGImage:cgimage]];
            CGImageRelease(cgimage);
        }
        dispatch_async(MAIN_QUEUE, ^{
            self.images = array;
            [self.collectionView reloadData];
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        });
    });
}

/**
 *  屏幕刷帧时显示当前滤波作用后的图像
 *
 *  discuss:当前playerItem的videoOutput会随着player播放推出新的视频帧, 然后更新滤波图的输入图像, 由opengl绘制(因ciContext与glContext共享数据)并显示在GLKView上
 */
- (void)refreshPlayView:(CADisplayLink *)displayLink { // 根据timestamp的差值显示
    CMTime itemTime = [self.videoOutput itemTimeForHostTime:CACurrentMediaTime()];
    if ([self.videoOutput hasNewPixelBufferForItemTime:itemTime]) {
        [self refreshAtTime:itemTime];
    }
}

- (void)refreshAtTime:(CMTime)time {
    LPFilterGraph *fg = self.selectedFilterGraph;
    CMTime displayTime = kCMTimeZero;
    CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:time itemTimeForDisplay:&displayTime];
    fg.inputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    self.playView.filterGraph = fg;
    CVPixelBufferRelease(pixelBuffer);
}

- (void)playViewTapped:(UITapGestureRecognizer *)gr {
    gr.enabled = NO;
    
    if (self.playController.playing) {
        [self.playController pause];
    } else {
        [self.playController play];
    }
    
    gr.enabled = YES;
}

- (void)dealloc {
    NSLog(@"%@ --- %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterGraphs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LPFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LPFilterCellReuseID
                                                                   forIndexPath:indexPath];
    LPFilterGraph *fg = self.filterGraphs[indexPath.item];
    cell.text = fg.effectName;
    cell.image = self.images[indexPath.item];
    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFilterGraph = self.filterGraphs[indexPath.item];
    if (!self.playController.playing) {
        [self refreshAtTime:[self.videoOutput itemTimeForHostTime:CACurrentMediaTime()]];
    }
}

#pragma mark - play controller delegate
- (void)playControllerDidCompletePlaying:(LPPlayController *)playController {
    NSLog(@"complete playing !!!");
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!alertView.title) { // 编码中返回
        if (buttonIndex == 1) { // 返回
            [self.encoder cancelEncoding];
            [self pop];
        } else {
            [self.encoder resumeEncoding];
        }
    } else if ([alertView.title isEqualToString:@"制作成功!"]) {
        if (buttonIndex == 1) {
            NSLog(@"查看作品啦!!!");
        }
    }
}
@end
