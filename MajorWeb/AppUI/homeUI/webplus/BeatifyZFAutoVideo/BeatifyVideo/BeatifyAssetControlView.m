#import "BeatifyAssetControlView.h"
#import "ThrowFloatView.h"
#import "AppDelegate.h"
#import "UIImageView+ZFCache.h"
#import "ThrowAssetController.h"
#import "BeatifyAssetSetView.h"
@interface BeatifyAssetControlView ()<ThrowFloatViewDelegate>
/// 封面图
@property (nonatomic, strong) ZFSliderView *sliderView;
/// 加载loading
@property (nonatomic, strong) UIButton *btnShare;
@property (nonatomic, strong) UIButton *btnlink;
@property (nonatomic, strong) UIButton *btnJump;
@property (nonatomic, strong) UIButton *btnSet;
@end


@implementation BeatifyAssetControlView

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

- (void)addShareBtn{
    CGRect rect = CGRectMake((MY_SCREEN_WIDTH>MY_SCREEN_HEIGHT?MY_SCREEN_WIDTH:MY_SCREEN_HEIGHT)-20, 30, 105*0.7, 35*0.7);
    if (!_btnSet) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.1, rect.origin.y, rect.size.width, rect.size.height);
        _btnSet = [self createShareBtn:@selector(throwVideoPlaySet:) rect:rect title:@"更多设置"];
    }
    if (!_btnlink) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5, rect.origin.y, rect.size.width, rect.size.height);
        _btnlink = [self createShareBtn:@selector(throwVideolink:) rect:rect title:@"电视投屏"];
    }
    if (!_btnJump) {
        rect = CGRectMake(rect.origin.x-rect.size.width*1.5, rect.origin.y, rect.size.width, rect.size.height);
        _btnJump = [self createShareBtn:@selector(throwVideoJump:) rect:rect title:[NSString stringWithFormat:@"%@%@%@%@",@"下",@"载",@"视",@"频"]];
    }
}

-(void)throwVideoJump:(UIButton*)sender{
   /* [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GetAppDelegate.param6] options:nil completionHandler:^(BOOL success) {
        
    }];*/
}

-(void)throwVideolink:(UIButton*)sender{
    [self.player intoLinkPlayController];
}

-(void)throwVideoPlaySet:(UIButton*)sender{
   [BeatifyAssetSetView showAssetView:self.player];
}

-(void)throwVideoShareUrl:(UIButton*)sender{
    [self sharePlay];
}


- (void)cancelAllPerformSelector{
    
}

- (void)sharePlay{
   
}


-(void)throwVideoShare:(UIButton*)sender{
    
}



- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImageView.frame = self.player.currentPlayerManager.view.bounds;
    float w = self.player.currentPlayerManager.presentationSize.width;
    float h = self.player.currentPlayerManager.presentationSize.height;
    if (w>0&&w<10000 && h>0 && h<10000) {
        self.btnSet.alpha = w>h?1:0;
    }
//    @weakify(self)
//    [RACObserve(GetAppDelegate.globalWebDesList,isCanFireAutoFadeOut) subscribeNext:^(id x) {
//        @strongify(self)
//        if (GetAppDelegate.globalWebDesList.isCanFireAutoFadeOut) {
//            [self autoFadeOutControlView];
//        }
//        else{
//            [self cancelAutoFadeOutControlView];
//        }
//    }];
}

- (void)resetControlView{
    [super resetControlView];
    [self updatePortraitDownBtn];
    self.portraitControlView.backPlayBtn.alpha =
    _btnShare.alpha =
    self.portraitControlView.cachesPlayBtn.alpha=
    self.portraitControlView.shareBtn.alpha=0;
    self.portraitControlView.backPlayBtn.hidden = YES;
    //
    [self cancelAllPerformSelector];
    [self performSelector:@selector(delayUpdateDown) withObject:nil afterDelay:6];
}




-(void)delayUpdateDown{
    
}

-(void)updateVideoBtns:(float)duration
{
    
    
}

- (void)updatePortraitDownBtn{
    
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

- (void)removeFixBtn{
    [self.portraitControlView.newsmallBtn setImage:nil forState:UIControlStateNormal];
}

-(void)showFixCtrl{
    if (GetAppDelegate.videoPlayMode!=1)
    {
        NSLog(@"portraitControlView = %@",NSStringFromCGRect(self.portraitControlView.frame));
        [self.landScapeControlView showControlView];
        [self.portraitControlView showControlView];
    }
    self.bottomPgrogress.hidden = YES;
    BOOL isCanVideo = false;
   // if([self.downVideoUrl rangeOfString:@"file://"].location!=NSNotFound){
     //   isCanVideo = true;
   // }
    if (GetAppDelegate.videoPlayMode==2) {
        [self addShareBtn];
        self.portraitControlView.cachesPlayBtn.hidden = YES;
        _btnlink.hidden  = _btnSet.hidden  = _btnShare.hidden = NO;
        _btnSet.hidden  = NO;
       // BOOL ret = ((GetAppDelegate.param4?false:true) && GetAppDelegate.param6)?true:false;
       // _btnJump.hidden = ret;
       // GetAppDelegate.isStatusBarHidden = NO;
        [self.player setStatusBarHidden:YES];
    }
    else{
        self.portraitControlView.cachesPlayBtn.hidden = isCanVideo;
    }
    self.portraitControlView.cachesPlayBtn.hidden = true;

   // self.portraitControlView.backPlayBtn.alpha =
    self.portraitControlView.newsmallBtn.alpha=1;
    //self.portraitControlView.shareBtn.alpha =
}


- (void)hideFixCtrl{
    [self.landScapeControlView hideControlView];
    [self.portraitControlView hideControlView];
    [self updateViewAppeared:false];
    _btnlink.hidden  = _btnSet.hidden  = _btnShare.hidden = YES;
    _btnJump.hidden = YES;
    _btnSet.hidden = YES;
   // GetAppDelegate.isStatusBarHidden = YES;
    self.portraitControlView.backPlayBtn.alpha  = self.portraitControlView.newsmallBtn.alpha=0;
    //self.portraitControlView.shareBtn.alpha
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

- (void)showCoverViewWithUrl:(NSString *)coverUrl{
    [self.coverImageView setImageWithURLString:coverUrl placeholder:[UIImage imageNamed:@"loading_bgView"]];

}

-(void)addVolumeListern
{
    
}

#pragma mark --手势处理
- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self throwFloatClickCallBack];
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
    [self throwFloatClickCallBack];
    [self throwSyncContainerViewFrameCallBack];
}
#pragma mark--MarjorFloatViewDelegate
-(void)throwFloatClickCallBack
{
    if (self.controlViewAppeared) {
        [self hideControlViewWithAnimated:NO];
    } else {
        [self showControlViewWithAnimated:NO];
    }
    self.bottomPgrogress.alpha = 0;
    BOOL isValue =  ((ThrowFloatView*)self.player.smallFloatView).isVerySamll;
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

-(void)throwSyncContainerViewFrameCallBack{
    self.player.containerView.frame = self.player.smallFloatView.frame;
}

- (void)throwHiddenCallBack:(BOOL)withAnimated{
    [self hideFixCtrl];
    //[self hideControlViewWithAnimated:withAnimated];
}

-(void)throwFloatPanBeganCallBack:(ZFPanDirection)direction {
    [self gestureBeganPan:NULL panDirection:direction panLocation:0];
}

-(void)throwFloatPanChangeCallBack:(ZFPanDirection)direction velocity:(CGPoint)location{
    [self gestureChangedPan:NULL panDirection:direction panLocation:0 withVelocity:location];
}

-(void)marjorFloatPanEndCallBack:(ZFPanDirection)direction {
    [self gestureEndedPan:NULL panDirection:direction panLocation:0 ];
}

-(void)throwFloatStopCallBack{
    ((ThrowAssetController*)self.player).closePlay();
}

-(void)throwFloatPauseCallBack{
    id<ZFPlayerMediaPlayback>player = self.player.currentPlayerManager;
    if ([player isPlaying]) {
        [player  pause];
    }
    else{
        [player  play];
    }
}
@end
