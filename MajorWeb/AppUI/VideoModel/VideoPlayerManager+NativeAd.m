//
//  VideoPlayerManager+Down.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "VideoPlayerManager+NativeAd.h"
#import "AppDelegate.h"
#import "BUDAdManager.h"
#import "NSDate+DateTools.h"
#import "MajorSystemConfig.h"
#import "VipPayPlus.h"
#import <AdSupport/AdSupport.h>
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "IQUIWindow+Hierarchy.h"
#import "MBProgressHUD.h"
static RACDisposable *nativeAdHandler=NULL;
static CGRect  oldsmallFloatViewRect;
static NSDate *dateTime;
#define unInitAdRacNotSetPos      [nativeAdHandler dispose]; \
nativeAdHandler = NULL; \
[self stopNativeAd];   

@implementation VideoPlayerManager(NativeAd)
-(void)initNativeAdRACObserve{
    return;
    unInitAdRacNotSetPos
    oldsmallFloatViewRect = self.player.smallFloatView.frame;
    if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
        @weakify(self)
        nativeAdHandler = [RACObserve(self.player.currentPlayerManager,playState) subscribeNext:^(id x) {
            @strongify(self)
            if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNativeAd) object:nil];
                [self performSelector:@selector(startNativeAd) withObject:nil afterDelay:1];
            }
        }];
    }
}


-(void)unitNaitveAdRACObserve{
    return;
    unInitAdRacNotSetPos
    if (oldsmallFloatViewRect.size.width>10) {
        self.player.smallFloatView.frame = oldsmallFloatViewRect;
    }
}

-(void)startNativeAd{
    return;
    if ([VipPayPlus getInstance].systemConfig.vip!=General_User) return;
    BOOL isCanAdd = true;
    if (dateTime && [[NSDate date]timeIntervalSinceDate:dateTime]<60 ) {
        isCanAdd = false;
    }
    if (!isCanAdd) return;
    dateTime = [NSDate date];
    self.player.smallFloatView.frame = CGRectMake(0, 0, MY_SCREEN_HEIGHT, MY_SCREEN_WIDTH);
    [self.player addPlayerViewToKeyWindow];
    [[VipPayPlus getInstance] reqeustVideoAd:NULL isShowAlter:YES isForce:false];
}



-(void)stopNativeAd{
    return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNativeAd) object:nil];
    [[VipPayPlus getInstance] stopVideoAd];
}

@end
