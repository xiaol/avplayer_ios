//
//  AVCaptureDevice+HighFrameRate.m
//  iVideo
//
//  Created by apple on 16/1/13.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "AVCaptureDevice+HighFrameRate.h"
#import "LPError.h"

@interface LPCaptureQualityHelper : NSObject
@property (nonatomic, strong, readonly) AVCaptureDeviceFormat *format;
@property (nonatomic, strong, readonly) AVFrameRateRange *frameRateRange;
@property (nonatomic, assign, readonly, getter=isHighFrameRate) BOOL highFrameRate;

+ (instancetype)captureQualityHelperWithFormat:(AVCaptureDeviceFormat *)format
                                frameRateRange:(AVFrameRateRange *)frameRateRange;
@end

@implementation LPCaptureQualityHelper

+ (instancetype)captureQualityHelperWithFormat:(AVCaptureDeviceFormat *)format
                                frameRateRange:(AVFrameRateRange *)frameRateRange {
    return [[self alloc] initWithFormat:format
                         frameRateRange:frameRateRange];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                          frameRateRange:(AVFrameRateRange *)frameRateRange {
    if (self = [super init]) {
        _format = format;
        _frameRateRange = frameRateRange;
    }
    return self;
}

- (BOOL)isHighFrameRate{
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end

@implementation AVCaptureDevice (HighFrameRate)

- (LPCaptureQualityHelper *)helper {
    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxRange = nil;
    for (AVCaptureDeviceFormat *format in self.formats) { // 遍历所有format
        // 从formatDescription中获取codecType
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;
            
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > maxRange.maxFrameRate) {
                    maxFormat = format;
                    maxRange = range;
                }
            }
        }
    }
    return [LPCaptureQualityHelper captureQualityHelperWithFormat:maxFormat
                                                   frameRateRange:maxRange];
}

- (BOOL)supportsHighFrameRateCapture {
    if (![self hasMediaType:AVMediaTypeVideo]) {
        return NO;
    }
    return [self helper].isHighFrameRate;
}

- (BOOL)enableHighFrameRateCaptureWithError:(NSError **)error{
    LPCaptureQualityHelper *helper = [self helper];
    if (!helper.isHighFrameRate) {
        if (error) { // 若不支持高帧率, 给error赋值
            NSString *desc = @"High FPS capture not supported!!!";
            NSDictionary *info = @{NSLocalizedDescriptionKey : desc};
            *error = [NSError errorWithDomain:LPCameraErrorDomain
                                         code:LPCameraErrorHighFrameRateCaptureNotSupported
                                     userInfo:info];
        }
        return NO;
    }
    if ([self lockForConfiguration:error]) {
        CMTime minFrameDuration = helper.frameRateRange.minFrameDuration;
        self.activeFormat = helper.format;
        self.activeVideoMinFrameDuration = minFrameDuration;
        self.activeVideoMaxFrameDuration = minFrameDuration;
        [self unlockForConfiguration];
        return YES;
    }
    return NO;
}

@end
