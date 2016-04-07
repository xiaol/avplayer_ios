//
//  LPCameraViewController.m
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCameraViewController.h"
#import "LPBaseCameraController.h"
#import "LPCameraOverlayView.h"
#import "LPCameraPreviewView.h"
#import "LPCameraNotification.h"
#import "LPError.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface LPCameraViewController () <LPCameraPreviewViewDelegate, LPBaseCameraControllerDelegate>
@property (nonatomic, strong) LPCameraPreviewView *preview;
@property (nonatomic, strong) LPCameraOverlayView *overlay;
@property (nonatomic, strong) LPBaseCameraController *cameraController;

@property (nonatomic, strong) NSTimer *timer;
@end

@implementation LPCameraViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [noteCenter addObserver:self
                   selector:@selector(updateThumbnail:)
                       name:LPThumbnailDidCreateNotification
                     object:nil];
    self.cameraController = [[LPBaseCameraController alloc] init];
    self.cameraController.delegate = self;
    
    self.preview = [[LPCameraPreviewView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.preview];

    NSError *error = nil;
    if ([self.cameraController setupSessionWithError:&error]) {
        [self.preview setSession:self.cameraController.session];
        self.preview.delegate = self;
        [self.cameraController startSession];
        self.preview.tapToFocusEnabled = self.cameraController.cameraSupportsFocus;
        self.preview.tapToExposeEnabled = self.cameraController.cameraSupportsExpose;
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    __weak typeof(self) wself = self;
    self.overlay = [LPCameraOverlayView overlayViewWithFrame:self.view.bounds
                                     captureStartHandler:^{
                                         if (wself.overlay.modeView.mode == LPCameraModeVideo) {
                                             if (!wself.cameraController.isRecording) {
                                                 [wself.cameraController startRecording];
                                                 [wself startTimer];
                                             } else {
                                                 [wself.cameraController stopRecording];
                                                 [wself stopTimer];
                                             }
                                         } else {
                                             [wself.cameraController captureStillImage];
                                         }
                                     } cameraSwapHandler:^{
                                         if ([wself.cameraController switchCamera]) {
                                             wself.preview.tapToFocusEnabled = wself.cameraController.cameraSupportsFocus;
                                             wself.preview.tapToExposeEnabled = wself.cameraController.cameraSupportsExpose;
                                             [wself.cameraController resetFocusAndExposeModes];
                                         }
                                     } thumbnailClickHandler:^{
                                         UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                                         imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                         imgPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                                         [wself presentViewController:imgPicker animated:YES completion:nil];
                                     }];
    [self.view addSubview:self.overlay];
    
}

#pragma mark - timing methods
- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f repeating:YES firing:^{
        CMTime duration = self.cameraController.recordDuration;
        NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
        NSUInteger hours = time / 3600;
        NSUInteger minutes = (time / 60) % 60;
        NSUInteger seconds = time % 60;
        
        NSString *format = @"%02i:%02i:%02i";
        NSString *recodedTime = [NSString stringWithFormat:format, hours, minutes, seconds];
        self.overlay.statusView.elapsedTimeLabel.text = recodedTime;
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.overlay.statusView.elapsedTimeLabel.text = @"00:00:00";
}

#pragma mark - handle thumbnail update
- (void)updateThumbnail:(NSNotification *)note {
    UIImage *thumbnail = note.object;
    UIButton *thumbnailBtn = self.overlay.modeView.thumbnailBtn;
    [thumbnailBtn setBackgroundImage:thumbnail forState:UIControlStateNormal];
    thumbnailBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbnailBtn.layer.borderWidth = 1.0f;
}

#pragma mark - preview delegate
- (void)preview:(LPCameraPreviewView *)preview tappedToExposeAtPoint:(CGPoint)exposePoint {
    [self.cameraController exposeAtPoint:exposePoint];
}

- (void)preview:(LPCameraPreviewView *)preview tappedToFocusAtPoint:(CGPoint)focusPoint {
    [self.cameraController focusAtPoint:focusPoint];
}

#pragma mark - camera controller delegate 


@end
