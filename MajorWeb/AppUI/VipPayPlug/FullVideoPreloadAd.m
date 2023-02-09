//
//  VideoPreloadAd.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "FullVideoPreloadAd.h"
#import <AdSupport/AdSupport.h>
#import <BUAdSDK/BUAdSDK.h>
#import "AppDelegate.h"
 #import "MajorSystemConfig.h"
@interface FullVideoPreloadAd()<BUNativeExpressFullscreenVideoAdDelegate>
@property(copy,nonatomic)void(^closeAdBlock)(void);
@property(strong,nonatomic)BUNativeExpressFullscreenVideoAd *fullscreenAd;
@property(strong,nonatomic)NSTimer *checkChangeTimer;
@property(assign,nonatomic)BOOL isCanSetVipPayPlus;
@property(assign,nonatomic)BOOL isVaild;
@property(assign,nonatomic)BOOL isShowState;
@end

@implementation FullVideoPreloadAd
-(void)start:(void (^)(void))closeAdBlock{
    if (!self.fullscreenAd) {
        self.closeAdBlock = closeAdBlock;
        self.isCanSetVipPayPlus  =true;
        [self loadAdReqeust];
    }
}

-(void)loadAdReqeust{
     NSString *slotID = [MajorSystemConfig getInstance].buqpxxlID?[MajorSystemConfig getInstance].buqpxxlID:@"000";
    self.isVaild =false;
    self.isShowState = false;
    self.fullscreenAd = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:slotID];
    self.fullscreenAd.delegate = self;
    [self.fullscreenAd loadAdData];
}

-(void)stop{
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
    if (self.fullscreenAd) {
         self.fullscreenAd.delegate = NULL;
        self.fullscreenAd = NULL;
        self.isCanSetVipPayPlus  = false;
    }
}


-(void)changeAdVideo
{
    if (self.isCanSetVipPayPlus) {
        self.fullscreenAd.delegate = NULL;
        self.fullscreenAd = NULL;
        [self loadAdReqeust];
    }
}

-(void)reloadRequest{
    self.isShowState = false;
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
      self.checkChangeTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(changeAdVideo) userInfo:nil repeats:NO];
}

-(void)show{
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
    if (!self.isShowState) {
        self.isShowState = true;
        [self.fullscreenAd showAdFromRootViewController:GetAppDelegate.getRootCtrlView.nextResponder];
    }
}
#pragma --BUNativeExpressFullscreenVideoAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
  [self reloadRequest];
      NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
}

- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
    self.isVaild = true;
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
         self.checkChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1200 target:self selector:@selector(changeAdVideo) userInfo:nil repeats:NO];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
     NSLog(@"%s",__func__);
    [self reloadRequest];
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdWillVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
    self.isShowState = true;
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidClickSkip:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
    [self reloadRequest];
}

- (void)nativeExpressFullscreenVideoAdWillClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s",__func__);
    if (self.closeAdBlock) {
        self.closeAdBlock();
    }
    self.isVaild = false;
    [self reloadRequest];
 }

- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    NSLog(@"%s",__func__);
}

@end
