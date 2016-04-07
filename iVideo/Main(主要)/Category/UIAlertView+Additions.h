//
//  UIAlertView+Additions.h
//  iVideo
//
//  Created by apple on 16/3/30.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Additions)

+ (void)alertViewShowWithTitle:(NSString *)title
                       message:(NSString *)message
                      delegate:(id<UIAlertViewDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelButtonTitle
              otherButtonTitle:(NSString *)otherButtonTitle;

+ (void)alertViewShowWithTitle:(NSString *)title message:(NSString *)message;

@end
