//
//  LPVideoLibraryViewController.h
//  iVideo
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LPVideoSelectCompletionHandler)(NSArray *videoItems);

@interface LPVideoLibraryViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *videos;

- (void)videosSelectedCompletion:(LPVideoSelectCompletionHandler)completion;
@end
