//
//  MMCameraViewController.m
//  MMBeautyKit_Example
//
//  Created by sunfei on 2019/12/17.
//  Copyright © 2019 sunfei_fish@sina.cn. All rights reserved.
//

#import "MMCameraViewController.h"
#import "MMCamera.h"
#import "MMDeviceMotionObserver.h"
#import "MMBeautyRender.h"
#import "MMCameraTabSegmentView.h"
@import MetalPetal;
@import AVFoundation;

@interface MMCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, MMDeviceMotionHandling>

@property (nonatomic, strong) MMCamera *camera;
@property (nonatomic, strong) MTIImageView *previewView;

@property (nonatomic, strong) MMBeautyRender *render;

@property (nonatomic, strong) MMCameraTabSegmentView *lookupView;
@property (nonatomic, strong) MMCameraTabSegmentView *beautyView;

@end

@implementation MMCameraViewController

- (void)dealloc {
    [MMDeviceMotionObserver removeDeviceMotionHandler:self];
    [MMDeviceMotionObserver stopMotionObserve];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    [self setupViews];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.camera = [[MMCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 position:AVCaptureDevicePositionFront];
    dispatch_queue_t queue = dispatch_queue_create("com.mmbeautykit.demo", nil);
    [self.camera enableVideoDataOutputWithSampleBufferDelegate:self queue:queue];
    
    [MMDeviceMotionObserver startMotionObserve];
    [MMDeviceMotionObserver addDeviceMotionHandler:self];
    
    self.render = [[MMBeautyRender alloc] init];
    self.render.inputType = MMRenderInputTypeStream;
}

- (void)setupViews {
    
    self.view.backgroundColor = UIColor.blackColor;
    
    self.previewView = [[MTIImageView alloc] initWithFrame:[UIScreen.mainScreen bounds]];
    [self.view addSubview:self.previewView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"flip" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(flipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.translatesAutoresizingMaskIntoConstraints = NO;
    [button2 setTitle:@"switch" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(switchButonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIStackView *vStackView = [[UIStackView alloc] initWithArrangedSubviews:@[button, button2]];
    vStackView.translatesAutoresizingMaskIntoConstraints = NO;
    vStackView.axis = UILayoutConstraintAxisVertical;
    vStackView.alignment = UIStackViewAlignmentCenter;
    vStackView.distribution = UIStackViewDistributionFill;
    vStackView.spacing = 8;
    [self.view addSubview:vStackView];
    
    [vStackView.widthAnchor constraintEqualToConstant:80].active = YES;
    [vStackView.heightAnchor constraintEqualToConstant:80].active = YES;
    [vStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    if (@available(iOS 11.0, *)) {
        [vStackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:100].active = YES;
    } else {
        [vStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100].active = YES;
    }
    
    MMCameraTabSegmentView *segmentView = [[MMCameraTabSegmentView alloc] initWithFrame:CGRectZero];
    segmentView.items = [self itemsForLookup];
    segmentView.translatesAutoresizingMaskIntoConstraints = NO;
    segmentView.hidden = YES;
    self.lookupView = segmentView;
    [self.view addSubview:segmentView];

    [segmentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [segmentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [segmentView.heightAnchor constraintEqualToConstant:160].active = YES;
    if (@available(iOS 11.0, *)) {
        [segmentView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        [segmentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    }

    segmentView.clickedHander = ^(MMSegmentItem *item) {
        [self.render setEffect:item.type];
        [self.render setIntensity:item.intensity];
    };

    segmentView.sliderValueChanged = ^(MMSegmentItem *item, CGFloat intensity) {
        [self.render setIntensity:intensity];
    };
   
    MMCameraTabSegmentView *segmentView2 = [[MMCameraTabSegmentView alloc] initWithFrame:CGRectZero];
    segmentView2.items = [self itemsForBeauty];
    segmentView2.backgroundColor = UIColor.clearColor;
    segmentView2.translatesAutoresizingMaskIntoConstraints = NO;
    self.beautyView = segmentView2;
    [self.view addSubview:segmentView2];

    [segmentView2.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [segmentView2.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [segmentView2.heightAnchor constraintEqualToConstant:160].active = YES;
    if (@available(iOS 11.0, *)) {
        [segmentView2.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        [segmentView2.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    }

    segmentView2.clickedHander = ^(MMSegmentItem *item) {
        [self.render setBeautyFactor:item.intensity forKey:item.type];
    };

    segmentView2.sliderValueChanged = ^(MMSegmentItem *item, CGFloat intensity) {
        [self.render setBeautyFactor:intensity forKey:item.type];
    };
}

- (void)switchButonClicked:(UIButton *)button {
    self.lookupView.hidden = !self.lookupView.hidden;
    self.beautyView.hidden = !self.beautyView.hidden;
}

- (NSArray<MMSegmentItem *> *)itemsForBeauty {
    NSArray *names = @[
        @"红润",
        @"美白",
        @"磨皮",
        @"大眼",
        @"瘦脸",
        @"鼻宽",
        @"脸宽",
        @"削脸",
        @"下巴",
        @"额头",
        @"短脸",
        @"祛法令纹",
        @"眼睛角度",
        @"眼距",
        @"眼袋",
        @"眼高",
        @"鼻子大小",
        @"鼻高",
        @"鼻梁",
        @"鼻尖",
        @"嘴唇厚度",
        @"嘴唇大小",
        @"宽颔",
    ];
    NSArray *types = @[
        kBeautyFilterKeyRubby,
        kBeautyFilterKeyWhitening,
        kBeautyFilterKeySmooth,
        kBeautyFilterKeyBigEye,
        kBeautyFilterKeyThinFace,
        kBeautyFilterKeyNoseWidth,
        kBeautyFilterKeyFaceWidth,
        kBeautyFilterKeyJawShape,
        kBeautyFilterKeyChinLength,
        kBeautyFilterKeyForehead,
        kBeautyFilterKeyShortenFace,
        kBeautyFilterKeyNasolabialFoldsArea,
        kBeautyFilterKeyEyeTilt,
        kBeautyFilterKeyEyeDistance,
        kBeautyFilterKeyEyesArea,
        kBeautyFilterKeyEyeHeight,
        kBeautyFilterKeyNoseSize,
        kBeautyFilterKeyNoseLift,
        kBeautyFilterKeyNoseRidgeWidth,
        kBeautyFilterKeyNoseTipSize,
        kBeautyFilterKeyLipThickness,
        kBeautyFilterKeyMouthSize,
        kBeautyFilterKeyJawWidth,
    ];
    
    NSArray *speciaTypes = @[
        kBeautyFilterKeyNoseWidth,
        kBeautyFilterKeyJawShape,
        kBeautyFilterKeyChinLength,
        kBeautyFilterKeyForehead,
        kBeautyFilterKeyEyeTilt,
        kBeautyFilterKeyEyeDistance,
        kBeautyFilterKeyNoseSize,
        kBeautyFilterKeyNoseLift,
        kBeautyFilterKeyNoseRidgeWidth,
        kBeautyFilterKeyNoseTipSize,
        kBeautyFilterKeyLipThickness,
        kBeautyFilterKeyMouthSize,
        kBeautyFilterKeyJawWidth
    ];
    
    NSMutableArray<MMSegmentItem *> *items = [NSMutableArray array];
    for (int i = 0; i < types.count; i ++) {
        MMSegmentItem *item = [[MMSegmentItem alloc] init];
        item.name = names[i];
        item.type = types[i];
        item.intensity = 0.0;
        if ([speciaTypes containsObject:item.type]) {
            item.begin = -1.0;
        } else {
            item.begin = 0.0;
        }
        item.end = 1.0;
        [items addObject:item];
    }
    return items.copy;
}

- (NSArray<MMSegmentItem *> *)itemsForLookup {
    NSArray *names = @[@"自然", @"清新", @"红颜", @"日系F2", @"少年时代", @"白鹭", @"复古", @"斯托克", @"野餐", @"弗洛达", @"罗马", @"烧烤", @"烧烤F2", @"冰激凌", @"凉白开", @"叛逆", @"可口", @"拿铁", @"日系", @"旧时光", @"海苔", @"灰调", @"焦糖", @"白梨", @"粉调", @"红调", @"芝士", @"藜麦", @"酥脆", @"雾感", @"鲜奶油"];
    NSArray *effects = @[
        kMMBeautyLookupEffectNatural,
        kMMBeautyLookupEffectFresh,
        kMMBeautyLookupEffectSoulmate,
        kMMBeautyLookupEffectSun,
        kMMBeautyLookupEffectBoyhood,
        kMMBeautyLookupEffectEgret,
        kMMBeautyLookupEffectRetro,
        kMMBeautyLookupEffectStoker,
        kMMBeautyLookupEffectPicnic,
        kMMBeautyLookupEffectFrida,
        kMMBeautyLookupEffectRome,
        kMMBeautyLookupEffectBroil,
        kMMBeautyLookupEffectBroilF2,
        kMMBeautyLookupEffectIceCream,
        kMMBeautyLookupEffectCoolWhite,
        kMMBeautyLookupEffectRebellious,
        kMMBeautyLookupEffectTasty,
        kMMBeautyLookupEffectLatte,
        kMMBeautyLookupEffectSunShine,
        kMMBeautyLookupEffectOld,
        kMMBeautyLookupEffectSeaweed,
        kMMBeautyLookupEffectGrayTone,
        kMMBeautyLookupEffectCaramel,
        kMMBeautyLookupEffectSnowPear,
        kMMBeautyLookupEffectPinkTone,
        kMMBeautyLookupEffectRedTone,
        kMMBeautyLookupEffectCheese,
        kMMBeautyLookupEffectQuinoa,
        kMMBeautyLookupEffectCrispy,
        kMMBeautyLookupEffectFoggy,
        kMMBeautyLookupEffectFreshCream,
    ];
    
    NSMutableArray<MMSegmentItem *> *items = [NSMutableArray array];
    for (int i = 0; i < effects.count; i ++) {
        MMSegmentItem *item = [[MMSegmentItem alloc] init];
        item.name = names[i];
        item.type = effects[i];
        item.intensity = 1.0;
        item.begin = 0.0;
        item.end = 1.0;
        [items addObject:item];
    }
    return items.copy;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.camera startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.camera stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {
        
        NSError *error = nil;
        CVPixelBufferRef renderedPixelBuffer = [self.render renderPixelBuffer:pixelBuffer error:&error];
        if (!renderedPixelBuffer || error) {
            NSLog(@"error: %@", error);
        } else {
            MTIImage *image = [[MTIImage alloc] initWithCVPixelBuffer:renderedPixelBuffer alphaType:MTIAlphaTypeAlphaIsOne];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.image = image;
            });
        }
    }
}

- (void)flipButtonTapped:(UIButton *)button {
    [self.camera rotateCamera];
    self.render.devicePosition = self.camera.currentPosition;
}

#pragma mark - MMDeviceMotionHandling methods

- (void)handleDeviceMotionOrientation:(UIDeviceOrientation)orientation {
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            self.render.cameraRotate = MMRenderModuleCameraRotate90;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.render.cameraRotate = MMRenderModuleCameraRotate0;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.render.cameraRotate = MMRenderModuleCameraRotate180;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.render.cameraRotate = MMRenderModuleCameraRotate270;
            break;
            
        default:
            break;
    }
}

@end
