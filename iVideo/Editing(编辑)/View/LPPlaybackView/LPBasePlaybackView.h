//
//  LPBasePlaybackView.h
//  iVideo
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPBasePlaybackView : UIView
@property (nonatomic, weak) AVPlayer *player;

- (void)prepareForPlaying;
- (void)startPlaying;
@end
