//
//  AVMetadataItem+keyString.m
//  iVideo
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "AVMetadataItem+KeyString.h"

@implementation AVMetadataItem (keyString)

- (NSString *)keyString {
    if ([self.key isKindOfClass:[NSString class]]) {
        return (NSString *)self.key;
    } else if ([self.key isKindOfClass:[NSNumber class]]) {
        UInt32 value = [(NSNumber *)self.key unsignedIntValue];
        
        size_t length = sizeof(UInt32);
        if ((value >> 24) == 0) --length;
        if ((value >> 16) == 0) --length;
        if ((value >> 8)  == 0) --length;
        if ((value >> 0)  == 0) --length;
        
        long address = (unsigned long)&value;
        address += (sizeof(UInt32) - length);
        value = CFSwapInt32BigToHost(value);
        
        char cstring[length];
        strncpy(cstring, (char *)address, length);
        cstring[length] = '\0';
        
        if (cstring[0] == '\xA9') {
            cstring[0] = '@';
        }
        
        return [NSString stringWithCString:(char *)cstring encoding:NSUTF8StringEncoding];
    } else {
        return @"<unknown key type>";
    }
}

@end
