//
//  AVCaptureDevice+HighFrameRate.h
//  iVideo
//
//  Created by apple on 16/1/13.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureDevice (HighFrameRate)
- (BOOL)supportsHighFrameRateCapture;
- (BOOL)enableHighFrameRateCaptureWithError:(NSError **)error;
@end
