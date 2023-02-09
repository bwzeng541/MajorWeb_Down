//
//  BUDAdManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/21.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "BUDAdManager.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import "BUAdSDK/BUSplashAdView.h"
#import "MajorSystemConfig.h"
#import "VideoPlayerManager.h"
#import "VipPayPlus.h"
#import "AppDelegate.h"
#import "GdtUserManager.h"
#import "GDTMobInterstitial.h"
#import "IQUIWindow+Hierarchy.h"

@interface BUDAdManager ()<BUSplashAdDelegate,GDTMobInterstitialDelegate>
@property(nonatomic,assign)NSInteger showIndex;
@property(nonatomic,strong)GDTMobInterstitial *interstitialObj;
@property(nonatomic,assign)BOOL isClick;
@property(nonatomic,assign)BOOL isAdRemove;
@property(nonatomic,assign)int IsGotoUserModel;
@property(nonatomic,strong)NSDate *dateTime;
@property(nonatomic,strong)UIWindow *splashWindow;
@property(nonatomic,strong)NSTimer *checkReadyTime;
@property(nonatomic,assign)NSInteger currentTime;
@end

@implementation BUDAdManager


-(id)init{
    self = [super init];
    self.isAdRemove = true;
    [[NSNotificationCenter defaultCenter] addObserver:self
                             selector:@selector(applicationDidEnterBackground)
                                 name:UIApplicationDidEnterBackgroundNotification
                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                             selector:@selector(applicationWillEnterForeground)
                                 name:UIApplicationWillEnterForegroundNotification
                               object:nil];
    return self;
}

-(void)initBudParam{
    [BUAdSDKManager setAppID:[BUDAdManager appKey]];
    [BUAdSDKManager setIsPaidApp:NO];
}

+(BUDAdManager*)getInstance{
    static BUDAdManager*g = nil;
    if (!g) {
        g = [[BUDAdManager alloc] init];
    }
    return g;
}

+ (NSString *)appKey{
//#if DEBUG
   // return @"5010477";
//#endif
    return [MajorSystemConfig getInstance].buDAdappKey?[MajorSystemConfig getInstance].buDAdappKey:@"000";
}

-(void)setIsGotoUserModel:(int)saveState{
    _IsGotoUserModel = saveState;
}

-(void)updateTime:(NSDate*)date{
    self.dateTime = date;
}

-(void)start{
    if ([VideoPlayerManager getVideoPlayInstance].player.isFullScreen) {
        return;
    }
    BOOL isUsr = [[GdtUserManager getInstance] initAdInfo];
    if (!isUsr) {
        return;
    }
   
    if (GetAppDelegate.isWatchHomeVideo || [VipPayPlus getInstance].systemConfig.vip!=General_User || self.isClick){self.isAdRemove = true;return;}
    if (self.isAdRemove) {
        BOOL isCanAdd = false;
        if (self.dateTime && [[NSDate date] timeIntervalSinceDate:self.dateTime]<30 ) {
            isCanAdd = false;
        }
        if (isCanAdd) {
            if (self.showIndex>0) {
                self.dateTime = [NSDate date];
                self.isAdRemove = false;
                _interstitialObj.delegate = nil;
                _interstitialObj = nil;
                NSDictionary *info = [[GdtUserManager getInstance] getInterstitialInfo];
                NSString *appkey = [info objectForKey:@"appkey"];//@"1105344611";//
                NSString *placementId =  [info objectForKey:@"placementId"];//@"5030722621265924";//
                _interstitialObj = [[GDTMobInterstitial alloc] initWithAppId:appkey placementId:placementId];
                _interstitialObj.delegate = self;
                _interstitialObj.isGpsOn = false;
                [_interstitialObj loadAd];
                self.currentTime = 0;
                self.checkReadyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkInterStitial) userInfo:nil repeats:YES];
            }
            self.showIndex++;
        }
    }
}

-(void)checkInterStitial {
    if ([_interstitialObj isReady]) {
        [self.checkReadyTime invalidate];
        self.checkReadyTime = nil;
        [_interstitialObj presentFromRootViewController:[UIApplication sharedApplication].keyWindow.currentViewController];
    }
    else{
        self.currentTime++;
        if (self.currentTime>20) {
            [self stop];
        }
    }
}

-(void)stop{
    [self.checkReadyTime invalidate];
    self.checkReadyTime = nil;
    self.splashWindow.hidden = YES;
     self.isAdRemove = true;
    [[VideoPlayerManager getVideoPlayInstance] tryToPlay];
}

-(void)applicationDidEnterBackground{
    
}

-(void)applicationWillEnterForeground{
    if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
        [self start];
    }
}

- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial{
    
}

- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error{
    [self stop];
}

- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial{
    
}
/**
 *  插屏广告视图展示成功回调
 *  详解: 插屏广告展示成功回调该函数
 */
- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial{
    [[VideoPlayerManager getVideoPlayInstance] tryToPause];
}
/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial{
    self.dateTime = [NSDate date];
    [self stop];
}
/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial{
    self.dateTime = [NSDate date];
    [self stop];
}
/**
 *  插屏广告曝光回调
 */
- (void)interstitialWillExposure:(GDTMobInterstitial *)interstitial{

}
/**
 *  插屏广告点击回调
 */
- (void)interstitialClicked:(GDTMobInterstitial *)interstitial{
    self.isClick = true;
}
/**
 *  点击插屏广告以后即将弹出全屏广告页
 */
- (void)interstitialAdWillPresentFullScreenModal:(GDTMobInterstitial *)interstitial{
    
}
/**
 *  点击插屏广告以后弹出全屏广告页
 */
- (void)interstitialAdDidPresentFullScreenModal:(GDTMobInterstitial *)interstitial{
    
}
/**
 *  全屏广告页将要关闭
 */
- (void)interstitialAdWillDismissFullScreenModal:(GDTMobInterstitial *)interstitial{
    
}
/**
 *  全屏广告页被关闭
 */
- (void)interstitialAdDidDismissFullScreenModal:(GDTMobInterstitial *)interstitial{
    
}
#pragma mark --BUSplashAdDelegate
- (void)splashAdDidClick:(BUSplashAdView *)splashAd{
    NSLog(@"%s",__FUNCTION__);
    self.isClick = true;
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd{
    self.dateTime = [NSDate date];
    [self stop];
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillClose:(BUSplashAdView *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidLoad:(BUSplashAdView *)splashAd{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error{
    [self stop];
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillVisible:(BUSplashAdView *)splashAd{
    NSLog(@"%s",__FUNCTION__);
    [[VideoPlayerManager getVideoPlayInstance] tryToPause];
}
@end
