//
//  ViewController.m
//  iVideo
//
//  Created by apple on 15/12/28.
//  Copyright © 2015年 lvpin. All rights reserved.
//

#import "ViewController.h"
#import "SpeechController.h"
#import <AssetsLibrary/AssetsLibrary.h>

static const NSString *PlayerItemStatusContext;

@interface ViewController ()
@property (nonatomic, strong) SpeechController *speechController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
//    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
//    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"hello! what's your name?"];
//    [synthesizer speakUtterance:utterance];
    
    self.speechController = [SpeechController speechController];
    [self.speechController beginConversation];
    
    NSURL *assetURL = [[NSBundle mainBundle] URLForResource:@"" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [item addObserver:self
           forKeyPath:@"status"
              options:0
              context:&PlayerItemStatusContext];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    [self.view.layer addSublayer:layer];
}

// KVO notification
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            // 开始播放 proceed with playback
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
