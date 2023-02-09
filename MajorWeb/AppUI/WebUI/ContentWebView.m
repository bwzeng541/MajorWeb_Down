
#import "ContentWebView.h"
#import "WebCoreManager.h"
#import "MajorWebView.h"
#import "AddressToolbarView.h"
#import "BottomToolsView.h"
#import "FileCache.h"
#import "MarjorWebConfig.h"
#import "VideoPlayerManager.h"
#import "ReadModeWeb.h"
#import "AppDelegate.h"
#import "UIAlertView+NSCookbook.h"
#import "ZYInputAlertView.h"
#import "POP.h"
#import "BottommTipsView.h"
#import "YBImageBrowserModel.h"
#import "MajorPicView.h"
#import "WebTopChannel.h"
#import "GoBackWebView.h"
#import "FTWCache.h"
#import "WebDesListView.h"
#import "MainMorePanel.h"
#import "ApiCoreManager.h"
#import "MajorSystemConfig.h"
#import "NSObject+UISegment.h"
#import "MajorFeedbackKit.h"
#import "ShareSdkManager.h"
#import "YTKNetworkPrivate.h"
#import "VideoPlayerManager+Down.h"
#import "WebGeneralTools.h"
#import "VipPayPlus.h"
#import "MarjorRedBag.h"
#import "VipPayPlus.h"
#import "MajorPrivacyHome.h"
#import <BUAdSDK/BUAdSDK.h>
#import "GDTUnifiedBannerView.h"
#import "MoreBeatfiyWebsView.h"
#import "BeatifyWebAdManager.h"
#import "BeatifyWebTopTools.h"
#import "helpFuntion.h"
#import "BeatifyAdListView.h"
#import "BeatifyGDTNativeView.h"
#import "BeatifyWebPicsView.h"
#import "QrMutilLineScanCtrl.h"
#import "QRSearchCtrl.h"
#import "QRRankCtrl.h"
#if DoNotKMPLayerCanShareVideo
#else
#import "ContentWebView+PlayLocalCaches.h"
#endif
#define MoreBeatfiyWebsViewTag 101
#define PlayVideoTishiViewTag 100
#define WebLeaveReadMode   [self.readModeBtn setImage:[UIImage imageNamed:@"Brower.bundle/ss_bottom_readMode_btn"] forState:UIControlStateNormal]; \
isInReadMode = false; \
[self.readModeWeb removeFromSuperview];self.readModeWeb = nil;

static BOOL isClickBeatifyPlugCtrlAd = false;
#define AddBannerClickKey @"20191010160108_key"
@interface ContentWebView()<BUNativeExpressAdViewDelegate,BeatifyAdListViewDelegate,BeatifyWebTopToolsDelegate,WebCoreManagerDelegate,AddressToolbarViewDelegate,ReadModeWebCallBack,BUBannerAdViewDelegate,MajorPrivacyHomeDelegate,GDTUnifiedBannerViewDelegate,QrMutilLineScanCtrlDelegate>{
    BOOL isInReadMode;
    BOOL isHidden;
    BOOL isHiddenTop;
    BOOL isAlterView;
    BOOL isInBack;
    float btnsViewh;
    BOOL  isInitFixBug ;
    CGRect scaleRect;
    BOOL  isShowAdAlter;
    BOOL  isLoadAdSuucess;
}
@property (nonatomic, strong)QRSearchCtrl *searchCtrl;
@property (nonatomic, strong)QRRankCtrl *rankCtrl;
@property (nonatomic, strong)NSDate *reLoadDate;
@property (nonatomic, strong)QrMutilLineScanCtrl *mutilLineCtrl;
@property (nonatomic, strong) BeatifyWebPicsView *webPicsView;
@property (nonatomic, strong) BUNativeExpressAdManager *adManager;
@property (nonatomic, strong) BUNativeExpressAdView *nativeAd;
@property(nonatomic,strong)NSMutableArray *expressAdViews;
@property(nonatomic,strong)UIView *rightGdtAdView;
@property(nonatomic,assign)CGRect rightGdtAdViewRect;
@property(strong,nonatomic)BeatifyAdListView *adListView;
@property(strong,nonatomic)BeatifyWebTopTools *topTools;
@property(assign,nonatomic)CGRect bannerAdRect;
@property(nonatomic,strong)GDTUnifiedBannerView *carouselBannerView ;
@property(assign,nonatomic)BOOL isPadLand;
@property(copy,nonatomic)NSString *currentHost;
@property(strong,nonatomic)UIProgressView  *webProgressView;
@property(assign,nonatomic)BOOL  isScaleState;
@property(strong,nonatomic)UIButton *scaleBtn;
@property(strong,nonatomic)UIButton *changeWebOrientation;
@property(strong,nonatomic)NSDate *clickBackTime;
@property(strong,nonatomic)WebDesListView *webDesAllView;
@property(strong,nonatomic)UIView *bottomBtnsView;
@property(strong,nonatomic)NSString *tmpVideoUrl;//避免多次加载
@property(strong,nonatomic)GoBackWebView *goBackWebView;
@property(assign,nonatomic)BOOL isRemoveAdMode;
@property(strong,nonatomic)ReadModeWeb *readModeWeb;
@property(assign,nonatomic)BOOL isAutoPlay;
@property(copy,nonatomic)NSString *requestUrl;
@property(copy,nonatomic)NSString *recordReadModeUrl;
@property(strong,nonatomic)UIImageView *snapshotView;
@property(strong,nonatomic)MajorWebView *marjorWebView;
@property(strong,nonatomic)AddressToolbarView *addressToolBar;
@property(strong,nonatomic)WebGeneralTools *webGeaneralTools;
@property(strong,nonatomic)BottomToolsView *bottomTools;
@property(strong,nonatomic)WebTopChannel *webChannelView;
@property(assign,nonatomic)BOOL isFrontWeb;
@property(copy,nonatomic)NSString *title;

@property(copy,nonatomic)NSString *current_Url;
@property(copy,nonatomic)NSString *mediaUrl;
@property(copy,nonatomic)NSString *mediaTitle;
@property(copy,nonatomic)NSString *mediaReferer;

@property(copy,nonatomic)NSString *iconUrl;
@property(nonatomic,strong)UIButton *showListBtn;
@property(nonatomic,strong)UIButton *playBtn;
@property(nonatomic,strong)UIButton *readModeBtn;
@property(nonatomic,copy)NSDictionary *contentInfo;
@property(nonatomic,copy)NSDictionary *nextInfo;

@property(nonatomic,strong)NSData *snapsthotSmallData;
@property(nonatomic,strong)NSString *webUUID;

@property(nonatomic,strong)WebConfigItem *webUserConfig;
@property(nonatomic,copy)NSArray *webTopArray;
@property(nonatomic,assign)BOOL isForceOpenThird;
@property(nonatomic,copy)NSString *userAgent;
@property(nonatomic,assign)BOOL isForceUseIjk;

@property(nonatomic,strong)NSTimer *dealyAddbanner;

#if (UseBeatifyAppJs==1)
@property(copy,nonatomic)NSString *assetUrl;
@property(assign,nonatomic)BOOL isAsset;
#endif
@end

@implementation ContentWebView
@synthesize marjorWebView = _marjorWebView;
#pragma mark --banner

-(void)stopGDTAD{
    isLoadAdSuucess = false;
    self.reLoadDate = NULL;
    [self.rightGdtAdView removeFromSuperview];self.rightGdtAdView = nil;
    self.adManager.delegate = nil;
    self.adManager = nil;
    self.nativeAd = nil;
    [self.marjorWebView evaluateJavaScript:@"removeaAdAdXinxlTimer()" completionHandler:nil];
}

-(MajorWebView*)marjorWebView{
    if (!_marjorWebView) {
        _marjorWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:self.requestUrl isAutoSelected:YES delegate:self];
    }
    return _marjorWebView;
}

-(void)loadGDTAD{
    if ( !self.adManager && !isClickBeatifyPlugCtrlAd &&!self.reLoadDate && [VipPayPlus getInstance].systemConfig.vip!=Recharge_User) {//800X1200
        isLoadAdSuucess = false;
       float adw = self.rightGdtAdView.frame.size.width;
          BUAdSlot *slot1 = [[BUAdSlot alloc] init];
            slot1.ID = @"942650625";
            slot1.AdType = BUAdSlotAdTypeFeed;
            slot1.position = BUAdSlotPositionFeed;
            slot1.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
            slot1.isSupportDeepLink = YES;
            float ww =  adw;
             if (!self.adManager) {
                self.adManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(ww, 0)];
            }
            self.adManager.adSize = CGSizeMake(ww, 0);
            self.adManager.delegate = self;
            self.expressAdViews = [NSMutableArray arrayWithCapacity:1];
            [self.adManager loadAd:1];
        self.reLoadDate = [NSDate date];
      }
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords{
    [self stopGDTAD];
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView{
    isClickBeatifyPlugCtrlAd = true;
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView{
    
     if (!nativeExpressAdView.superview) {
           UIView *paretView = nil;
         self.nativeAd = nativeExpressAdView;
           if(self.rightGdtAdView.subviews.count==0){
               paretView = self.rightGdtAdView;
           }
           if (nativeExpressAdView.frame.size.height<paretView.frame.size.height) {
               paretView.frame = CGRectMake( paretView.frame.origin.x,  paretView.frame.origin.y,  paretView.frame.size.width, nativeExpressAdView.frame.size.height);
           }
           else{
               paretView.frame = CGRectMake( paretView.frame.origin.x,  paretView.frame.origin.y,  paretView.frame.size.width, nativeExpressAdView.frame.size.height);
           }
          self.rightGdtAdViewRect = paretView.frame;
           [paretView addSubview:nativeExpressAdView];
           [nativeExpressAdView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.edges.equalTo(paretView);
           }];
         isLoadAdSuucess = true;
         [self updateRightGdtAdView:false];
       }
}

- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views{
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
       if (self.expressAdViews.count) {
           [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
               expressView.rootViewController = GetAppDelegate.window.rootViewController;
               [expressView render];
           }];
       }
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *_Nullable)error{
    self.reLoadDate = nil;
    isLoadAdSuucess = false;
    [self stopGDTAD];
}

-(void)startBanner{
    [self.dealyAddbanner invalidate];self.dealyAddbanner = nil;
    if ([[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:AddBannerClickKey nCount:1 intervalDay:4 isUseYYCache:NO time:nil]) {
        self.dealyAddbanner = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(delayAddBanner) userInfo:nil repeats:YES];
    }
}

-(void)delayAddBanner{
    [self.dealyAddbanner invalidate];self.dealyAddbanner = nil;
    [[MajorSystemConfig getInstance] updateBannerZeor:true];
    [[MajorSystemConfig getInstance] setBannerRect];
    self.bannerAdRect = [MajorSystemConfig getInstance].bannerAdRect;
    if (self.bannerAdRect.size.height<10) {
        return;
    }
    if (!self.carouselBannerView) {
        NSString *key = @"910477474";
#if DEBUG
        key = @"910644095";
#endif
        //覆盖到工具栏上
        self.bannerAdRect = CGRectMake((MY_SCREEN_WIDTH-self.bannerAdRect.size.width)/2, MY_SCREEN_HEIGHT-self.bannerAdRect.size.height-(GetAppDelegate.appStatusBarH-20)-10, self.bannerAdRect.size.width, self.bannerAdRect.size.height);
        self.carouselBannerView = [[GDTUnifiedBannerView alloc]
                                   initWithFrame:self.bannerAdRect appId:@"1109675609"
                                   placementId:@"8080589358776897"
                                   viewController:GetAppDelegate.window.rootViewController];
        _carouselBannerView.animated =  NO;
        _carouselBannerView.autoSwitchInterval = 0;
        _carouselBannerView.delegate = self;
        self.carouselBannerView.delegate = self;
        [self addSubview:self.carouselBannerView];
        self.bannerAdRect  = CGRectMake(0, GetAppDelegate.appStatusBarH, 0, 0);
        [self.carouselBannerView loadAdAndShow];
        [self updateWebProgressAndWeb];
    }
}

- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s ",__FUNCTION__);
}

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error{
    NSLog(@"%s error = %@",__FUNCTION__,[error description]);
}

- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView{
    [[VideoPlayerManager getVideoPlayInstance] stop];
    [[helpFuntion gethelpFuntion] isValideCommonDay:AddBannerClickKey nCount:1 intervalDay:4 isUseYYCache:NO time:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayAdjustBanner) object:nil];
    [self performSelector:@selector(delayAdjustBanner) withObject:nil afterDelay:20];
}

- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView{
    NSLog(@"%s",__FUNCTION__);//禁止点击关闭按钮
    [self delayAdjustBanner];
}

- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayAdjustBanner) object:nil];
    [self performSelector:@selector(delayAdjustBanner) withObject:nil afterDelay:20];
}

- (void)unifiedBannerViewDidDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView{
    NSLog(@"%s",__FUNCTION__);
    [self delayAdjustBanner];
}

-(void)stopBanner{
    [self.dealyAddbanner invalidate];self.dealyAddbanner = nil;
    [self.carouselBannerView removeFromSuperview];
    self.carouselBannerView = nil;
    [[MajorSystemConfig getInstance] updateBannerZeor:true];
    [[MajorSystemConfig getInstance] setBannerRect];
    self.bannerAdRect = [MajorSystemConfig getInstance].bannerAdRect;
    [self updateWebProgressAndWeb];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayAdjustBanner) object:nil];
}

-(void)videoWillChangeFull:(NSNotification*)object{
    if ([object.object boolValue]) {
        [self stopBanner];
    }
}

-(void)videoDidChangeFull:(NSNotification*)object{
    if (![object.object boolValue]) {
        [self startBanner];
    }
}

-(void)delayAdjustBanner{
    [self stopBanner];
}


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
-(void)updateShowState:(BOOL)showState{
    if(showState){
        [[WebCoreManager getInstanceWebCoreManager] updateUseWKWebview:self.marjorWebView];
    }
    self.isFrontWeb = showState;
}

-(void)removeFromSuperviewAndDesotryWeb{
    [self stopGDTAD];
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.marjorWebView];
    self.marjorWebView = nil;
    self.addressToolBar = nil;
    self.readModeWeb = nil;self.snapsthotSmallData = nil;
    [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/%@.png",AppNotSynchronizationDir,self.webUUID] error:nil];
    [self removeFromSuperview];
}

-(void)removeFromSuperview{
    self.rankCtrl = nil; self.searchCtrl=nil;
    [super removeFromSuperview];
}

-(void)adList_WillRemove:(BOOL)isReload{
    [self.adListView removeFromSuperview];self.adListView=nil;
    if (isReload) {
        [self.marjorWebView reload];
    }
}

-(void)top_clickWebHostUrl{
    if (!isInReadMode) {
        NSString *host = [self.marjorWebView.URL host];
        if ([host rangeOfString:@"hangzhou.aliyuncs"].location ==NSNotFound) {
            [self.marjorWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",[self.marjorWebView.URL scheme],host]]]];
        }
    }
}

-(void)top_clickWebHostWebRank{
    if (!isInReadMode && !self.rankCtrl) {
    __weak typeof(self) weakSelf = self;
    self.rankCtrl=[[QRRankCtrl alloc] initWithNibName:@"QRRankCtrl" bundle:nil];
    self.rankCtrl.view.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.rankCtrl.view];
    [self.rankCtrl setBlock:^(NSString * _Nonnull url) {
            
                [weakSelf loadUrl:url];
    } willRemoveBlock:^{
                [weakSelf.rankCtrl.view removeFromSuperview];
                weakSelf.rankCtrl = nil;
            }];
    return;
//        NSArray *array =   [[BeatifyWebAdManager getInstance]getAdDomCssAndTime:self.current_Url];
//        if (!self.adListView && array.count>0) {
//            _adListView = [[BeatifyAdListView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width , self.frame.size.height)];
//            //遵守协议
//            _adListView.delegate = self;
//            //传递数据
//            [_adListView showThePopViewWithArray:[NSMutableArray arrayWithArray:array]md5:self.current_Url];
//        }
//        else{
//            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"此网站还没有已经屏蔽的广告" message:@"请按住广告图片，然后选择\"屏蔽广告\"，每个网站有多个广告，需要多选择几次"];
//            alertView.buttonFont = [UIFont systemFontOfSize:14];
//            TYAlertAction *quxiao  = [TYAlertAction actionWithTitle:@"确定"
//                                                              style:TYAlertActionStyleDefault
//                                                            handler:^(TYAlertAction *action) {
//                                                            }];
//            [alertView addAction:quxiao];
//            [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
//        }
    }
}

-(void)top_clickWebHostSearchVideo{
    if (!isInReadMode && !self.searchCtrl) {
        __weak __typeof(self)weakSelf = self;
        self.searchCtrl= [[QRSearchCtrl alloc] initWithNibName:@"QRSearchCtrl" bundle:nil];
        self.searchCtrl.view.frame = [UIScreen mainScreen].bounds;
        [self addSubview:self.searchCtrl.view];
        [self.searchCtrl initClickBlock:^(NSString * _Nonnull url) {
            if (url) {
                [weakSelf loadUrl:url];
            }
            [weakSelf.searchCtrl.view removeFromSuperview];
            weakSelf.searchCtrl = nil;
        }];
        return;
    }
}
//在所有config未NO的时候才判断
-(void)exchangeWebConfig:(NSString*)host url:(NSString*)reqesetUrl{
    if (self.currentHost &&[host isEqualToString:self.currentHost]) {
        return;
    }
    BOOL isFind = false;
    NSArray *array = [MainMorePanel getInstance].morePanel.notConfig;
    for (int i = 0; i < array.count && reqesetUrl && host;i++) {
       notConfig *conifg = [array objectAtIndex:i];
       NSString *scheme = host;
        NSLog(@"host = %@ config.host = %@",scheme,conifg.host);
      if([conifg.host rangeOfString:scheme].location != NSNotFound){
          self.webUserConfig = conifg.conifg;
          self.webUserConfig.url = reqesetUrl;
          self.currentHost = host;
          isFind = true;
       }
    }
  //  [self.webChannelView addAdBlockUI:isInReadMode?true:!isFind ];
    if (!isFind) {
        self.currentHost = nil;
        NSLog(@"exchangeWebConfig faild");
        self.webUserConfig = [[WebConfigItem alloc] init];
    }
    self.isForceUseIjk = self.webUserConfig.isForceUseIjk;
}

-(instancetype)initWithSnapshotFrame:(CGRect)frame config:(WebConfigItem*)webUserConfig webUUID:(NSString*)webUUID imageData:(NSData*)imageData webTopArray:(NSArray*)webTopArray lastUrl:(NSString*)lastUrl{
    self = [super initWithFrame:frame];
    btnsViewh = [[UIScreen mainScreen] bounds].size.width*0.078;//640*50
    self.webUUID = webUUID;
    self.webUserConfig = webUserConfig;
    self.requestUrl = lastUrl;
    self.isForceOpenThird = false;
    [self exchangeWebConfig:[[NSURL URLWithString:lastUrl]host]url:lastUrl];
    self.webTopArray = webTopArray;
    [self createConfigSige];
    self.snapsthotSmallData = imageData;
    self.snapsthotBigImagefile = [NSString stringWithFormat:@"%@/%@.png",AppNotSynchronizationDir,self.webUUID];
    self.snapshotView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
    self.snapshotView.frame = self.bounds;
    [self addSubview:self.snapshotView];
    isInBack = true;
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame config:(WebConfigItem*)webUserConfig{
    self = [super initWithFrame:frame];
    self.reLoadDate = nil;
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef string = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    self.webUUID = [NSString stringWithFormat:@"%@", (__bridge NSString*)string];
    btnsViewh = [[UIScreen mainScreen] bounds].size.width*0.078;//640*50
    CFRelease(string);
    CFRelease(uuid);
    self.isForceOpenThird = false;
    NSArray *tmp = [MarjorWebConfig getInstance].webItemArray;
    if (tmp) {
        self.webTopArray = tmp;
    }
    else{
        self.webTopArray = [NSArray array];
    }
    self.webTopArray = [NSArray array];
    self.webUserConfig = webUserConfig;
    self.userAgent = webUserConfig.userAgent;
    self.isForceUseIjk = webUserConfig.isForceUseIjk;
    self.requestUrl = self.webUserConfig.url;
    [self exchangeWebConfig:[[NSURL URLWithString:self.webUserConfig.url]host]url:self.requestUrl];
    [self createBottomFixBug];
    [self isInitUINew];
    [self createConfigSige];
    isInBack = false;
    [self loadUrl:self.requestUrl];
    return self;
}

-(void)loaUrl:(NSString*)url config:(WebConfigItem*)webUserConfig{
    if (!self.webUserConfig) {
        self.webUserConfig = webUserConfig;
        self.userAgent = webUserConfig.userAgent;
        if (self.userAgent) {
            [self.marjorWebView setCustomUserAgent:self.userAgent];
        }
    }
    [self.marjorWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.webProgressView) {
          CGRect rect = self.webProgressView.frame;
          self.webProgressView.frame = CGRectMake(rect.origin.x, rect.origin.y, self.frame.size.width, rect.size.height);
      }
}

-(void)createBottomFixBug{
    if (!isInBack && !self.bottomTools) {
        float toolsH = 32;
        self.bottomTools = [[BottomToolsView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-toolsH-(GetAppDelegate.appStatusBarH-20), MY_SCREEN_WIDTH, toolsH)];
        [self.bottomTools initUI];
        self.bottomTools.backgroundColor = [UIColor whiteColor];
        [self createBottomSige];
        [self initBtnsView];
        [self addSubview:self.bottomTools];
    }
}

-(void)loadUrlFromLoadReqeust:(NSString*)url{
    self.isForceOpenThird = false;
    NSArray *tmpArray = [MainMorePanel getInstance].arraySort.forceOpenThird;
    for (int i= 0; i<tmpArray.count; i++) {
        if( [url rangeOfString:[tmpArray objectAtIndex:i]].location != NSNotFound){
            self.isForceOpenThird = true;
            break;
        }
    }
    self.mediaReferer = self.mediaUrl = self.mediaTitle = nil;
    [self.marjorWebView stopLoading];
    [self.marjorWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)loadUrl:(NSString*)url{
    self.tmpVideoUrl = nil;
    [self removeWebDesView];
    [self loadReqeustFromUrl:url];
}

-(void)createConfigSige{
    self.clipsToBounds = YES;
    MarjorWebConfig *config = [MarjorWebConfig getInstance];
    self.isAutoPlay = config.isAutoPlay;
    @weakify(self)
    [RACObserve(config,webFontSize) subscribeNext:^(id x) {
        @strongify(self)
        [self updateWebFont];
    }];
    
    [RACObserve(config,isNightMode) subscribeNext:^(id x) {
        @strongify(self)
        [self updateNightMode];
    }];
    [RACObserve(config,isRemoveAd) subscribeNext:^(id x) {
        @strongify(self)
        if (self.marjorWebView) {
            [self.marjorWebView reload];
        }
    }];
    
    [RACObserve(config,isAllowsBackForwardNavigationGestures) subscribeNext:^(id x) {
        @strongify(self)
        if (self.marjorWebView) {
            self.marjorWebView.allowsBackForwardNavigationGestures = config.isAllowsBackForwardNavigationGestures;
        }
    }];
    
    [RACObserve(config,isAutoPlay) subscribeNext:^(id x) {
        @strongify(self)
        if (config.isAutoPlay != self.isAutoPlay ) {
            if (self.marjorWebView) {
                [[WebCoreManager getInstanceWebCoreManager] updateVideoPlayMode:self.marjorWebView isSuspensionMode:[MarjorWebConfig getInstance].isSuspensionMode];
                [self loadRequestRefreshFun:nil];
            }
            self.isAutoPlay = config.isAutoPlay;
        }
    }];
    
    [RACObserve(config,isShowPicMode) subscribeNext:^(id x) {
        @strongify(self)
        if (self.marjorWebView) {
            [self loadRequestRefreshFun:nil];
        }
    }];
    
    [RACObserve(config,isCanReadMode) subscribeNext:^(id x) {
        @strongify(self)
        [self updateReadBtn];
    }];
    
    
    [RACObserve(self,title) subscribeNext:^(id x) {
        @strongify(self)
        [self updateShowTitle];
    }];
    
    [RACObserve(GetAppDelegate,isUpateJsChange) subscribeNext:^(id x) {
        @strongify(self)
        [self updateJsWeb];
    }];
}

-(void)updateWebFont{
    if (!isInReadMode) {
        NSString *str = [NSString stringWithFormat:@"window.__firefox__.setFontSize('%ld%%')",[MarjorWebConfig getInstance].webFontSize];
        [self.marjorWebView evaluateJavaScript:str completionHandler:^(id ret, NSError * _Nullable error) {
            NSLog(@"updateWebFont");
        }];
    }
}

-(void)updateJsWeb{
    if (self.marjorWebView) {
        [[WebCoreManager getInstanceWebCoreManager] updateVideoPlayMode:self.marjorWebView isSuspensionMode:[MarjorWebConfig getInstance].isSuspensionMode];
        if ([self.current_Url length]>10) {
            [self loadRequestRefreshFun:nil];
        }
    }
}

-(void)updateReadBtn{
    if ([MarjorWebConfig getInstance].isCanReadMode) {
        self.readModeBtn.alpha = 1;
    }
    else{
        self.readModeBtn.alpha = 0;
        if (isInReadMode) {
            [self leaveReadMode];
        }
    }
}

-(void)updateVideoArrayFromWeb:(NSNotification*)object{
    id value = object.object;
    if ([value isKindOfClass:[NSArray class]]&&[value count]>0) {
        [[VideoPlayerManager getVideoPlayInstance] updateVideoArrayUrl:value];
    }
}

-(void)updateDesUrlFromWeb:(NSNotification*)object
{
    id value = object.object;
    NSDictionary *saveInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.requestUrl,@"requestUrl",self.title,@"theTitle", nil];
    if ([value isKindOfClass:[NSString class]]) {
          [[VideoPlayerManager getVideoPlayInstance] playWithUrl:value title:self.mediaTitle referer:self.mediaReferer saveInfo:saveInfo replayMode:true  rect:CGRectZero throwUrl:nil isUseIjkPlayer:self.isForceUseIjk];
    }
    else{
          [[VideoPlayerManager getVideoPlayInstance] playWithPlayerInterface:value title:self.mediaTitle saveInfo:saveInfo isMustSeekBegin:true];
    }
}

-(void)createBottomSige{
    @weakify(self)
    self.bottomTools.addWebHome = ^{
        @strongify(self)
        [self addWebHome:nil];
    };
    self.bottomTools.feeBack = ^{
        @strongify(self)
        [self fanguiyijian:nil];
    };
    self.bottomTools.shareApp = ^{
        @strongify(self)
        [self shareapp:nil];
    };
    self.bottomTools.popViewShow = ^(BOOL isShow) {
        @strongify(self)
        if (isShow) {
            [self stopBanner];
        }
        else{
            [self startBanner];
        }
    };
    self.bottomTools.shareWeb = ^{
        @strongify(self)
        [self shareWeb:nil];
    };
    self.bottomTools.clickBack = ^{
        @strongify(self)
        [self checkShowWebH];
        [self  backWebFromToolBar];
    };
    self.bottomTools.clickNext = ^{
        @strongify(self)
        [self.marjorWebView goForward];
    };
    self.bottomTools.reloadUrl = ^(NSString *url) {
        @strongify(self)
        [self loadUrl:url];
    };
    self.bottomTools.clickRefresh = ^(void) {
        @strongify(self)
        [self.marjorWebView reload];
    };
    self.bottomTools.clickSearch = ^(void) {
        @strongify(self)
        [self showSearchTools];
    };
    
    self.bottomTools.addFavorite = ^{
        @strongify(self)
        [self addFavorite];
    };
    self.bottomTools.showPicBlock = ^{
        @strongify(self)
        [self showPicBlock];
    };
    [RACObserve(self.marjorWebView,canGoBack) subscribeNext:^(id x) {
        @strongify(self)
        self.bottomTools.btnGoBack.enabled = self.marjorWebView.canGoBack;
    }];
}

-(void)showSearchTools{
    self.addressToolBar = [[AddressToolbarView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, 40) tabManager:nil];
    self.addressToolBar.backgroundColor = [UIColor whiteColor];
    self.addressToolBar.delegate = self;
    self.addressToolBar.relatedBrowserView = self;
    [self.addressToolBar enlargeAddressBar:NO];
    self.addressToolBar.current_Url = self.current_Url;
    
    if (self.title) {
        self.addressToolBar.addressBar.text = self.title;
    }
    else
    {
        if (isInReadMode) {
            self.addressToolBar.addressBar.text = self.recordReadModeUrl;
        }
        else{
            self.addressToolBar.addressBar.text = self.marjorWebView.URL.absoluteString;
        }
    }
    [self.addressToolBar showInput];
    [self addSubview:self.addressToolBar];
}

- (void)_willEnterForeground:(NSNotification*)notification {
    [BeatifyGDTNativeView startBeatifyView:^{
        
    } willRemove:^{
        
    }];
}

-(BOOL)isInitUINew{
    if (self.showListBtn) {
        return false;
    }
    [[MajorSystemConfig getInstance] updateBannerZeor:true];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGlobalWebUrl:) name:@"PostGlobalWebUrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDesUrlFromWeb:) name:@"UpdateDesUrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoArrayFromWeb:) name:@"UpdateVideoArray" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoWillChangeFull:) name:@"videoWillChangeFull" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidChangeFull:) name:@"videoDidChangeFull" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self startBanner];
    isHidden = false;
    isHiddenTop = false;
    self.backgroundColor = [UIColor whiteColor];
     float hh = 24;
    float webGeneraH = 24;
    if (IF_IPAD) {
        hh = 40;
        webGeneraH = 40;
    }webGeneraH = 0;
    @weakify(self)
    if (self.webTopArray.count>0) {
        self.webGeaneralTools = [[WebGeneralTools alloc] initWithFrame:CGRectMake(0, self.bottomTools.frame.origin.y-hh,MY_SCREEN_WIDTH, webGeneraH)];
        [self addSubview:self.webGeaneralTools];
        self.webChannelView = [[WebTopChannel alloc] initWithFrame:CGRectMake(0, self.webGeaneralTools.frame.origin.y-hh,MY_SCREEN_WIDTH, hh)];
         [self addSubview:self.webChannelView];
        [self.webChannelView updateTopArray:self.webTopArray];
        self.webChannelView.clickBlock = ^(WebConfigItem *item) {
            @strongify(self)
            self.webUserConfig = item;
            self.requestUrl = self.webUserConfig.url;
            [self loadUrl:self.requestUrl];
            [self.addressToolBar cancel];
            GetAppDelegate.isClickWebEvent = true;
            [self startBanner];
        };
        self.webChannelView.moreBlock = ^{
            @strongify(self)
            if (self.carouselBannerView)
            [self bringSubviewToFront:self.carouselBannerView];
        };
    }
    else{
        self.webGeaneralTools = [[WebGeneralTools alloc] initWithFrame:CGRectMake(0, self.bottomTools.frame.origin.y-webGeneraH,MY_SCREEN_WIDTH, webGeneraH)];
        [self addSubview:self.webGeaneralTools];
 
    }
    self.webGeaneralTools.addHomeBlock = ^{
        @strongify(self)
        [self addfuli];
       // [self addWebHome:nil];
    };
    self.webGeaneralTools.addFavoriteBlock = ^{
        @strongify(self)
        [self addFavorite];
    };
    self.webGeaneralTools.webSubmitBlock = ^NSString *{
        @strongify(self)
        return self.current_Url;
    };
    self.webGeaneralTools.getRedBagBlock = ^{
        @strongify(self)
        [self.bottomTools showFavorite:nil];
    };
    self.isRemoveAdMode = [MarjorWebConfig getInstance].isRemoveAd;
   // self.marjorWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:self.requestUrl isAutoSelected:YES delegate:self];
    if (self.userAgent) {
        [self.marjorWebView setCustomUserAgent:self.userAgent];
    }
    [self addSubview:self.marjorWebView];
    {
        self.topTools = [[BeatifyWebTopTools alloc] init];
        [self addSubview:self.topTools];
        self.topTools.delegate = self;
        [self.topTools initUI];
        self.topTools.frame = CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, IF_IPAD?45:35);
        //添加
    }
    float webH = MY_SCREEN_WIDTH;
    float webProgressStartY = self.topTools.frame.origin.y+self.topTools.frame.size.height;
    self.webProgressView = [[UIProgressView alloc]
                            initWithFrame:CGRectMake(0, webProgressStartY,
                                                     self.frame.size.width, 2)];
    self.webProgressView.progressTintColor =RGBCOLOR(255, 0, 0); // ProgressTintColor;
    self.webProgressView.trackTintColor = [UIColor blackColor];
    self.webProgressView.alpha = 1;
    [self addSubview:self.webProgressView];
    float webStartX = 0;
    self.marjorWebView.frame = CGRectMake(webStartX, webProgressStartY, webH, MY_SCREEN_HEIGHT-webProgressStartY-self.webChannelView.frame.size.height);
    [self showBottomAndAjust];
    float btnw = 91,btnh=46,btnVideow=307/1.5,btnVideoh = 111/1.5;
    if (IF_IPHONE) {
        btnw/=1.5;btnh/=1.5;
        btnVideow/=(2*1.3);
        btnVideoh/=(2*1.3);
    }
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"Brower.bundle/ss_bottom_play_btn"] forState:UIControlStateNormal];
    [self addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(btnVideow);
        make.height.mas_equalTo(btnVideoh);
        make.right.equalTo(self);
       // make.bottom.equalTo(self.bottomTools.mas_top).mas_offset(-self->_webChannelView.frame.size.height-4-self.webGeaneralTools.frame.size.height);
        make.top.mas_equalTo(DefalutVideoRect.origin.y+DefalutVideoRect.size.height);
    }];
    self.playBtn.hidden = YES;

    self.showListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showListBtn setImage:[UIImage imageNamed:@"Brower.bundle/ss_showlist_btn"] forState:UIControlStateNormal];
    [self addSubview:self.showListBtn];
    [self.showListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(btnVideow);
        make.height.mas_equalTo(btnVideoh);
        make.right.equalTo(self);
        make.bottom.equalTo(self.playBtn.mas_top).mas_offset(-10);
    }];
    self.showListBtn.hidden = YES;
    
    [self updateTishiAction:!self.playBtn.hidden];
    self.readModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.readModeBtn setImage:[UIImage imageNamed:@"Brower.bundle/ss_bottom_readMode_btn"] forState:UIControlStateNormal];
    [self addSubview:self.readModeBtn];
    [self.readModeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(btnw);
        make.height.mas_equalTo(btnh);
        make.left.equalTo(self);
        make.bottom.equalTo(self.playBtn.mas_top).mas_offset(-4);
    }];
    self.readModeBtn.hidden = YES;

    if (IF_IPAD) {
        CGSize scaleBtnSize = CGSizeMake(73, 86);
        self.scaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.scaleBtn];
        scaleRect = CGRectMake(MY_SCREEN_WIDTH-scaleBtnSize.width, self.addressToolBar.frame.origin.y+self.addressToolBar.frame.size.height+80, scaleBtnSize.width, scaleBtnSize.height);
        [self.scaleBtn setFrame:scaleRect];
        [self.scaleBtn bk_addEventHandler:^(id sender) {
            @strongify(self)
            [self updateMarjorW];
        } forControlEvents:UIControlEventTouchUpInside];
        [self updateMarjorW];
        /*
        self.changeWebOrientation = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.changeWebOrientation setFrame:CGRectMake(scaleRect.origin.x, scaleRect.origin.y+scaleRect.size.height*1.5, scaleBtnSize.width, scaleBtnSize.height)];
        [self.changeWebOrientation setImage:[UIImage imageNamed:@"Brower.bundle/web_xuanzhuan.png"] forState:UIControlStateNormal];
        [self addSubview:self.changeWebOrientation];
        [self.changeWebOrientation bk_addEventHandler:^(id sender) {
            @strongify(self)
           // [self addJustUI];
         } forControlEvents:UIControlEventTouchUpInside];*/
    }
    
    [self.marjorWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.nextPageStopLoading()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
       
    }];
    [self webSetVideoFloatingPageScrollOffset];
    
   
    [self.showListBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        self.webDesAllView.hidden = NO;
    } forControlEvents:UIControlEventTouchUpInside];
    [self.playBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self playMedia:false rect:CGRectZero apiArray:nil isSeek:false];
    } forControlEvents:(UIControlEventTouchUpInside)];
    [self.readModeBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self intoReadMode];
    } forControlEvents:(UIControlEventTouchUpInside)];
    return true;
}

-(void)updateWebProgressAndWeb{
/*    float webProgressStartY = _bannerAdRect.origin.y+_bannerAdRect.size.height;
    self.webProgressView.frame = CGRectMake(0, webProgressStartY,
                                            self.frame.size.width, 2);
    float webStartX = 0;
   CGRect rect =  CGRectMake(webStartX, webProgressStartY, MY_SCREEN_WIDTH, self.webChannelView.frame.origin.y-webProgressStartY);
    self.marjorWebView.frame = rect;*/

}
-(void)updateTishiAction:(BOOL)isTishi{
    [[self.playBtn.superview viewWithTag:PlayVideoTishiViewTag] removeFromSuperview];
    if (isTishi && self.playBtn) {//1242 120
        [self.playBtn pop_removeAllAnimations];
        UIButton *imageTishiView = [UIButton buttonWithType:UIButtonTypeCustom];
        forceFireTime *tmpo = [MainMorePanel getInstance].morePanel.forceFireTime;
        BOOL isForce = [MarjorWebConfig isValid:tmpo.btime a2:tmpo.etime];
        BOOL isCanexcutApi = [self checkTimeVaild:isForce];
        if(isCanexcutApi){
            [imageTishiView setImage:[UIImage imageNamed:@"Brower.bundle/bofang1_btn.png"] forState:UIControlStateNormal];
        }
        else {
            [imageTishiView setImage:[UIImage imageNamed:@"Brower.bundle/bofang_btn.png"] forState:UIControlStateNormal];
        }
        imageTishiView.tag = PlayVideoTishiViewTag;
        imageTishiView.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [imageTishiView bk_addEventHandler:^(id sender) {
            [weakSelf playMedia:false rect:CGRectZero apiArray:nil isSeek:false];
        } forControlEvents:(UIControlEventTouchUpInside)];
        float ww =MY_SCREEN_WIDTH;
        float hh =180.0/1242*MY_SCREEN_WIDTH;
        imageTishiView.frame = CGRectMake(0,DefalutVideoRect.origin.y+DefalutVideoRect.size.height, ww, hh);
        [self.playBtn.superview insertSubview:imageTishiView belowSubview:self.playBtn];
        self.playBtn.alpha=0;
    }
}

-(void)addfuli{
    if(self.requestUrl){
        [self stopBanner];
        UIPasteboard *appPasteBoard =  [UIPasteboard generalPasteboard];
        [appPasteBoard setString:self.requestUrl];
        UIView *parentView =  self;
        MajorPrivacyHome*   majorPrivacyHomeView = [[MajorPrivacyHome alloc] init];
        majorPrivacyHomeView.delegate = self;
        majorPrivacyHomeView.frame =  CGRectMake(0,GetAppDelegate.appStatusBarH-20, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20));
        [parentView addSubview:majorPrivacyHomeView];
        [majorPrivacyHomeView initUI];
        [majorPrivacyHomeView addUrlTitle:self.current_Url title:self.title];
    }
}

-(void)major_privacy_end_remove{
    [self startBanner];
}

-(void)movePlayAction{
    UIView *imageTishiView = [self.playBtn.superview viewWithTag:PlayVideoTishiViewTag];
    if(imageTishiView.pop_animationKeys.count>0)return;
    POPBasicAnimation *animFrame = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
    animFrame.fromValue = [NSValue valueWithCGPoint:imageTishiView.center];
    animFrame.toValue=[NSValue valueWithCGPoint:CGPointMake(imageTishiView.center.x+imageTishiView.frame.size.width, imageTishiView.center.y)];
    animFrame.duration = 1;
    animFrame.beginTime = CACurrentMediaTime()+0.5;
    [imageTishiView pop_addAnimation:animFrame forKey:@"imageTishiView"];
    [animFrame setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.playBtn.currentImage];
        imageView.frame = self.playBtn.frame;
        [imageTishiView addSubview:imageView];
        imageView.center = CGPointMake(-imageView.bounds.size.width/2, 0);
        POPBasicAnimation *animFrame = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        animFrame.fromValue = [NSValue valueWithCGPoint:imageTishiView.center];
        animFrame.toValue=[NSValue valueWithCGPoint:CGPointMake(imageTishiView.center.x, self.playBtn.center.y)];
        animFrame.duration = 1;
        animFrame.beginTime = CACurrentMediaTime()+0.5;
        [imageTishiView pop_addAnimation:animFrame forKey:@"imageTishiView"];
        [animFrame setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            self.playBtn.alpha = 1;
            [imageTishiView removeFromSuperview];
        }];
    }];
}


-(void)updateRightGdtAdView:(BOOL)isAdd{
    if(!self.rightGdtAdView || isClickBeatifyPlugCtrlAd)return;
 
    NSString *js = [NSString stringWithFormat:@"addJustAdXinxlH('%fpx')",self.rightGdtAdView.frame.size.height];
    
    [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable v, NSError * _Nullable error) {
        if (isAdd && self->isLoadAdSuucess ) {
            [self.rightGdtAdView  removeFromSuperview];
            CGRect rect = self.rightGdtAdView.frame ;
            if ([self.current_Url rangeOfString:@"sigu.me"].location!=NSNotFound) {
                v = [NSNumber numberWithInt:50];
            }
            self.rightGdtAdView.frame = CGRectMake(rect.origin.x, [v floatValue], rect.size.width, rect.size.height);
            [self.marjorWebView.scrollView addSubview:self.rightGdtAdView];
        }
    }];
    if(self.isScaleState){
      self.rightGdtAdView.frame = self.rightGdtAdViewRect;
    }
    else{
        self.rightGdtAdView.frame = CGRectMake((self.marjorWebView.bounds.size.width-self.rightGdtAdView.frame.size.width)/2, self.rightGdtAdView.frame.origin.y, self.rightGdtAdView.frame.size.width, self.rightGdtAdView.frame.size.height);
    }
    [self.nativeAd mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.rightGdtAdView);
    }];
}

-(void)updateMarjorW{
    if (IF_IPAD) {
        self.isScaleState = !self.isScaleState;
        float   webH = MY_SCREEN_WIDTH;
        float  webStartX = 0;
        if (self.isScaleState) {
            webStartX=webH*0.2;
            webH*=0.6;
        }
        CGRect rect =  self.marjorWebView.frame;
        [self.marjorWebView pop_removeAllAnimations];
        [self addFrameAnimation:self.marjorWebView rect:CGRectMake(webStartX,rect.origin.y, webH,rect.size.height) isAnimation:YES];
        [self.scaleBtn setImage:self.isScaleState?[UIImage imageNamed:@"Brower.bundle/web_fangda.png"]:[UIImage imageNamed:@"Brower.bundle/web_suoxiao.png"] forState:UIControlStateNormal];
        [self updateRightGdtAdView:false];
    }
}

-(void)initBtnsView{
    
}

-(void)shareapp:(UIButton*)sender{
     [self.marjorWebView evaluateJavaScript:@"document.title" completionHandler:^(id re, NSError * _Nullable error) {
         [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
             return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
         } value:^NSString *{
             return nil;
         } titleBlock:^NSString *{
             return nil;
         } imageBlock:^UIImage *{
             return nil;
         }urlBlock:^NSString  *{
             return nil;
         }shareViewTileBlock:^NSString *{
             return @"分享app";
         }];
    }];
}

-(void)shareWeb:(UIButton*)sender{
    NSString *webUrl = self.requestUrl;
    [self.marjorWebView evaluateJavaScript:@"document.title" completionHandler:^(id re, NSError * _Nullable error) {
        [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
            return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
        } value:^NSString *{
            return re;
        } titleBlock:^NSString *{
            return re;
        } imageBlock:^UIImage *{
            return nil;
        }urlBlock:^NSString  *{
            return webUrl;
        }shareViewTileBlock:^NSString *{
            return @"分享网页";
        }];
    }];
}

-(void)fanguiyijian:(UIButton*)sender{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    [[MajorFeedbackKit getInstance] openFeedbackViewController:topViewController];
}

-(void)addWebHome:(UIButton*)sender{
    NSInteger count = [FileCache getTableDataCount:KEY_DATENAME tbName:KEY_TABEL_USERMAINHOME maxCount:12 isAutoDel:false];
    if(self.requestUrl.length>0 && count <12){
        NSString *tmpTitle = self.title;
        if (tmpTitle.length<=0) {
            tmpTitle = @"输入网页描述";
        }
        @weakify(self)
        ZYInputAlertView *alertView = [ZYInputAlertView alertView];
        alertView.placeholder = tmpTitle;
        alertView.alertViewDesLabel.text = @"添加到首页";
        alertView.inputTextView.text = tmpTitle;
        [alertView confirmBtnClickBlock:^(NSString *inputString) {
            @strongify(self)
            if ([self.requestUrl rangeOfString:@"http://127.0.0.1"].location == NSNotFound) {
                [MarjorWebConfig saveUserHomeMain:self.requestUrl theTitle:inputString  webUrl:self.requestUrl];
            }
            else if (self.recordReadModeUrl){
                [MarjorWebConfig saveUserHomeMain:self.recordReadModeUrl theTitle:inputString  webUrl:self.recordReadModeUrl];
            }
        }];
        [alertView show];
    }
    else{
        UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最多只能保存12个" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [v show];
    }
}

-(void)showAlterAd{
    if (isInReadMode) {
        return;
    }
    isShowAdAlter = true;
    [self.marjorWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    UIAlertControllerStyle style =UIAlertControllerStyleAlert;
    if (IF_IPHONE) {
        style = UIAlertControllerStyleActionSheet;
    }
    __block NSString *domPath =nil;
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.beginElementHiding()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        domPath = ret;
    }];
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setElementHidingEditMode(true)" completionHandler:nil];

    
    UIAlertController *showActionTip =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:style];
    UIAlertAction *ActionSacn = [UIAlertAction actionWithTitle:@"屏蔽广告"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     NSString *js = [NSString stringWithFormat:@"window.__firefox__.hideElementByPath(\"%@\")",domPath];
                                     [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                                         if (!error) {
                                             [[BeatifyWebAdManager getInstance] addAdDom:self.requestUrl domCss:domPath];
                                         }
                                     }];
                                     [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setElementHidingEditMode(false)" completionHandler:nil];
                                     self->isShowAdAlter = false;
                                 }];
    
    [showActionTip addAction:ActionSacn];
    UIAlertAction *ActionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       self->isShowAdAlter = false;
                                         [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setElementHidingEditMode(false)" completionHandler:nil];
                                    }];
    [showActionTip addAction:ActionCancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *ctrl = [UIApplication sharedApplication].keyWindow.rootViewController;
        [ctrl presentViewController:showActionTip animated:YES completion:nil];
    });
}

-(void)showWebH
{
    if (!self.goBackWebView) {
        self.goBackWebView = [[GoBackWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, MY_SCREEN_HEIGHT-self.bottomTools.bounds.size.height) bottomOffsetY:0];
        [self addSubview:self.goBackWebView];
        @weakify(self)
        self.goBackWebView.clickBlock = ^(NSString *url) {
            @strongify(self)
            [self loadUrl:url];
        };
        self.goBackWebView.closeBlock = ^() {
            @strongify(self)
            [self.goBackWebView removeFromSuperview];
            self.goBackWebView = nil;
        };
    }
}

-(void)showBottomAndAjust{
    [self bringSubviewToFront:self.bottomTools];
    self.bottomTools.backgroundColor = [UIColor whiteColor];
    if (_carouselBannerView) {
        [self bringSubviewToFront:_carouselBannerView];
    }
}

-(void)showAllImage:(NSArray*)array title:(NSString*)title{
    if (array.count>0) {
        NSURL *referer = [NSURL URLWithString:self.requestUrl];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
        [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YBImageBrowserModel *model = [YBImageBrowserModel new];
            model.referer = [NSString stringWithFormat:@"%@://%@",[referer scheme],[referer host]];
            [model setUrlWithDownloadInAdvance:[NSURL URLWithString:obj]];
            model.sourceImageView = nil;
            model.maximumZoomScale = 10;
            [tempArray addObject:model];
        }];
        MajorPicView *v =  [[MajorPicView alloc]initWithFrame:CGRectMake(0,0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)) withData:tempArray];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:v];
        if (self.carouselBannerView) {
            [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:self.carouselBannerView];
        }
    }
}

-(void)showPicBlock{
    @weakify(self)
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.getImgURLsWithSizeLimitAndTitle(20)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        @strongify(self)
        if ([ret isKindOfClass:[NSDictionary class]]) {
            NSArray *array =  [ret objectForKey:@"bigImages"];
            NSMutableArray *retArray = [NSMutableArray array];
            for(int i = 0 ; i < array.count;i++)
            {
                NSString *url = [array objectAtIndex:i];
                NSURL *urlA = [NSURL URLWithString:url];
                if(!urlA){
                    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    urlA = [NSURL URLWithString:url];
                }
                if (urlA) {
                    [retArray addObject:url];
                }
            }
            [self showAllImage:retArray title:[ret objectForKey:@"title"]];
        }
    }];
}
//添加到数据库
-(void)addFavorite{
    if(self.requestUrl.length>0){
        NSString *tmpTitle = self.title;
        if (tmpTitle.length<=0) {
            tmpTitle = @"输入收藏名字";
        }
        @weakify(self)
        ZYInputAlertView *alertView = [ZYInputAlertView alertView];
        alertView.placeholder = tmpTitle;
        alertView.inputTextView.text = tmpTitle;
        [alertView confirmBtnClickBlock:^(NSString *inputString) {
            @strongify(self)
            if ([self.requestUrl rangeOfString:@"http://127.0.0.1"].location == NSNotFound) {
                [MarjorWebConfig addFavorite:inputString iconUrl:self.iconUrl  requestUrl:self.requestUrl];
            }
            else if (self.recordReadModeUrl){
                [MarjorWebConfig addFavorite:inputString iconUrl:self.iconUrl  requestUrl:self.recordReadModeUrl];
            }
        }];
        [alertView show];
    }
}

-(void)leaveReadMode
{
    [self.readModeBtn setImage:[UIImage imageNamed:@"Brower.bundle/ss_bottom_readMode_btn"] forState:UIControlStateNormal];
    isInReadMode = false;
    [self loadUrl:self.recordReadModeUrl];
    [self.readModeWeb removeFromSuperview];self.readModeWeb = nil;
}

-(void)intoReadMode
{
    if (isInReadMode) {
        [self leaveReadMode];
        return;
    }
    if (!self.readModeWeb) {
        self.recordReadModeUrl = self.requestUrl;
        [self.readModeBtn setImage:[UIImage imageNamed:@"Brower.bundle/ss_bottom_exit_readMode_btn"] forState:UIControlStateNormal];
        self.readModeWeb = [[ReadModeWeb alloc] initWithFrame:self.marjorWebView.frame];
        [self addSubview:self.readModeWeb];
        self.readModeWeb.contentDelegate = self;
        [self sendSubviewToBack:self.readModeWeb];
    }
    [self reyudujs];
}

-(void)readMoreWebContent:(NSString*)content title:(NSString*)title nextUrl:(NSString*)url{
    NSString *js = [NSString stringWithFormat:@"window.__firefox__.reader.setNextPageContentAndNewNextPageAndIndexPage(\"%@\",\"%@\",\"%@\")",title,content,url];
    @weakify(self)
    [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        @strongify(self)
        self.title = title;
        [self updateShowTitle];
    }];
}

-(void)reyudujs {
    isInReadMode= true;
    __weak typeof(self) weakSelf = self;
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.reader.readerize()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        if ([ret isKindOfClass:[NSDictionary class]]) {
            weakSelf.contentInfo = ret;
            [weakSelf.marjorWebView evaluateJavaScript:@"window.__firefox__.getNextPageAndIndexURL()" completionHandler:^(id _Nullable ret2, NSError * _Nullable error) {
                weakSelf.nextInfo = ret2;
                [self gotoReadModeServier];
            }];
        }
    }];
}

-(void)gotoReadModeServier{
    NSDictionary *info = [MarjorWebConfig convertIdFromNSString:[FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/readModeConfig" ofType:@"plist_data"]]] type:1];
    NSString *title =  [self.contentInfo objectForKey:@"title"];
    NSString *content = [self.contentInfo objectForKey:@"content"];
    NSString *indexpage = [self.nextInfo objectForKey:@"index"];
    NSString *next = [self.nextInfo objectForKey:@"next"];

    NSMutableString *htmlStr = [NSMutableString stringWithString:[info objectForKey:@"body1"]];
    [htmlStr appendString:title];
    [htmlStr appendString:[NSMutableString stringWithString:[info objectForKey:@"body2"]]];
    [htmlStr appendString:next];
    [htmlStr appendString:[NSMutableString stringWithString:[info objectForKey:@"body3"]]];
    [htmlStr appendString:indexpage];
    [htmlStr appendString:[NSMutableString stringWithString:[info objectForKey:@"body4"]]];
    [htmlStr appendString:title];
    [htmlStr appendString:[NSMutableString stringWithString:[info objectForKey:@"body5"]]];
    [htmlStr appendString:content];
    [htmlStr appendString:[NSMutableString stringWithString:[info objectForKey:@"body6"]]];
    GetAppDelegate.readBodyReturn = htmlStr;
    [self loadReadUrl:[NSString stringWithFormat:@"http://127.0.0.1:%d/reader-mode/page?url=%@",ReadModeServerPort,self.requestUrl]];
}

-(void)loadReadUrl:(NSString*)url{
    self.tmpVideoUrl = nil;
    [self removeWebDesView];
    [self.marjorWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)playMedia:(BOOL)isAuto rect:(CGRect)rect apiArray:(NSArray*)apiArray isSeek:(BOOL)isSeek
{
    if (isInBack || [self.superview viewWithTag:MoreBeatfiyWebsViewTag]) {
        return;
    }
    if (isAuto) {
        if (self.tmpVideoUrl && [self.tmpVideoUrl isEqualToString:self.mediaUrl]) {
            return;
        }
    }
    self.tmpVideoUrl = self.mediaUrl;
    __block BOOL isCanexcutApi = false;

    forceFireTime *tmpo = [MainMorePanel getInstance].morePanel.forceFireTime;
    BOOL isForce = [MarjorWebConfig isValid:tmpo.btime a2:tmpo.etime];
    isCanexcutApi = [self checkTimeVaild:isForce];
#if (UseBeatifyAppJs==1)
    isForce = true;
    isCanexcutApi = apiArray.count>0?true:false;
#endif
   // if (true || !self.webUserConfig.isUseApi)
    {
        @weakify(self)
        [self.marjorWebView evaluateJavaScript:@"document.title" completionHandler:^(id re, NSError * _Nullable error) {
            @strongify(self)
            [[VideoPlayerManager getVideoPlayInstance]stop];
            self.mediaTitle = re;
            NSLog(@"self.mediaTitle = %@",self.mediaTitle);
            
            NSMutableDictionary *saveInfo = nil;
            //requestUrl->mediaUrl
            if (self.mediaUrl && re ) {
                saveInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.mediaUrl,@"requestUrl",re,@"theTitle", nil];
            }
            if (self.mediaUrl && [self isPlayCacheFileSuccess:self.mediaUrl title:self.mediaTitle]) {//播放本地数据成功
                return ;
            }//end change
            BOOL isSuccess = false;
            if (isCanexcutApi) {
                isSuccess = [self doWeb:apiArray isSeek:isSeek];
            }
            if(!isSuccess){
                [[ApiCoreManager getInstace] stopApiReqeust];
            }
    
            if (!GetAppDelegate.isProxyState && self.webUserConfig.isUseApi && isForce) {//配置了api和强制使用APi的情况
                [saveInfo setObject:[[NSBundle mainBundle] pathForResource:@"MajorJs.bundle/app_default_loading2" ofType:@"mp4"] forKey:@"externUrl"];
            }
            if(!isSuccess){
                [[VideoPlayerManager getVideoPlayInstance] playWithUrl:self.mediaUrl title:self.mediaTitle referer:self.mediaReferer saveInfo:saveInfo replayMode:isCanexcutApi rect:rect throwUrl:nil isUseIjkPlayer:self.isForceUseIjk];
            }
        }];
    }
}

-(BOOL)checkTimeVaild:(BOOL)isfocre{
    BOOL isCanexcutApi = false;
    if (self.webUserConfig.isUseApi) {
        if (isfocre) {
            isCanexcutApi = true;
        }
        else{
            NSString *btime = self.webUserConfig.beginTime;
            NSString *etime = self.webUserConfig.endTime;
            isCanexcutApi = [MarjorWebConfig isValid:btime a2:etime];
        }
    }
    return isCanexcutApi;
}

-(BOOL)doWeb:(NSArray*)apiArray isSeek:(BOOL)seek{
#ifdef DEBUG
#else
    if (GetAppDelegate.isProxyState) {
        return false;
    }
#endif
#if (UseBeatifyAppJs==0)
    WebConfigItem*tmp = [[WebConfigItem alloc] init];
    tmp.url = self.requestUrl;
    tmp.isUseApi = self.webUserConfig.isUseApi;
    tmp.name = self.webUserConfig.name;
    tmp.isNoPcWeb = self.webUserConfig.isNoPcWeb;
    [[ApiCoreManager getInstace] startApiReqeust:self.marjorWebView config:tmp searchTitle:self.mediaTitle urlMedia:self.mediaUrl];
    return true;
#else
    /*
    if (apiArray.count>0) {
        if (![self.superview viewWithTag:MoreBeatfiyWebsViewTag]) {
            NSMutableArray *arratRet = [NSMutableArray arrayWithArray:apiArray];
            if (self.assetUrl) {
                if (false && arratRet.count>0) {
                    [arratRet insertObject:self.assetUrl atIndex:0];
                }
                else{
                    [arratRet addObject:self.assetUrl];
                }
            }
            __weak __typeof(self)weakSelf = self;
            MoreBeatfiyWebsView *v = [[MoreBeatfiyWebsView alloc] initWithFrame:CGRectZero array:arratRet isDefautAsset:self.assetUrl?true:false title:[@"" stringByAppendingString:self.mediaTitle] url:[self.marjorWebView.URL absoluteString] webNode:self.marjorWebView  callBack:^{
                [weakSelf.marjorWebView reload];
            } isSeek:seek];
            v.tag = MoreBeatfiyWebsViewTag;
            [self.superview addSubview:v];
        return true;
    }
    }*/
    if(apiArray.count){
        if (![self.superview viewWithTag:MoreBeatfiyWebsViewTag]) {
            NSMutableArray *arratRet = [NSMutableArray arrayWithArray:apiArray];
                      if (self.assetUrl) {
                          if (false && arratRet.count>0) {
                              [arratRet insertObject:self.assetUrl atIndex:0];
                          }
                          else{
                              [arratRet addObject:self.assetUrl];
                          }
                      }
            self.mutilLineCtrl = [[QrMutilLineScanCtrl alloc] initWithNibName:@"QrMutilLineScanCtrl" bundle:nil array:arratRet webView:self.marjorWebView title:[@"" stringByAppendingString:self.mediaTitle]];
            self.mutilLineCtrl.view.tag = MoreBeatfiyWebsViewTag;
            self.mutilLineCtrl.delegate = self;
            self.mutilLineCtrl.view.frame = self.superview.bounds;
            [self.superview addSubview:self.mutilLineCtrl.view];
                  return true;
        }
    }
#endif
    return false;
}

-(void)qrMutitlLineRemove{
      [self.mutilLineCtrl.view removeFromSuperview];
      self.mutilLineCtrl = nil;
}

-(void)removeSnapsthoView {
    self.snapsthotSmallData=nil;
    [self.snapshotView removeFromSuperview];
    self.snapshotView = nil;
}

-(void)snapshotToExct{
    isInBack = false;
    [self createBottomFixBug];
    if([self isInitUINew]){
        if (self.snapshotView) {
            UIImage *image = [UIImage imageWithContentsOfFile:self.snapsthotBigImagefile];
            if (!image) {
                image = [UIImage imageWithData:self.snapsthotSmallData];
            }
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [self.snapshotView.layer addAnimation:transition forKey:@"a"];
            self.snapshotView.image = image;
            [self bringSubviewToFront:self.snapshotView];
            [self bringSubviewToFront:self.addressToolBar];
            [self showBottomAndAjust];
            //[self performSelector:@selector(showBottomAndAjust) withObject:nil afterDelay:1];
        }
        [self loadUrl:self.requestUrl];
    }
    else if(![MarjorWebConfig getInstance].isBackClear){
        [self removeSnapsthoView];
    }
}

-(void)addJustUI{
    self.marjorWebView.frame = CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-GetAppDelegate.appStatusBarH-self.webChannelView.frame.size.height);
    if (!self.isPadLand) {
        self.isPadLand = !self.isPadLand;
        [self updateWebFrame:false isAnmation:false isForceUpdate:true];
        self.marjorWebView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
        self.isScaleState = true;
        self.scaleBtn.hidden = YES;
    }
    else{
        self.isPadLand = !self.isPadLand;
        self.marjorWebView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
        [self updateWebFrame:false isAnmation:false isForceUpdate:true];
        self.isScaleState = false;
        self.scaleBtn.hidden = NO;
     }
    if (!self.isPadLand) {
        [self updateMarjorW];
    }
    [self.marjorWebView reload];
}

-(void)removeUI{
    [self removeWebDesView];
    [self stopBanner];
    [BeatifyGDTNativeView stopGdtNatiview];
    [[ApiCoreManager getInstace] stopApiReqeust];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.adListView removeFromSuperview];self.adListView = nil;
    [self.webProgressView removeFromSuperview];self.webProgressView = nil;
    [self.showListBtn removeFromSuperview];self.showListBtn = nil;
    [self.goBackWebView removeFromSuperview];self.goBackWebView = nil;
    [self.addressToolBar removeFromSuperview];self.addressToolBar = nil;
    [self.scaleBtn removeFromSuperview];self.scaleBtn = nil;
    [self.changeWebOrientation removeFromSuperview];self.changeWebOrientation = nil;
    [self.bottomTools removeFromSuperview];self.bottomTools = nil;
    [self.playBtn removeFromSuperview];self.playBtn = nil;
    [self.webChannelView removeFromSuperview];self.webChannelView = nil;
    [self.bottomBtnsView removeFromSuperview];self.bottomBtnsView = nil;
    [self.readModeBtn removeFromSuperview];self.readModeBtn = nil;
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.marjorWebView];
    self.marjorWebView = nil;
    [self.readModeWeb removeFromSuperview];self.readModeWeb = nil;
}

-(void)updateNightMode{
    if (![MarjorWebConfig getInstance].isNightMode) {
        [self.marjorWebView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.setMainFrameNightModeEnable(false)"] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {

        }];
    }
    else{
        [self.marjorWebView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.setMainFrameNightModeEnable(true)"] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
}
-(void)hiddeVideoMode{
    //视频悬浮[NSNumber numberWithBool:false]，不悬浮播放
    if (![MarjorWebConfig getInstance].isSuspensionMode) {
        [self.marjorWebView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.setMainFrameVideoEnable(false,'',false)"] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
    else{
        [self.marjorWebView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.setMainFrameVideoEnable(true,'',false)"] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
}
-(void)hiddenWebPic{
    if ([MarjorWebConfig getInstance].isShowPicMode) {
      [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setMainFrameNoImageEnable(false)" completionHandler:nil];
    }
    else{
        [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setMainFrameNoImageEnable(true)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
}


-(void)hiddenTopAd{
    NSString *msg = @"null";
    NSArray *array = [[BeatifyWebAdManager getInstance] getAdDomCss:self.requestUrl];
    if (array.count>0) {
         msg = [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
    }
    if ([MarjorWebConfig getInstance].isRemoveAd) {
        NSString *js =  [@"" stringByAppendingFormat:@"window.__firefox__.setElementHidingArray(%@,true,70,0,20,[\"cmt\", \"comment\", \"nav\", \"tab\", \"login\", \"signup\", \"regist\", \"toast\", \"share\", \"tip\", \"pop\", \"bar\", \"box\", \"user\", \"pass\", \"pwd\", \"search\", \"menu\", \"main\", \"side\", \"card\", \"content\", \"drop\", \"panel\", \"modal\", \"info\", \"dialog\", \"blur\", \"head\", \"footer\", \"input\", \"tool\", \"page\", \"map\", \"post\", \"album\", \"item\", \"refresh\", \"load\"],[\"baidu.com\", \"weibo.cn\", \"google.com\", \"translate.google\", \"qq.com\", \"neets.cc\", \"avgle.com\"],'')",msg];
        [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
    else{
        msg = @"null";
          NSString *js =  [@"" stringByAppendingFormat:@"window.__firefox__.setElementHidingArray(%@,false,70,0,20,[\"cmt\", \"comment\", \"nav\", \"tab\", \"login\", \"signup\", \"regist\", \"toast\", \"share\", \"tip\", \"pop\", \"bar\", \"box\", \"user\", \"pass\", \"pwd\", \"search\", \"menu\", \"main\", \"side\", \"card\", \"content\", \"drop\", \"panel\", \"modal\", \"info\", \"dialog\", \"blur\", \"head\", \"footer\", \"input\", \"tool\", \"page\", \"map\", \"post\", \"album\", \"item\", \"refresh\", \"load\"],[\"baidu.com\", \"weibo.cn\", \"google.com\", \"translate.google\", \"qq.com\", \"neets.cc\", \"avgle.com\"],'')",msg];
        [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {

        }];
    }
   
}

-(void)fireScoll{
    if (isInReadMode) {
        [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setTouchToScrollEnable(true,200)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
    else{
        [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setTouchToScrollEnable(false,100)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
}
-(void)webSetVideoFloatingPageScrollOffset{
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.setVideoFloatingPageScrollOffset(0)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}

-(void)hideAdsByLoadingPercent{
    if([MarjorWebConfig getInstance].isRemoveAd)
    {
        [self.marjorWebView evaluateJavaScript:@" window.__firefox__.hideAdsByLoadingPercent()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
        }];
    }
}

-(void)webGetFavicon{
    [self.marjorWebView evaluateJavaScript:@"__firefox__.favicon.getFavicon()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}

-(NSData*)getSnapshotSmallImageData{
    if (!self.snapsthotSmallData) {
        UIImage *image = NISnapshotOfView(self);
        NSData *bigData = UIImageJPEGRepresentation(image,0.3);//UIImagePNGRepresentation(image);
        [bigData writeToFile:[NSString stringWithFormat:@"%@/%@.png",AppNotSynchronizationDir,self.webUUID] atomically:YES];
        //image  = [image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
        self.snapsthotSmallData = bigData;//UIImageJPEGRepresentation(image,0.3);
    }
    return self.snapsthotSmallData;
}

-(void)updateShowTitle{
    if (self.title) {
        self.bottomTools.webTitleLable.text = self.title;
    }
}

-(void)createSnapshotViewOfView:(BOOL)isRemoveWeb
{
    if (!self.snapshotView) {
        isInBack = true;
        UIImage* image = NISnapshotOfView(self);
        NSData *bigData = UIImageJPEGRepresentation(image, 0.3);
        self.snapsthotBigImagefile = [NSString stringWithFormat:@"%@/%@.png",AppNotSynchronizationDir,self.webUUID];
        [bigData writeToFile:self.snapsthotBigImagefile atomically:YES];
        self.snapsthotSmallData = bigData;//UIImageJPEGRepresentation(image, 0.3);
        self.snapshotView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.snapshotView];
        self.snapshotView.frame= self.bounds;
        if ([MarjorWebConfig getInstance].isBackClear) {
            [self removeUI];
        }
    }
}

-(void)showSnapshot:(BOOL)isShow{
    if (isShow) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:self.snapsthotBigImagefile];
            if (!image) {
                image = [UIImage imageWithData:self.snapsthotSmallData];
            }
            else{
                // self.snapsthotSmallData = nil;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
              self.snapshotView.image = image;
            });
        });
    }
    else{
        self.snapshotView.image = nil;
    }
}

- (void)newWebFromToolBar{
    WebConfigItem *item = [[WebConfigItem alloc] init];
    item.url = @"https://cpu.baidu.com/1022/ac797dc4/i?scid=15951";
    [MarjorWebConfig getInstance].webItemArray = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

- (void)addWebFavritorFromToolBar{
    [self addFavorite];
}

- (void)checkShowWebH{
    if (self.clickBackTime && ABS([[NSDate date] timeIntervalSinceDate:self.clickBackTime]) < 3) {
       // [self showWebH];
    }
    self.clickBackTime  = [NSDate date];
}

- (void)backWebFromToolBar{
    if (self.marjorWebView.canGoBack) {
         [self.marjorWebView goBack];
    }
    isInReadMode = false;
    [self.readModeWeb removeFromSuperview];self.readModeWeb = nil;
}

- (void)loadRequestRefreshFun:(id)addressToolbar{//阅读模式？
    WebLeaveReadMode
    [self.addressToolBar removeFromSuperview];self.addressToolBar = nil;
    [self.marjorWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.current_Url]]];
}

- (void)cancelToolsFun:(id)addressToolbar{
    self.current_Url = self.requestUrl;
    [self.addressToolBar removeFromSuperview];self.addressToolBar=nil;
    [self updateShowTitle];
}

- (void)removeWebDesView{
    [self.marjorWebView evaluateJavaScript:@"__webjsNodePlug__.stopCheckList();" completionHandler:nil];
    [self.webDesAllView removeFromSuperview];self.webDesAllView = nil;
    self.showListBtn.hidden = YES;
}

- (void)loadReqeustFromUrl:(NSString*)url{
  WebLeaveReadMode
    [self.addressToolBar removeFromSuperview];self.addressToolBar = nil;
    [self loadUrlFromLoadReqeust:url];
}

-(BOOL)isWebConfig{
    BOOL ret = false;
    if (self.requestUrl && self.webUserConfig.url) {
        NSURL *url = [NSURL URLWithString:self.requestUrl];
        NSString *main = [[NSURL URLWithString:self.webUserConfig.url] host];
        NSArray *array =  [[url host] componentsSeparatedByString:@"."];
        for (int i = 0; i < array.count; i++) {
            NSString *s =  [array objectAtIndex:i];
            if (![s isEqualToString:@"m"] && ![s isEqualToString:@"www"] &&![s isEqualToString:@"com"]&&![s isEqualToString:@"cn"]&&![s isEqualToString:@"net"]) {
                NSRange range =   [main rangeOfString:s];
                if (range.location!=NSNotFound) {
                    ret = true;
                    break;
                }
            }
        }
    }
    return ret;
}

-(void)updateWebDesList:(NSDictionary*)info
{
    NSArray *array = [info objectForKey:@"listArray"];
    if (array.count>0) {
        [self.marjorWebView evaluateJavaScript:@"__webjsNodePlug__.stopCheckList();" completionHandler:nil];
    }
    __weak typeof(self)weakSelf = self;
    float viewOffsetH = 50;
    if (array.count>0) {
        if (!self.webDesAllView) {
            self.webDesAllView = [[WebDesListView alloc]initWith:CGRectZero viewOffset:viewOffsetH  block:^(id v) {
                weakSelf.webDesAllView.hidden = YES;
                weakSelf.showListBtn.hidden = NO;
            } selectBlock:^(NSInteger index) {
            } updateLine:^(NSInteger index) {
            } nCount:array isSousouType:true];
            if (IF_IPAD) {
                [self.webDesAllView updateCulm:8];
            }
            else{
            [self.webDesAllView updateCulm:7];
            }
            if (IF_IPAD) {
                [self.superview addSubview:self.webDesAllView];
            }
            else {
                if (self.bottomBtnsView) {
                    [self insertSubview:self.webDesAllView belowSubview:self.bottomBtnsView];
                }
                else{
                    [self addSubview:self.webDesAllView];
                }
            }
            self.webDesAllView.selectUrlBlock = ^(NSString *url) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostGlobalWebUrl" object:url];
                [weakSelf loadUrl:url];
            };
            self.webDesAllView.backgroundColor = [UIColor blackColor];
        }
        self.webDesAllView.hidden = NO;
        self.showListBtn.hidden = YES;
        [self.webDesAllView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            if(self.webChannelView){
                make.bottom.equalTo(self.webChannelView.mas_top);
            }
            else{
                make.bottom.equalTo(self.bottomTools.mas_top);
            }
            float h = (self.bounds.size.height*(IF_IPAD?0.46:0.5)-self->_bottomBtnsView.bounds.size.height);
            make.height.mas_equalTo(h);
        }];
        [self.webDesAllView layoutSubviews];
    }
    else{
        self.showListBtn.hidden = YES;
        RemoveViewAndSetNil(self.webDesAllView);
        RemoveViewAndSetNil(GetAppDelegate.globalWebDesList);
    }
    [self.webDesAllView initUI:@[@"test"] title:[info objectForKey:@"ShowName"]];
    [self.webDesAllView updateLineData:array];
    [self createGloablWebDesList:array tempArray:@[@"test"] title:[info objectForKey:@"ShowName"]selectIndex:[[info objectForKey:@"SelectIndex"]intValue]];
    [self bk_performBlock:^(id obj) {
        [weakSelf.webDesAllView updateSelectIndex:[[info objectForKey:@"SelectIndex"]intValue]];
    } afterDelay:0.3];
}

-(void)getGlobalWebUrl:(NSNotification*)object
{
    [self loadUrl:object.object];
}

-(void)createGloablWebDesList:(NSArray*)listArray tempArray:(NSArray*)tmpArray title:(NSString*)title selectIndex:(NSInteger)selectIndex{
    if (listArray.count>0)
    {
        __weak typeof(self)weakSelf = self;
        if (!GetAppDelegate.globalWebDesList) {
            GetAppDelegate.globalWebDesList = [[WebDesListView alloc]initWith:CGRectZero viewOffset:0 block:^(id v) {
                GetAppDelegate.globalWebDesList.hidden = YES;
            } selectBlock:^(NSInteger index) {
            } updateLine:^(NSInteger index) {
            } nCount:listArray isSousouType:true];
            [GetAppDelegate.globalWebDesList updateCulm:3];
         
            GetAppDelegate.globalWebDesList.selectUrlBlock = ^(NSString *url) {
                [weakSelf loadUrl:url];
            };
            GetAppDelegate.globalWebDesList.backgroundColor = [UIColor blackColor];
            GetAppDelegate.globalWebDesList.hidden = YES;
        }
        [GetAppDelegate.globalWebDesList initUI:@[@"test"] title:title];
        [GetAppDelegate.globalWebDesList updateLineData:listArray];
        [self bk_performBlock:^(id obj) {
            [GetAppDelegate.globalWebDesList updateSelectIndex:selectIndex];
        } afterDelay:0.3];
    }
}

#if (UseBeatifyAppJs==1)
-(void)webViewGetPicsFromPagWebCallBack:(BOOL)isSuccess uuid:(NSString *)uuid ret:(NSDictionary *)retInfo{
    if (!self.webPicsView) {
        self.webPicsView = [[BeatifyWebPicsView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        [self addSubview:self.webPicsView];
        @weakify(self)
        [self.webPicsView initUI2:^{
            @strongify(self)
            [self.webPicsView removeFromSuperview];self.webPicsView = nil;
        } imageBlock:^(UIImage * _Nonnull image) {
            @strongify(self)
            [self.webPicsView removeFromSuperview];self.webPicsView = nil;
        }clickBlock:^(NSString * _Nonnull url) {
            @strongify(self)
            [self.webPicsView removeFromSuperview];self.webPicsView = nil;
            [self loadUrl:url];
        }title:self.title webUrl:self.current_Url firstLoadFinish:^{
            @strongify(self)
            [self.webPicsView loadPicFromWebs:retInfo];
        }];
    }
}


-(void)webViewAddAdLayerView:(CGRect)rect{
    [self updateRightGdtAdView :true];
}

- (void)webViewInsertView:(CGRect)rect{
    if (!self.rightGdtAdView && rect.size.width>10) {
           self.rightGdtAdViewRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
           self.rightGdtAdView = [[UIView alloc] initWithFrame:self.rightGdtAdViewRect];
           //[self.marjorWebView.scrollView addSubview:self.rightGdtAdView];
           [self loadGDTAD];
       }
}

- (void)webViewGetAsset:(NSString*)url referer:(NSString*)referer title:(NSString*)title isAsset:(BOOL)isAsset rect:(CGRect)rect{
    self.isAsset = isAsset;
    if (!isAsset) {
        [self playMedia:false rect:CGRectZero apiArray:nil isSeek:false];
    }
    self.assetUrl = nil;
    if (isAsset) {
        self.assetUrl = url;
        [self tryPlayOperation];
    }
}

-(void)webViewPostMoreInfoCallBack:(NSArray*)array isSeek:(BOOL)seek{
    NSLog(@"webViewPostMoreInfoCallBack调用api");
    [self playMedia:false rect:CGRectZero apiArray:[NSArray arrayWithArray:array] isSeek:seek];
}

-(void)webViewPressAsset{
    if (self.assetUrl && self.isAsset && self.requestUrl && self.title) {
        self.mediaUrl = self.assetUrl;
        [self playMedia:true rect:CGRectZero apiArray:nil isSeek:false];
    }
}
#endif


- (void)tryPlayOperation
{
#if (UseBeatifyAppJs==1)
    if (!isInReadMode) {
        [self.marjorWebView evaluateJavaScript:@"tryToOperation();" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            if (![ret boolValue]) {
                [self webViewPressAsset];
            }
        }];
    }
#endif
}

-(void)checkBtnVideoState:(NSString*)url
{
    forceFireTime *tmpo = [MainMorePanel getInstance].morePanel.forceFireTime;
    BOOL isForce = [MarjorWebConfig isValid:tmpo.btime a2:tmpo.etime];
    BOOL isCanexcutApi = [self checkTimeVaild:isForce];
    if (isCanexcutApi &&!GetAppDelegate.isProxyState && self.webUserConfig.isUseApi && self.playBtn.hidden) {
        NSArray *array = self.webUserConfig.rule;
        for (int i = 0; i < array.count; i++) {
            NSRange range = [url rangeOfString:[array objectAtIndex:i]];
            if (range.location != NSNotFound) {
                self.playBtn.hidden = NO;
                [self updateTishiAction:!self.playBtn.hidden];
                if(!self.mediaUrl){
                    self.mediaUrl = [[NSBundle mainBundle] pathForResource:@"MajorJs.bundle/app_default_loading2" ofType:@"mp4"];
                }
                if (!self.mediaReferer) {
                    self.mediaReferer = self.webUserConfig.url;
                }
                break;
            }
        }
    }
    if (!self.playBtn.hidden && ![self.playBtn.superview viewWithTag:PlayVideoTishiViewTag]){
        [self updateTishiAction:!self.playBtn.hidden];
    }
}

- (void)updateProcessbar:(float)progress animated:(BOOL)animated {
    if (progress == 1.0) {
        [self.webProgressView setProgress:progress animated:animated];
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.webProgressView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [self.webProgressView setProgress:0.0 animated:NO];
                             }
                         }];
    } else {
        if (self.webProgressView.alpha < 1.0) {
            self.webProgressView.alpha = 1.0;
        }
        [self.webProgressView setProgress:progress
                                 animated:(progress > self.webProgressView.progress) && animated];
    }
#if (UseBeatifyAppJs==1)
    if (!isInReadMode && progress>0.4) {
        NSURL *_url = self.marjorWebView.URL;
        if (_url) {
            NSString *js = [NSString stringWithFormat:@"hanledUrl1(\"%@\",\"%@\")",_url.absoluteString,_url.host];
            [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable v, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"hanledUrl1 externParam = %@",[error description]);
                }
            }];
        }
    }
#endif
}

#pragma call back

- (void)webCore_webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}

- (void)webCore_webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    [self hiddenWebPic];
    [self hiddeVideoMode];
    [self hiddenTopAd];
    [self updateNightMode];
    [self fireScoll];
    //开起阅读模式 关闭window.alookDisableReaderMode = true
    [self.marjorWebView evaluateJavaScript:@"window.__firefox__.forceReaderMode = true" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    [self updateWebFont];
    [self webSetVideoFloatingPageScrollOffset];
    if (isInReadMode) {
        [self.marjorWebView evaluateJavaScript:@"window.__firefox__.nextPageStopLoading()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
    else{//非阅读模式下
        NSString *vv = [[MainMorePanel getInstance].morePanel.maskBtn JSONString];
        if (!vv || [vv length]<2) {
            vv = [@{@"special":@[@"notuser:com"],@"notuser":@[@"notuser"]} JSONString];
        }
        NSString *js = [NSString stringWithFormat:@"videoJsonText = %@",vv];
        [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
        // typeof a != "undefined" ? true : false;
    }
}

- (void)webCore_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [self removeWebDesView];
    if ([[webView.URL host] compare:@"127.0.0.1"]==NSOrderedSame) {
        return;
    }
    RemoveViewAndSetNil(GetAppDelegate.globalWebDesList);
    NSString *urlString = webView.URL.absoluteString;
    [self exchangeWebConfig:[webView.URL host] url:urlString];
    [self updateWebFrame:false isAnmation:false isForceUpdate:false];
    if (self.webUserConfig.isAlwaysAds) {
        if (self.isRemoveAdMode) {
            self.isRemoveAdMode = false;
            [[WebCoreManager getInstanceWebCoreManager] updateRuleListState:false webView:self.marjorWebView url:urlString];
        }
    }
    else{
        if ([urlString rangeOfString:@"cpu.baidu.com"].location != NSNotFound ||
            [urlString rangeOfString:@"cpro.baidu.com"].location != NSNotFound) {
            if (self.isRemoveAdMode) {
                self.isRemoveAdMode = false;
                [[WebCoreManager getInstanceWebCoreManager] updateRuleListState:false webView:self.marjorWebView url:urlString];
            }
        }
        else{
            if (self.isRemoveAdMode!=[MarjorWebConfig getInstance].isRemoveAd) {
                self.isRemoveAdMode = [MarjorWebConfig getInstance].isRemoveAd;
                [[WebCoreManager getInstanceWebCoreManager] updateRuleListState:[MarjorWebConfig getInstance].isRemoveAd webView:self.marjorWebView url:urlString];
            }
        }
    }
    self.playBtn.hidden = YES;
    [self updateTishiAction:!self.playBtn.hidden];
    self.readModeBtn.hidden = YES;
    self.title = nil;
    self.assetUrl = nil;
    if (!isInReadMode && (urlString != nil || urlString.length > 0)) {
        self.current_Url = urlString;
    }
  
    if ([[webView.URL host] compare:@"127.0.0.1"]!=NSOrderedSame) {
       WebLeaveReadMode
    }
    [self fireScoll];
    if ((self.reLoadDate && fabs([self.reLoadDate timeIntervalSinceDate:[NSDate date]])>120)||!self.reLoadDate) {
        [self stopGDTAD];
    }
    [self.rightGdtAdView removeFromSuperview];
    [self webViewInsertView:CGRectMake(0, 0, MY_SCREEN_WIDTH, 0)];
}

- (BOOL)webCore_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (isShowAdAlter) {
        NSLog(@"isShowAdAlter = true");
        decisionHandler(WKNavigationActionPolicyCancel);
        return YES;
    }
    self.requestUrl = webView.URL.absoluteString;
    if ([self.requestUrl rangeOfString:@"&ck="].location != NSNotFound) {
        NSLog(@"self.requestUrl = %@",self.requestUrl);
    }
    if (!isInReadMode) {
#if (UseBeatifyAppJs==1)
        if (!navigationAction.targetFrame.isMainFrame) {
          //  [self.marjorWebView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
        }
#endif
        [self hideAdsByLoadingPercent];
        [self webGetFavicon];
        [self updateNightMode];
        NSLog(@"self.requestUrl = %@ [webView.URL host]= %@",self.requestUrl,[webView.URL host]);
        NSString *tmp = [webView.URL host];
        if(tmp && [tmp compare:@"127.0.0.1"]==NSOrderedSame)
        {
            decisionHandler(WKNavigationActionPolicyCancel);
            return YES;
        }
      }
    [self fireScoll];
    return false;
}
- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self removeSnapsthoView];
    [self webGetFavicon];
    [self.marjorWebView evaluateJavaScript:@" window.__firefox__.reader.checkReadability()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    if (!isInReadMode) {
        [self hiddenWebPic];
         @weakify(self)
        [self.marjorWebView evaluateJavaScript:@"document.title" completionHandler:^(id re, NSError * _Nullable error) {
            @strongify(self)
            self.title = re;
            if([[webView.URL host] compare:@"127.0.0.1"]!=NSOrderedSame)
            [MarjorWebConfig updateDB:self.title withFavicon:self.iconUrl withUrl:webView.URL.absoluteString];
        }];
#if (UseBeatifyAppJs==0)
        NSString *js = [NSString stringWithFormat:@"__webjsNodePlug__.clickfixUrl(\"%@\")",self.requestUrl];
        [self.marjorWebView evaluateJavaScript:js completionHandler:^(id ret, NSError *  error) {
            NSLog(@"clickfixUrl error %@",error);
        }];
        [self checkBtnVideoState:webView.URL.absoluteString];
#endif
    }
}

- (void)webCore_webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    [self hiddenWebPic];
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webCore_webViewLoadProgress:(float)progress{
    [self hideAdsByLoadingPercent];
    [self updateProcessbar:progress animated:YES];
    [self.addressToolBar updateProcessbar:progress animated:YES];
    if (progress>0.5){
#if (UseBeatifyAppJs==0)
        [self.marjorWebView evaluateJavaScript:@"__webjsNodePlug__.startCheckAdBlock();" completionHandler:^(id ret , NSError * _Nullable error) {
            
        }];
#endif
    }
//#ifndef DEBUG
      if (progress>0.5 && progress<=1 && self.webUserConfig.viewlist && [self isWebConfig]) {//
      // [self.marjorWebView evaluateJavaScript:@"__webjsNodePlug__.startCheckList();" completionHandler:nil];
    }
    if (progress>0.3) {//尝试检查是否有合适的url
        [self.marjorWebView evaluateJavaScript:@"tryToGetWebsFromAsset()" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
            NSLog(@"tryToGetPicFromWeb = %@",error);
        }];
    }
//#endif
}

- (void)webCore_webViewUrlChange:(NSString*)url{
         self.requestUrl = url;
        NSLog(@"webCore_webViewUrlChange = %@",url);
    if (!isInReadMode) {
#if (UseBeatifyAppJs==1)
        if (![url isKindOfClass:[NSNull class]]) {
            NSString* host = [[NSURL URLWithString:url] absoluteString];
        NSString *js = [NSString stringWithFormat:@"hanledUrl1(\"%@\",\"%@\")",url,host];
        [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable v, NSError * _Nullable error) {
            if (error) {
                NSLog(@"hanledUrl1 externParam = %@",[error description]);
            }
        }];
        }
#else
        [self checkBtnVideoState:self.marjorWebView.URL.absoluteString];
#endif
    }
}
-(void)webCore_webViewTitleChange:(NSString*)title{
    self.title = title;
    if (title.length>0) {
        NSString *msg = [[@"  " stringByAppendingString:title] stringByAppendingString:@"  "];
        [self makeToast:msg duration:2 position:@"center"];
    }
}
//web pos消息给ui
- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name compare:@"PostMoreInfo"]==NSOrderedSame){
        [self webViewPostMoreInfoCallBack:[message.body objectForKey:@"array"]isSeek:[[message.body objectForKey:@"seek"]boolValue]];
    }
    else if(!isInReadMode && [message.name compare:sendMessageGetPicFromPagWeb]==NSOrderedSame){
#if (UseBeatifyAppJs==1)
        [self webViewGetPicsFromPagWebCallBack:true uuid:@"" ret:message.body];
#endif
    }
    else if ([message.name compare:@"contextMenuMessageHandler"]==NSOrderedSame) {
#if (UseBeatifyAppJs==1)
        id v = message.body;
        if([v isKindOfClass:[NSDictionary class]] && ![v objectForKey:@"action"] && [v allKeys].count>2){
            [self showAlterAd];
         }
#endif
    }
    else if ([message.name compare:@"appAddAdMaskLayerMessage"]==NSOrderedSame){
         [self webViewAddAdLayerView:CGRectMake(0, 0, MY_SCREEN_WIDTH, 200)];
    }
    else if ([message.name compare:@"updateMaskLayerPosMessage"]==NSOrderedSame){
      
    }
    else if (!isInReadMode && [message.name compare:@"faviconMessageHandler"]==NSOrderedSame) {
       NSArray *array = [message.body componentsSeparatedByString:@":#:"];
        if (array.count>0) {
            self.current_Url = [array objectAtIndex:0];
            if (array.count>1) {
                self.iconUrl = [array objectAtIndex:1];
            }
        }
    }
    else if( [message.name compare:@"spotlightMessageHandler"]==NSOrderedSame){
        NSString *description = [message.body objectForKey:@"description"];
        NSString *title = [message.body objectForKey:@"title"];
        self.title = title;
        NSString *url = self.marjorWebView.URL.absoluteString;
        [GetAppDelegate addSpotlight:title des:description key:[NSString stringWithFormat:@"%@%@",description,url]url:url];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/"];
        GetAppDelegate.penFromSpotLightUrl = [url stringByTrimmingCharactersInSet:set];
    }
    else if([message.name compare:@"ClickOverButttonVideo"]==NSOrderedSame){
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            [[VideoPlayerManager getVideoPlayInstance] stop];
                NSDictionary *info =  message.body;
               self.mediaUrl = [info objectForKey:@"videoUrl"];
                self.mediaTitle =  [info objectForKey:@"title"];
            if ([self.mediaUrl length]>10) {
                self.mediaReferer = [info objectForKey:@"referer"];
                self.playBtn.hidden = NO;
                [self updateTishiAction:!self.playBtn.hidden];
//                float x = [[info objectForKey:@"x"] floatValue];
//                float y = [[info objectForKey:@"y"] floatValue];
//                float w = [[info objectForKey:@"w"] floatValue];
//                float h = [[info objectForKey:@"h"] floatValue];
                [self playMedia:false rect:CGRectZero apiArray:nil isSeek:false];
            }
            else{
                NSString *url =  [info objectForKey:@"webUrl"];
                [self loadUrl:url];
                forceFireTime *tmpo = [MainMorePanel getInstance].morePanel.forceFireTime;
                BOOL isForce = [MarjorWebConfig isValid:tmpo.btime a2:tmpo.etime];
                BOOL isCanexcutApi = [self checkTimeVaild:isForce];
#ifdef DEBUG
                isCanexcutApi = true;
#endif
                if (isCanexcutApi) {
                    [self doWeb:nil isSeek:false];
                }
            }
        }
    }
    else if([message.name compare:@"GetAssetSuccess"]==NSOrderedSame){
        if ([message.body isKindOfClass:[NSString class]]) {
                            return;
                         }
        [self webViewPostMoreInfoCallBack:[message.body objectForKey:@"array"]isSeek:[[message.body objectForKey:@"seek"]boolValue]];
    }
    else if([message.name compare:@"VideoHandler"]==NSOrderedSame)
    {
        if ([message.body isKindOfClass:[NSString class]]) {
            return;
        }
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *info = message.body;
            self.assetUrl = [info objectForKey:@"src"];
            self.mediaUrl  =  [info objectForKey:@"src"];
            self.mediaTitle =  [info objectForKey:@"title"];
            self.mediaReferer = [info objectForKey:@"referer"];
#if (UseBeatifyAppJs==0)
            self.playBtn.hidden = NO;
            [self updateTishiAction:!self.playBtn.hidden];
#endif
            NSString *msgID = [info objectForKey:@"msgId"];
            id rectDic = [message.body objectForKey:@"rect"];
            CGRect rect = CGRectMake([[rectDic objectForKey:@"left"] floatValue], [[rectDic objectForKey:@"top"] floatValue], [[rectDic objectForKey:@"width"] floatValue], [[rectDic objectForKey:@"height"] floatValue]);
            //printf("VideoHandler = %s\n",[[message.body description] UTF8String]);
#if (UseBeatifyAppJs==1)
            if ([msgID isEqualToString:@"play"]) {
                [self.marjorWebView evaluateJavaScript:@"tryToOperation();" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                    [self webViewGetAsset:[message.body objectForKey:@"src"] referer:[message.body objectForKey:@"referer"] title:[message.body objectForKey:@"title"] isAsset:[ret boolValue]rect:rect];
                }];
            }
            else if([msgID isEqualToString:@"get"]){
                NSString *js = [NSString stringWithFormat:@"hanledUrl1(\"%@\",\"%@\")",self.requestUrl,[NSURL URLWithString:self.requestUrl].host];
                [self webViewInsertView:rect];
                [self.marjorWebView evaluateJavaScript:@"addAdXinxlTimer()" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
                          NSLog(@"addAdXinxlTimer %@",error);
                  }];
                [self.marjorWebView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                    [self.marjorWebView evaluateJavaScript:@"checkAssetVaild();" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                        if ([ret boolValue]) {
                            [self webViewGetAsset:[message.body objectForKey:@"src"] referer:[message.body objectForKey:@"referer"] title:[message.body objectForKey:@"title"]isAsset:[ret boolValue]rect:rect];
                        }
                    }];
                }];
            }
#else
            if ([msgID isEqualToString:@"play"]) {
                if(![self checkTimeVaild:false])
                [self playMedia:false rect:CGRectZero ];
            }
            else if([msgID isEqualToString:@"get"]){
                    if ([self isWebConfig] && self.webUserConfig.isAuToPlay) {
                        [self playMedia:true rect:CGRectZero];
                    }
                    else{
                        if(![self checkTimeVaild:false]){
                            [self playMedia:true rect:CGRectZero];
                        }
                    }
                }
#endif
        }
    }
    else if ([message.name compare:@"readerModeMessageHandler"]==NSOrderedSame){
        NSString *type = [message.body objectForKey:@"Type"];
        if([type compare:@"ReaderModeStateChange"] ==NSOrderedSame)
        {
            NSString *value = [message.body objectForKey:@"Value"];
            if([value compare:@"Available"]==NSOrderedSame){
                self.readModeBtn.hidden = NO;
            }
            else if ([value compare:@"Active"]==NSOrderedSame){
                self.readModeBtn.hidden = NO;
            }
            else{
                if(!isInReadMode){
                    self.readModeBtn.hidden = YES;
                }
            }
            [self updateReadBtn];
        }
        else if ([type compare:@"LoadingNextPage"]==NSOrderedSame){
            NSString *value = [message.body objectForKey:@"Value"];//单独创建一个web请求数据
            if (value && [NSURL URLWithString:value]) {
                self.recordReadModeUrl = value;
                [self.readModeWeb loadUrl:value];
            }
        }
    }
    else if(!isInReadMode && [message.name compare:sendWebJsNodeMessageInfo]==NSOrderedSame)
    {
        [self updateWebDesList:message.body];
    }
}


-(void)openURL:(NSURL*)url{
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
    }
    else{
        BottommTipsView *v = [[BottommTipsView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-self.bottomTools.frame.size.height-40, self.bounds.size.width, 40) des:[NSString stringWithFormat:@"打开:%@失败",url]];
        [self insertSubview:v belowSubview:self.bottomTools];
        [v remveAction];
    }
}

//通过 openURL 打开，appstore ，或者第三方app
- (void)webCore_webViewOpenOtherAction:(NSURL*)url{
    if (self.isForceOpenThird) {
        [self openURL:url];
        return;
    }
    return;
    if (isInBack || [MajorSystemConfig getInstance].isGotoUserModel==2) {
        return;
    }
    NSURL *lastUrl =  [NSURL URLWithString:self.requestUrl];
    BOOL ret = [[MarjorWebConfig getInstance] isCanOpenInAppStore: lastUrl.host];
    if (ret) {
        //提示
        BottommTipsView *v = [[BottommTipsView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height+40, self.bounds.size.width, 40) barH:self.bottomTools.bounds.size.height appStoreUrl:url sourceUrl:[NSURL URLWithString:self.requestUrl] des:[NSString stringWithFormat:@"已阻止:%@:",[url scheme]]];
        [self insertSubview:v belowSubview:self.bottomTools];
        [v showAction];
        __weak typeof(self) weakSelf = self;
        v.openUrlBlock = ^(NSURL *openUrl) {
            [weakSelf openURL:openUrl];
        };
        return;
    }
    if (isAlterView) {
        return;
    }
    isAlterView = true;
    NSString *urlDes = [url absoluteString];
    if ([urlDes length]>40) {
       NSString *tmp  = [urlDes substringToIndex:20];
       NSString *tmp2 = [urlDes substringWithRange:NSMakeRange([urlDes length]-10, 10)];
        urlDes = [NSString stringWithFormat:@"%@...%@",tmp,tmp2];
    }
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"%@想启动第三方应用:%@",lastUrl.host,urlDes]
                              message:nil
                              delegate:nil
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"打开",@"此网站禁止打开", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1: {
                [self openURL:url];
                self->isAlterView = false;
                break;
            }
            case 0:{
                NSLog(@"webCore_webViewOpenInAppStore = 0");
                self->isAlterView = false;
                break;
            }
            case 2:{
                self->isAlterView = false;
                [[MarjorWebConfig getInstance] addOpenInAppStoreDisable:[NSURL URLWithString:self.requestUrl].host];
                NSLog(@"webCore_webViewOpenInAppStore = 2");
            }
        }
    }];
}

- (void)webCore_webViewOpenInAppStore:(NSURL*)url{
    if (self.isForceOpenThird) {
        [self openURL:url];
        return;
    }
    return;
    if (isInBack || [MajorSystemConfig getInstance].isGotoUserModel==2) {
        return;
    }
   BOOL ret = [[MarjorWebConfig getInstance] isCanOpenInAppStore: [NSURL URLWithString:self.requestUrl].host];
    if (ret) {
        //提示
        BottommTipsView *v = [[BottommTipsView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height+40, self.bounds.size.width, 40) barH:self.bottomTools.bounds.size.height appStoreUrl:url sourceUrl:[NSURL URLWithString:self.requestUrl] des:@"已阻止AppStore打开"];
        [self insertSubview:v belowSubview:self.bottomTools];
        [v showAction];
        __weak typeof(self) weakSelf = self;
        v.openUrlBlock = ^(NSURL *openUrl) {
            [weakSelf openURL:openUrl];
        };
        return;
    }
    if (isAlterView) {
        return;
    }
    isAlterView = true;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"%@需要打开AppStore",[NSURL URLWithString:self.requestUrl].host]
                              message:nil
                              delegate:nil
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"打开",@"此网站禁止打开", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1: {
                [self openURL:url];
                self->isAlterView = false;
                break;
            }
            case 0:{
                self->isAlterView = false;
                NSLog(@"webCore_webViewOpenInAppStore = 0");
                break;
            }
            case 2:{
                self->isAlterView = false;
                [[MarjorWebConfig getInstance] addOpenInAppStoreDisable:[NSURL URLWithString:self.requestUrl].host];
                NSLog(@"webCore_webViewOpenInAppStore = 2");
            }
        }
    }];
}

- (void)webCore_webViewOpenInCall:(NSURL*)url{
    //if (isInBack || [MajorSystemConfig getInstance].isGotoUserModel==2) {
     //   return;
   // }
    [self openURL:url];
}

- (BOOL)webCore_webViewIsOpenInNewWeb:(NSURL*)url{
    return false;
}


- (void)addFrameAnimation:(UIView*)view rect:(CGRect)rect isAnimation:(BOOL)isAnimation{
    if (view) {
        if (isAnimation) {
            POPBasicAnimation *animFrame = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            animFrame.beginTime = CACurrentMediaTime();
            animFrame.duration = 0.2;
            animFrame.toValue=[NSValue valueWithCGRect:rect];
            [view pop_addAnimation:animFrame forKey:nil];
        }
        else{
            view.frame = rect;
        }
    }
}

- (void)webCore_toolBarState:(BOOL)isHidden
{
    [self updateWebFrame:isHidden isAnmation:true isForceUpdate:false];
}

-(void)updateWebFrame:(BOOL)isHidden isAnmation:(BOOL)isAnmation isForceUpdate:(BOOL)isForceUpdate{
    NSLog(@"isHiddenTop = %d",isHiddenTop);
    if (self->isHiddenTop != isHidden) {
        self->isHiddenTop = isHidden;
        isForceUpdate = true;
    }
    if (self.webTopArray.count>0 || self.webChannelView.feeBackBlock) {
        isHidden = false;
    }
    isHidden = false;
    if (self->isHidden!=isHidden || !isInitFixBug || isForceUpdate) {
        isInitFixBug = true;
        self->isHidden = isHidden;
        [self.addressToolBar pop_removeAllAnimations];
        [self.marjorWebView pop_removeAllAnimations];
        [self.bottomBtnsView pop_removeAllAnimations];
        [self.scaleBtn pop_removeAllAnimations];
        [self.topTools pop_removeAllAnimations];
        CGRect rectWebChannel = CGRectZero;
        if (self.webTopArray.count>0 || self.webChannelView.feeBackBlock) {
            rectWebChannel = CGRectMake(0, self.webGeaneralTools.frame.origin.y-self.webChannelView.bounds.size.height,MY_SCREEN_WIDTH, self.webChannelView.bounds.size.height);
        }
        float s = 1;
        if (IF_IPAD) {
            s = 0.6;
        }
          CGRect rectBar = CGRectMake(0, rectWebChannel.origin.y-40, MY_SCREEN_WIDTH, 40);
        CGRect rectTop = CGRectMake(0,GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH,IF_IPAD?45:35);
        if (isHiddenTop) {
            rectTop = CGRectMake(0,GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH,0);
        }
        float startYYY =  GetAppDelegate.appStatusBarH+rectTop.size.height;
        
        self.webProgressView.frame = CGRectMake(0, startYYY,
                                                self.frame.size.width, 2);
        CGRect rectMaj = CGRectMake(0,startYYY, MY_SCREEN_WIDTH, self.webGeaneralTools.frame.origin.y-rectWebChannel.size.height-startYYY);
        CGRect rectBtnsView = CGRectMake(0, self.bottomTools.frame.origin.y-btnsViewh*s, self.bottomTools.frame.size.width, btnsViewh*s);
        CGRect rectScaleNew = scaleRect;
        if (isHidden) {
            if (self.webTopArray.count>0 || self.webChannelView.feeBackBlock) {
                rectWebChannel = CGRectMake(0, rectWebChannel.origin.y+self.webChannelView.bounds.size.height,MY_SCREEN_WIDTH, self.webChannelView.bounds.size.height);
            }
            rectBar = CGRectMake(0, MY_SCREEN_HEIGHT+40, MY_SCREEN_WIDTH, 40);
            rectMaj = CGRectMake(0,rectTop.origin.y+rectTop.size.height, MY_SCREEN_WIDTH, self.bottomTools.frame.origin.y-(rectTop.origin.y+rectTop.size.height));
            rectBtnsView = CGRectMake(0,rectBtnsView.origin.y+rectBtnsView.size.height,rectBtnsView.size.width,self.bottomTools.frame.size.height);
            rectScaleNew = CGRectMake(scaleRect.origin.x, -scaleRect.size.height*1.5, scaleRect.size.width, scaleRect.size.height);
        }
        if (IF_IPAD) {
            rectMaj = CGRectMake(self.marjorWebView.frame.origin.x, rectMaj.origin.y, self.marjorWebView.frame.size.width, rectMaj.size.height);
        }
        [self addFrameAnimation:self.webChannelView rect:rectWebChannel isAnimation:isAnmation];
        [self addFrameAnimation:self.addressToolBar rect:rectBar isAnimation:isAnmation];
        [self addFrameAnimation:self.topTools rect:rectTop isAnimation:isAnmation];
        if (self.isPadLand ) {
            float yy = 20+self.bottomTools.bounds.size.height+self.webChannelView.bounds.size.height;
            [self addFrameAnimation:self.marjorWebView rect:CGRectMake(20, 0,MY_SCREEN_HEIGHT-yy,MY_SCREEN_WIDTH) isAnimation:isAnmation];
            self.marjorWebView.center = CGPointMake(self.center.x, self.center.y-yy/4);
        }
        else{
            [self addFrameAnimation:self.marjorWebView rect:rectMaj isAnimation:isAnmation];
        }
        [self addFrameAnimation:self.bottomBtnsView rect:rectBtnsView isAnimation:isAnmation];
        [self addFrameAnimation:self.scaleBtn rect:rectScaleNew isAnimation:isAnmation];
        
        //if(isHidden){
       // }
    }
    [self movePlayAction];
}
#pragma mark 数据库操作


@end
