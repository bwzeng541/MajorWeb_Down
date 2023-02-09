//
//  MajorThumbnail.m
//  WatchApp
//
//  Created by zengbiwang on 2017/12/22.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "MajorThumbnail.h"
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "ZFUtilities.h"
#import "MajorPlayerController.h"
#import "MajorVideoControlView.h"
#import "POP.h"
static float audioVolume = 0;
@interface MajorThumbnailCtrlView : ZFPlayerControlView

@end

@implementation MajorThumbnailCtrlView
-(void)addAllSubViews{
    
}
@end
@interface MajorThumbnail(){
    id<IJKMediaPlayback> _ijkPlayrCtrl;
    NSString *_tmpVideoUrl;
    bool isSetPlayNil;
    UILabel *sizelable;
    CGSize videoSize;
}
@property(weak)id<MajorThumbnailDelegate>delegate;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
//@property(strong)VideoWebView *webVideo;
@property(assign)float videoTime;
@property(copy)NSString *webUrl;
@property(copy)NSString *title;
@property(copy)NSString* tmpVideoUrl;
@property(strong)UILabel *labelDes;
@end
@implementation MajorThumbnail
@synthesize videoUrl;

-(void)dealloc{
    
    NSLog(@"%s",__FUNCTION__);
}

-(ZFPlayerControlView*)controlView{
    if (!_controlView) {
        _controlView = [MajorThumbnailCtrlView new];
        UIImage *image = ZFPlayer_Image(@"loading_1");
        _controlView.placeholderImage = image;
    }
    return _controlView;
}

-(void)updateSize{
    [_player.currentPlayerManager.view pop_removeAllAnimations];
    POPBasicAnimation *ba = [POPBasicAnimation animationWithPropertyNamed:kPOPViewSize];
    CGSize size = _player.currentPlayerManager.view.frame.size;
    ba.fromValue = [NSValue valueWithCGSize:size];
    ba.beginTime = CACurrentMediaTime();
    ba.toValue = [NSValue valueWithCGSize:CGSizeMake(size.width*1, size.height*1)];
    [_player.currentPlayerManager.view pop_addAnimation:ba forKey:nil];
}

-(void)addZFAVPlayerInterface{

    id<ZFPlayerMediaPlayback> playerManager = [[ZFAVPlayerManager alloc] init];
    CGSize viewSize = self.bounds.size;
    float w = viewSize.width;
    float h = w*0.56;
    UIView*videoView =  [[UIView alloc]initWithFrame:CGRectMake(0, (viewSize.height-h)/2, w, h)];
    //16:9的方式d调整视图
    self.player = [MajorPlayerController playerWithPlayerManager:playerManager containerView:videoView];
    self.player.controlView = self.controlView;
    self.player.WWANAutoPlay = YES;
    self.player.shouldAutoPlay = YES;
    self.player.allowOrentitaionRotation = NO;
    [self addSubview:videoView];
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
    self.player.currentPlayerManager.view.userInteractionEnabled = NO;
    @weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
    };
    self.player.presentationSizeChanged = ^(CGSize presentSize) {
        @strongify(self)
        self->videoSize = presentSize;
        self->sizelable.text = [NSString stringWithFormat:@"分辨率:%0.0fX%0.0f",presentSize.width,presentSize.height];
        NSLog(@"majorThumbnail 86= %@  ",NSStringFromCGSize(presentSize))  ;
    };
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        @strongify(self)
        [self unInitPlayer];
        if ([self.delegate respondsToSelector:@selector(pipePreFail)]){
            NSLog(@"faild videoUrl = %@",self.tmpVideoUrl);
            if (self.isShowWeb) {
                [self addWebVideo];
            }
            else{
                [self.delegate pipePreFail];
            }
        }
    };
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        [self updateSize];
    };
    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)
        [self updateTime:duration];
    };
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(pipeIsMute)] && [self.delegate pipeIsMute]){
            [self.player.currentPlayerManager setVolume:0];
        }
        else{
            audioVolume = self.player.volume;
        }
    };
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        
    };
    self.player.assetURL = [NSURL URLWithString:self.tmpVideoUrl];
}

-(void)addIjkInterface {
    _ijkPlayrCtrl = [[IJKAVMoviePlayerController alloc]initWithContentURLString:self.tmpVideoUrl];
    _ijkPlayrCtrl.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _ijkPlayrCtrl.view.frame = self.bounds;
    _ijkPlayrCtrl.scalingMode = IJKMPMovieScalingModeAspectFit;
    _ijkPlayrCtrl.shouldAutoplay = YES;
    [_ijkPlayrCtrl setPauseInBackground:true];
    [self addSubview:_ijkPlayrCtrl.view];
    [self installMovieNotificationObservers];
    [_ijkPlayrCtrl prepareToPlay];
}

-(instancetype)initWith:(NSString*)webUrl videoUrl:(NSString*)videoUrl title:(NSString*)title frame:(CGRect)frame isAddWebVideo:(BOOL)isAddWebVideo delegate:(id<MajorThumbnailDelegate>)delegate{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    _tmpVideoUrl = [[NSString alloc]initWithString:videoUrl];
    self.delegate = delegate;
    self.tmpVideoUrl = videoUrl;
    self.webUrl = webUrl;
    self.title = title;
    if (isAddWebVideo) {
        [self addWebVideo];
    }
    else{//需要修改成ZFPlayer接口，少加载一次数据可以
        //[self addIjkInterface];
        [self addZFAVPlayerInterface];
        isSetPlayNil = false;
        self.labelDes = [[UILabel alloc]init];
        self.labelDes.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.labelDes.frame = self.bounds;
        [self addSubview:self.labelDes];
        self.labelDes.textAlignment = NSTextAlignmentCenter;
        self.labelDes.textColor = [UIColor whiteColor];
        self.labelDes.text = @" ";
        float hw = 20;
        [self addMaskView:CGRectMake(0, 0, self.bounds.size.width, hw)];
        [self addMaskView:CGRectMake(0, self.bounds.size.height-15-hw, self.bounds.size.width, hw)];
       // [self addMaskView:CGRectMake(0,0, hw, self.bounds.size.height)];
       // [self addMaskView:CGRectMake(0,self.bounds.size.width-hw, hw, self.bounds.size.height)];
        
    }
    return self;
}

-(void)addMaskView:(CGRect)rect{
    UIView *v = [[UIView alloc] initWithFrame:rect];
    [self addSubview:v];
    v.backgroundColor = [UIColor blackColor];
}

-(ZFPlayerController*)getZFAVPlayerInterface{
    [self.player.currentPlayerManager setVolume:audioVolume];
    return self.player;
}

-(id<IJKMediaPlayback>)getPlayInterface{
    return _ijkPlayrCtrl;
}

-(void)updateMuteState{
    [self.player.currentPlayerManager setVolume:0];
}


-(void)setZFAVPlayerInterfaceNil{
    isSetPlayNil = true;
    _player = nil;
   // [self.player updatePlayerManager:nil];
}

-(void)setPlayInterfaceNil{
    [_ijkPlayrCtrl pause];
    [self removeMovieNotificationObservers];
    [_ijkPlayrCtrl.view removeFromSuperview];
    isSetPlayNil = true;
}

-(void)removeFromSuperview{
    [self unInitPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

-(void)play{
    if (!isSetPlayNil)
        [_ijkPlayrCtrl play];
}

-(void)stop{
    if (!isSetPlayNil)
        [_ijkPlayrCtrl stop];
    // RemoveViewAndSetNil(self.webVideo)
}

-(void)unInitPlayer{
    [self removeMovieNotificationObservers];
    if (!isSetPlayNil || _ijkPlayrCtrl) {
        [_ijkPlayrCtrl shutdown];
        [_ijkPlayrCtrl.view removeFromSuperview];
        _ijkPlayrCtrl = nil;
    }
    if (!isSetPlayNil || _player) {
        [_player stop];
        self.controlView = nil;
        self.player = nil;
    }
}

-(void)addWebVideo{
    
}

-(void)playFromWeb{
    if ([self.delegate respondsToSelector:@selector(pipePlayFromWebSuccess:)]) {
        [self.delegate pipePlayFromWebSuccess:self];
    }
}

-(void)clickPlay:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(pipeClickPlay)]) {
        [self.delegate pipeClickPlay];
    }
}

-(void)updateTime:(float)duration{
    if (![self viewWithTag:1000]) {
        
        RemoveViewAndSetNil(self.labelDes)
        RemoveViewAndSetNil(sizelable)
        //267 X62
        float btnW = 267,btnH = 62,lableH = 30;
        if (IF_IPHONE) {
            btnW/=2;
            btnH/=2;
            lableH = 23;
        }
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:playBtn];
        playBtn.frame = CGRectMake((self.bounds.size.width-btnW)/2, (self.bounds.size.height-btnH)/2, btnW, btnH);
        playBtn.tag = 1000;
        [playBtn setImage:UIImageFromNSBundlePngPath(@"thumBnail_play") forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
        CGSize size = self.bounds.size;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height-lableH, size.width, lableH)];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = RGBACOLOR(0, 0, 0, 255*0.8);
        //左下角title
          UILabel *  labelText = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height-lableH, size.width, lableH)];
            labelText.textColor = [UIColor whiteColor];
            labelText.backgroundColor = [UIColor clearColor];
            labelText.text = [NSString stringWithFormat:@"▲线路:%@",self.title];
            labelText.font = [UIFont systemFontOfSize:14];
        
        int hh = (int)duration/3600;
        int mm = (((int)duration)-(hh)*3600)/60;
        int ss =  (int)(duration-hh*3600) % 60;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"总时间%02d:%02d:%02d", hh, mm,ss];
        label.font = [UIFont systemFontOfSize:IF_IPHONE?20:30];
        label.textColor = [UIColor redColor];
        [self addSubview:label];
        [self addSubview:labelText];
        
        sizelable  = [[UILabel alloc] initWithFrame:labelText.frame];
        sizelable.textAlignment = NSTextAlignmentRight;
        sizelable.font = [UIFont systemFontOfSize:14];
        sizelable.textColor =  [UIColor greenColor];
        [self addSubview:sizelable];
        sizelable.text = [NSString stringWithFormat:@"分辨率:%0.0fX%0.0f",videoSize.width,videoSize.height];

        videoUrl = _tmpVideoUrl;//fix 判断duration是否为直播
        if ((isnan(duration) || duration > 600) && [self.delegate respondsToSelector:@selector(pipePreSuccess:)]) {
            NSLog(@"playOK videoUrl = %@",_tmpVideoUrl);
            self.videoTime = duration;
            [self.delegate pipePreSuccess:isnan(duration)];
            if (self.videoTime>0) {
                [self.player seekToTime:self.videoTime*0.6 completionHandler:^(BOOL finished) {
                }];
            }
        }
        else if((isnan(duration) || duration <= 600) && [self.delegate respondsToSelector:@selector(pipePreShortSuccess)]){
            [self.delegate pipePreShortSuccess];
        }
    }
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_ijkPlayrCtrl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_ijkPlayrCtrl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_ijkPlayrCtrl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_ijkPlayrCtrl];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_ijkPlayrCtrl];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_ijkPlayrCtrl];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_ijkPlayrCtrl];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_ijkPlayrCtrl];
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    if (notification.object!=_ijkPlayrCtrl) {
        return;
    }
    switch (_ijkPlayrCtrl.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlaybackStateStopped");
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlaybackStatePlaying");
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlaybackStatePaused");
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlaybackStateInterrupted");
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlaybackStateSeekingBackward");
            break;
        }
        default: {
            break;
        }
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    if (notification.object!=_ijkPlayrCtrl) {
        return;
    }
    RemoveViewAndSetNil(self.labelDes)
    if([self.delegate respondsToSelector:@selector(pipeIsMute)] && [self.delegate pipeIsMute]){
        _ijkPlayrCtrl.playbackVolume = 0;
    }
    [self updateTime:_ijkPlayrCtrl.duration];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    if (notification.object!=_ijkPlayrCtrl) {
        return;
    }
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            [self unInitPlayer];
            if ([self.delegate respondsToSelector:@selector(pipePreFail)]){
                NSLog(@"faild videoUrl = %@",self.tmpVideoUrl);
                if (self.isShowWeb) {
                    [self addWebVideo];
                }
                else{
                    [self.delegate pipePreFail];
                }
            }
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    if (notification.object!=_ijkPlayrCtrl) {
        return;
    }
    IJKMPMovieLoadState loadState = _ijkPlayrCtrl.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {//缓冲结束
        
    }
    else if ((loadState & IJKMPMovieLoadStateStalled) != 0) { //缓冲开始
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    }
    else if((loadState & IJKMPMovieLoadStatePlayable) != 0)
    {
        
    }
    else
    {
    }
}
@end
