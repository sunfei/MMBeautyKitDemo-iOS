//
//  MMBeautyRender.h
//  MMBeautyKit_Example
//
//  Created by sunfei on 2019/12/19.
//  Copyright © 2019 sunfei_fish@sina.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MMBeautyKit/MMRenderModuleManager.h>
#import <MMBeautyKit/MMRenderFilterBeautyModule.h>
#import <MMBeautyKit/MMRenderFilterBeautyKey.h>
#import <MMBeautyKit/MMRenderFilterLookupModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMBeautyRender : NSObject

// 如果是相机，需要传入前置/后置位置, 该参数仅在相机模式下设置
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;

// 目前摄像头相对于人脸的旋转角度, 该参数仅在相机模式下设置
@property (nonatomic, assign) MMRenderModuleCameraRotate cameraRotate;

// 图像数据形式, 默认MMRenderInputTypeStream。 相机或视频MMRenderInputTypeStream，静态图片MMRenderInputTypeStatic
@property (nonatomic, assign) MMRenderInputType inputType;

- (void)setBeautyFactor:(float)value forKey:(MMBeautyFilterKey)key;

- (void)setEffect:(MMBeautyLookupEffect)effect;
- (void)setIntensity:(CGFloat)intensity;

- (CVPixelBufferRef _Nullable)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer
                                          error:(NSError * __autoreleasing _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
