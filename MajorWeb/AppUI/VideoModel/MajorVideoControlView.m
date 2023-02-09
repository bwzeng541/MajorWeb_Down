
#import "MajorVideoControlView.h"
#import "UIView+ZFFrame.h"
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#import "ZFLoadingView.h"
#import "MarjorWebConfig.h"
#import  "ZFSliderView.h"
#import "AppDelegate.h"
#import "MarjorFloatView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ShareSdkManager.h"
#import "WebDesListView.h"
#import "MajorPlayerController.h"
#import "AppStateInfoManager.h"
#import "YTKNetworkPrivate.h"
#import "VideoPlayerSetView.h"
#import "VideoPlayerManager.h"
#import "MajorVideosSelect.h"
#import "RecordUrlToUUID.h"
#import "MajorZFPortraitControlView.h"
#import "MajorZFLandScapeControlView.h"
#define VideoInValideDuratime 100000
@interface MajorVideoControlView ()<MarjorFloatViewDelegate,MajorVideosSelectDelegate>
/// 封面图
@property (nonatomic, strong) ZFSliderView *sliderView;
/// 加载loading
@property (nonatomic, strong) UIButton *btnShare;
@property (nonatomic, strong) UIButton *btnShareUrl;
@property (nonatomic, strong) UIButton *btnCache;
@property (nonatomic, strong) UIButton *btnlink;
@property (nonatomic, strong) UIButton *btnCloseAutoDown;
@property (nonatomic, strong) UIButton *btnSet;
@property (nonatomic, strong) MajorVideosSelect *videoSelectView;
@property (nonatomic, copy)NSString *videoUUID;
@end

@implementation MajorVideoControlView
@synthesize player = _player;
@synthesize portraitControlView = _portraitControlView;
@synthesize landScapeControlView = _landScapeControlView;

- (ZFPortraitControlView *)portraitControlView {
        if (!_portraitControlView) {
            @weakify(self)
            _portraitControlView = [[MajorZFPortraitControlView alloc] init];
            _portraitControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
                @strongify(self)
                [self cancelAutoFadeOutControlView];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PortraitSlilderChangeState" object:[NSNumber numberWithBool:true]];
            };
            _portraitControlView.sliderValueChanged = ^(CGFloat value) {
                @strongify(self)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PortraitSlilderChangeState" object:[NSNumber numberWithBool:false]];
                [self autoFadeOutControlView];
            };
        }
        return _portraitControlView;
}

- (ZFLandScapeControlView *)landScapeControlView {
        if (!_landScapeControlView) {
            @weakify(self)
            _landScapeControlView = [[MajorZFLandScapeControlView alloc] init];
            _landScapeControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
                @strongify(self)
                [self cancelAutoFadeOutControlView];
            };
            _landScapeControlView.sliderValueChanged = ^(CGFloat value) {
                @strongify(self)
                [self autoFadeOutControlView];
            };
        }
        return _landScapeControlView;
    
}

-(void)marjor_select_video_url:(NSString*)videosUrl{
    if (self.updateVideoUrl) {
        self.updateVideoUrl(videosUrl);
    }
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (UIButton*)createShareBtn:(SEL)action rect:(CGRect)rect title:(NSString*)title{
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        btn.backgroundColor = [UIColor clearColor];
        [self addSubview:btn];
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        btn.frame = rect;
         return btn;
}

-(float)getVideoPlayDuration{
    float duration = self.player.totalTime;
    if (!isnan(duration) && duration > 2) {
        
    }
    else{
        duration = VideoInValideDuratime;//没有取到就设置一个很大值
    }
    return duration;
}

- (void)addShareBtn{
    
    CGRect rect = CGRectMake(MY_SCREEN_HEIGHT-105*0.7-10, 30/*self.landScapeControlView.titleLabel.center.y-35*0.7*/, 105*0.7, 35*0.7);
    if (!_btnCache) {
        _btnCache = [self createShareBtn:@selector(majorVideoCache:) rect:rect title:@"下载视频"];
    }
  
    if (!_btnShareUrl) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5, rect.origin.y, rect.size.width, rect.size.height);
        _btnShareUrl = [self createShareBtn:@selector(majorVideoShareUrl:) rect:rect title:@"视频地址"];
    }
    if (!_btnSet) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5, rect.origin.y, rect.size.width, rect.size.height);
        _btnSet = [self createShareBtn:@selector(majorVideoPlaySet:) rect:rect title:@"拉伸加速"];
    }
    if (!_btnShare) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5, rect.origin.y, rect.size.width, rect.size.height);
        _btnShare = [self createShareBtn:@selector(majorVideoShare:) rect:rect title:@"分享APP"];
    }
    if (!_btnlink) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5, rect.origin.y, rect.size.width, rect.size.height);
        _btnlink = [self createShareBtn:@selector(majorVideolink:) rect:rect title:@"电视投屏"];
    }
    if (!_btnCloseAutoDown) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5-6, rect.origin.y, rect.size.width+25, rect.size.height);
        _btnCloseAutoDown = [self createShareBtn:@selector(majorAutoDown:) rect:rect title:@"关闭自动下载"];
    }
    if (!_videoSelectView) {
        float w = 136;
        if (IF_IPHONE) {
            w/=2;
        }
        _videoSelectView = [[MajorVideosSelect alloc] initWithNibName:nil bundle:nil];
        [_videoSelectView updateFrame:CGRectMake(MY_SCREEN_HEIGHT-w, (MY_SCREEN_WIDTH - MY_SCREEN_WIDTH/2)/2, w, MY_SCREEN_WIDTH/2)];
        [self addSubview:_videoSelectView.view];
        _videoSelectView.delegate = self;
    }
    @weakify(self)
    [RACObserve([MarjorWebConfig getInstance],isAllowsAutoCachesVideoWhenPlay) subscribeNext:^(id x) {
        @strongify(self)
        NSString *msg = nil;
        if ([MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay) {
            msg = @"关闭自动下载";
        }
        else{
            msg = @"打开自动下载";
        }
        [self.btnCloseAutoDown setTitle:msg forState:UIControlStateNormal];
     }];
    
    [RACObserve([VideoPlayerManager getVideoPlayInstance],isPushState) subscribeNext:^(id x) {
        @strongify(self)//0=顶部播放,1小模式播放,2全屏播放
        if([VideoPlayerManager getVideoPlayInstance].isPushState){
            [self.btnlink setTitle:@"关闭投屏" forState:UIControlStateNormal];
        }
        else{
            [self.btnlink setTitle:@"电视投屏" forState:UIControlStateNormal];
        }
    }];
}


-(void)majorVideolink:(UIButton*)sender{
    [self.player intoLinkPlayController];
}

-(void)majorAutoDown:(UIButton*)sender{
    [MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay = ![MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay;
    [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMajorSetView" object:nil];
    NSString *msg = nil;
    if (![MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay) {
        msg = @"已经关闭视频自动下载";
    }
    else{
        msg = @"视频自动下载已经打开";
    }
    [self makeToast:msg duration:1 position:@"center"];
}

-(void)majorVideoPlaySet:(UIButton*)sender{
    [VideoPlayerSetView showVideoPlayerView:self.player];
}

-(void)majorVideoCache:(UIButton*)sender{
    if (self.downVideoUrl && self.downVideoHtml && self.downTitle) {
        //!isnan(duration) && duration > 2
        float duration = [self getVideoPlayDuration];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.downTitle,@"parma0",self.downVideoUrl,@"parma1",self.downVideoHtml,@"parma3",@(duration),@"parma4", nil];
        NSLog(@"majorVideoCache  = %@",[dic description]);
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgapp1 object:dic];
    }
}

-(void)majorVideoShareUrl:(UIButton*)sender{
    [self sharePlay];
}

- (void)videoCachesDown{
    [self majorVideoCache:nil];
}

-(void)sharePlay
{
    
    NSString *name = self.portraitControlView.titleLabel.text;
    NSString *_url = [self.player.assetURL absoluteString];
    
     TYAlertView *alertView =[[ShareSdkManager getInstance] showShareType:SSDKContentTypeWebPage typeArray:^NSArray *{
        return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
    } value:^NSString *{
        return _url ;
    } titleBlock:^NSString *{
        return [BeatifyAssetVideoShareMsg stringByAppendingString:name];
    } imageBlock:^UIImage *{
        return nil;
    } urlBlock:^NSString  *{
        return _url;
    }shareViewTileBlock:^NSString *{
        return @"已经复制视频地址请分享";
    }];
    
    if (self.player.isFullScreen && self.player.orientationObserver.fullScreenMode==ZFFullScreenModeLandscape) {
        alertView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}

-(void)majorVideoShare:(UIButton*)sender{
   NSString *name = self.portraitControlView.titleLabel.text;
   TYAlertView *alertView =  [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
                return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
    } value:^NSString *{
        return name;
    } titleBlock:^NSString *{
        return name;
    } imageBlock:^UIImage *{
        return nil;
    } urlBlock:^NSString  *{
        return nil;
    }shareViewTileBlock:^NSString *{
        return @"分享app";
    }];
    
    if (self.player.isFullScreen && self.player.orientationObserver.fullScreenMode==ZFFullScreenModeLandscape) {
        alertView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    NSLog(@"有子视图 添加 或者 插入到 我上面了");
}


/**
 *  子视图 从该视图中移除的时候 调用
 */
- (void)willRemoveSubview:(UIView *)subview
{
    NSLog(@"我将要移除一个子视图==%@",[[subview class] description]);
}



/**
 *  当该视图 已经变更了父视图时候调用（该视图添加到父视图 或者从父视图上移除 会调用）
 *
 *  eg:A 移动到 B上， A调用该方法 ; A 从B上移除  A也会调用
 */
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    NSLog(@"我被移动到 父视图上了");
}


/**
 *  该视图 将要变更腹肌试图时候调用 （该视图添加到父视图 或者从父视图上移除 会调用）
 */
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    NSLog(@"我将要变更父级 视图了==%@",[[newSuperview class] description]);
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImageView.frame = self.player.currentPlayerManager.view.bounds;
    float w = self.player.currentPlayerManager.presentationSize.width;
    float h = self.player.currentPlayerManager.presentationSize.height;
    if (w>0&&w<10000 && h>0 && h<10000) {
        self.btnSet.alpha = w>h?1:0;
    }
    @weakify(self)
    [RACObserve(GetAppDelegate.globalWebDesList,isCanFireAutoFadeOut) subscribeNext:^(id x) {
        @strongify(self)
         if (GetAppDelegate.globalWebDesList.isCanFireAutoFadeOut) {
            [self autoFadeOutControlView];
        }
        else{
            [self cancelAutoFadeOutControlView];
        }
    }];
}

- (void)resetControlView {
    [super resetControlView];
    [self updatePortraitDownBtn];
    _btnCache.alpha = 0;
    self.portraitControlView.cachesPlayBtn.alpha=0;
    //
    [self cancelAllPerformSelector];
    self.videoUUID = nil;
    [self performSelector:@selector(delayUpdateDown) withObject:nil afterDelay:6];
}

- (void)cancelAllPerformSelector{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayUpdateDown) object:nil];
}

-(void)delayUpdateDown{
    @weakify(self)
    [RACObserve(self.player.currentPlayerManager,totalTime) subscribeNext:^(id x) {
        @strongify(self)
       [self updateVideoBtns:self.player.currentPlayerManager.totalTime];
    }];
    
}

-(void)updatePlayTime:(float)playTime{
    if (self.videoUUID) {
        float duration = self.player.totalTime;
        if (!isnan(duration) && duration > 2 && (playTime<=duration)){
            [[RecordUrlToUUID getInstance] updateVideoTime:self.videoUUID playTime:@{@"playTime":@(playTime),@"duration":@(duration)}];
        }
    }
}

-(void)updateVideoBtns:(float)duration
{
   
    if (!isnan(duration) && duration > 2 && self.downVideoHtml && ([self.downVideoUrl rangeOfString:@"file://"].location==NSNotFound)) {//大于2秒的视频
        _btnCache.alpha = 1;
        self.portraitControlView.cachesPlayBtn.alpha=1;
        BOOL isValue =  self.portraitControlView.backPlayBtn.hidden;
        if (isValue) {
            self.portraitControlView.cachesPlayBtn.alpha=0;
        }
        else{
            self.portraitControlView.cachesPlayBtn.alpha=1;
        }
        
       self.videoUUID = [AppStateInfoManager getVideoUUIDFrom:self.downVideoHtml videoUrl:self.downVideoUrl durtime:@(duration)];
       BOOL isAdd =  [[[AppStateInfoManager getInstance] isAddCaches:self.videoUUID] boolValue];
        if (!isAdd && [MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay) {
            [self videoCachesDown];
        }
    }
    else if([self.downVideoUrl rangeOfString:@"file://"].location!=NSNotFound && [self.downVideoUrl rangeOfString:@"VideoDownCaches"].location!=NSNotFound){
        self.videoUUID = [[self.downVideoUrl lastPathComponent] stringByDeletingPathExtension];
    }
}

- (void)updatePortraitDownBtn{
    self.portraitControlView.cachesPlayBtn.hidden = YES;
    BOOL isCanVideo = false;
    if([self.downVideoUrl rangeOfString:@"file://"].location!=NSNotFound){
        isCanVideo = true;
    }
    if (GetAppDelegate.videoPlayMode!=2) {
        self.portraitControlView.cachesPlayBtn.hidden = isCanVideo;
        [VideoPlayerSetView hiddeVideoPlayerView];
    }
}

/// 加载状态改变
- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state {
    [super videoPlayer:videoPlayer loadStateChanged:state];

}

/// 播放进度改变回调
- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    [super videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];

}

- (void)lockedVideoPlayer:(ZFPlayerController *)videoPlayer lockedScreen:(BOOL)locked {
    [self showControlViewWithAnimated:NO];
}

/// 缓冲改变回调
- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    [super videoPlayer:videoPlayer bufferTime:bufferTime];
 }

- (void)showControlViewWithAnimated:(BOOL)animated  {
    if (animated) {
        [UIView animateWithDuration:animated?ZFPlayerControlViewAutoFadeOutTimeInterval:0 animations:^{
            [self showFixCtrl];
        } completion:^(BOOL finished) {
            [self autoFadeOutControlView];
        }];
    }
    else{
        [self showFixCtrl];
        [self autoFadeOutControlView];
    }
}

- (void)updateDynamic:(NSArray*)videoArray{
    [_videoSelectView updateSelectUrl:self.player.assetURL.absoluteString];
    [_videoSelectView updateVideoArray:videoArray];
}

-(void)showFixCtrl{
    self.portraitControlView.titleLabel.hidden = YES;
    self.portraitControlView.titleLabel.alpha = 0;
    self.landScapeControlView.titleLabel.font = [UIFont systemFontOfSize:18];

    if (GetAppDelegate.videoPlayMode!=1)
    {
        NSLog(@"portraitControlView = %@",NSStringFromCGRect(self.portraitControlView.frame));
        [self.landScapeControlView showControlView];
        [self.portraitControlView showControlView];
    }
    self.bottomPgrogress.hidden = YES;
    BOOL isCanVideo = false;
    if([self.downVideoUrl rangeOfString:@"file://"].location!=NSNotFound){
        isCanVideo = true;
    }
    if (GetAppDelegate.videoPlayMode==2) {
        [self addShareBtn];
        self.portraitControlView.cachesPlayBtn.hidden = YES;
        _videoSelectView.view.hidden = _btnlink.hidden = _btnCloseAutoDown.hidden = _btnSet.hidden = _btnShareUrl.hidden = _btnShare.hidden = NO;
        
        float w = 136;
        if (IF_IPHONE) {
            w/=2;
        }
         _videoSelectView.view.frame = CGRectMake(MY_SCREEN_HEIGHT-w, (MY_SCREEN_WIDTH - MY_SCREEN_WIDTH/2)/2, w, MY_SCREEN_WIDTH/2);
        if (self.updateVidesArray) {
            [_videoSelectView updateSelectUrl:self.player.assetURL.absoluteString];
            [_videoSelectView updateVideoArray:self.updateVidesArray()];
        }
        else{
            [_videoSelectView updateVideoArray:[NSArray array]];
        }
        _btnCache.hidden  = isCanVideo;
        [self.player setStatusBarHidden:YES];
    }
    else{
        self.portraitControlView.cachesPlayBtn.hidden = isCanVideo;
    }
    self.portraitControlView.backPlayBtn.alpha = self.portraitControlView.shareBtn.alpha = self.portraitControlView.newsmallBtn.alpha=1;
}

-(void)hideFixCtrl{
    [self.landScapeControlView hideControlView];
    [self.portraitControlView hideControlView];
    [self updateViewAppeared:false];
    _videoSelectView.view.hidden = _btnlink.hidden = _btnCloseAutoDown.hidden = _btnSet.hidden = _btnCache.hidden = _btnShareUrl.hidden = _btnShare.hidden = YES;
    self.portraitControlView.backPlayBtn.alpha = self.portraitControlView.shareBtn.alpha = self.portraitControlView.newsmallBtn.alpha=0;
    if (GetAppDelegate.videoPlayMode==2 ) {
        [self.player setStatusBarHidden:YES];
    }
}

- (void)hideControlViewWithAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated?ZFPlayerControlViewAutoFadeOutTimeInterval:0 animations:^{
        if (GetAppDelegate.videoPlayMode!=1){
            [self hideFixCtrl];
        }
    } completion:^(BOOL finished) {
        self.bottomPgrogress.hidden = NO;
    }];
}

-(void)addVolumeListern
{
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:)name:@"AVSystemController_SystemVolumeDidChangeNotification"
     //                                          object:nil];
}

- (void)setPlayer:(ZFPlayerController *)player {
    [super setPlayer:player];
    _player = player;
}

- (void)showCoverViewWithUrl:(NSString *)coverUrl {
    [self.coverImageView setImageWithURLString:coverUrl placeholder:[UIImage imageNamed:@"loading_bgView"]];
}

#pragma mark --手势处理
- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self marjorFloatClickCallBack];
}

- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addVolumeListern) object:nil];
    [super gestureBeganPan:gestureControl panDirection:direction panLocation:location];
}

/// 滑动中手势事件//0=顶部播放,1小模式播放,2全屏播放
- (void)gestureChangedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location withVelocity:(CGPoint)velocity {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addVolumeListern) object:nil];
        [super gestureChangedPan:gestureControl panDirection:direction panLocation:location withVelocity:velocity];
}

/// 滑动结束手势事件
- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    [super gestureEndedPan:gestureControl panDirection:direction panLocation:location];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self performSelector:@selector(addVolumeListern) withObject:nil afterDelay:0.2];
}

- (void)reSetTopCtrlView{
    [self marjorFloatClickCallBack];
    [self marjorSyncContainerViewFrameCallBack];
}
#pragma mark--MarjorFloatViewDelegate
-(void)marjorFloatClickCallBack
{
    if (self.controlViewAppeared) {
        [self hideControlViewWithAnimated:NO];
    } else {
        [self showControlViewWithAnimated:NO];
    }
    self.bottomPgrogress.alpha = 0;
    BOOL isValue =  ((MarjorFloatView*)self.player.smallFloatView).isVerySamll;
   self.portraitControlView.shareBtn.hidden = self.portraitControlView.newsmallBtn.hidden =  self.portraitControlView.backPlayBtn.hidden = isValue;
    if (isValue) {
        self.portraitControlView.cachesPlayBtn.alpha = 0;
    }
    else{
        self.portraitControlView.cachesPlayBtn.alpha = 1;
    }
    if (self.portraitControlView.backPlayBtn.alpha<1) {
        self.portraitControlView.cachesPlayBtn.alpha = 0;
    }
}

-(void)marjorSyncContainerViewFrameCallBack{
    self.player.containerView.frame = self.player.smallFloatView.frame;
}

- (void)marjorHiddenCallBack:(BOOL)withAnimated{
    [self hideFixCtrl];
    //[self hideControlViewWithAnimated:withAnimated];
}

-(void)marjorFloatPanBeganCallBack:(ZFPanDirection)direction {
    [self gestureBeganPan:NULL panDirection:direction panLocation:0];
}

-(void)marjorFloatPanChangeCallBack:(ZFPanDirection)direction velocity:(CGPoint)location{
    [self gestureChangedPan:NULL panDirection:direction panLocation:0 withVelocity:location];
}

-(void)marjorFloatPanEndCallBack:(ZFPanDirection)direction {
    [self gestureEndedPan:NULL panDirection:direction panLocation:0 ];
}

-(void)marjorFloatStopCallBack{
    ((MajorPlayerController*)self.player).closePlay();
}

-(void)marjorFloatPauseCallBack{
    id<ZFPlayerMediaPlayback>player = self.player.currentPlayerManager;
    if ([player isPlaying]) {
        [player  pause];
    }
    else{
        [player  play];
    }
}
@end
