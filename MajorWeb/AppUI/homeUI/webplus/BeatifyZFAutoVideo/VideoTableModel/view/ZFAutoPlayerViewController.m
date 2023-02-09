

#import "ZFAutoPlayerViewController.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "ZFTableViewCell.h"
#import "ZFTableData.h"
#import "AppDelegate.h"
#import "CLUPnPDevice.h"
#import "ZFAutoListParseManager.h"
#import "TYAlertAction+TagValue.h"
//#import "BeatfiyShare.h"
#import "MajorSystemConfig.h"
#import "DNLAController.h"
#import <AVFoundation/AVFoundation.h>
#import "helpFuntion.h"
#import "UIAlertView+NSCookbook.h"
#import "ZFUtilities.h"
#import "MBProgressHUD.h"
#import "AXPracticalHUD.h"
//#import "VideoAdManager.h"
#import "BeatifyNativeAdManager.h"
//#import "ViewController.h"
#import "BeatifyAssetControlView.h"
#import "ZFAdCellLayout.h"
#import "VipPayPlus.h"
#import "ZFAdCell.h"
#import "WebPushItem.h"
#import "NSObject+UISegment.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "BeatifyAnimationDelegate.h"
#import "AppDelegate.h"
#import "ZFAutoAssetListView.h"
#import "ZFAutoPlayerCtrl.h"
#import "ShareSdkManager.h"
#import "BUPlayer.h"
#import "VideoPlayerManager.h"
#import "BeatifyGDTNativeView.h"
#import "BUDFeedAdTableViewCell.h"
#import <BUAdSDK/BUNativeExpressAdManager.h>
#import <BUAdSDK/BUNativeExpressAdView.h>
static NSString *kIdentifier = @"kIdentifier";
static NSString *kAdIdentifier = @"kAdIdentifier";
static NSString *kBuAdIdentifier = @"kBuAdIdentifier";
static ZFAutoPlayerViewController * autoCtrl;
static BOOL  isFristInto = true;
static BOOL  isFull = false;
typedef enum TableScrollViewState{
    Table_Scroll_Finger_Begin,
    Table_Scroll_Finger_End,
}_TableScrollViewState;

typedef enum TableScrollViewDirection{
    Table_Scroll_Normal,
    Table_Scroll_Up,
    Table_Scroll_Down,
}_TableScrollViewDirection;
#define TableScrollDis 50

@interface ZFAutoPlayerViewController () <ZFAutoAssetListViewDelegate,UITableViewDelegate,UITableViewDataSource,ZFTableViewCellDelegate,BeatifyNativeAdManagerDelegate,BeatifyStartAnimationDelegate,BUNativeAdDelegate,BUNativeExpressAdViewDelegate>
{
    float isLoadAd;
    float topOffsetY;
    float fixOffsetH;
    BOOL  isTj;
    
    BOOL  isHidden;
    BOOL  isTouch;
    float offsetBeginY;
    BOOL  isAddLastAsset;
    _TableScrollViewState scrollState;
    _TableScrollViewDirection scrollDirection;
    BOOL  isWaitViewHidden;
}
@property (nonatomic, strong) BUNativeExpressAdManager *adManager;
@property (nonatomic,strong)NSTimer *delayFireTime;
@property (nonatomic,strong)NSTimer *delayNativeTime;
@property (nonatomic,strong)UIView *progressWaitView;
@property (nonatomic,strong)ZFAutoAssetListView *assetlistView;
@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong)UIButton *topViewBtn1;
@property (nonatomic,strong)UIButton *topViewBtn2;
@property (nonatomic,strong)UIButton *topViewBtn3;
@property (nonatomic, assign) BOOL isPushState;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZFAutoPlayerCtrl *player;
@property (nonatomic, strong) BeatifyAssetControlView *controlView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *dataOriginalSource;
@property (nonatomic, strong) NSMutableArray *expressAdViews;
@property (nonatomic, strong) NSMutableArray *budNativeAdViews;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, assign) CGSize viewSize;
@property (nonatomic, strong) UIButton *btnCut;
@property (nonatomic, strong) UIButton *btnPause;
@end

@implementation ZFAutoPlayerViewController

+(BOOL)isInitUI{
    if (autoCtrl) {
        return true;
    }
    return false;
}

+(BOOL)isFull{
    if (autoCtrl) {
        return isFull;
    }
    return false;
}

+(void)showAdVideoAndExitFull{
    [autoCtrl showAdVideoAndExitFull ];
}

+(void)exitAdVideoAndEnterFull{
    
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)shareApp:(UIButton*)sender{
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
}

-(void)unInit{
    self.adManager.delegate = nil;
    self.adManager = nil;
    autoCtrl = nil;
    [self.delayNativeTime invalidate];self.delayNativeTime = nil;
    [self.delayFireTime invalidate];self.delayFireTime = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRload:) object:nil];
    [self removeAssetListView];
     [BeatifyNativeAdManager getInstance].delegate= nil;
    [[ZFAutoListParseManager getInstance] stopParse];
    [self.tableView removeFromSuperview];self.tableView = nil;
    [self.player stop];self.controlView=nil;self.player=nil;
}

-(instancetype)init{
    self = [super init];
    fixOffsetH = [MajorSystemConfig getInstance].zhiboFixTopH;
    [BeatifyGDTNativeView stopGdtNatiview];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    autoCtrl = self;
    [[VideoPlayerManager getVideoPlayInstance] stop];
    self.view.tag = TmpTopViewTag;
    
    [[DNLAController getInstance] sdkAuthRequest];
    [BeatifyNativeAdManager getInstance].delegate= self;
    [[BeatifyNativeAdManager getInstance] startReqeust:false];
    self.expressAdViews = [NSMutableArray arrayWithCapacity:10];
    self.budNativeAdViews = [NSMutableArray arrayWithCapacity:10];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wirelessRoutesAvailableChange:) name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wirelessRouteActiveChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceGDTUnifiedNotifi:) name:@"GDTUnifiedInterstitialAdNotifi" object:nil];
    if(!self.delayNativeTime){
        self.delayNativeTime = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(loadNativeAds) userInfo:nil repeats:YES];
    }
    
    if([[VipPayPlus getInstance]isCanShowFullVideo]){
        [[VipPayPlus getInstance] tryShowFullVideo:^{
            
        }];
    }
}

- (void)loadNativeAds {
    [self.delayNativeTime invalidate];self.delayNativeTime = nil;
      BUAdSlot *slot1 = [[BUAdSlot alloc] init];
        slot1.ID = [MajorSystemConfig getInstance].buDxxlID?[MajorSystemConfig getInstance].buDxxlID:@"000";
        slot1.AdType = BUAdSlotAdTypeFeed;
        slot1.position = BUAdSlotPositionFeed;
        slot1.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
        slot1.isSupportDeepLink = YES;
     float ww = self.view.bounds.size.width;
      if (!self.adManager) {
         self.adManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(ww, 0)];
     }
     self.adManager.adSize = CGSizeMake(ww, 0);
     self.adManager.delegate = self;
     [self.adManager loadAd:3];
}

-(void)reviceGDTUnifiedNotifi:(NSNotification*)object
{
    if ([object.object boolValue]) {
        GetAppDelegate.isOldFullScreen = GetAppDelegate.isFullScreen;
        [self.player enterFullScreen:NO animated:NO];
    }
    else{
        if (GetAppDelegate.isOldFullScreen) {
            [self.player enterFullScreen:YES animated:NO];
        }
    }
}

-(void)wirelessRoutesAvailableChange:(NSNotification*)object{
    MPVolumeView *v = self.controlView.portraitControlView.airPlayBtn;
    NSLog(@"v.wirelessRoutesAvailable = %d",v.wirelessRoutesAvailable);
}

-(void)wirelessRouteActiveChange:(NSNotification*)object{
    NSString *serviceName = nil;
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription* currentRoute = audioSession.currentRoute;
    for (AVAudioSessionPortDescription* outputPort in currentRoute.outputs){
        if ([outputPort.portType isEqualToString:AVAudioSessionPortAirPlay])
            serviceName =  outputPort.portName;
        break;
    }
    if (serviceName.length>0) {
        self.isPushState = true;
    }
    else{
        self.isPushState = false;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatelinkBtn];
    });
}

-(UIView*)topView{
    if (!_topView) {
        //233X78
        float w = 233,h = 78;
        if (IF_IPHONE) {
            w/=2;h/=2;
        }
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, fixOffsetH+topOffsetY, MY_SCREEN_WIDTH, h)];_topView.backgroundColor = RGBCOLOR(0, 0, 0);
        self.topViewBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topViewBtn1 setImage:[UIImage imageNamed:@"tuijian_home"] forState:UIControlStateNormal];
        [self.topViewBtn1 addTarget:self action:@selector(clickTj:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_topViewBtn1];
        
        self.topViewBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topViewBtn2 setImage:[UIImage imageNamed:@"tuijian_sc_home_"] forState:UIControlStateNormal];
        [self.topViewBtn2 addTarget:self action:@selector(clickSc:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_topViewBtn2];
        
        [NSObject initii:_topView contenSize:_topView.frame.size vi:_topViewBtn1 viSize:CGSizeMake(w, h) vi2:nil index:0 count:2];
        [NSObject initii:_topView contenSize:_topView.frame.size vi:_topViewBtn2 viSize:CGSizeMake(w, h) vi2:_topViewBtn1 index:2 count:2];
        
        @weakify(self)
        [RACObserve([ZFAutoListParseManager getInstance],isReadyInit) subscribeNext:^(id x) {
            @strongify(self)
            if ([x boolValue] && !self.topViewBtn3) {
                self.topViewBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.topViewBtn3 setImage:[UIImage imageNamed:@"tuijian_sc_select"] forState:UIControlStateNormal];
                [self.topViewBtn3 addTarget:self action:@selector(clickM:) forControlEvents:UIControlEventTouchUpInside];
                [self.topView addSubview:self.topViewBtn3];
                [NSObject initii:self.topView contenSize:self.topView.frame.size vi:self.topViewBtn1 viSize:CGSizeMake(w, h) vi2:nil index:0 count:3];
                [NSObject initii:self.topView contenSize:self.topView.frame.size vi:self.topViewBtn3 viSize:CGSizeMake(w, h) vi2:self.topViewBtn1 index:1 count:3];
                [NSObject initii:self.topView contenSize:self.topView.frame.size vi:self.topViewBtn2 viSize:CGSizeMake(w, h) vi2:self.topViewBtn3 index:2 count:3];
            }
        }];
    }
    return _topView;
}

-(void)clickAssetListView:(NSInteger)pos{
    isTj = true;
    [self.controlView.portraitControlView.scBtn setImage:ZFPlayer_Image(@"play_sc") forState:UIControlStateNormal];
    [_topViewBtn1 setImage:[UIImage imageNamed:@"tuijian_home"] forState:UIControlStateNormal];
    [_topViewBtn2 setImage:[UIImage imageNamed:@"tuijian_sc_home_"] forState:UIControlStateNormal];
     [self.player stop];
    self.progressWaitView.hidden = NO;
    [[ZFAutoListParseManager getInstance] updateTypePos:pos delayTime:0.2];
    [self reloadAssetAndAd];
    BOOL rr = [self tryToFindVaildAsset];
    self.progressWaitView.hidden = rr;
    isFristInto = !rr;
    [ZFAutoListParseManager getInstance].isCanUpdate = true;
}

-(void)removeAssetListView{
    [self.assetlistView removeFromSuperview];self.assetlistView = nil;
}

-(void)clickM:(UIButton*)sender{
    if (!self.assetlistView) {
        _assetlistView = [[ZFAutoAssetListView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height)array:[MajorSystemConfig getInstance].param8];
        _assetlistView.delegate = self;
        [self.view addSubview:_assetlistView];
    }
}

-(void)clickSc:(UIButton*)sender{
    if (isTj) {
        [self.controlView.portraitControlView.scBtn setImage:ZFPlayer_Image(@"play_sc_") forState:UIControlStateNormal];
        [_topViewBtn1 setImage:[UIImage imageNamed:@"tuijian_home_"] forState:UIControlStateNormal];
        [_topViewBtn2 setImage:[UIImage imageNamed:@"tuijian_sc_home"] forState:UIControlStateNormal];
        isTj = false;
        [self reloadAssetAndAd];
        [self tryToFindVaildAsset];
    }
}

-(void)clickTj:(UIButton*)sender{
    if (!isTj) {
        [self.controlView.portraitControlView.scBtn setImage:ZFPlayer_Image(@"play_sc") forState:UIControlStateNormal];
        [_topViewBtn1 setImage:[UIImage imageNamed:@"tuijian_home"] forState:UIControlStateNormal];
        [_topViewBtn2 setImage:[UIImage imageNamed:@"tuijian_sc_home_"] forState:UIControlStateNormal];
        isTj = true;
        [self reloadAssetAndAd];
        [self tryToFindVaildAsset];
    }
}

-(void)showAdVideoAndExitFull{
    [((ZFPlayerControlView*)self.player.controlView).landScapeControlView backBtnClickAction:nil];
}

-(void)initUI{
    isTj = true;
    self.view.backgroundColor = RGBCOLOR(0, 0, 0);
    self.viewSize = self.view.bounds.size;
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"share_app"];
    topOffsetY = image.size.height/image.size.width * MY_SCREEN_WIDTH;
    [btnShare setImage:image forState:UIControlStateNormal];
    
    btnShare.frame = CGRectMake(0, fixOffsetH, MY_SCREEN_WIDTH, topOffsetY);
    [self.view addSubview:btnShare];
    [btnShare addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:btnShare];
    
    UIView *topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH,fixOffsetH)];
    topBlackView.backgroundColor = RGBCOLOR(255, 255, 255);
    [self.view addSubview:topBlackView];
    
    self.isPushState = false;
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    /// player的tag值必须在cell里设置
    self.player = [ZFAutoPlayerCtrl playerWithScrollView:self.tableView playerManager:playerManager containerViewTag:100];
    self.player.controlView = self.controlView;
    self.player.assetURLs = self.urls;
    /// 0.8是消失80%时候，默认0.5
    self.player.playerDisapperaPercent = 0.8;
    /// 移动网络依然自动播放
    self.player.WWANAutoPlay = YES;

    @weakify(self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        if (self.player.playingIndexPath.row < self.urls.count - 1) {
            //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.player.playingIndexPath.row+1 inSection:0];
            //            [self player:indexPath scrollToTop:YES];
            [self.player.currentPlayerManager replay];
        } else {
            [self.player stopCurrentPlayingCell];
        }
    };
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        if (isFullScreen) {
            GetAppDelegate.videoPlayMode=2;
        }
        else{
            GetAppDelegate.videoPlayMode=0;
        }
        [self setNeedsStatusBarAppearanceUpdate];
        [UIViewController attemptRotationToDeviceOrientation];
        self.tableView.scrollsToTop = !isFullScreen;
    };

    self.player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {//isFullScreen
        @strongify(self)
        GetAppDelegate.supportRotationDirection = [self supportedInterfaceOrientations];
        GetAppDelegate.isFullScreen = isFullScreen;
        [self setNeedsStatusBarAppearanceUpdate];
        [self updateBtnsAple:isFullScreen];
        isFull = isFullScreen;
        
        if (isFullScreen) {//不是全屏的时候
            if (!self.delayFireTime) {
                self.delayFireTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(delayFireTimeAd) userInfo:nil repeats:YES];
            }
        }
        else{
            [self.delayFireTime invalidate];self.delayFireTime = nil;
            [BUPlayer reSetMute:false];
        }
    };
    self.player.playerLoadStatChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        @strongify(self)
        [self updateState:loadState];
    };
    self.player.videoLink = ^{
        @strongify(self)
        [self videoLink];
    };
    self.player.videoSc = ^{
        @strongify(self)
        [self videoSc];
    };
    self.player.presentationSizeChanged = ^(CGSize presentSize) {
        @strongify(self)
        BOOL isVertical = presentSize.width<presentSize.height?true:false;
        self.player.orientationObserver.fullScreenMode = isVertical?ZFFullScreenModePortrait:ZFFullScreenModeLandscape;
    };
    [self.player fixSomeControl];
  //  [RACObserve(GetAppDelegate,param4) subscribeNext:^(id x) {
    //    @strongify(self)
        self.controlView.portraitControlView.newbackBtn.hidden =  false;
    //}];
    [self requestData];
    
    [RACObserve(self.player.currentPlayerManager,isPlaying) subscribeNext:^(id x) {
        @strongify(self)
        [self updateCutImage:[x boolValue]];
    }];
    [RACObserve([ZFAutoListParseManager getInstance],listArrayChange) subscribeNext:^(id x) {
        @strongify(self)
        if([ZFAutoListParseManager getInstance].isCanUpdate && [ZFAutoListParseManager getInstance].listArray.count>0){
            self->isWaitViewHidden = YES;
            self.progressWaitView.hidden  = self->isWaitViewHidden;
            [self reloadAssetAndAd];
            if (isFristInto) {
                isFristInto = false;
                [self tryToFindVaildAsset];
               // [self playTheVideoAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]scrollToTop:true];
            }
        }
        if ([ZFAutoListParseManager getInstance].listArray.count) {
            if (!self->isLoadAd) {
                self->isLoadAd = true;
               // [self loadAd];
            }
        }
    }];
    
 //   [RACObserve(GetAppDelegate,isGetSuccess) subscribeNext:^(id x) {
    //        @strongify(self)
   //     if ([x boolValue]) {
     //       [self reloadAssetAndAd];
      //  }
   // }];
    
    
    self.btnPause = [UIButton buttonWithType:UIButtonTypeCustom];
    float w = 102,h=39;
    self.btnPause.frame = CGRectMake(0, self.viewSize.height-fixOffsetH-h*1.5, w, h);
    [self.controlView.landScapeControlView addSubview:self.btnPause];
    [self.btnPause addTarget:self action:@selector(clickBtnPause) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnCut = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCut.frame = CGRectMake(self.viewSize.width-w, self.viewSize.height-fixOffsetH-h*1.5, w, h);
    [self.controlView.landScapeControlView addSubview:self.btnCut];
    [self.btnCut addTarget:self action:@selector(clickBtnCut) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCut setImage:[UIImage imageNamed:@"loading_kai"] forState:UIControlStateNormal];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"Brower.bundle/b_close.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, fixOffsetH, 50, 30);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)delayFireTimeAd{
    [self.delayFireTime invalidate];self.delayFireTime = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoStopCheckState" object:nil];
}

-(void)backHome:(id)sender{
    if ([self.delegate respondsToSelector:@selector(zfautoPlayerWillRemove:)]) {
        [self unInit];
        [self.delegate zfautoPlayerWillRemove:nil];
    }
}


-(void)updateState:(ZFPlayerLoadState)state{
    if((state == ZFPlayerLoadStateStalled || state == ZFPlayerLoadStatePrepare) && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying)
    {//显示
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRload:) object:nil];
        [self performSelector:@selector(delayRload:) withObject:nil afterDelay:3];
    }
    else{//隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRload:) object:nil];
    }
}

-(void)delayRload:(id)value{
    [self.player.currentPlayerManager replay];
}

-(void)loadAd{
    [BeatifyNativeAdManager getInstance].delegate = self;
    [[BeatifyNativeAdManager getInstance] startReqeust:false];
}

#pragma mark - BUNativeExpressAdViewDelegate
-(void)beatifyNativeExpressAdSuccessToLoad:(NSArray*)adArray{
    [self.expressAdViews removeAllObjects];//【重要】不能保存太多view，需要在合适的时机手动释放不用的，否则内存会过大
    if (adArray.count) {
        [self.expressAdViews addObjectsFromArray:adArray];
        [adArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = GetAppDelegate.window.rootViewController;
            [expressView render];
        }];
    }
    [self reloadAssetAndAd];
}

-(void)beatifyNativeRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{
    [self reloadAssetAndAd];
}


-(void)beatifyNativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
 {//【重要】需要在点击叉以后 在这个回调中移除视图，否则，会出现用户点击叉无效的情况
    NSUInteger index = [self.dataSource indexOfObject:nativeExpressAdView];
    [self.dataSource removeObject:nativeExpressAdView];
    [self.expressAdViews removeObject:nativeExpressAdView];
    [self.urls removeObjectAtIndex:index];
    [self.dataOriginalSource removeObjectAtIndex:index];
    self.player.assetURLs = self.urls;
    [self.tableView reloadData];
    //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


-(void)updatelinkBtn{
    UIButton*  v = self.controlView.portraitControlView.lelinkPlayBtn;
    if (self.isPushState) {
        [v setImage:ZFPlayer_Image(@"touying1") forState:UIControlStateNormal];
    }
    else{
        [v setImage:ZFPlayer_Image(@"touying2") forState:UIControlStateNormal];
    }
}

-(void)didEnterForeground{
    //zbw 广点通
}

-(void)linkWithDevice:(NSInteger)pos{
    NSString *url = [self.player.currentPlayerManager.assetURL absoluteString];
    NSDictionary *dicHeader =  nil;
    [self.player.currentPlayerManager pause];
    NSLog(@"linkWithDevice url= %@",url);
    [[DNLAController getInstance] playWithUrl:url time:self.player.currentPlayerManager.currentTime header:dicHeader isLocal:NO deviceIndex:pos];
    self.isPushState = true;
    [self updatelinkBtn];
}

-(void)videoSc{
    if (isTj) {
        [[ZFAutoListParseManager getInstance] addFavite:[self.player.scParam objectForKey:@"uuid"] assetObject:self.player.scParam];
    }
    else{
        [[ZFAutoListParseManager getInstance] removeFavite:[self.player.scParam objectForKey:@"uuid"]];
        [self reloadAssetAndAd];
        [self tryToFindVaildAsset];
    }
}

-(BOOL)tryToFindVaildAsset{
    NSArray *cellView = [self.tableView visibleCells];
    BOOL isFind = false;
    for (int i =0;i<cellView.count; i++) {
       isFind = [self playTheVideoAtIndexPath:[self.tableView indexPathForCell:cellView[i]] scrollToTop:NO]  ;
        if (isFind) {
            break;
        }
    }
    if (!isFind) {
        [self.player stop];
    }
    return isFind;
}

-(void)videoLink{
     if (self.isPushState) {
        if(self.controlView.portraitControlView.airPlayBtn.wirelessRouteActive){
            [self.controlView.portraitControlView.airPlayBtn.MPButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            return;
        }
        self.isPushState = false;
        [self updatelinkBtn];
        [[DNLAController getInstance] disConnect];
        [self.player.currentPlayerManager play];
        return;
    }
    
    [[AXPracticalHUD sharedHUD] showTextInView:[((AppDelegate*) [UIApplication sharedApplication].delegate) window] text:@"搜索电视中，请稍等..." detail:nil configuration:nil];
       __weak __typeof(self) weakSelf = self;
       [[DNLAController getInstance] startSearchDevice:^{
           [weakSelf showSelectLinker];
       }];
}

-(void)showSelectLinker{
    [[AXPracticalHUD sharedHUD] hide:NO];
    NSArray *deviceArray = [DNLAController getInstance].lelinkServices;
    TYAlertView *alertView = nil;
    alertView.buttonFont = [UIFont systemFontOfSize:14];
    if ( deviceArray.count>0 || self.controlView.portraitControlView.airPlayBtn.wirelessRoutesAvailable) {
        alertView = [TYAlertView alertViewWithTitle:@"选择投屏设备" message:@""];
        @weakify(self)
        
        TYAlertAction *v  = [TYAlertAction actionWithTitle:@"退出"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                   }];
        [alertView addAction:v];
        for (int i = 0; i < deviceArray.count; i++) {
            NSString *name = @"";
             #if (QRUserLBLelinkKit==1)
             LBLelinkService *v = [deviceArray objectAtIndex:i];
             name = v.lelinkServiceName;
             #else
             CLUPnPDevice *device = [deviceArray objectAtIndex:i];
             name = device.friendlyName;
             #endif
            TYAlertAction *tn  = [TYAlertAction actionWithTitle:name
                                                          style:TYAlertActionStyleDefault
                                                        handler:^(TYAlertAction *action) {
                                                            @strongify(self)
                                                            [self linkWithDevice:action.tagValue];
                                                        }];
            [alertView addAction:tn];
            tn.tagValue = i;
         }
        BOOL ret = self.controlView.portraitControlView.airPlayBtn.wirelessRoutesAvailable;
        if(ret){
            //添加airplay
            TYAlertAction *action = [TYAlertAction actionWithTitle:@"AirPlay(推荐)"
                                                             style:TYAlertActionStyleDefault
                                                           handler:^(TYAlertAction *action) {
                                                               @strongify(self)
                                                               [self.controlView.portraitControlView.airPlayBtn.MPButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                                                           }];
            [alertView addAction:action];
        }
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
        if ([self supportedInterfaceOrientations]==UIInterfaceOrientationMaskLandscape) {
            alertView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
    }
    else{
        alertView = [TYAlertView alertViewWithTitle:@"投屏失败" message:@"1:手机和电视必须在同一个无线网络才能投屏播放\n\n2：当搜索不到电视时，请重启电视机和APP再搜索\n\n3：视频投屏到电视时，手机上还可以看其他电影或者玩游戏，支持手机后台投影播放\n"];
        [alertView addAction:[TYAlertAction actionWithTitle:@"确定"
                                                      style:TYAlertActionStyleDefault
                                                    handler:^(TYAlertAction *action) {
                                                    }]];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
        if([self supportedInterfaceOrientations]==UIInterfaceOrientationMaskLandscape){
            alertView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
    }
}

-(void)updateBtnsAple:(BOOL)isFullScreen{
    isFullScreen = false;
    if (!isFullScreen) {
        self.btnCut.alpha = self.btnPause.alpha=0;
    }
    else {
        CGSize size = self.player.controlView.frame.size;
        if (size.width<size.height) {
            self.btnCut.alpha = self.btnPause.alpha=1;
        }
        else{
            self.btnCut.alpha = self.btnPause.alpha=0;
        }
    }
}

-(void)clickBtnPause{
    if (self.player.currentPlayerManager.isPlaying) {
        [self.player.currentPlayerManager pause];
        [self updateCutImage:true];
    }
    else{
        [self.player.currentPlayerManager play];
        [self updateCutImage:false];
    }
}

 -(void)clickBtnCut{/*
    UIImage *imageData = [self.player.currentPlayerManager thumbnailImageAtCurrentTime];
     [self unInit];
    [self.controlView.landScapeControlView backBtnClickAction:nil];
    [self.delegate zfautoPlayerWillRemove:imageData];*/
}

-(void)updateCutImage:(BOOL)isPause{/*
    UIImage *image = [UIImage imageNamed:!isPause?@"zanting_pintu":@"kaishi_pintu"];
    [self.btnPause setImage:image forState:UIControlStateNormal];
    self.btnCut.hidden = !isPause;*/
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat y = fixOffsetH+topOffsetY;
    CGFloat h = CGRectGetMaxY(self.view.frame);
    self.tableView.frame = CGRectMake(0, y, self.view.frame.size.width, h-y);
    if (!self.progressWaitView) {
        self.progressWaitView = [[UIView alloc] initWithFrame:self.tableView.frame];
        MBProgressHUD*progress = [[MBProgressHUD alloc] initWithView:self.progressWaitView];
        [progress showAnimated:YES];
        self.progressWaitView.hidden = YES;
        progress.tag = 1;
        [self.progressWaitView addSubview:progress];
        [self.view insertSubview:_progressWaitView belowSubview:self.topView];

    }
    self.progressWaitView.frame= self.tableView.frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    printf("viewDidAppear0\n");
    isAddLastAsset = false;
    @weakify(self)
    [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        printf("viewDidAppear1\n");
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }];
    isAddLastAsset = true;
}

- (void)realoadArray:(NSArray*)array{
    self.urls = @[].mutableCopy;
    self.dataSource = @[].mutableCopy;
    self.dataOriginalSource = @[].mutableCopy;
    for (int i = 0; i<array.count; i++) {
        id dataDic = [array objectAtIndex:i];
        if ([dataDic isKindOfClass:[NSDictionary class]]) {
            [self.dataOriginalSource addObject:dataDic];
            ZFTableData *data = [[ZFTableData alloc] init];
            [data setValuesForKeysWithDictionary:dataDic];
            ZFTableViewCellLayout *layout = [[ZFTableViewCellLayout alloc] initWithData:data];
            [self.dataSource addObject:layout];
            NSString *URLString = [data.video_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURL *url = [NSURL URLWithString:URLString];
            [self.urls addObject:url];
        }
        else{
            NSString *defaultV = @"http://www.baidu.com";
            [self.urls addObject:[NSURL URLWithString:defaultV]];
            [self.dataOriginalSource addObject:[NSURL URLWithString:defaultV]];
            [self.dataSource addObject:dataDic];
        }
    }
    self.player.assetURLs = self.urls;
    [self.tableView reloadData];
}

-(NSMutableArray*)adjustLastAsset:(NSMutableArray*)array{
    NSString *lastUUID = [[ZFAutoListParseManager getInstance] getLastAsset];
    for(int i = 0;i <array.count && lastUUID && array.count>1;i++ ){
        NSDictionary *dataDic =  [array objectAtIndex:i];
        if (lastUUID && [lastUUID compare:[dataDic objectForKey:@"uuid"]]==NSOrderedSame && i>0) {
            [array exchangeObjectAtIndex:0 withObjectAtIndex:i];
            break;
        }
    }
    return array;
}

- (void)reloadAssetAndAd{
    NSMutableArray *arraySj_ = nil;
    NSArray *tmep = [[ZFAutoListParseManager getInstance] getDefaultData];
    if (tmep) {
        arraySj_ = [NSMutableArray arrayWithArray:tmep];
    }
    if([ZFAutoListParseManager getInstance].listArray.count>0){
        arraySj_ = [NSMutableArray arrayWithArray:[ZFAutoListParseManager getInstance].listArray];
    }
    if (!arraySj_ || arraySj_.count==0) {//读取本地数据
        arraySj_ = [NSMutableArray arrayWithArray:[[ZFAutoListParseManager getInstance] getDefaultArray]];
    }
    if (!isTj) {
        arraySj_ = [NSMutableArray arrayWithArray:[[ZFAutoListParseManager getInstance] getFavite]];
    }
    arraySj_ = [self adjustLastAsset:arraySj_];
    //
    //array 和 self.expressAdViews 合拼成一个
    NSInteger space = 3;
    NSInteger oldPos = 0;
    if(arraySj_.count>3)
    {
        oldPos=2;
    }
    else if (arraySj_.count>0) {
        oldPos = 1;
    }
    bool isFindAdVideo = false;
    for(int i = 0;i<self.budNativeAdViews.count;i++){
        isFindAdVideo = true;
        if ([self.expressAdViews containsObject:[self.budNativeAdViews objectAtIndex:i]] == NO){
            if (self.expressAdViews.count>0) {
                [self.expressAdViews insertObject:[self.budNativeAdViews objectAtIndex:i] atIndex:0];
            }
            else{
                [self.expressAdViews addObject:[self.budNativeAdViews objectAtIndex:i]];
            }
        }
    }
    for (int i = 0; i<self.expressAdViews.count; i++)
    {
        UIView *view = [self.expressAdViews objectAtIndex:i];
        if (isFindAdVideo && i ==0) {
            oldPos=1;
        }
        else{
            //   oldPos = saveOldPos;
        }
        if (i == 0) {
            if (arraySj_.count==0) {
                          oldPos = 0;
            }
            [arraySj_ insertObject:view atIndex:oldPos];
        }
        else {
            do{
                if (oldPos+space<arraySj_.count) {
                    oldPos=oldPos+space;
                    break;
                }
                else{
                    oldPos = arraySj_.count;
                    break;
                }
            }while (true);
            [arraySj_ insertObject:view atIndex:oldPos];
        }
    }
    [self realoadArray:arraySj_];
}

- (void)requestData {
    if (isTj) {
        NSArray *arrayTmp =  [[ZFAutoListParseManager getInstance] getDefaultData];
        if([ZFAutoListParseManager getInstance].listArray.count>0){
            arrayTmp = [NSArray arrayWithArray:[ZFAutoListParseManager getInstance].listArray];
        }
        if (!arrayTmp || arrayTmp.count==0) {
            arrayTmp = [[ZFAutoListParseManager getInstance] getDefaultArray];
            [ZFAutoListParseManager getInstance].isCanUpdate = true;
        }
        [self realoadArray:[self adjustLastAsset:[NSMutableArray arrayWithArray:arrayTmp]]];
    }
    else{
        [self realoadArray:[[ZFAutoListParseManager getInstance]getFavite]];
    }
}

- (BOOL)shouldAutorotate {
    /// 如果只是支持iOS9+ 那直接return NO即可，这里为了适配iOS8
    return self.player.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.player.isFullScreen && self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}


-(void)updateTopState:(BOOL)isHidden{
    if (self->isHidden != isHidden) {
        self->isHidden = isHidden;
    [self.topView.layer removeAllAnimations];
    BeatifyAnimationDelegate *animation = [BeatifyAnimationDelegate animationWithKeyPath:@"position"];
    animation.duration = 1;
    animation.ledDelegate = self;
    CGPoint startPos =  self.topView.center;
    CGPoint endPos =  self.topView.center;
        NSString *key = @"hiddenKey";
    if (isHidden) {
        endPos = CGPointMake(startPos.x, -self.topView.frame.size.height/2);
    }
    else{
        key = @"showKey";
        endPos = CGPointMake(startPos.x, fixOffsetH+topOffsetY+self.topView.frame.size.height/2);
    }
    [animation setAutoreverses:NO];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.fromValue = [NSValue valueWithCGPoint:startPos]; // 起始帧
    animation.toValue = [NSValue valueWithCGPoint:endPos]; // 起始帧
    [self.topView.layer addAnimation:animation forKey:key];
    }
}

- (void)animationDidStop:(CAAnimation *)anim{
    if([self.topView.layer animationForKey:@"showKey"] == anim){
        self.topView.center = CGPointMake(self.topView.center.x,  fixOffsetH+topOffsetY+self.topView.frame.size.height/2);
    }
    else if([self.topView.layer animationForKey:@"hiddenKey"]==anim){
        self.topView.center = CGPointMake(self.topView.center.x,  -self.topView.frame.size.height/2);
    }
}

#pragma mark - UIScrollViewDelegate 列表播放必须实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isTouch = false;
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
    if (isTouch) {
        float vv = scrollView.contentOffset.y;//(vv>10上面搜索消失，<10,上面搜索出现)
        float offsetY = offsetBeginY - vv;
        _TableScrollViewDirection tmpDirection = Table_Scroll_Normal;
        
        if (offsetY>TableScrollDis||vv<10) {
            tmpDirection = Table_Scroll_Up;
            offsetBeginY = vv;
            [self updateTopState:false];
        }
        else if(offsetY<-TableScrollDis){
            tmpDirection = Table_Scroll_Down;
            offsetBeginY = vv;
            [self updateTopState:true];
        }
        if (tmpDirection !=Table_Scroll_Normal && scrollDirection != tmpDirection && scrollState == Table_Scroll_Finger_Begin) {
            scrollDirection = tmpDirection;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isTouch = true;
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id v = self.dataSource[indexPath.row];
    if ([v isKindOfClass:[ZFTableViewCellLayout class]]) {
        ZFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
        [cell setDelegate:self withIndexPath:indexPath];
        cell.layout = v;
        cell.isScState = isTj;
        [cell setNormalMode];
        return cell;
    }
    else{
        if ([v isKindOfClass:[GDTNativeExpressAdView class]]) {
            ZFAdCell *cell = [tableView dequeueReusableCellWithIdentifier:kAdIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView.backgroundColor = [UIColor clearColor];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell.contentView addSubview:v];
            return cell;
        }
        else if ([v isKindOfClass:[BUNativeExpressAdView class]]){
            BUNativeExpressAdView *nativeAd = (BUNativeExpressAdView *)v;
            UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:kBuAdIdentifier];
            cell.frame = CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height);
            UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
            if ([subView superview]) {
                    [subView removeFromSuperview];
            }
            UIView *view = nativeAd;
            view.tag = 1000;
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell.contentView addSubview:view];
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /// 如果正在播放的index和当前点击的index不同，则停止当前播放的index
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[ZFTableViewCellLayout class]]) {
        if (self.player.playingIndexPath != indexPath) {
            [self.player stopCurrentPlayingCell];
        }
        /// 如果没有播放，则点击进详情页会自动播放
        if (true || !self.player.currentPlayerManager.isPlaying) {
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id layout = self.dataSource[indexPath.row];
    if ([layout isKindOfClass:[ZFTableViewCellLayout class]]) {
        ZFTableViewCellLayout *_layout = layout;
        float defualtH = self.viewSize.height*0.5;
        return defualtH>_layout.height?defualtH:_layout.height;
    }
    else{
        if ([layout isKindOfClass:[GDTNativeExpressAdView class]]) {
            float v = ((UIView*)layout).bounds.size.height;
            return v;
        }
        else if([layout isKindOfClass:[BUNativeExpressAdView class]]){
            float v = ((UIView*)layout).bounds.size.height;
            return v;
        }
    }
    return 0;
}

#pragma mark - ZFTableViewCellDelegate

- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}
#pragma mark - private method

/// play the video
- (BOOL)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRload:) object:nil];
    if([[self.dataSource objectAtIndex:indexPath.row]isKindOfClass:[GDTNativeExpressAdView class] ] || [[self.dataSource objectAtIndex:indexPath.row]isKindOfClass:[BUNativeExpressAdView class] ])return false;
    self.player.scParam = [self.dataOriginalSource objectAtIndex:indexPath.row];
    if (isAddLastAsset || ![[ZFAutoListParseManager getInstance] getLastAsset]) {
        [[ZFAutoListParseManager getInstance] saveLastAsset:[self.player.scParam objectForKey:@"uuid"]];
    }
    [self.player playTheIndexPath:indexPath scrollToTop:scrollToTop];
    ZFTableViewCellLayout *layout = self.dataSource[indexPath.row];
    [self.controlView showTitle:layout.data.title
                 coverURLString:layout.data.thumbnail_url
        fullScreenMode:layout.isVerticalVideo?ZFFullScreenModePortrait:ZFFullScreenModeLandscape];
    [self updateCutImage:false];
    @weakify(self)
    [RACObserve(self.player.currentPlayerManager,playState) subscribeNext:^(id x) {
        @strongify(self)
        if(self.player.notification.backgroundState == ZFPlayerBackgroundStateForeground){
//            if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused && [[VideoAdManager getInstance]isCanPlayVideoAd:false]) {
//                if ([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:PlayVideoPauseWatchVideoKey nCount:1 isUseYYCache:NO time:nil]) {
//                    [[UIApplication sharedApplication].keyWindow makeToast:@"一天只有一次视频广告，看完就没有了，暂停播放" duration:4 position:@"center"];
//                    [self exitFullAndPlayAd:false];
//                }
//                else{
//                    [GetAppDelegate startInterstitial];
//                }
//            }
        }
    }];
    return true;
}

-(void)exitFullAndPlayAd:(BOOL)isForeground{
//    GetAppDelegate.isOldFullScreen = GetAppDelegate.isFullScreen;
//    [self.player enterFullScreen:NO animated:NO];
//    [[VideoAdManager getInstance] tryPlayVideoAd:isForeground block:^(BOOL isSuccess) {
//        if (GetAppDelegate.isOldFullScreen) {
//            [self.player enterFullScreen:YES animated:NO];
//        }
//        [[helpFuntion gethelpFuntion] isValideOneDay:PlayVideoPauseWatchVideoKey nCount:1 isUseYYCache:NO time:nil];
//        [[VideoAdManager getInstance] tryPlayVideoFinish];
//    }];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ZFTableViewCell class] forCellReuseIdentifier:kIdentifier];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBuAdIdentifier];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kAdIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.backgroundColor = RGBCOLOR(0, 0, 0);
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        /// 停止的时候找出最合适的播放
        @weakify(self)
        _tableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        };
    }
    return _tableView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [BeatifyAssetControlView new];
    }
    return _controlView;
}

#pragma mark --信息流视频广告部分

- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    [self.budNativeAdViews removeAllObjects];
    if (views.count) {
        [self.budNativeAdViews addObjectsFromArray:views];
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
            expressView.rootViewController = GetAppDelegate.window.rootViewController;
            [expressView render];
        }];
    }
    [self reloadAssetAndAd];
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    [self.tableView reloadData];
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *_Nullable)error{
    NSLog(@"%s",__func__);
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    NSLog(@"click dislike");
   
//    NSMutableArray *dataSources = [self.dataSource mutableCopy];
//    [dataSources removeObject:nativeAd];
//    self.dataSource = [dataSources copy];
//    [self.tableView reloadData];
}
@end

