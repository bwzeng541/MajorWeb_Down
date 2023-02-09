//
//  GdtUserManager.m
//  grayWolf
//
//  Created by zengbiwang on 2018/6/4.
//

#import "GdtUserManager.h"
#import "MajorSystemConfig.h"
#import "AdvertGdtManager.h"
#import "GDTMobInterstitial.h"
#import "GDTNativeAd.h"
#import "IQUIWindow+Hierarchy.h"
#import "SSExpressNativeManager.h"

#define  GdtUserManagerClickIndex @"UserIndex20180629Index"
@interface GdtUserManager()<GDTMobBannerViewDelegate,GDTMobInterstitialDelegate>{
    GDTMobBannerView *_banner;     //原生广告实例
    GDTMobInterstitial *_interstitialObj;
    GDTMobBannerView *_tmpBanner;
    
    
    NSInteger _exPressIndex;
    BOOL isCanCreateNew;
    BOOL isClick;
}
@property(nonatomic, weak) UIView* interstitialView;
@property(nonatomic, weak) UIViewController* interstitialCtrl;
@property(strong)UIViewController *rootCtrl;
@property(strong)NSArray *bannerArray;
@property(strong)NSArray *interstitialArray;
@property(strong)NSArray *kaiPinArray;
@property(strong)NSArray *expressArray;

@property(assign)NSInteger index;

//@property(strong)NSTimer *checkInterstitiiTImer;
@property(strong)NSTimer *reSetClickTimer;
@property(strong)NSTimer *bbDisTimer;

@end

@implementation GdtUserManager
+(GdtUserManager*)getInstance{
    static GdtUserManager*g = nil;
    if (!g) {
        g = [[GdtUserManager alloc]init];
    }
    return g;
}

-(id)init{
    self = [super init];
    
    
    return self;
}

-(void)updateInterstitialRoot:(UIViewController*)ctrl showPartView:(UIView*)showPartView{
    self.interstitialCtrl = ctrl;
    self.interstitialView = showPartView;
}

-(void)setTmpBanner
{
    return;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _tmpBanner = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0,0,GDTMOB_AD_SUGGEST_SIZE_728x90.width,GDTMOB_AD_SUGGEST_SIZE_728x90.height)
                                                   appId:@"1234567" placementId:@"0000"];
    } else {
        _tmpBanner = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0,0,GDTMOB_AD_SUGGEST_SIZE_320x50.width,GDTMOB_AD_SUGGEST_SIZE_320x50.height)
                                                   appId:@"1234567" placementId:@"0000"];
    }
    _tmpBanner.delegate = self;
    _tmpBanner.interval = 30;
    _tmpBanner.isGpsOn = false;
    _tmpBanner.currentViewController =  self.rootCtrl;
    [self.rootCtrl.view addSubview:_tmpBanner];
    [_tmpBanner loadAdAndShow];
}

-(void)reSetAppInfo{
    NSString *pkgname = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"];
    NSString *appn = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"_appn"];
    NSString *appnversion = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"_app_version_code"];
    [[GetStatsMgrPro getInstance] setNewValue:self.gdtStatsMgr key:@"_an" value:pkgname];
    [[GetStatsMgrPro getInstance] setNewValue:self.gdtStatsMgr key:@"_appn" value:appn];
    [[GetStatsMgrPro getInstance] setNewValue:self.gdtStatsMgr key:@"_app_version_code" value:appnversion];
}

-(void)initWithRootCtrl:(UIViewController*)rootCtrl{
    if (![MajorSystemConfig getInstance].gdtUserBannerInfo) {
        return;
    }
    [SSExpressNativeManager getInstance].intsertitialBlock = ^(BOOL isClose) {
        isCanCreateNew = isClose;
    };
    self.rootCtrl = rootCtrl;
    self.bannerArray = [MajorSystemConfig getInstance].gdtUserBannerInfo;
    self.interstitialArray = [MajorSystemConfig getInstance].gdtUserInterstitial;
    self.kaiPinArray = [MajorSystemConfig getInstance].gdtUserKaiKaiPinInfo;
    self.expressArray = [MajorSystemConfig getInstance].gdtUserExpressInfo;
    [self setTmpBanner];
    isCanCreateNew = true;
    self.index = [[[NSUserDefaults standardUserDefaults] objectForKey:GdtUserManagerClickIndex] intValue];
    _exPressIndex = self.index;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GdtUserIDChange" object:nil];
}

-(BOOL)isRootCtrlVaild{
    if (!self.rootCtrl) {
        return false;
    }
    return true;
}

-(BOOL)checkStateShowInterstitial{
    if ([self isRootCtrlVaild] && [[SSExpressNativeManager getInstance]isShowExpressInterstitial:self.interstitialCtrl showPartView:self.interstitialView]) {
        return true;
    }
    return false;
}


-(NSDictionary*)getExpressInfo{
    if (self.rootCtrl && _exPressIndex<self.expressArray.count) {
        [MajorSystemConfig getInstance].gdtExpressAdInfo = [self.expressArray objectAtIndex:_exPressIndex];
        if (![MajorSystemConfig getInstance].gdtBannerAdInfo) {
            [MajorSystemConfig getInstance].gdtBannerAdInfo = [self.bannerArray objectAtIndex:_exPressIndex];
        }
        [self reSetAppInfo];
        return [MajorSystemConfig getInstance].gdtExpressAdInfo;
    }
    return nil;
}

-(NSDictionary*)getInterstitialInfo{
    if (self.rootCtrl && self.index<self.interstitialArray.count) {
        [MajorSystemConfig getInstance].gdtInterstitialAdInfo = [self.interstitialArray objectAtIndex:self.index];
        _exPressIndex = self.index;
        [self reSetAppInfo];
        return [MajorSystemConfig getInstance].gdtInterstitialAdInfo;
    }
    return nil;
}

-(NSDictionary*)getKaiPinInfo{
    if (self.rootCtrl && self.index<self.kaiPinArray.count) {
        [MajorSystemConfig getInstance].gdtKaiPinAdInfo = [self.kaiPinArray objectAtIndex:self.index];
        _exPressIndex = self.index;
        [self reSetAppInfo];
        return [MajorSystemConfig getInstance].gdtKaiPinAdInfo;
    }
    return nil;
}

-(NSDictionary*)getBannerInfo{
    if (self.rootCtrl && self.index<self.bannerArray.count) {
        [MajorSystemConfig getInstance].gdtBannerAdInfo = [self.bannerArray objectAtIndex:self.index];
        _exPressIndex = self.index;
        [self reSetAppInfo];
        return [MajorSystemConfig getInstance].gdtBannerAdInfo;
    }
    return nil;
}

-(BOOL)initAdInfo{
    return false;
    if (!self.rootCtrl || !isCanCreateNew) {
        return false;
    }
    if (isClick) {
        //return false;
    }
    RemoveViewAndRelease(_banner)
    [_interstitialObj release];
    _interstitialObj = nil;
    isClick = false;
    [self.bbDisTimer invalidate];self.bbDisTimer=nil;
    if (self.index>=self.bannerArray.count) {
        self.index = 0;
    }
    if (self.index<self.bannerArray.count) {
        _exPressIndex = self.index;
        [MajorSystemConfig getInstance].gdtBannerAdInfo = [self.bannerArray objectAtIndex:self.index];
        [MajorSystemConfig getInstance].gdtInterstitialAdInfo = [self.interstitialArray objectAtIndex:self.index];
        [MajorSystemConfig getInstance].gdtKaiPinAdInfo = [self.kaiPinArray objectAtIndex:self.index];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"GdtUserIDChange" object:nil];
        [self reSetAppInfo];
        [self setBanner:[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"appkey"] placementId:[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"]];
        [self setInterstitialInfo:[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"appkey"] placementId:[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"]];
        self.index++;
    }
    if(self.index>=self.bannerArray.count){
        self.index = 0;
    }
    [self updateGdtUserManagerClickIndex];
    return true;
}

-(void)updateGdtUserManagerClickIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.index]  forKey:GdtUserManagerClickIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showit{
    if (!self.rootCtrl) {
        return;
    }
    if( _interstitialObj && _interstitialObj.isReady ){//加载topWIndo
        if (self.interstitialCtrl) {
            [_interstitialObj presentFromRootViewController:self.interstitialCtrl];//self.rootCtrl
        }
        else {
            [_interstitialObj presentFromRootViewController:self.rootCtrl];//self.rootCtrl
        }
    }
    if (_banner) {
       CGRect rect = _banner.frame;
        rect.origin.y=self.rootCtrl.view.bounds.size.height-rect.size.height*2;
        rect.origin.x=self.rootCtrl.view.bounds.size.width/2-rect.size.width/2;
        _banner.frame = rect;
    }
}

-(void)setInterstitialInfo:(NSString*)appKey placementId:(NSString*)placementId{
    _interstitialObj = [[GDTMobInterstitial alloc] initWithAppId:appKey placementId:placementId];
    _interstitialObj.delegate = self;
    _interstitialObj.isGpsOn = false;
    [_interstitialObj loadAd];
}

-(void)setBanner:(NSString*)appKey placementId:(NSString*)placementId{
    return;
    RemoveViewAndRelease(_banner)
    RemoveViewAndRelease(_tmpBanner)
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
    _banner.currentViewController =  self.rootCtrl;
    [self.rootCtrl.view addSubview:_banner];
    [_banner loadAdAndShow];
}

-(void)startSetTimer{
    [self.reSetClickTimer invalidate];
    self.reSetClickTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(ggg) userInfo:nil repeats:YES];
}

-(void)ggg
{
    [self.reSetClickTimer invalidate];
    self.reSetClickTimer = nil;
    isClick  = false;
}

#pragma mark banner delegate
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial
{
   // printf("GDTMobInterstitial loadOk %s",[[GetAppDelegate.gdtInterstitialAdInfo objectForKey:@"placementId"] UTF8String]);
}

- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error{
    
}

- (void)bannerViewDidReceived:(GDTMobInterstitial *)interstitial
{
   // printf("bannerViewDidReceived loadOk %s\n",[[GetAppDelegate.gdtBannerAdInfo objectForKey:@"placementId"] UTF8String]);
}

- (void)bannerViewFailToReceived:(NSError *)error
{
   // printf("banner failed to Received : %s bannerid = %s\n",[[error description] UTF8String],[[GetAppDelegate.gdtBannerAdInfo objectForKey:@"placementId"] UTF8String]);
}

-(void)bannerViewWillExposure{
  //  printf("banner bannerViewWillExposure  bannerid = %s\n",[[GetAppDelegate.gdtBannerAdInfo objectForKey:@"placementId"] UTF8String]);
}

- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial{
    isCanCreateNew = false;
}

- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial{
    isCanCreateNew = true;
    [self.bbDisTimer invalidate];self.bbDisTimer=nil;
}

- (void)interstitialClicked:(GDTMobInterstitial *)interstitial{
    [self startSetTimer];
    isClick = true;
}

- (void)bannerViewClicked{
    [self startSetTimer];
    isClick = true;
}
/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial{
    
}
@end
