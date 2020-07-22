//
//  MMBeautyRender.m
//  MMBeautyKit_Example
//
//  Created by sunfei on 2019/12/19.
//  Copyright © 2019 sunfei_fish@sina.cn. All rights reserved.
//

#import "MMBeautyRender.h"
#import <MMBeautyKit/CosmosBeautySDK.h>

@interface MMBeautyRender () <CosmosBeautySDKDelegate>

@property (nonatomic, strong) MMRenderModuleManager *render;
@property (nonatomic, strong) MMRenderFilterBeautyModule *beautyDescriptor;
@property (nonatomic, strong) MMRenderFilterLookupModule *lookupDescriptor;

@end

@implementation MMBeautyRender

- (instancetype)init {
    self = [super init];
    if (self) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
#if DEBUG
            [CosmosBeautySDK initSDKWithAppId:@"280f8ef2cec41cde3bed705236ab9bc4" delegate:self];
#else
            [CosmosBeautySDK initSDKWithAppId:@"6b38bc8e6afdbd040b8f6386b65c0aac" delegate:self];
#endif
        });
        
        MMRenderModuleManager *render = [[MMRenderModuleManager alloc] init];
        render.devicePosition = AVCaptureDevicePositionFront;
        self.render = render;
        
        MMRenderFilterBeautyModule *descriptor1 = [[MMRenderFilterBeautyModule alloc] init];
        [render registerFilterModule:descriptor1];
        
        MMRenderFilterLookupModule *descriptor2 = [[MMRenderFilterLookupModule alloc] init];
        [render registerFilterModule:descriptor2];
        
        self.beautyDescriptor = descriptor1;
        self.lookupDescriptor = descriptor2;
    }
    return self;
}

- (CVPixelBufferRef _Nullable)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer
                                          error:(NSError * __autoreleasing _Nullable *)error {
    return [self.render renderPixelBuffer:pixelBuffer error:error];
}

- (void)setInputType:(MMRenderInputType)inputType {
    self.render.inputType = inputType;
}

- (MMRenderInputType)inputType {
    return self.render.inputType;
}

- (void)setCameraRotate:(MMRenderModuleCameraRotate)cameraRotate {
    self.render.cameraRotate = cameraRotate;
}

- (MMRenderModuleCameraRotate)cameraRotate {
    return self.render.cameraRotate;
}

- (void)setDevicePosition:(AVCaptureDevicePosition)devicePosition {
    self.render.devicePosition = devicePosition;
}

- (AVCaptureDevicePosition)devicePosition {
    return self.render.devicePosition;
}

- (void)setBeautyFactor:(float)value forKey:(MMBeautyFilterKey)key {
    [self.beautyDescriptor setBeautyFactor:value forKey:key];
}

- (void)setEffect:(MMBeautyLookupEffect)effect {
    [self.lookupDescriptor setEffect:effect];
    [self.lookupDescriptor setIntensity:1.0];
}

- (void)setIntensity:(CGFloat)intensity {
    [self.lookupDescriptor setIntensity:intensity];
}

#pragma mark - delegate

// 发生错误时，不可直接发起 `+[CosmosBeautySDK prepareBeautyResource]` 重新请求，否则会造成循环递归
- (void)context:(CosmosBeautySDK *)context result:(BOOL)result detectorConfigFailedToLoad:(NSError * _Nullable)error {
    NSLog(@"cv load error: %@", error);
}

// 发生错误时，不可直接发起  `+[CosmosBeautySDK requestAuthorization]` 重新请求，否则会造成循环递归
- (void)context:(CosmosBeautySDK *)context
authorizationStatus:(MMBeautyKitAuthrizationStatus)status
requestFailedToAuthorization:(NSError * _Nullable)error {
    NSLog(@"authorization failed: %@", error);
}

@end
