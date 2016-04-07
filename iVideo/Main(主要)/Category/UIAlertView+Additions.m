//
//  UIAlertView+Additions.m
//  iVideo
//
//  Created by apple on 16/3/30.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "UIAlertView+Additions.h"

@implementation UIAlertView (Additions)

+ (void)alertViewShowWithTitle:(NSString *)title message:(NSString *)message {
    [self alertViewShowWithTitle:title message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitle:nil];
}

+ (void)alertViewShowWithTitle:(NSString *)title
                       message:(NSString *)message
                      delegate:(id<UIAlertViewDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelButtonTitle
              otherButtonTitle:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:otherButtonTitle, nil];
    [alert show];
}

@end
