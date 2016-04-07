//
//  NSFileManager+Additions.h
//  iVideo
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Additions)

// 生成路径唯一的临时文件
- (NSString *)temporaryFileDirectoryWithTemplateString:(NSString *)templateString;

@end
