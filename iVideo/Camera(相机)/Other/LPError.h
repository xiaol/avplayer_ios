//
//  LPError.h
//  iVideo
//
//  Created by apple on 16/1/18.
//  Copyright © 2016年 lvpin. All rights reserved.
//


extern NSString * const LPCameraErrorDomain;

typedef NS_ENUM(NSUInteger, LPCameraErrorCode) {
    LPCameraErrorCodeFailedToAddInput = 99,
    LPCameraErrorCodeFailedToAddOutput,
    LPCameraErrorHighFrameRateCaptureNotSupported
};