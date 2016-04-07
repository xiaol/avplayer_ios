//
//  AppDelegate.m
//  iVideo
//
//  Created by apple on 15/12/28.
//  Copyright © 2015年 lvpin. All rights reserved.
//

#import "AppDelegate.h"
#import "LPNavigationViewController.h"
#import "LPHomeViewController.h"
#import "LPEditViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)configureAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    // 1. 设置分类
    if (![session setCategory:AVAudioSessionCategoryPlayback error:&error]) { // Playback模式允许混音和音频播放, 适于音视频播放
        NSLog(@"Audio Session Category Error: %@", error.localizedDescription);
    }
    // 2. 激活会话
    if (![session setActive:YES error:&error]) {
        NSLog(@"Audio Session Activation Error: %@", error.localizedDescription);
    }
}

- (void)configureWindowAndRootVc {
//    LPHomeViewController *homeVc = [[LPHomeViewController alloc] init];
    LPEditViewController *editVc = [[LPEditViewController alloc] init];
    LPNavigationViewController *nav = [[LPNavigationViewController alloc] initWithRootViewController:editVc];
    nav.navigationBarHidden = YES;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 配置音频会话
//    [self configureAudioSession];
    // 设置主窗口与根控制器
    [self configureWindowAndRootVc];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
