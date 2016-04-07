//
//  LPHomeViewController.m
//  iVideo
//
//  Created by apple on 16/1/8.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPHomeViewController.h"
#import "LPCameraViewController.h"
#import "LPNavigationViewController.h"
#import "LPEditViewController.h"

@interface LPHomeViewController ()

@end

@implementation LPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
}

#pragma mark - set up views
- (void)setupSubviews {
    [self setupBgView];
    
    [self setupLogo];
    
    [self setupBtns];
}

- (void)setupBgView {
    UIImageView *bg = [[UIImageView alloc] init];
    bg.frame = self.view.bounds;
    [self.view addSubview:bg];
    if (iPhone4) {
        bg.image = [UIImage imageNamed:@"4"];
    } else if (iPhone5) {
        bg.image = [UIImage imageNamed:@"5"];
    } else if (iPhone6) {
        bg.image = [UIImage imageNamed:@"6"];
    } else {
        bg.image = [UIImage imageNamed:@"6+"];
    }
    UIView *hud = [[UIView alloc] initWithFrame:self.view.bounds];
    hud.backgroundColor = [UIColor blackColor];
    hud.alpha = 0.2;
    [self.view addSubview:hud];
}

- (void)setupLogo {
    CGFloat y = 150;
    CGFloat w = 160;
    CGFloat x = self.view.centerX - w / 2;
    CGFloat h = 39;
    
    CGRect logoF = CGRectMake(x, y, w, h);
    UIImageView *logo = [[UIImageView alloc] initWithFrame:logoF];
    logo.image = [UIImage imageNamed:@"iVideo"];
    [self.view addSubview:logo];
}

- (void)setupBtns {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    LPCameraViewController *cameraVc = [[LPCameraViewController alloc] init];
//    [self.navigationController presentViewController:cameraVc animated:YES completion:nil];
    LPEditViewController *editVC = [[LPEditViewController alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:editVC animated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
