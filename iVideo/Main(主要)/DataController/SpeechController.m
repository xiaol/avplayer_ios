//
//  SpeechController.m
//  iVideo
//
//  Created by apple on 15/12/31.
//  Copyright © 2015年 lvpin. All rights reserved.
//

#import "SpeechController.h"

@interface SpeechController ()

@property (nonatomic, strong) NSArray *voices;

/**
 *  models
 */
@property (nonatomic, strong) NSArray *speechStrings;

@end

@implementation SpeechController

+ (instancetype)speechController {
    return [[self alloc] init];
}

// initialize  synthesizer, voices
- (instancetype)init {
    if (self = [super init]) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"],
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"]];
        
        NSLog(@"%@", [AVSpeechSynthesisVoice currentLanguageCode]);
        unsigned int count;
        Ivar *ivars = class_copyIvarList([AVSpeechSynthesizer class], &count);
        for (int i = 0; i < count; i ++) {
            NSLog(@"ivar : %s", ivar_getName(ivars[i]));
        }
        
        free(ivars);
        
        Method *methods = class_copyMethodList([AVSpeechSynthesizer class], &count);
        for (int i = 0; i < count; i++) {
            NSLog(@"method: %@", NSStringFromSelector(method_getName(methods[i])));
        }
        free(methods);
        
//        NSArray *voiceCategories = [AVSpeechSynthesisVoice speechVoices];
//        for (AVSpeechSynthesisVoice *voice in voiceCategories) {
//            NSLog(@"%@", voice.language);
//        }
    }
    return self;
}

- (NSArray *)speechStrings {
    return @[@"赵书记, 你好!",
             @"你好, 有何贵干?",
             @"没事, 问问你吃了没?",
             @"吃啦!哈哈!"];
}

- (void)beginConversation {
    for (NSUInteger i = 0; i < self.speechStrings.count; i ++) {
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.speechStrings[i]];
        utterance.voice = self.voices[i % 2];
        utterance.rate = 0.4;
        utterance.postUtteranceDelay = 0.5;
        utterance.pitchMultiplier = 1.0;
        [self.synthesizer speakUtterance:utterance];
    }
}

@end
