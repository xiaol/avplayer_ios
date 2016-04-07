//
//  LPPlaybackView.h
//  iVideo
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPPlaybackView : UIView

@property (nonatomic, weak) AVPlayer *player;

@property (nonatomic, copy) NSString *text;

- (void)hideTime;

- (void)prepareForPlaying;

- (void)startPlaying;

@end
