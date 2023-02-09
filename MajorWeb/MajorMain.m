//
//  ViewController.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorMain.h"
#import "WebCoreManager.h"
#import "WebBoardView.h"
#import "MainView.h"
#import "WebCtrlCore.h"
#import "ZFAutoListParseManager.h"
#import "AddressBarView.h"
#import "VideoPlayerManager.h"
#import "MarjorWebConfig.h"
#import "AppDelegate.h"
#import "MajorModeDefine.h"
#import "MajorSystemConfig.h"
#import "ReactiveCocoa.h"
#import "UIViewController+GDTCtrl.h"
#import "GLLogging.h"
#import "GDtRootCtrl.h"
#import "GDtBannerRootCtrl.h"
#import "GDtInterstitialRootCtrl.h"
#import "GdtUserManager.h"
#import "AdvertGdtManager.h"
#import "ClickManager.h"
#import "MajorICloudSync.h"
#import "MajorPlayVideoHistory.h"
#import "WXApi.h"
#import "WebLiveParseManager.h"
#import "WebViewLivePlug.h"
#import "BUDAdManager.h"
#import "VipPayPlus.h"
#import "JsServiceManager.h"
#import "YSCHUDManager.h"
#import "WebPushView.h"
#import "MainMorePanel.h"
#import "TmpSetView.h"
#import "RemoveMarkWeb.h"
#import "VipEncryption.h"
#import <BUAdSDK/BUAdSDK.h>
#import "ClearCachesTool.h"
#import "helpFuntion.h"
#import "BuDNativeAdManager.h"
#import "NewVipPay.h"
#import "ZFAutoPlayerViewController.h"
#import "DNLAController.h"
#import "MarjorRedBag.h"
#import "BUAdSDK/BUSplashAdView.h"
#define AutoAlterVideo 1
#define WebTagNode 10
@interface MajorMain ()<WXApiDelegate,VipPayPlusPreLoadDelegate,BUSplashAdDelegate>
@property(nonatomic,strong)UIView *viewAdMaskView ;
@property(nonatomic,strong)WebBoardView *webBoardView;
@property(nonatomic,strong)MainView *mainView;
@property(nonatomic,strong)UIView *webView;//显示的web加载在这个上面
@property(nonatomic,strong)WebCtrlCore *webCreateCore;//
@property(nonatomic,assign)BOOL isAdLoadFinish;
@property(nonatomic,strong)BUBannerAdView *carouselBannerView;
@end

@implementation MajorMain

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *topWrite = [[UIView alloc] init];
    
    if (@available(iOS 13.0, *)) {
              UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
          GetAppDelegate.appStatusBarH =statusBarManager.statusBarFrame.size.height;
          }
          else{
            GetAppDelegate.appStatusBarH =[[UIApplication sharedApplication] statusBarFrame].size.height;
          }
    
    [self.view addSubview:topWrite];topWrite.backgroundColor = [UIColor whiteColor];
    [topWrite mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(GetAppDelegate.appStatusBarH);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openUrlFromCacheCell:) name:@"OpenUrlFromCacheCell" object:nil];
    GetAppDelegate.isCanCreateNewWeb=true;
    self.webView.backgroundColor = [UIColor whiteColor];
    [WebCoreManager getInstanceWebCoreManager];
    [MajorPlayVideoHistory getInstance];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView = [[UIView alloc] init];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.webBoardView = [[WebBoardView alloc] init];
    [self.view addSubview:self.webBoardView];
    
    self.mainView = [[MainView alloc] init];
    [self.view addSubview:self.mainView];
    [self.mainView initUI];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    __weak typeof(self) weakSelf = self;
    self.mainView.searchBlock = ^(WebConfigItem *webConfig) {
        [weakSelf loadUrlFromNewWeb:webConfig];
    };
    self.webCreateCore = [[WebCtrlCore alloc] init];
    [MarjorWebConfig getInstance];
    self.webBoardView.popWebViewBlock = ^(UIView *web) {
        [web removeFromSuperview];
        [weakSelf.webView addSubview:web];
        [weakSelf delayShowWeb:web];
        [weakSelf.view bringSubviewToFront:weakSelf.webView];
        web.tag = WebTagNode;
        [(ContentWebView*)web snapshotToExct];
        [weakSelf.webCreateCore updateFrontWebView:web];
        GetAppDelegate.isCanCreateNewWeb = true;
    };
    self.webBoardView.delWebViewBlock = ^(UIView *webView) {
        [weakSelf.webCreateCore removeContentWebView:webView];
    };
    self.webBoardView.clearAllBlock = ^{
        [weakSelf.webCreateCore clearAllWeb];
    };

    self.webBoardView.backHomeBlock = ^{
        [weakSelf loadSnycMarkFromLocal];
    };
    
    [self loadSnycMarkFromLocal];

    @weakify(self)
    
    [RACObserve([MajorICloudSync getInstance], isSyncToFinish) subscribeNext:^(id x) {
        @strongify(self)
        if ([MajorICloudSync getInstance].isSyncToFinish) {
            [self loadSyncFromICloud];
        }
    }];
    
    [RACObserve([MajorSystemConfig getInstance], isReqestFinish) subscribeNext:^(id x) {
        @strongify(self)
       MajorSystemConfig *majorConfig = [MajorSystemConfig getInstance];
        if(majorConfig.isReqestFinish){
            [[DNLAController getInstance] sdkAuthRequest];
            [[NewVipPay getInstance] autoLogin];
            if(majorConfig.isReqestFinish && ![MajorSystemConfig getInstance].isOpen)
            {
                [UIViewController hookViewController];
                [[GLLogging getInstance]setupWithConfiguration:nil];
                if(!majorConfig.gdtRootCtrl && majorConfig.isExcApla)
                {
                    CGSize size = majorConfig.appSize ;
                    majorConfig.gdtRootCtrl = [[GDtRootCtrl alloc]init];
                    [self.view addSubview:majorConfig.gdtRootCtrl.view];
                    majorConfig.gdtRootCtrl.view.frame = CGRectMake(0,size.height*20,size.width,size.height/2);
                    majorConfig.gdtBannerRootCtrl = [[GDtBannerRootCtrl alloc]init];
                    majorConfig.gdtBannerRootCtrl.view.backgroundColor = [UIColor blueColor];
                    majorConfig.gdtBannerRootCtrl.view.frame = CGRectMake(0,size.height*10,size.width,size.height/2);
                    [self.view  addSubview:majorConfig.gdtBannerRootCtrl.view];
                    majorConfig.gdtInterstitialRootCtrl = [[GDtInterstitialRootCtrl alloc]init];
                    majorConfig.gdtInterstitialRootCtrl.view.backgroundColor = [UIColor blueColor];
                    majorConfig.gdtInterstitialRootCtrl.view.frame = CGRectMake(0,size.height*12,size.width,size.height);
                    [self.view addSubview:majorConfig.gdtInterstitialRootCtrl.view];
#if DEBUG
                    [MajorSystemConfig getInstance].isGotoUserModel = 2;
#endif
                    [[GdtUserManager getInstance] initWithRootCtrl:self];
                    //以下代码初始化广告sdk会卡主，要用一个等待状态处理
                    //[YSCHUDManager showHUDOnKeyWindow];
                   // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  /*                      [MarjorWebConfig  clearAllCache];
                        [ClearCachesTool clearCache];
                        [ClearCachesTool clearWKWebKitCache];
                        [ClearCachesTool clearSDImageDefaultCache];
*/
                        
                        [VipPayPlus getInstance].delegate = self;
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vipPlayPlusDelegateLoadFinish) name:@"VideoStopCheckState" object:nil];
                    #if DEBUG
                    [self performSelector:@selector(delayReqeustAd) withObject:nil afterDelay:1000];
                    #else
                    [self performSelector:@selector(delayReqeustAd) withObject:nil afterDelay:30];
                    #endif
                    [self initWatchLibSDk];
                       // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showClickAdView) name:@"showClickAdView" object:nil];
                        //[YSCHUDManager hideHUDOnKeyWindow];
                   // });
                    //end 卡主
                }
            }
    }}];
    
    [RACObserve([JsServiceManager getInstance], isWebJsSuccess) subscribeNext:^(id x) {
        @strongify(self)
        if ([JsServiceManager getInstance].isWebJsSuccess) {
            [[WebLiveParseManager getInstance] startParse:self.view];
        }
    }];
    
    NSInteger w = [[helpFuntion gethelpFuntion] isVaildOneDayNotAutoAddExcTimesfixBug:NewVipWatchVideoTimesVaildCountKey nCount:NewVipWatchVideoTimesVaildCount intervalDay:1 isUseYYCache:YES time:nil];
    if (w==0) {
       // NSString *msgContent = @"今日没有广告了~";
       // [self.view makeToast:msgContent duration:7 position:@"center"];
    }
    
#ifdef DEBUG
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MarjorRedBag  *v = [[MarjorRedBag alloc] initWithNibName:@"MarjorRedBag" bundle:nil willCloseBlock:^{
              
          }];
          [self presentViewController:v animated:YES completion:^{
              
          }];
    });
#endif
}

-(void)delayReqeustAd{
    [[VipPayPlus getInstance] preloadAd];
}
    
-(void)vipPlayPlusDelegateLoadStart{
#if (AutoAlterVideo==1)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayReqeustAd) object:nil];
    self.isAdLoadFinish = false;
#endif
}

-(void)vipPlayPlusDelegateLoadFinish{//1242X2208
#if (AutoAlterVideo==1)
    self.isAdLoadFinish = true;
    [MajorSystemConfig getInstance].isStartVideoAdLoadfinish = true;
    [YSCHUDManager hideHUDOnKeyWindow];
    if ([[VipPayPlus getInstance] isCanPlayVideoAd:false] && !self.viewAdMaskView && [VipPayPlus getInstance].systemConfig.vip!=Recharge_User && ([VideoPlayerManager getVideoPlayInstance].player.isFullScreen && [ZFAutoPlayerViewController isFull])) {
        //[self showClickAdView];
    }
    else if([[VipPayPlus getInstance] isCanPlayVideoAd:false] && !self.viewAdMaskView && [VipPayPlus getInstance].systemConfig.vip!=Recharge_User && (![VideoPlayerManager getVideoPlayInstance].player.isFullScreen && ![ZFAutoPlayerViewController isFull]) ){
        static BOOL isGet = false;
        if (!isGet) {
            isGet = true;
            [self showClickAdView];
        }
    }
#endif
}

-(void)showClickAdView{
    if (!self.viewAdMaskView ) {
       // [[VideoPlayerManager getVideoPlayInstance] stop];
        self.viewAdMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        self.viewAdMaskView.backgroundColor = [UIColor blackColor];
        UIButton *btnVipMask = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        float h = MY_SCREEN_HEIGHT;
        float w = MY_SCREEN_HEIGHT*(1242/2208.0);
        [btnVipMask setFrame:CGRectMake((MY_SCREEN_WIDTH-w)/2, 0, w, h)];
        [btnVipMask setImage:UIImageFromNSBundlePngPath(@"main_load_ad_alter") forState:UIControlStateNormal];
        [btnVipMask addTarget:self action:@selector(clickAd:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewAdMaskView addSubview:btnVipMask];
        [[UIApplication sharedApplication].keyWindow addSubview:self.viewAdMaskView];
        self.viewAdMaskView.hidden = YES;
        
     
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self clickAd:nil];
           // [GetAppDelegate.window makeToast:@"每次启动软件只有一次广告" duration:3 position:@"center"];
       
        });
    }
}

-(void)clickAd:(UIButton*)sender{
    self.viewAdMaskView.hidden = YES;
  /*  if ([[VipPayPlus getInstance]isCanShowFullVideo]) {
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
        [[VipPayPlus getInstance] tryShowFullVideo:^{
            GetAppDelegate.isWatchHomeVideo = true;
            [[helpFuntion gethelpFuntion] isValideOneDay:@"showClickAdView_Vip" nCount:1 isUseYYCache:NO time:nil];
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
            [self.viewAdMaskView removeFromSuperview];self.viewAdMaskView = nil;
        }];
    }
    else{
        [self.viewAdMaskView removeFromSuperview];self.viewAdMaskView = nil;
    }
    return;*/
    @weakify(self)
    [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
    [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
        @strongify(self)
        if (isSuccess) {
            GetAppDelegate.isWatchHomeVideo = true;
           // [self watchFinishAtler];
            [[helpFuntion gethelpFuntion] isValideOneDay:@"showClickAdView_Vip" nCount:1 isUseYYCache:NO time:nil];
        }
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];

        [self.viewAdMaskView removeFromSuperview];self.viewAdMaskView = nil;
         [GetAppDelegate.window makeToast:@"每次启动软件只有一次广告" duration:3 position:@"center"];
     }isShowAlter:true isForce:NO];
}

-(void)openUrlFromCacheCell:(NSNotification*)object{
     ContentWebView *v =  (ContentWebView*)[self.webView viewWithTag:WebTagNode];
    if (v) {
        [v loaUrl:object.object config:nil];
    }
    else{
        WebConfigItem *config =[[WebConfigItem alloc] init];
        config.url  = object.object;
        [self loadUrlFromNewWeb:config];
    }
    [TmpSetView hidenTmpSetView];
}

-(void)initWatchLibSDk{
    static BOOL isIniWatchSDk = false;
    if(!isIniWatchSDk){
        [[BUDAdManager getInstance] initBudParam];
        [self addSplashAD];
        isIniWatchSDk = true;
        if ([VipPayPlus getInstance].systemConfig.vip!=General_User) {
            [[UIApplication sharedApplication].keyWindow makeToast:@"会员欢迎你" duration:2 position:@"center"];
            [self initGDTWhenVideoFinshes];
            return;
        }
        else{
            [self initGDTWhenVideoFinshes];
        }
        /*
        @weakify(self)
        TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"看两次视频广告,获得一天会员" message:nil];
        TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                       @strongify(self)
                                                       HomeAdShow *show =  [MainMorePanel getInstance].morePanel.homeADshow;
                                                       if([MarjorWebConfig isValid:show.beginTime a2:show.endTime]){
                                                           [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                               @strongify(self)
                                                               if (isSuccess) {
                                                                   GetAppDelegate.isWatchHomeVideo = true;
                                                                   [self watchFinishAtler];
                                                               }
                                                               [self initGDTWhenVideoFinshes];
                                                           }isShowAlter:NO];
                                                       }
                                                       else{
                                                           [self initGDTWhenVideoFinshes];
                                                       }
                                                   }];
         [alertView addAction:v];
        
        NSInteger times = [[VipPayPlus getInstance] getWatchVideoTimes];
        NSArray *array = nil;
        if (times==0) {
            array = @[@"视频1",@"视频2"];
        }
        else if(times==1){
            array = @[@"已观看",@"视频2"];
        }
        else {
            array = @[@"已观看",@"已观看"];
        }
        for (int i = 0; i < array.count; i++) {
            TYAlertAction *v1  = [TYAlertAction actionWithTitle:[array objectAtIndex:i]
                                                          style:TYAlertActionStyleDefault
                                                        handler:^(TYAlertAction *action) {
                                                             [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                                if (isSuccess) {
                                                                    GetAppDelegate.isWatchHomeVideo = true;
                                                                    [self watchFinishAtler];
                                                                }
                                                                 [self initGDTWhenVideoFinshes];
                                                             }isShowAlter:false];
                                                        }];
            [alertView addAction:v1];
        }
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];*/
    }
}

- (void)addSplashAD {
    CGRect frame = [UIScreen mainScreen].bounds;
    if ([MajorSystemConfig getInstance].bukaipinID) {
        BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:[MajorSystemConfig getInstance].bukaipinID frame:frame];
        splashView.tolerateTimeout = 10;
        splashView.delegate = self;
        UIWindow *keyWindow = GetAppDelegate.window;
        [splashView loadAdData];
        [keyWindow.rootViewController.view addSubview:splashView];
        splashView.rootViewController = keyWindow.rootViewController;
    }
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
 }

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    [splashAd removeFromSuperview];
  }

- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
 }

-(void)watchFinishAtler{
    NSInteger times = [[VipPayPlus getInstance] updateWatchVideoTimes];
    if (times<2) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜你获得本次会员" duration:2 position:@"center"];
    }
    else{
        [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜你获得今天会员" duration:2 position:@"center"];
    }
}

-(void)initGDTWhenVideoFinshes{
    MajorSystemConfig *majorConfig = [MajorSystemConfig getInstance];
    if(majorConfig.isGotoUserModel==2){//广告通和视频广告一起跑
        static BOOL isStartG = false;
        if (!isStartG) {
            isStartG = true;
             [[AdvertGdtManager getInstance] startRun:self];
            [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkClickState:) userInfo:nil repeats:YES];
        }
       /* [[BUDAdManager getInstance] setIsGotoUserModel:majorConfig.isGotoUserModel];
        majorConfig.isGotoUserModel = 0;
        @weakify(self)
        [RACObserve([BUDAdManager getInstance], isAdRemove) subscribeNext:^(id x) {
            @strongify(self)
            if ([BUDAdManager getInstance].isAdRemove) {
                static BOOL isStartG = false;
                if (!isStartG) {
                    isStartG = true;
                    majorConfig.isGotoUserModel =  [BUDAdManager getInstance].IsGotoUserModel;
                    [[AdvertGdtManager getInstance] startRun:self];
                    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkClickState:) userInfo:nil repeats:YES];
                }
            }
        }];*/
        [[BUDAdManager getInstance] start];
    }
    else{
        [[BUDAdManager getInstance] start];
        //   test_GDTCp();
    }
}

-(void)checkClickState:(NSTimer*)timer{
    int ire=[[ClickManager getInstance] isAllInfoClick:[MajorSystemConfig getInstance].gdtUserBannerInfo];
    if (ire==1) {
        [timer invalidate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[AdvertGdtManager getInstance]stopAllReqeust];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MajorSystemConfig getInstance].isGotoUserModel = 1;
                test_GDTCp();
                [GdtUserManager getInstance].gdtStatsMgr = [AdvertGdtManager getInstance].gdtStatsMgr;
                [[GdtUserManager getInstance] initWithRootCtrl:self];
            });
        });
    }
}

-(void)loadSyncFromICloud{
    [self.webBoardView removeFromSuperview];
    [self.mainView updateWebBoardView:self.webBoardView];
    [self.webCreateCore initData];
    [[MajorPlayVideoHistory getInstance] initData];
    [self.mainView loadSnycMarkFromLocal:[self.webCreateCore getAlllLocalMarkWeb]];
    GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
    GetAppDelegate.isFavoriteUpdate = !GetAppDelegate.isFavoriteUpdate;
    GetAppDelegate.isUserMainHomeUpdate = !GetAppDelegate.isUserMainHomeUpdate;
    [[MarjorWebConfig getInstance] initConfig];
}

-(void)loadSnycMarkFromLocal{
    [self.webBoardView removeFromSuperview];
    [self.mainView updateWebBoardView:self.webBoardView];
    [self.mainView loadSnycMarkFromLocal:[self.webCreateCore getAlllLocalMarkWeb]];
    [self.view bringSubviewToFront:self.mainView];
}

-(void)updateHisotryAndFavorite{
    [self.mainView updateHisotryAndFavorite];
}
//返回首页的时候
-(void)showAppHomeView{
    ContentWebView *view = [self.webView viewWithTag:WebTagNode];
    [view stopBanner];
    [self.webBoardView removeFromSuperview];
    [self.mainView updateWebBoardView:self.webBoardView];
    if (view) {
        [self.webBoardView addOneWeb:view];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MajorAppTjCellRefresh" object:nil];
    [self.view bringSubviewToFront:self.mainView];
}

//把所有网也当在标签上
-(void)showWebBoardView{
    [self.webBoardView removeFromSuperview];
    [self.webBoardView updateIsSize:self.view.bounds.size];
    self.webBoardView.frame = self.view.bounds;
    ContentWebView *view = [self.webView viewWithTag:WebTagNode];
    [view stopBanner];
    if (view) {
        [self.webBoardView addOneWeb:view];
    }
    [self.view addSubview:self.webBoardView];
    [self.view bringSubviewToFront:self.webBoardView];
}

- (void)loadUrlFromNewWeb:(WebConfigItem*)webConfig{
    if (!GetAppDelegate.isCanCreateNewWeb) {
        return;
    }
    GetAppDelegate.isCanCreateNewWeb = false;
    NSArray *arary = nil;
    ContentWebView *v = [self.webCreateCore createNewWebView:webConfig arrayBack:&arary];
    if(!v)
    {
        GetAppDelegate.isCanCreateNewWeb = true;
        return;
    }
    v.tag = WebTagNode;
    if (arary) {
        NSMutableArray *tmpArray = [NSMutableArray arrayWithObject:v];
        [tmpArray addObjectsFromArray:arary];
        //要做切换动画
        ContentWebView *view = [self.webView viewWithTag:WebTagNode];
        [view createSnapshotViewOfView:true];
        [view removeFromSuperview];
        [self.view bringSubviewToFront:self.webBoardView];
        [self.webBoardView updateChlidWeb:tmpArray popWeb:v];
    }
    else
    {
        GetAppDelegate.isCanCreateNewWeb = true;
        [self.webCreateCore updateFrontWebView:v];
        [self delayShowWeb:v];
        [self.webView addSubview:v];
        [self.view bringSubviewToFront:self.webView];
    }
}

-(void)delayShowWeb:(UIView*)view{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
}


-(BOOL)shouldAutorotate{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([VideoPlayerManager getVideoPlayInstance].player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    if ([WebPushView isShow]) {
        return true;
    }
    if ([ZFAutoPlayerViewController isFull]) {
        return true;
    }
    return [VideoPlayerManager getVideoPlayInstance].player.isStatusBarHidden;
}

-(BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return GetAppDelegate.supportRotationDirection;
//    if ([VideoPlayerManager getVideoPlayInstance].player.isFullScreen) {
//        return UIInterfaceOrientationMaskLandscape;
//    }
//    return UIInterfaceOrientationMaskPortrait;
}


-(void) onReq:(BaseReq*)req{
    
}

-(void) onResp:(BaseResp*)resp{
    
}


//测试支付
/*
static WGamePlatform *wSdkPlatform = nil;
- (void)init_WSDK{
    if (!wSdkPlatform){
        wSdkPlatform = [WGamePlatform shareInstance];
    }
    wSdkPlatform.rootVC = self;
    wSdkPlatform.delegate = self;
    wSdkPlatform.deviceID = @"123";
    wSdkPlatform.appId = 1;
    
    [wSdkPlatform initWGamePlatform];
}
*/
//登录
- (void)login_WSDK{
//    [wSdkPlatform loginWGamePlatform];
}

//注销
- (void)logout_WSDK{
  //  [wSdkPlatform logoutWGamePlatform];
}

//显示zhifu选择界面
- (void)showZhifu_WSDK:(NSInteger)productID attach:(NSString *)attach{
 //   wSdkPlatform.productID = productID;
 //   wSdkPlatform.attach = attach;
 //   [wSdkPlatform testByWGamePlatform];
}

#pragma WGameCallbackDelegate 实现登陆、注册、修改密码、绑定账号、游客登录的统一成功回调
- (void)loginSuccessBack{
    NSLog(@"loginSuccessBack");
    
    //APP收到回调就可以继续自己的游戏服登录了

}
@end
