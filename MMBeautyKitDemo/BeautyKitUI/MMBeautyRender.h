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
#import <MMBeautyKit/MMRenderFilterLookupModule.h>
#import <MMBeautyKit/MMRenderFilterStickerModule.h>
#import <MMBeautyKit/MMRenderFilterBigHeadEffectModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMBeautyRender : NSObject

// 如果是相机，需要传入前置/后置位置, 该参数仅在相机模式下设置
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;

// 目前摄像头相对于人脸的旋转角度, 该参数仅在相机模式下设置
@property (nonatomic, assign) MMRenderModuleCameraRotate cameraRotate;

// 图像数据形式, 默认MMRenderInputTypeStream。 相机或视频MMRenderInputTypeStream，静态图片MMRenderInputTypeStatic
@property (nonatomic, assign) MMRenderInputType inputType;

// 设置美颜参数
- (void)setBeautyFactor:(float)value forKey:(MMBeautyFilterKey)key;

// 设置lookup素材路径
- (void)setLookupPath:(NSString *)lookupPath;
// 设置lookup滤镜浓度
- (void)setLookupIntensity:(CGFloat)intensity;

// 设置贴纸资源路径
- (void)setMaskModelPath:(NSString *)path;
- (void)clearSticker;

- (CVPixelBufferRef _Nullable)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer
                                          error:(NSError * __autoreleasing _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
