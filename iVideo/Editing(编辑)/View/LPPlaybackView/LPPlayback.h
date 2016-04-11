//
//  LPBasePlaybackView.h
//  iVideo
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LPPlayback <NSObject>

- (void)prepareForPlaying;
- (void)startPlaying;

@property (nonatomic, weak) AVPlayer *player;

@end