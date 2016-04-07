//
//  NSFileManager+Additions.m
//  iVideo
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "NSFileManager+Additions.h"

@implementation NSFileManager (Additions)

- (NSString *)temporaryFileDirectoryWithTemplateString:(NSString *)templateString {
    NSString *tmpString = [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];
    const char *tmpCStr = [tmpString fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(tmpCStr) + 1);
    strcpy(buffer, tmpCStr);
    NSString *dirPath = nil;
    char *result = mkdtemp(buffer);
    if (result) {
        dirPath = [self stringWithFileSystemRepresentation:buffer length:strlen(result)];
    }
    free(buffer);
    return dirPath;
}

@end
