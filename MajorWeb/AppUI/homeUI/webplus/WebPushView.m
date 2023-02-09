//
//  WebPushView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "WebPushView.h"
#import "WebPushManager.h"
#import "WebPushCell.h"
#import "UIScrollView+ZFPlayer.h"
#import "ZFPlayer.h"
#import "ZFPlayerControlView.h"
#import "ZFAVPlayerManager.h"
#import "WebPushVideoControlView.h"
#import "WebPushPlayerController.h"
#import "NSObject+UISegment.h"
#import <AVFoundation/AVFoundation.h>
#import "WebTopChannel.h"
#import "MainMorePanel.h"
#import "VideoPlayerManager.h"
#import <BUAdSDK/BUAdSDK.h>
#import "MajorSystemConfig.h"
#import "YSCHUDManager.h"
#import "BUDDrawTableViewCell.h"
#import "WebPushView+VipPlus.h"
#import "VipPayPlus.h"
#import "AppDelegate.h"
#import "CLUPnPDevice.h"
#import "BUDAdManager.h"
#import "SparkMPVolumnView.h"
#import "DNLAController.h"
#import "AXPracticalHUD.h"
#import "TYAlertAction+TagValue.h"
#define SetBntsImage     [self.douYinBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/dou_no_select"] forState:UIControlStateNormal]; \
[self.defaultBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/mo_no_select"] forState:UIControlStateNormal]; \
[self.smallBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/xiao_no_select"] forState:UIControlStateNormal];
static BOOL WebPushViewIsShow = false;
@interface WebPushView()<UITableViewDelegate,UITableViewDataSource,BUNativeAdsManagerDelegate>
@property(strong)NSMutableArray *dataArray;
@property(assign,nonatomic)BOOL isFirstPlay;
@property(assign,nonatomic)NSInteger willDisayTimes;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) UIButton *douYinBtn;
@property (nonatomic, strong) UIButton *defaultBtn;
@property (nonatomic, strong) UIButton *smallBtn;
@property (nonatomic, strong) UIButton *fullBtn;
@property (nonatomic, strong) UIButton *lelinkBtn;
@property (nonatomic, strong) SparkMPVolumnView *airPlayBtn;
@property (nonatomic, strong) UIButton *buyVip;
@property (nonatomic, strong) UIButton *newbackBtn;
@property (nonatomic, strong) WebTopChannel *webChannelView;
@property (nonatomic, copy)NSString *mediaTitle;
@property (nonatomic, strong) BUNativeAdsManager *adManager;
@property (nonatomic, strong)UIView *waitView;
@property (nonatomic, assign) BOOL isPushState ;
@end

@implementation WebPushView

+(BOOL)isShow{
    return WebPushViewIsShow;
}
-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    WebPushViewIsShow = false;
    [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
    _adManager.delegate = nil;
    [self removeWaitView];
    [[WebPushManager getInstance] stop];
    [super removeFromSuperview];
}

-(void)removeWaitView{
    self.webChannelView.userInteractionEnabled = YES;
    [YSCHUDManager hideHUDOnView:self.waitView animated:NO];
    [self.waitView removeFromSuperview];
    self.waitView = nil;
}

-(id)initWithFrame:(CGRect)frame{
    self  = [super initWithFrame:frame];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wirelessRouteActiveChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    self.backgroundColor = [UIColor blackColor];
    [[VideoPlayerManager getVideoPlayInstance] stop];
    self.isUsePopGesture = true;
    self.isFirstPlay = true;
    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH,MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT -(GetAppDelegate.appStatusBarH)) style:UITableViewStylePlain];
    _myTableView.pagingEnabled = YES;
    _myTableView.dataSource = self;
    _myTableView.backgroundColor = [UIColor blackColor];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.rowHeight = self.myTableView.frame.size.height;
    _myTableView.delaysContentTouches = NO;
    _myTableView.delegate = self;
    _myTableView.estimatedRowHeight = 0;
    _myTableView.estimatedSectionFooterHeight = 0;
    _myTableView.estimatedSectionHeaderHeight = 0;
    if (@available(iOS 11.0, *)) {
        _myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
    }
    [self addSubview:_myTableView];
    [_myTableView registerClass:[WebPushCell class] forCellReuseIdentifier:@"postCellId"];
    [self.myTableView registerClass:[BUDDrawAdTableViewCell class] forCellReuseIdentifier:@"BUDDrawAdTableViewCell"];
    @weakify(self)
    _myTableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initUIComp];
        if (self.waitView) {
            [self bringSubviewToFront:self.waitView];
        }
    });
    [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
    return self;
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
        self.player.pauseWhenAppResignActive = NO;
        self.isPushState = true;
    }
    else{
        self.isPushState = false;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatelinkBtn];
    });
}


-(void)linkWithDevice:(NSInteger)pos{
    NSString *url = [self.player.currentPlayerManager.assetURL absoluteString];
    NSDictionary *dicHeader =  nil;
    [self.player.currentPlayerManager pause];
    NSLog(@"linkWithDevice url= %@",url);
    [[DNLAController getInstance] playWithUrl:url time:self.player.currentPlayerManager.currentTime header:dicHeader isLocal:NO deviceIndex:pos];
    self.isPushState = true;
    [self updatelinkBtn];
    self.player.pauseWhenAppResignActive = false;
}

-(void)updatelinkBtn{
     if (self.isPushState) {
        [self.newbackBtn  setImage:[UIImage imageNamed:@"WebPlus.bundle/touying1"] forState:UIControlStateNormal];
    }
    else{
        [self.newbackBtn  setImage:[UIImage imageNamed:@"WebPlus.bundle/touying2"] forState:UIControlStateNormal];
    }
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
       if (deviceArray.count>0 || self.controlView.portraitControlView.airPlayBtn.wirelessRoutesAvailable) {
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
           if(self.controlView.portraitControlView.airPlayBtn.wirelessRoutesAvailable){
               //添加airplay
               TYAlertAction *action = [TYAlertAction actionWithTitle:@"AirPlay(推荐)"
                                                                style:TYAlertActionStyleDefault
                                                              handler:^(TYAlertAction *action) {
                                                                  @strongify(self)
                                                                  [self.controlView.portraitControlView.airPlayBtn.MPButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                                                              }];
               [alertView addAction:action];
           }
           v  = [TYAlertAction actionWithTitle:@"帮助"
                                         style:TYAlertActionStyleDestructive
                                       handler:^(TYAlertAction *action) {
                                           UIAlertView *l  = [[UIAlertView alloc] initWithTitle:@"说明" message:@"1:手机和电视必须在同一个无线网络才能投屏播放\n2：选择列表显示出来的都可以投影出来播放\n3：你可以投屏到电视，同时在手机上看其他电影，支持后台投影播放\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                           [l show];
                                       }];
           [alertView addAction:v];
           [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
       }
       else{
           UIAlertView *l  = [[UIAlertView alloc] initWithTitle:@"投屏失败" message:@"1:手机和电视必须在同一个无线网络才能投屏播放\n2：选择列表显示出来的都可以投影出来播放\n3：你可以投屏到电视，同时在手机上看其他电影，支持后台投影播放\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
           [l show];
       }
}

-(void)updateAirPlayerBtn:(BOOL)isAirPlayer allowsExternalPlayback:(BOOL)allowsExternalPlayback {
    if (isAirPlayer) {
        [self.lelinkBtn  setImage:[UIImage imageNamed:@"WebPlus.bundle/touying1"] forState:UIControlStateNormal];
    }
    else{
        [self.lelinkBtn  setImage:[UIImage imageNamed:@"WebPlus.bundle/touying2"] forState:UIControlStateNormal];
    }
    if (IF_IPAD) {
      //  v.alpha = 0;
    }
}


-(void)updateBtnState{
    SetBntsImage
   WebPushPlayMode mode = ((WebPushVideoControlView*)self.player.controlView).webPlayMode;
    if (mode==WebPush_DouYin_Mode) {
        [self.douYinBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/dou_select"] forState:UIControlStateNormal];
    }
    else if(mode==WebPush_Defualt_Mode){
        [self.defaultBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/mo_select"] forState:UIControlStateNormal];
    }
    else if(mode==WebPush_Small_Mode){
        [self.smallBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/xiao_select"] forState:UIControlStateNormal];
    }
}

-(void)addWebsBtns{

    if (!self.douYinBtn) {
        @weakify(self)
        NSArray *array = [MainMorePanel getInstance].morePanel.huyaurl;
        float startY = GetAppDelegate.appStatusBarH;
        if (array.count>0) {
            float hh = 30;
            if (IF_IPAD) {
                hh = 40;
            }
            UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnClose setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
            btnClose.frame = CGRectMake(0, startY, hh, hh);
            [self addSubview:btnClose];
            [btnClose bk_addEventHandler:^(id sender) {
                @strongify(self)
                [self removeFromSuperview];
            } forControlEvents:UIControlEventTouchUpInside];
            self.webChannelView = [[WebTopChannel alloc] initWithFrame:CGRectMake(hh, startY,MY_SCREEN_WIDTH, hh)];
            [self addSubview:self.webChannelView];
            UIView *backTmp = [[UIView alloc] initWithFrame:CGRectMake(0, startY, MY_SCREEN_WIDTH, hh)];
            backTmp.backgroundColor = [UIColor blackColor];
            [self insertSubview:backTmp belowSubview:btnClose];
            startY = self.webChannelView.frame.origin.y+self.webChannelView.frame.size.height+5;
            [self.webChannelView updateTopArray:array];
            self.webChannelView.clickBlock = ^(huyaNodeInfo *item) {
                [[WebPushManager getInstance] startWithUrlUsrOldBlock:item.url];
             };
            [self.webChannelView hiddenMore];
            [self.webChannelView updateSelect:0];
        }
        
        self.douYinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fullBtn setImage:[UIImage imageNamed:@"WebPlus.bundle/quanpin_btn"] forState:UIControlStateNormal];
        SetBntsImage
        float w = 176,h=55,tishiw =640,tishih=207;
        if (IF_IPHONE) {
            w = w/2.3;
            h = h/2.3;
            tishiw/=2;
            tishih/=2;
        }
        else{
            w = w/1.5;
            h = h/1.5;
        }
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-h , MY_SCREEN_WIDTH, h)];
        [self addSubview:view];
        [view addSubview:self.defaultBtn];
        [view addSubview:self.douYinBtn];
        [view addSubview:self.smallBtn];
        [view addSubview:self.fullBtn];
        
        _newbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [view addSubview:_newbackBtn];
        _newbackBtn.frame = CGRectMake(5, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-h, w , h);
        self.airPlayBtn = [ [SparkMPVolumnView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.airPlayBtn  setRouteButtonImage:[UIImage imageNamed:@"WebPlus.bundle/touying2"] forState:UIControlStateNormal];
        self.airPlayBtn.alpha = 0 ;
        [self.airPlayBtn setFrame:_newbackBtn.bounds];
        [self.airPlayBtn setShowsVolumeSlider:NO];
        [self.airPlayBtn setShowsRouteButton:YES];
        [_newbackBtn addSubview:self.airPlayBtn];
        
        [_newbackBtn  bk_addEventHandler:^(id sender) {
            @strongify(self)
            [self videoLink];
        } forControlEvents:UIControlEventTouchUpInside];
        [RACObserve([VipPayPlus getInstance],systemConfig.vip) subscribeNext:^(id x) {
            @strongify(self)
            [self updateBuyBtn:[VipPayPlus getInstance].systemConfig.vip==General_User];
        }];
        
        [RACObserve([VipPayPlus getInstance],isVideoVerify) subscribeNext:^(id x) {
            @strongify(self)
            [self updateBuyBtn:!false];
        }];
        
        [NSObject initiiWithFrame:view contenSize:CGSizeMake(MY_SCREEN_WIDTH, h) vi:self.douYinBtn viSize:CGSizeMake(w, h) vi2:nil index:0 count:5];
        [NSObject initiiWithFrame:view contenSize:CGSizeMake(MY_SCREEN_WIDTH, h) vi:self.defaultBtn viSize:CGSizeMake(w, h) vi2:self.douYinBtn index:1 count:5];
        [NSObject initiiWithFrame:view contenSize:CGSizeMake(MY_SCREEN_WIDTH, h) vi:self.smallBtn viSize:CGSizeMake(w, h) vi2:self.defaultBtn index:2 count:5];
        [NSObject initiiWithFrame:view contenSize:CGSizeMake(MY_SCREEN_WIDTH, h) vi:self.fullBtn viSize:CGSizeMake(w, h) vi2:self.smallBtn index:3 count:5];
        [NSObject initiiWithFrame:view contenSize:CGSizeMake(MY_SCREEN_WIDTH, h) vi:_newbackBtn viSize:CGSizeMake(w, h) vi2:self.fullBtn index:4 count:5];

        [self.douYinBtn bk_addEventHandler:^(id sender) {
            @strongify(self)
            if ([self isVaild]) {
                [((WebPushVideoControlView*)self.player.controlView) updatePlayMode:WebPush_DouYin_Mode];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self.defaultBtn bk_addEventHandler:^(id sender) {
            @strongify(self)
            [((WebPushVideoControlView*)self.player.controlView) updatePlayMode:WebPush_Defualt_Mode];
        } forControlEvents:UIControlEventTouchUpInside];
        [self.smallBtn bk_addEventHandler:^(id sender) {
            @strongify(self)
            [((WebPushVideoControlView*)self.player.controlView) updatePlayMode:WebPush_Small_Mode];
        } forControlEvents:UIControlEventTouchUpInside];
        
        [_fullBtn bk_addEventHandler:^(id sender) {
            @strongify(self)
            if ([self isVaild]) {
                [((WebPushVideoControlView*)self.player.controlView) intoFull:true title:self.mediaTitle];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        static BOOL isFristSHow = true;
        if (isFristSHow) {
            UIImageView *tishiView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WebPlus.bundle/help"]];
            [tishiView setFrame:CGRectMake((MY_SCREEN_WIDTH-tishiw)/2, view.frame.origin.y-tishih, tishiw, tishih)];
            [self addSubview:tishiView];
            tishiView.alpha=0.9;
            [UIView animateWithDuration:60 animations:^{
                tishiView.alpha=1;
            }completion:^(BOOL finished) {
                [tishiView removeFromSuperview];
            }];
        }
        isFristSHow = false;
    }
}

-(void)updateBuyBtn:(BOOL)isAdd{
    RemoveViewAndSetNil(self.buyVip);
    self.lelinkBtn.hidden = NO;
    BOOL ret = (([VipPayPlus getInstance].systemConfig.vip!=General_User) || [[VipPayPlus getInstance] isVaildOperationCheck:NSStringFromClass([self class])]);
    if (isAdd && !ret) {
        self.buyVip = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buyVip.frame = _newbackBtn.bounds;
        [self.buyVip  setImage:[UIImage imageNamed:@"WebPlus.bundle/touying2"]  forState:UIControlStateNormal];
        [self.newbackBtn addSubview:self.buyVip];
        @weakify(self)
        [self.buyVip bk_addEventHandler:^(id sender) {
            @strongify(self)
            [self isVaild];
        } forControlEvents:(UIControlEventTouchUpInside)];
        self.lelinkBtn.hidden = YES;
    }
    else{
        [self updatelinkBtn];
    }
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [WebPushVideoControlView new];
    }
    return _controlView;
}


-(void)playTheVideoAtIndexPath:(NSIndexPath*)indexPath scrollToTop:(BOOL)scrollToTop{
   WebPushItem *item =  [self.dataArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[BUNativeAd class]]) {
        [self.player.currentPlayerManager pause];
    }
    else if ([item isKindOfClass:[WebPushItem class]]){
        if ([item.playUrl length]>2) {
            self.mediaTitle = item.title;
            [self.player playTheIndexPath:indexPath assetURL:[NSURL URLWithString:item.playUrl] scrollToTop:scrollToTop];
            [self.controlView showTitle:item.title
                     coverURLString:@""
                     fullScreenMode:ZFFullScreenModePortrait];
        }
    }
}

-(void)initUIComp{
    /// playerManager
    @weakify(self)
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    self.player = [WebPushPlayerController playerWithScrollView:self.myTableView playerManager:playerManager containerViewTag:100];
    self.player.controlView = self.controlView;
    ((WebPushVideoControlView*)self.player.controlView).webPlayMode = WebPush_Defualt_Mode;
    self.player.playerDisapperaPercent = 0.8;
    self.player.WWANAutoPlay = YES;
    self.player.shouldAutoPlay = YES;
    self.player.allowOrentitaionRotation = NO;
    
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPan;
    
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        self.myTableView.scrollsToTop = !isFullScreen;
    };
    [self.myTableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }];
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        
    };
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"playerPrepareToPlay webPushView");
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        [self.player seekToTime:1 completionHandler:^(BOOL finished) {
        }];
    };
    
    self.player.playerLoadStatChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        @strongify(self)
        if (loadState==ZFPlayerLoadStatePrepare)
        {
            
        }
        else if(loadState==ZFPlayerLoadStatePlaythroughOK){
            [((WebPushVideoControlView*)self.player.controlView) updateWebMode];
        }
    };
    
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        if (self.player.playingIndexPath.row < self.dataArray.count - 1 && !self.player.isFullScreen) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.player.playingIndexPath.row+1 inSection:0];
            [self playTheVideoAtIndexPath:indexPath scrollToTop:YES];
        } else if (self.player.isFullScreen) {
            [self.player enterFullScreen:NO animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.player.orientationObserver.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player stopCurrentPlayingCell];
            });
        }
    };
    [self addWebsBtns];
    [RACObserve(((WebPushVideoControlView*)self.player.controlView),webPlayMode) subscribeNext:^(id x) {
        @strongify(self)
        [self updateBtnState];
    }];
    WebPushViewIsShow = true;
}

-(void)loadHome{
    if (!self.waitView) {
        self.webChannelView.userInteractionEnabled = NO;
        self.waitView = [[UIView alloc] init];
        [self addSubview:self.waitView];
        self.waitView.frame = CGRectMake(0,GetAppDelegate.appStatusBarH + 20, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
        self.waitView.userInteractionEnabled = false;
        [YSCHUDManager showHUDOnView:self.waitView message:@"loading..."];
    }
}

-(void)reInitPlayerUrls{
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:10];
    for (int i =0; i< self.dataArray.count; i++) {
        WebPushItem *item =  [self.dataArray objectAtIndex:i];
        if ([item isKindOfClass:[BUNativeAd class]]) {
            [urls addObject:[NSURL URLWithString:@"http://www.baidu.com"]];
        }
        else if ([item isKindOfClass:[WebPushItem class]]){
            if ([item.playUrl length]>2) {
                self.mediaTitle = item.title;
                [urls addObject:[NSURL URLWithString:item.playUrl]];
            }
            else{
                [urls addObject:[NSURL URLWithString:@"http://www.baidu.com"]];
            }
        }
    }
    self.player.assetURLs = urls;
}

-(void)addDataArray:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll
{
    if (((NSArray*)item).count==0) {
        return;
    }
    [self removeWaitView];
    if (isRemoveOldAll) {
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:item];
    [self reInitPlayerUrls];
    [self.myTableView reloadData];
    if (isRemoveOldAll) {
        [self playTheVideoAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] scrollToTop:NO];
    }
}

-(void)addDataItem:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll{
    if (isRemoveOldAll) {
        [self.dataArray removeAllObjects];
    }
    [self removeWaitView];
    [self.dataArray addObject:item];
    [self reInitPlayerUrls];
    [self.myTableView reloadData];
    if (isRemoveOldAll) {
        [self playTheVideoAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] scrollToTop:NO];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//         WebPushItem *item =  [self.dataArray objectAtIndex:indexPath.row];
//        if ([item isKindOfClass:[BUNativeAd class]]) {
//            float v = ((UIView*)item).bounds.size.height;
//            return v;
//        }
//    return 230;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    _willDisayTimes++;
    if (_willDisayTimes%4==0) {
        [[BUDAdManager getInstance] start];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"postCellId";
    
    NSUInteger index = indexPath.row;
    id model = self.dataArray[index];
    if ([model isKindOfClass:[BUNativeAd class]]) {
        BUNativeAd *nativeAd = (BUNativeAd *)model;
        nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        BUDDrawAdTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"BUDDrawAdTableViewCell" forIndexPath:indexPath];
        cell.nativeAdRelatedView.videoAdView.delegate = self;
        [cell refreshUIWithModel:nativeAd];
        [model registerContainer:cell withClickableViews:@[cell.creativeButton]];
        return cell;
    }
    else{
        WebPushCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                            forIndexPath:indexPath];
        [cell initWithItem:[self.dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.player.playingIndexPath != indexPath) {
//        [self.player stopCurrentPlayingCell];
//    }
//    /// 如果没有播放，则点击进详情页会自动播放
//    if (!self.player.currentPlayerManager.isPlaying) {
//        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}


- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    CGRect rect = self.webChannelView.frame ;
    if(!CGRectContainsPoint(rect, point)){
        [super doMoveAction:recognizer];
    }
}


#pragma mark --
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray{
    NSMutableArray *dataSources = [self.dataArray mutableCopy];
    if (dataSources.count<=2) {
        return;
    }
    NSMutableArray *attay = [NSMutableArray arrayWithArray:nativeAdDataArray];
    int space = 4;
    NSInteger oldPos = 0;
    for(int i = 0;i<attay.count;i++){
        id model = [attay objectAtIndex:i];
        if (i == 0) {
            oldPos = 1;
            if (dataSources.count>5) {
                oldPos = 4;
            }
            [dataSources insertObject:model atIndex:oldPos];
        }
        else {
            do{
                if (oldPos+space<dataSources.count) {
                    oldPos=oldPos+space;
                    break;
                }
                else{
                    oldPos = dataSources.count;
                    break;
                }
            }while (true);
            [dataSources insertObject:model atIndex:oldPos];
        }
    }
    self.dataArray = [NSMutableArray arrayWithArray:dataSources];
    [self.myTableView reloadData];
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error{
    
}

#pragma mark --- BUVideoAdViewDelegate
- (void)videoAdView:(BUVideoAdView *)videoAdView stateDidChanged:(BUPlayerPlayState)playerState {
    NSLog(@"videoAdView state change to %ld", (long)playerState);
}

- (void)videoAdView:(BUVideoAdView *)videoAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"videoAdView didLoadFailWithError");
}

- (void)playerDidPlayFinish:(BUVideoAdView *)videoAdView {
    NSLog(@"videoAdView didPlayFinish");
}

- (void)loadNativeAds {
    if(GetAppDelegate.isWatchHomeVideo ||([VipPayPlus getInstance].systemConfig.vip!=General_User))return;
    if ([MajorSystemConfig getInstance].isGotoUserModel != 2) {//插屏
        
    }
}

- (BOOL)isValidGesture:(CGPoint)point{
    if (point.x<self.bounds.size.width/2) {
        return true;
    }
    return false;
}
@end
