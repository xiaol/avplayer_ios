//
//  LPCameraPreviewView.m
//  iVideo
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCameraPreviewView.h"

#define BOX_BOUNDS CGRectMake(0, 0, 150, 150.0f)

@interface LPCameraPreviewView ()
@property (nonatomic, strong) UIView *focusBox;
@property (nonatomic, strong) UITapGestureRecognizer *focusTapRecognizer;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSMutableDictionary *faceLayers;
@property (nonatomic, strong) CALayer *faceOverlayLayer;
@end

@implementation LPCameraPreviewView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.faceLayers = [NSMutableDictionary dictionary];
    
    // 设置人脸图层的透视效果(绕Y轴3D旋转)
    self.faceOverlayLayer = [CALayer layer];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0 / 2000;
    self.faceOverlayLayer.sublayerTransform = transform;
    
    _focusTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:_focusTapRecognizer];
    
    _focusBox = [self boxViewWithColor:[UIColor whiteColor]];
    [self addSubview:_focusBox];
}

- (UIView *)boxViewWithColor:(UIColor *)color {
    UIView *box = [[UIView alloc] initWithFrame:BOX_BOUNDS];
    box.backgroundColor = [UIColor clearColor];
    box.layer.borderColor = color.CGColor;
    box.layer.borderWidth = 5.0f;
    box.hidden = YES;
    return box;
}

- (void)setTapToFocusEnabled:(BOOL)tapToFocusEnabled {
    _tapToFocusEnabled = tapToFocusEnabled;
    self.focusTapRecognizer.enabled = tapToFocusEnabled;
}

- (void)setTapToExposeEnabled:(BOOL)tapToExposeEnabled {
    _tapToExposeEnabled = tapToExposeEnabled;
    // 
}

#pragma mark - video preview layer setup & config session
+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

// session关联layer, 确保二者同步
- (void)setSession:(AVCaptureSession *)session {
    [self.previewLayer setSession:session];
}

- (AVCaptureSession *)session {
    return [self.previewLayer session];
}

#pragma mark - screen point to device point
- (CGPoint)captureDevicePointFromPoint:(CGPoint)point {
    return [self.previewLayer captureDevicePointOfInterestForPoint:point];
}

#pragma mark - handle tap (focus)
- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    [self boxAnimationOnView:self.focusBox point:point];
    if (self.delegate && [self.delegate respondsToSelector:@selector(preview:tappedToFocusAtPoint:)]) {
        [self.delegate preview:self tappedToFocusAtPoint:point];
    }
}

- (void)boxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                     }
                     completion:^(BOOL finished) { // 0.5秒后消失
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             view.hidden = YES;
                             view.transform = CGAffineTransformIdentity;
                         });
                     }];
}

#pragma mark - face processing
// 展示人脸
- (void)showFaces:(NSArray *)faces {
    // 1. 坐标转换
    NSArray *tFaces = [self transformedFacesFromFaces:faces];
    // 2. 创建 移除的人脸id 数组
    NSMutableArray *lostFaceKeys = [self.faceLayers.allKeys copy];
    // 3. 处理每个屏幕内人脸
    for (AVMetadataFaceObject *face in tFaces) {
        // 3.1 对当前人脸, 先从移除数组中删除相应键
        NSNumber *faceID = @(face.faceID);
        [lostFaceKeys removeObject:faceID];
        // 3.2 如果是新脸, 操作如下
        CALayer *faceLayer = self.faceLayers[faceID];
        if (!faceLayer) {
            // 3.2.1 创建一个layer
            faceLayer = [self newFaceLayer];
            // 3.2.2 加至人脸覆盖图层显示
            [self.faceOverlayLayer addSublayer:faceLayer];
            // 3.2.3 存至字典
            self.faceLayers[faceID] = faceLayer;
        }
        // 3.3 设置人脸frame与transform
        faceLayer.transform = CATransform3DIdentity;
        faceLayer.frame = CGRectInset(face.bounds, 5, 5);
        // 3.4 根据倾斜角和偏转角更新transform
        if (face.hasRollAngle) {
            CATransform3D t = [self transformForRollAngle:face.rollAngle];
            faceLayer.transform = CATransform3DConcat(faceLayer.transform, t);
        }
        if (face.hasYawAngle) {
            CATransform3D t = [self transformForYawAngle:face.yawAngle];
            faceLayer.transform = CATransform3DConcat(faceLayer.transform, t);
        }
    }
    // 4. remove移除数组所对应的所有人脸
    for (NSNumber *faceID in lostFaceKeys) {
        CALayer *lostLayer = self.faceLayers[faceID];
        [lostLayer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }
}

// 将人脸坐标从设备坐标系转换至视图坐标系
- (NSArray *)transformedFacesFromFaces:(NSArray *)faces {
    NSMutableArray *transformedFaces = [NSMutableArray array];
    for (AVMetadataObject *face in faces) {
        AVMetadataObject *transformedFace = [self.previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaces addObject:transformedFace];
    }
    return transformedFaces;
}

- (CALayer *)newFaceLayer {
    CALayer *layer = [CALayer layer];
    layer.borderWidth = 3.0f;
    layer.borderColor = [UIColor yellowColor].CGColor;
    layer.cornerRadius = 3.0f;
    return layer;
}

// 倾斜变换(绕Z轴)
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngle {
    CGFloat radian = rollAngle * M_PI / 180;
    return CATransform3DMakeRotation(radian, 0.0f, 0.0f, 1.0f);
}

// 偏转变换(绕Y轴)
- (CATransform3D)transformForYawAngle:(CGFloat)rollAngle {
    CGFloat radian = rollAngle * M_PI / 180;
    CATransform3D yawT = CATransform3DMakeRotation(radian, 0.0f, - 1.0f, 0.0f);
    return CATransform3DConcat(yawT, [self orientationTransform]);
}

- (CATransform3D)orientationTransform {
    CGFloat angle = 0.0f;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = - M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}

@end
