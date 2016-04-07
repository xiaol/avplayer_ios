//
//  SpeechController.h
//  iVideo
//
//  Created by apple on 15/12/31.
//  Copyright © 2015年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeechController : NSObject

@property (nonatomic, strong, readonly) AVSpeechSynthesizer *synthesizer;

+ (instancetype)speechController;

- (void)beginConversation;

@end
