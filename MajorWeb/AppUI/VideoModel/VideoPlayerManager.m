//
//  VideoPlayerManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/26.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "VideoPlayerManager.h"
#import "MajorVideoControlView.h"
#import "ZFAVPlayerManager.h"
#import "ZFIJKPlayerManager.h"
#import "AppDelegate.h"
#import "AXPracticalHUD.h"
#import "ZFPlayerMediaControl.h"
#import "MajorPlayerController.h"
#import "MarjorFloatView.h"
#import "AFURLRequestSerialization.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "ZFUtilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MarjorWebConfig.h"
#import "ZFPlayerLogManager.h"
#import "CLUPnPDevice.h"
//#import "KSMediaPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ApiCoreManager.h"
#import "WebDesListView.h"
#import "ZFPlayerMediaPlayback.h"
#import "VideoPlayerManager+Down.h"
#import "VideoPlayerManager+Banner.h"
#import "VideoPlayerManager+NativeAd.h"
#import "YTKNetworkPrivate.h"
#import "VideoPlayerManager+VideoNativeAd.h"
#import "YSCHUDManager.h"
#import "BUDMacros.h"
#import "DNLAController.h"
#import "TYAlertAction+TagValue.h"
#import "Toast+UIView.h"
#import "VipPayPlus.h"
#import "RecordUrlToUUID.h"
#import "BUPlayer.h"
#import "BuDNativeAdManager.h"
#define VideoSaveValidTime 10
#define VideoClearVaildTime [autoAddValidTime invalidate];autoAddValidTime=nil;currentPlayTime=0;
#define CreateVideoVaildTime if (!self->autoAddValidTime && self->_saveVideoInfo) { \
    self->currentPlayTime = 0; \
    self->autoAddValidTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkVideVaildTime:) userInfo:nil repeats:YES]; \
}

static NSString *gbVideoUrl = nil;
static NSDictionary *gbSaveVideoInfo = nil;
static NSString *gburlReferer = nil;
static NSString *gbmediaTitle = nil;
static NSInteger gbSeekTime = 1;
#define VideoCachesDownNotfiSuffix @"_VideoPlayerNotifi"
@interface VideoPlayerManager()
{
    NSInteger currentPlayTime;
    NSTimer   *autoAddValidTime;
}
@property (nonatomic,assign)BOOL isAppFround;
@property (nonatomic,strong)NSTimer *delayFireTime;
@property (nonatomic,assign)BOOL isOldFull;
@property (nonatomic,assign)BOOL isOldFullScreen;
@property (nonatomic,assign)BOOL isFullScreen;
@property (nonatomic, copy)NSArray *videosArrayUrl;
@property (nonatomic, assign)BOOL isPortraitFull;
@property (nonatomic, copy) void(^webPushBlock)(void);
@property (nonatomic, assign)CGRect webVideoRect;
@property (nonatomic, strong)NSDictionary *saveVideoInfo;
@property (nonatomic, strong)NSMutableDictionary * lockDict;
@property (nonatomic, copy)NSString *mediaTitle;
@property (nonatomic, strong)UIButton *btnBackPlay;
@property (nonatomic, assign)CGRect smallFloatRect;
@property (nonatomic, strong) MajorPlayerController *player;
@property (nonatomic, strong) MajorVideoControlView* controlView;
@property (nonatomic, strong) UIView* playView;
@property (nonatomic,copy) NSString* urlReferer;
@property (nonatomic,copy) NSString* throwUrl;

@property (nonatomic,assign) BOOL forceReplayMode;//强制循环

@property (nonatomic,assign)BOOL isPushState;
@property (nonatomic,assign)BOOL isForceUseIjkPlayer;
//后台模式的参数
@property (nonatomic, assign)BOOL isForceBackPlayMode;
@property(nonatomic,assign)BOOL isBDownMode;
@property(nonatomic,copy)NSDictionary *bSaveVideoInfo;
@property(nonatomic,copy)NSString *bmediaTitle;
@property(nonatomic,copy)NSString *burlReferer;
@property(nonatomic,copy)NSString *bVideoUrl;
@property(nonatomic,assign)float bSeekTime;
//end
@end

@implementation VideoPlayerManager

+(VideoPlayerManager*)getVideoPlayInstance{
    static VideoPlayerManager*g = nil;
    if (!g) {
        g = [[VideoPlayerManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    GetAppDelegate.videoPlayMode = 0;
    [self configNeedNotifi];
    self.isAppFround = true;
    return self;
}

-(void)configNeedNotifi{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wirelessRoutesAvailableChange:) name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wirelessRouteActiveChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGlobalWebUrl:) name:@"PostGlobalWebUrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revicePipePlayUrl:) name:@"RevicePipePlayUrl" object:nil];
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

-(void)getGlobalWebUrl:(NSNotification*)object{
    [self exitPlay];
}

-(void)playPause{
    if (self.player) {
        if (self.player.currentPlayerManager.playState==ZFPlayerPlayStatePlaying) {
            [self.player.currentPlayerManager pause];
        }
        else if (self.player.currentPlayerManager.playState==ZFPlayerPlayStatePaused){
            [self.player.currentPlayerManager play];
        }
    }
}

-(void)showAdVideoAndExitFull{
    self.isOldFull = self.player.isFullScreen;
    if (self.player.isFullScreen) {
        [((ZFPlayerControlView*)self.player.controlView).landScapeControlView backBtnClickAction:nil];
        [self updatePlayAlpha:0];
        [self.player.currentPlayerManager pause];
    }
}

-(void)exitAdVideoAndEnterFull{
    if (self.isOldFull) {
        [((ZFPlayerControlView*)self.player.controlView).portraitControlView fullScreenButtonClickAction:nil];
    }
    [self updatePlayAlpha:1];
    [self.player.currentPlayerManager play];
    self.isOldFull = false;
}

-(void)tryToPause{
    if (!self.isOldFull) {
        [self.player.currentPlayerManager pause];
    }
}

-(void)tryToPlay{
    [self.player.currentPlayerManager play];
}

-(void)play{
    if (self.player) {
        [self.player.currentPlayerManager play];
    }
}


-(void)pause{
    if (self.player) {
        [self.player.currentPlayerManager pause];
    }
}

-(void)stop{
    [self exitPlay];
}

- (MajorVideoControlView *)controlView {
    if (!_controlView) {
        _controlView = [MajorVideoControlView new];
        UIImage *image = ZFPlayer_Image(@"loading_1");
        _controlView.placeholderImage = image;
        __weak VideoPlayerManager *_weak = self;
        _controlView.updateVidesArray = ^NSArray *{
            return _weak.videosArrayUrl;
        };
        _controlView.updateVideoUrl = ^(NSString *videoUrl) {
if(_weak.player.currentPlayerManager.loadState == ZFPlayerLoadStatePlayable &&   (_weak.player.currentPlayerManager.playState==ZFPlayerPlayStatePlaying||_weak.player.currentPlayerManager.playState==ZFPlayerPlayStatePaused)) {
                _weak.bSeekTime = _weak.player.currentTime;
            }
            _weak.player.assetURL = [NSURL URLWithString:videoUrl];
        };
    }
    return _controlView;
}

-(void)updateVideoPlayMode{
    if (GetAppDelegate.videoPlayMode==0) {
        self.player.pauseWhenAppResignActive = self.isForceBackPlayMode?NO:YES;
        [self.player addPlayerViewToKeyWindow];
        self.player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
        [self unitNaitveAdRACObserve];
        [self startVideoBanner];
    }
    else if(GetAppDelegate.videoPlayMode==1){
        [self stopVideoBanner];
        [[BuDNativeAdManager getInstance] stopNative];
        [self unitNaitveAdRACObserve];
        [self.player addPlayerViewToKeyWindow];
        self.player.pauseWhenAppResignActive = self.isForceBackPlayMode?NO:YES;
        self.player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
    }
    else if (GetAppDelegate.videoPlayMode==2){
        [self stopVideoBanner];
        [self initNativeAdRACObserve];
        self.player.disableGestureTypes = ZFPlayerDisableGestureTypesNone;
    }
}

-(void)updateOrientationWillChange:(BOOL)isFullScreen{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoWillChangeFull" object:@(isFullScreen)];
    if (!isFullScreen && self.webPushBlock) {
        self.player.currentPlayerManager.view.alpha = 0;
        //[[BuDNativeAdManager getInstance] startNative:self.player.smallFloatView pos:BuDNativeAdManagerAdPos_ParentView_Bottom];
    }
    if (isFullScreen) {
        [[BuDNativeAdManager getInstance] stopNative];
        [GetAppDelegate setStatusBarBackgroundColor:[UIColor clearColor]];
        GetAppDelegate.videoPlayMode = 2;
        if (self.isPortraitFull) {
            self.player.allowOrentitaionRotation = false;
        }
        else{
            self.player.allowOrentitaionRotation = true;
            [GetAppDelegate setSupportRotationDirection:(UIInterfaceOrientationMaskLandscapeRight)];
        }
    }
    else{
        self.player.allowOrentitaionRotation = false;
        [GetAppDelegate setSupportRotationDirection:(UIInterfaceOrientationMaskPortrait)];
        [self updateGlobalWebDesList:false];
    }
}


-(void)updateOrientationDidChanged:(BOOL)isFullScreen{
    self.isFullScreen = isFullScreen;
    self.isOldFull = isFullScreen;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoDidChangeFull" object:@(isFullScreen)];
    if (!isFullScreen) {
        if (GetAppDelegate.videoPlayMode!=0) {
            GetAppDelegate.videoPlayMode=0;
            [self startVideoNative];
        }
        [self.controlView resetControlView];
        [self.controlView hideControlViewWithAnimated:NO];
        [self.controlView updateViewAppeared:false];
    }
    if (!isFullScreen && self.webPushBlock) {
        self.player.currentPlayerManager.view.alpha = 1;
        [self exitPlay];
        self.webPushBlock();
        return ;
    }
    if (!isFullScreen && ((MarjorFloatView*)self.player.smallFloatView).isVerySamll) {
        self.player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
        if (GetAppDelegate.videoPlayMode!=1)
            GetAppDelegate.videoPlayMode = 1;
    }
    if (!isFullScreen && GetAppDelegate.videoPlayMode==1) {
        [self.controlView hideFixCtrl];
    }
    if(isFullScreen){
        [self stopVideoNative];
        [self updateGlobalWebDesList:true];
    }
    [self updateTitle];
}

-(void)configPlayCallBack{
    self.isPushState = false;
    [self updatelinkBtn];
    @weakify(self)
    _player.closePlay = ^{
        @strongify(self)
        [self exitPlay];
        [[NSNotificationCenter defaultCenter] postNotificationName:ClickVideoPlayerManagerCloseEvent object:nil];
    };
    _player.smallPlay = ^{
        @strongify(self)
        [self intoSmall];
    };
    _player.backPlay = ^{
        @strongify(self)
        [self intoBack];
    };
    _player.sharePlay = ^{
        @strongify(self)
        [self.controlView sharePlay];
    };
    _player.videoDownPlay = ^{
        @strongify(self)
        [self.controlView videoCachesDown];
    };
    _player.videoLink = ^{
        @strongify(self)
        [self videoLink];
    };
    self.player.controlView = self.controlView;
    self.player.containerView.alpha=0;
    self.player.containerView.hidden = YES;
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    self.player.shouldAutoPlay = YES;
    self.player.pauseWhenAppResignActive = self.isForceBackPlayMode?NO:YES;
    self.player.stopWhileNotVisible = NO;
    self.player.smallFloatView.frame = DefalutVideoRect;
    [ZFPlayerLogManager setLogEnable:false];
    ((MarjorFloatView*)self.player.smallFloatView).marjorCallBack =  self.controlView;
    self.player.currentPlayerManager.view.userInteractionEnabled = YES;
    [RACObserve(GetAppDelegate,videoPlayMode) subscribeNext:^(id x) {
        @strongify(self)//0=顶部播放,1小模式播放,2全屏播放
        [self updateVideoPlayMode];
    }];
    
    [RACObserve(GetAppDelegate,isClickWebEvent) subscribeNext:^(id x) {
        @strongify(self)
        if (GetAppDelegate.isClickWebEvent && self.playView.alpha) {
            [self intoSmall];
        }
    }];
    
    MarjorWebConfig *config = [MarjorWebConfig getInstance];
    [RACObserve(config,isPlayVideoAutoRotate) subscribeNext:^(id x) {
        @strongify(self)
        if (config.isPlayVideoAutoRotate) {
            [self.player removeDeviceOrientationObserver];
            [self.player addDeviceOrientationObserver];
        }
        else{
            [self.player removeDeviceOrientationObserver];
        }
    }];
    [RACObserve(config,webItemArray) subscribeNext:^(id x) {
        @strongify(self)
        if (config.webItemArray) {
            [self updateSmallFloatViewWhenWebTopChange:true];
        }
        else{
            [self updateSmallFloatViewWhenWebTopChange:false];
        }
    }];
    //[[BuDNativeAdManager getInstance] startNative:self.player.smallFloatView pos:BuDNativeAdManagerAdPos_ParentView_Bottom];
    self.player.presentationSizeChanged = ^(CGSize presentSize) {
        @strongify(self)
        [self updateFullDirection:presentSize];
    };
    self.player.playerReferer = ^NSString *{
        @strongify(self)
        return self.urlReferer;
    };
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        id<ZFPlayerMediaPlayback> value = asset;
        if((!isinf(value.totalTime) && self.forceReplayMode)  || (self.player.isReplayMode)){
            [self.player.currentPlayerManager replay];
            return ;
        }
        if (self.player.isFullScreen) {
            GetAppDelegate.videoPlayMode = 0;
            [self.player enterFullScreen:NO animated:YES];
        }
        [self exitPlay];
    };
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        @strongify(self)
        if (self.player.isFullScreen) {
            [self.player enterFullScreen:NO animated:YES];
        }
    };
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self updateOrientationWillChange:isFullScreen];
    };
    self.player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self updateOrientationDidChanged:isFullScreen];
        if (isFullScreen) {//全屏的时候
           // if (!self.delayFireTime) {
             //   self.delayFireTime = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(delayFireTimeAd) userInfo:nil repeats:YES];
//            }
        }
        else{
            [self.delayFireTime invalidate];self.delayFireTime = nil;
        }
    };
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
#ifndef DEBUG
#else
        UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"error" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [v show];
#endif
        
    };
    self.player.playerLoadStatChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {

    };
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        if (self.player.currentPlayerManager.totalTime>self.bSeekTime) {
            if ([self.player.currentPlayerManager isKindOfClass:[ZFAVPlayerManager class]]) {
                [self.player seekToTime:self.bSeekTime completionHandler:^(BOOL finished) {
                    
                }];
            }
            else if ([self.player.currentPlayerManager isKindOfClass:[ZFIJKPlayerManager class]]){
                [self.player seekToTime:self.bSeekTime completionHandler:^(BOOL finished) {
                    
                }];
            }
            self.player.currentPlayerManager.rate = 1;
            [self.player.currentPlayerManager setScalingMode:(ZFPlayerScalingModeAspectFit)];
        }
    };
    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)
        if (!isnan(duration) && duration>700 && !self.videosArrayUrl) {
            [[ApiCoreManager getInstace] stopApiReqeust];
        }
        if(currentTime>0){//fix 隐藏
            MajorVideoControlView *videoControlView = (MajorVideoControlView*)self.player.controlView;
            [videoControlView.activity stopAnimating];
            if(!isnan(duration)){
                [(MajorVideoControlView*)self.player.controlView updatePlayTime:currentTime];
            }
        }
        CreateVideoVaildTime
    };
    
    self.player.playerPlayStatChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        @strongify(self)
        if (self.isAppFround && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused &&[[VipPayPlus getInstance]isCanPlayVideoAd2]) {
            [self exitFullAndPlayAd:false isUseTimeLimit:false];
        }
    };
}

-(void)exitFullAndPlayFUllAd:(BOOL)isForeground{
    self.isOldFullScreen = self.isFullScreen;
    if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
        [self.player enterFullScreen:NO animated:NO];
        [self updatePlayAlpha:0];
    }
    [[VipPayPlus getInstance] tryShowFullVideo:^{
      if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
                   [self updatePlayAlpha:1];
               }
               if (self.isOldFullScreen) {
                   if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
                       [self.player enterFullScreen:YES animated:NO];
                   }
               }
               [[VipPayPlus getInstance] tryPlayVideoFinish];
    }];
}



-(void)delayFireTimeAd{
    [self.delayFireTime invalidate];self.delayFireTime = nil;
    static BOOL isPlayExitFullVideo = false;
    if(!isPlayExitFullVideo && [[VipPayPlus getInstance]isCanPlayVideoAd:false]){
        [[VipPayPlus getInstance] tryPlayVideoAd:false   isUseTimeLimit:true block: ^(BOOL isSuccess) {
            if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
                [self updatePlayAlpha:1];
            }
            [[VipPayPlus getInstance] tryPlayVideoFinish];
            [[UIApplication sharedApplication].keyWindow makeToast:@"本次已经无广告" duration:2 position:@"center"];
        }];
        isPlayExitFullVideo = true;
    }
}

-(void)revicePipePlayUrl:(NSNotification*)object{
    if (!object.object) {
        return;
    }
    if (self.videosArrayUrl) {
       NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.videosArrayUrl];
        [tmpArray addObject:object.object];
        self.videosArrayUrl = [NSArray arrayWithArray:tmpArray];
    }
    else{
        self.videosArrayUrl = [NSArray arrayWithObject:object.object];
    }
    
}

-(void)updateVideoArrayUrl:(NSArray*)array{
    self.videosArrayUrl = array;
}

-(void)initPlayer:(NSString*)url referer:(NSString*)referer rect:(CGRect)rect{
    if (!self.playView) {
        id<ZFPlayerMediaPlayback> playerManager = [[ZFIJKPlayerManager alloc] init];
        
        self.smallFloatRect = DefalutVideoRect;
        self.playView = [[UIView alloc]initWithFrame:self.smallFloatRect];
        [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
        self.player = (MajorPlayerController*)[MajorPlayerController playerWithPlayerManager:playerManager containerView:self.playView];
    }
    [self configPlayCallBack];
    id<ZFPlayerMediaPlayback> playCtrl = self.player.currentPlayerManager;
    NSString *playCtrlClassName = @"ZFAVPlayerManager";
    if ([url rangeOfString:@"file://"].location!=NSNotFound || [url rangeOfString:@"10080/videopath/"].location!=NSNotFound) {
        playCtrlClassName = @"ZFIJKPlayerManager";
        if([url rangeOfString:@"file://"].location!=NSNotFound){
          NSString *uuid =  [VideoPlayerManager tryToGetLocalUUID:url];
            //检查进度重新设置//
           NSDictionary *info = [[RecordUrlToUUID getInstance]playTimeFromKey:uuid];
             float time1 = [[info objectForKey:@"playTime"] floatValue];
            float time2  = [[info objectForKey:@"duration"] floatValue];
            if (time1>0 &&time2>0 && (time2-time1)>20) {
                self.bSeekTime = time1;
            }
        }
        [(MajorVideoControlView*)self.player.controlView updateDynamic:[NSArray array]];
    }
    if (self.isForceUseIjkPlayer) {
        playCtrlClassName = @"ZFIJKPlayerManager";
    }
    if (![playCtrlClassName isEqualToString:NSStringFromClass([playCtrl class])]) {
        [self.player updatePlayerManager:[[NSClassFromString(playCtrlClassName) alloc]init]];
    }
    
    NSURL *urlA = nil;//
    BOOL isLoadVideo = false;
    if ([url rangeOfString:@"app_default_loading2.mp4"].location!=NSNotFound) {//本地数据
        urlA = [NSURL fileURLWithPath:url];
        isLoadVideo = true;
    }
    else if([url rangeOfString:@"loading.mp4"].location == NSNotFound){
        urlA = [NSURL URLWithString:url];
        if(!urlA){
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            urlA = [NSURL URLWithString:url];
            isLoadVideo = true;
        }
    }
    else{
        urlA = [NSURL fileURLWithPath:url];
    }
    self.urlReferer = nil;//[referer length]>2?referer:nil;
    self.player.assetURL = urlA;
    [self updatePlayUI:rect isLoadVideo:isLoadVideo url:url];
}

-(void)updatePlayUI:(CGRect)rect isLoadVideo:(BOOL)isLoadVideo url:(NSString*)url {
    [self.btnBackPlay removeFromSuperview];
    self.btnBackPlay = nil;
    self.playView.alpha=1;
    self.player.controlView.alpha = 1;
    self.player.smallFloatView.alpha =1;
    self.player.currentPlayerManager.view.alpha = 1;
    
    self.webVideoRect = rect;
    if(!self.player.isFullScreen){
        [((MarjorFloatView*)self.player.smallFloatView) reSetNormal];
        GetAppDelegate.videoPlayMode = 0;
        [self updateTopVideoView];
    }
    
    if(!self.player.isFullScreen){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.player addPlayerViewToKeyWindow];
        });
    }
    @weakify(self)
    AVPlayer *avplayer = [self.player.currentPlayerManager getManagerAVPlayer];
    if ([avplayer isKindOfClass:[AVPlayer class]]) {
        [RACObserve(avplayer,externalPlaybackActive) subscribeNext:^(id x) {
            @strongify(self)
            [self updateAirPlayerBtn:avplayer.externalPlaybackActive allowsExternalPlayback:avplayer.allowsExternalPlayback];
        }];
    }
    
    MajorVideoControlView *videoControlView = (MajorVideoControlView*)self.player.controlView;
    videoControlView.downVideoHtml = nil;
    videoControlView.downVideoUrl  = nil;
    videoControlView.downTitle = nil;
    if (!isLoadVideo) {
        videoControlView.downVideoHtml  = [self.saveVideoInfo objectForKey:@"requestUrl"];
        videoControlView.downTitle  = [self.saveVideoInfo objectForKey:@"theTitle"];
        videoControlView.downVideoUrl  = url;
    }
    [RACObserve(videoControlView.landScapeControlView,isShow) subscribeNext:^(id x) {
        @strongify(self)
        if (self.player.isFullScreen) {
            [self updateGlobalWebDesList:videoControlView.landScapeControlView.isShow];
        }
    }];
}

-(void)updateFullDirection:(CGSize)videoSize{
    ZFFullScreenMode mode = videoSize.width<videoSize.height?ZFFullScreenModePortrait:ZFFullScreenModeLandscape;
    if (mode==ZFFullScreenModePortrait) {
        self.webVideoRect = CGRectMake(DefalutVideoRect.origin.x, DefalutVideoRect.origin.y, DefalutVideoRect.size.width, DefalutVideoRect.size.height*2);
        self.isPortraitFull = true;
    }
    else{
        self.webVideoRect = CGRectZero;
        self.isPortraitFull = false;
    }
    [self.controlView.portraitControlView showTitle:self.mediaTitle fullScreenMode:mode];
    [self.controlView.landScapeControlView showTitle:self.mediaTitle fullScreenMode:mode];
    if (self.webVideoRect.size.width>20) {
        [self updateTopVideoView];
    }
}

-(void)checkVideVaildTime:(NSTimer*)timer{//
    if (self.saveVideoInfo && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying && currentPlayTime++>VideoSaveValidTime)
    {
        //保存数据
        NSString *url = [self.saveVideoInfo objectForKey:@"requestUrl"];
            NSString *title = [self.saveVideoInfo objectForKey:@"theTitle"];
        NSString *externUrl = [self.saveVideoInfo objectForKey:@"externUrl"];
        NSString *currentPlayUrl = self.player.assetURL.absoluteString;
        BOOL isSave = true;
        if (externUrl &&[currentPlayUrl rangeOfString:externUrl].location!=NSNotFound) {
            isSave = false;
        }
        if (isSave && url && title) {
            //截图
            UIImage *imageData = [self.player.currentPlayerManager thumbnailImageAtCurrentTime];
            if (imageData) {
                NSData *bigData = UIImageJPEGRepresentation(imageData,0.3);
                NSString *base64Pig = [bigData base64EncodedStringWithOptions:0];
                [MarjorWebConfig saveVideoHistory:url theTitle:title videoImg:base64Pig webUrl:url];
            }
        }
        self.saveVideoInfo = nil;
    }
    if (!self.saveVideoInfo) {
        VideoClearVaildTime
    }
}

-(void)updateGlobalWebDesList:(BOOL)isShow
{
    [GetAppDelegate.globalWebDesList removeFromSuperview];
    if (isShow) {
        GetAppDelegate.globalWebDesList.hidden = NO;
        [GetAppDelegate.window addSubview:GetAppDelegate.globalWebDesList];
        if (!IF_IPHONE) {
            GetAppDelegate.globalWebDesList.frame = CGRectMake(0, MY_SCREEN_WIDTH-70, MY_SCREEN_HEIGHT, 50);
        }
        else{
            float hh = (BUDiPhoneX)?30:0;
            GetAppDelegate.globalWebDesList.frame = CGRectMake(0, MY_SCREEN_WIDTH-60-hh, MY_SCREEN_HEIGHT, 40);
        }
        [GetAppDelegate.globalWebDesList updateSelectState];
    }
    if(self.player.isFullScreen){
        [(MajorVideoControlView*)self.player.controlView addShareBtn];
    }
}

-(void)updateTopVideoView{
    
    if (self.webVideoRect.size.width>20) {
        self.smallFloatRect = self.webVideoRect;
        self.playView.frame = self.webVideoRect;
        self.player.smallFloatView.frame = self.webVideoRect;
        return;
    }
    self.player.smallFloatView.frame = DefalutVideoRect;
}

-(void)updateSmallFloatViewWhenWebTopChange:(BOOL)isWebTopShow
{
    if (GetAppDelegate.videoPlayMode==0) {
        [self updateTopVideoView];
    }
    else{
        
    }
}

-(void)updateAirPlayerBtn:(BOOL)isAirPlayer allowsExternalPlayback:(BOOL)allowsExternalPlayback {
    MPVolumeView *v = self.controlView.portraitControlView.airPlayBtn;
    if (isAirPlayer) {
        [v  setRouteButtonImage:ZFPlayer_Image(@"touying1") forState:UIControlStateNormal];
    }
    else{
        [v  setRouteButtonImage:ZFPlayer_Image(@"touying2") forState:UIControlStateNormal];
    }
    if (IF_IPAD) {
        v.alpha = 0;
    }
}

-(void)exitPlay{
    [[BuDNativeAdManager getInstance] stopNative];
    VideoClearVaildTime
    [self.delayFireTime invalidate];self.delayFireTime = nil;
    [self.player stop];
    [self stopVideoBanner];
    [[ApiCoreManager getInstace] stopApiReqeust];
    id player = [self.player.currentPlayerManager getManagerAVPlayer];
    if ([player isKindOfClass:[AVPlayer class]]) {
        [player replaceCurrentItemWithPlayerItem:nil];
    }
    [self removeCachesDownNotifi];
    self.playView.alpha=0;
    self.player.assetURL = nil;
    self.player.controlView.alpha = 0;
    self.player.smallFloatView.alpha =0;
    [self.btnBackPlay removeFromSuperview];
    self.btnBackPlay = nil;
    self.saveVideoInfo = nil;
    self.bVideoUrl = nil;
    self.bmediaTitle = nil;
    self.burlReferer = nil;
    self.btnBackPlay = nil;
}

-(void)linkWithDevice:(NSInteger)pos{
    NSString *url = [self.player.currentPlayerManager.assetURL absoluteString];
    NSDictionary *dicHeader =  nil;
    if (self.urlReferer) {
        dicHeader = @{@"referer":self.urlReferer};
    }
    [self.player.currentPlayerManager pause];
    NSLog(@"linkWithDevice url= %@",url);//localhost 需要更换成手机局域网地址
    [[DNLAController getInstance] playWithUrl:self.throwUrl?self.throwUrl:url time:self.player.currentPlayerManager.currentTime header:dicHeader isLocal:NO deviceIndex:pos];
    self.isPushState = true;
    [self updatelinkBtn];
    self.player.pauseWhenAppResignActive = false;
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
         if (self.player.isFullScreen && self.player.orientationObserver.fullScreenMode==ZFFullScreenModeLandscape) {
             alertView.transform = CGAffineTransformMakeRotation(M_PI_2);
         }
     }
     else{
         UIAlertView *l  = [[UIAlertView alloc] initWithTitle:@"投屏失败" message:@"1:手机和电视必须在同一个无线网络才能投屏播放\n2：选择列表显示出来的都可以投影出来播放\n3：你可以投屏到电视，同时在手机上看其他电影，支持后台投影播放\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [l show];
     }
}

-(void)intoBack
{
    self.player.pauseWhenAppResignActive = NO;
    if (!self.btnBackPlay) {
        self.btnBackPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnBackPlay setImage:[UIImage imageNamed:@"Brower.bundle/play_show.png"] forState:UIControlStateNormal];
        
        float btnw = 91,btnh=46,btnVideow=153,btnVideoh = 46;
        if (IF_IPHONE) {
            btnw/=1.5;btnh/=1.5;
            btnVideow/=1.5;
            btnVideoh/=1.5;
        }
        self.btnBackPlay.frame = CGRectMake(MY_SCREEN_WIDTH-btnw, MY_SCREEN_HEIGHT-btnVideoh*3-10, btnw, btnh);
        [[UIApplication sharedApplication].keyWindow addSubview:self.btnBackPlay];
        @weakify(self)
        [self.btnBackPlay bk_addEventHandler:^(id sender) {
            @strongify(self)
            self.playView.alpha=1;
            self.player.controlView.alpha = 1;
            self.player.smallFloatView.alpha =1;
            [self.btnBackPlay removeFromSuperview];
            self.btnBackPlay = nil;
            [self updateVideoPlayMode];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    self.playView.alpha=0;
    self.player.controlView.alpha = 0;
    self.player.smallFloatView.alpha =0;
    [self stopVideoBanner];
}

-(void)intoSmall
{
    [((MarjorFloatView*)self.player.smallFloatView) intoSamll];
    self.controlView.portraitControlView.shareBtn.hidden = self.controlView.portraitControlView.newsmallBtn.hidden = self.controlView.portraitControlView.backPlayBtn.hidden = YES;
}

-(void)updateTitle{
    MajorVideoControlView *view = (MajorVideoControlView*)self.player.controlView;
    view.portraitControlView.titleLabel.text = self.mediaTitle;
    view.landScapeControlView.titleLabel.text = self.mediaTitle;
}

-(void)addCachesDownNotifi
{
    [self removeCachesDownNotifi];
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        NSString *htmlUrl = [self.saveVideoInfo objectForKey:@"requestUrl"];
        NSString *videoUrl = self.bVideoUrl;
        if (htmlUrl) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceVideoDownFinish:) name:[NSString stringWithFormat:@"%@%@",[YTKNetworkUtils md5StringFromString:htmlUrl],VideoCachesDownNotfiSuffix] object:nil];
        }
        if (videoUrl) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceVideoDownFinish:) name:[NSString stringWithFormat:@"%@%@",[YTKNetworkUtils md5StringFromString:videoUrl],VideoCachesDownNotfiSuffix] object:nil];
        }
    }
}

-(void)reviceVideoDownFinish:(NSNotification*)object{
   __block NSString *filePath = object.object;
    if (filePath) {
        [YSCHUDManager showHUDOnKeyWindowWithMesage:@"正在切换为已下载视频播放"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *uuid = [object.name substringToIndex:[object.name length] - [VideoCachesDownNotfiSuffix length]];
            filePath = [VideoPlayerManager tryToPathConvert:filePath uuid:uuid];
            filePath = [[NSURL fileURLWithPath:filePath] absoluteString];
            [self playFromLocalWhenCacheFinish:filePath];
            [YSCHUDManager hideHUDOnKeyWindow];
        });
        return;
        TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"本集视频已下载完成！！" message:@"是否播放？"];
        TYAlertAction *quxiao  = [TYAlertAction actionWithTitle:@"取消"
                                                          style:TYAlertActionStyleCancel
                                                        handler:^(TYAlertAction *action) {
                                                            
                                                        }];
        [alertView addAction:quxiao];
        TYAlertAction *chongxia  = [TYAlertAction actionWithTitle:@"播放"
                                                            style:TYAlertActionStyleDefault
                                                          handler:^(TYAlertAction *action) {
                                                              [self playFromLocalWhenCacheFinish:filePath];
                                                          }];
        [alertView addAction:chongxia];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
    }
}

-(void)playFromLocalWhenCacheFinish:(NSString*)filePath{
    float playTime = self.player.currentPlayerManager.currentTime;
    BOOL isFull = self.isFullScreen;
    if([self playWithUrl:filePath title:self.mediaTitle referer:nil saveInfo:nil replayMode:NO rect:CGRectZero throwUrl:nil isUseIjkPlayer:false]){
        if (playTime>=1&&playTime<INT16_MAX) {
            self.bSeekTime = playTime;
        }
        if (isFull) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [((ZFPlayerControlView*)self.player.controlView).portraitControlView fullScreenButtonClickAction:nil];
            });
        }
    }
}


-(void)removeCachesDownNotifi{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self configNeedNotifi];
}

-(void)playWithPlayerInterface:(id)playerInterface title:(NSString*)title saveInfo:(NSDictionary*)saveInfo isMustSeekBegin:(BOOL)isMustSeekBegin
{
    self.videosArrayUrl = nil;
    if (!self.playView) {
        self.smallFloatRect = DefalutVideoRect;
        self.playView = [[UIView alloc]initWithFrame:self.smallFloatRect];
        [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
    }
    self.isForceUseIjkPlayer = false;
    [(MajorVideoControlView*)self.player.controlView cancelAllPerformSelector];
    self.player = playerInterface;
    [self.player.controlView removeFromSuperview];
    self.player.controlView = self.controlView;
    [self.player updateContainerView:self.playView];
    self.controlView.frame = DefalutVideoRect;
    self.saveVideoInfo = saveInfo;
    self.bVideoUrl  = [self.player.currentPlayerManager.assetURL absoluteString];
    self.throwUrl = nil;
    self.burlReferer = nil;
    self.bSeekTime = 1;
    self.mediaTitle = self.bmediaTitle = title;
    self.forceReplayMode = false;
    [((ZFPlayerControlView*)self.player.controlView) showTitle:title coverURLString:nil fullScreenMode:ZFFullScreenModeLandscape];
    [self updatePlayUI:CGRectZero isLoadVideo:false url:self.bVideoUrl];
    [self configPlayCallBack];
    [self setlockMedia:title url:self.bVideoUrl];
    [self addCachesDownNotifi];
    if(isMustSeekBegin){
        [self.player.currentPlayerManager replay];
    }
    [[BuDNativeAdManager getInstance]stopNative];
    //[[BuDNativeAdManager getInstance] startNative:self.player.smallFloatView pos:BuDNativeAdManagerAdPos_ParentView_Bottom];
}

-(BOOL)playWithUrl:(NSString*)url title:(NSString*)title referer:(NSString*)referer saveInfo:(NSDictionary*)saveInfo replayMode:(BOOL)replayMode   rect:(CGRect)rect  throwUrl:(NSString*)throwUrl isUseIjkPlayer:(BOOL)isUseIjkPlayer
{
    [[MajorSystemConfig getInstance] setBannerRect];
    self.videosArrayUrl = nil;
    if (!url) {
        return false;
    }
    if ([VideoPlayerManager tryToTestLocalCanPlay:url]==Video_Play_Enough_Gold) {
        return false;
    }
    {//
        self.saveVideoInfo = saveInfo;
        self.bVideoUrl = url;
        self.bmediaTitle = title;
        self.burlReferer = referer;
        self.bSeekTime = 1;
        self.throwUrl = throwUrl;
    }
    NSLog(@"%s url = %@ title = %@",__FUNCTION__,url,title);
    self.forceReplayMode = replayMode;
    self.isForceUseIjkPlayer = isUseIjkPlayer;
    [self performSelector:@selector(delayPlay:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",title,@"title",referer,@"referer",saveInfo,@"saveInfo",[NSValue valueWithCGRect:rect],@"SmallRect",nil] afterDelay:0.1];
    return true;
}

-(void)webPushPlay:(NSString*)url title:(NSString*)title webPushBlock:(void(^)(void))webPushBlock{
    self.webPushBlock = webPushBlock;
    self.videosArrayUrl = nil;
    if (url) {
        self.forceReplayMode = false;
        [self delayPlay:[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",title,@"title",nil]];
    }
}

-(void)updatePlayAlpha:(float)alpha{
    if (!self.bVideoUrl && alpha>=0.5) {
        return;
    }
    self.player.smallFloatView.alpha = alpha;
    self.player.controlView.alpha = alpha;
    self.playView.alpha = alpha;
    self.player.currentPlayerManager.view.alpha = alpha;
}
    
-(void)webPushLand:(CGSize)videoSize{
    if (videoSize.width>0) {
        [self updateFullDirection:videoSize];
    }
    [(MajorPlayerController*)self.player webPushLand];
}

-(void)delayPlay:(NSDictionary*)info{
    VideoClearVaildTime
    NSString *url = [info objectForKey:@"url"];
    NSString *title = [info objectForKey:@"title"];
    NSValue *value = [info objectForKey:@"SmallRect"];
    NSString *referer = [info objectForKey:@"referer"];
    self.saveVideoInfo = [info objectForKey:@"saveInfo"];
    NSString *externUrl = [self.saveVideoInfo objectForKey:@"externUrl"];
    NSString *tmpUrl = externUrl?externUrl:url;
    [(MajorVideoControlView*)self.player.controlView cancelAllPerformSelector];
    [self.player.currentPlayerManager stop];
    [self initPlayer:tmpUrl referer:referer rect:[value CGRectValue]];
    self.mediaTitle = [info objectForKey:@"title"];
    [self setlockMedia:title url:url];
    [self addCachesDownNotifi];
}

-(void)setlockMedia:(NSString*)title url:(NSString*)url{
    [((ZFPlayerControlView*)self.player.controlView) showTitle:title coverURLString:nil fullScreenMode:ZFFullScreenModeLandscape];
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        self.lockDict = [[NSMutableDictionary alloc]initWithCapacity:10];
        if (GetAppDelegate.backGroundDownMode && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [self.lockDict setObject:@"后台模式" forKey:MPMediaItemPropertyTitle];
            [self.lockDict setObject:@"后台下载中，请勿暂停播放" forKey:MPMediaItemPropertyAlbumTitle ];
        }
        else{
            [self.lockDict setObject:url forKey:MPMediaItemPropertyAlbumTitle ];
            if (title) {
                [self.lockDict setObject:title forKey:MPMediaItemPropertyTitle];
            }
        }
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"AppIcon20x20.png"]];
        [self.lockDict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = self.lockDict;
    }
}

-(void)didEnterForeground:(NSNotification*)object{
    self.isAppFround = true;
    self.isForceBackPlayMode = false;
    if (self.isBDownMode) {
        
        if (gbVideoUrl) {
            self.bVideoUrl = gbVideoUrl;
            self.burlReferer = gburlReferer;
            self.bSaveVideoInfo = gbSaveVideoInfo;
            self.bmediaTitle = gbmediaTitle;
            self.forceReplayMode = false;
            self.bSeekTime = gbSeekTime;
            [self performSelector:@selector(delayPlay:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.bVideoUrl,@"url",self.bmediaTitle,@"title",self.burlReferer,@"referer",self.bSaveVideoInfo,@"saveInfo",nil] afterDelay:0];
        }
    }
    self.isBDownMode = false;
    if (false &&[[VipPayPlus getInstance]isCanPlayVideoAd:true]) {//20200214取消广告
        static BOOL isWatchVideo = true;
        if (isWatchVideo) {
            [self exitFullAndPlayAd:true isUseTimeLimit:true];
        }
        isWatchVideo = false;
    }
}

-(void)didEnterBackground:(NSNotification*)object{
    self.isAppFround = false;
     NSString *urlTest=  [self.player.assetURL absoluteString];
     if (urlTest && [urlTest rangeOfString:@"back_down_play"].location ==NSNotFound) {
         return;
     }
    
    self.isBDownMode = false;
    self.isForceBackPlayMode = false;
    NSLog(@"[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = %@",[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo);
    if (GetAppDelegate.backGroundDownMode) {//checkIsDown
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"AppNewStateManager",@"param1",@"getInstance",@"param2",@"checkIsDown",@"param3", nil];
        NSString *savebVideoUrl = nil;
        NSDictionary *saveBVideoInfo =nil;
        NSString *bmediaTitle =nil;
        NSString *burlReferer = nil;
        if (self.bVideoUrl && self.bmediaTitle && _saveVideoInfo) {
             savebVideoUrl = [NSString stringWithString:self.bVideoUrl];
             saveBVideoInfo = [NSDictionary dictionaryWithDictionary:_saveVideoInfo];
             bmediaTitle = [NSString stringWithString:self.bmediaTitle];
            burlReferer = self.burlReferer?[NSString stringWithString:self.burlReferer]:nil;
            self.bSeekTime = self.player.currentTime;
            gbSeekTime = self.bSeekTime;
        }
        if([[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue])
        {
            self.isForceBackPlayMode = true;
            self.isBDownMode = true;
            NSString *strPath = [[NSBundle mainBundle] pathForResource:@"back_down_play" ofType:@"mp3"];
            [self exitPlay];
            self.forceReplayMode = true;
            [self delayPlay:[NSDictionary dictionaryWithObjectsAndKeys:[[NSURL fileURLWithPath:strPath] absoluteString],@"url",@"",@"title",nil]];
            [self intoBack];
        }
        
        if (savebVideoUrl) {
            gbVideoUrl = [[NSString alloc] initWithString:savebVideoUrl];
        }
        if (burlReferer) {
            gburlReferer = [[NSString alloc] initWithString:burlReferer];
        }
        if (bmediaTitle) {
            gbmediaTitle = [[NSString alloc] initWithString:bmediaTitle];
        }
        if (saveBVideoInfo) {
            gbSaveVideoInfo = [[NSDictionary alloc] initWithDictionary:saveBVideoInfo];
        }
        self.bVideoUrl =savebVideoUrl ;
        self.bSaveVideoInfo =saveBVideoInfo ;
        self.bmediaTitle =bmediaTitle ;
        self.burlReferer =burlReferer ;
        NSLog(@"test1");
        NSLog(@"self.bVideoUrl = %@ self.bSaveVideoInfo = %@ self.bmediaTitle = %@ self.burlReferer =%@",self.bVideoUrl,[self.bSaveVideoInfo description],self.bmediaTitle,self.burlReferer);
        NSLog(@"test2");
    }
}


-(void)exitFullAndPlayAd:(BOOL)isForeground isUseTimeLimit:(BOOL)isUseTimeLimit{
    self.isOldFullScreen = self.isFullScreen;
    if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
        [self.player enterFullScreen:NO animated:NO];
        [self updatePlayAlpha:0];
    }
    [[VipPayPlus getInstance] tryPlayVideoAd:isForeground  isUseTimeLimit:isUseTimeLimit  block: ^(BOOL isSuccess) {
        if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
            [self updatePlayAlpha:1];
        }
        if (self.isOldFullScreen) {
            if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
                [self.player enterFullScreen:YES animated:NO];
            }
        }
        [[VipPayPlus getInstance] tryPlayVideoFinish];
    }];
}

@end
