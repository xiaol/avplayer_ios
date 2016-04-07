//
//  LPMusicLibraryViewController.h
//  iVideo
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LPAudioItem.h"

typedef void (^LPMusicSelectCompletionHandler)(LPAudioItem *music);

@interface LPMusicLibraryViewController : UIViewController

- (void)musicSelectCompletion:(LPMusicSelectCompletionHandler)completion;

@end
