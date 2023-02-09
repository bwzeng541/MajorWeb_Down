//
//  ZFIJKPlayerManager.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFIJKPlayerManager.h"
#if __has_include(<ZFPlayer/ZFPlayer.h>)
#import <ZFPlayer/ZFPlayer.h>
#else
#import "ZFPlayer.h"
#endif
#if __has_include(<IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>)

@interface ZFIJKPlayerManager ()
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) IJKFFOptions *options;
@property (nonatomic, assign) CGFloat lastVolume;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) CGSize videoSize;

@end

@implementation ZFIJKPlayerManager
@synthesize view                           = _view;
@synthesize currentTime                    = _currentTime;
@synthesize totalTime                      = _totalTime;
@synthesize playerPlayTimeChanged          = _playerPlayTimeChanged;
@synthesize playerBufferTimeChanged        = _playerBufferTimeChanged;
@synthesize playerDidToEnd                 = _playerDidToEnd;
@synthesize bufferTime                     = _bufferTime;
@synthesize playState                      = _playState;
@synthesize loadState                      = _loadState;
@synthesize assetURL                       = _assetURL;
@synthesize playerPrepareToPlay            = _playerPrepareToPlay;
@synthesize playerReadyToPlay              = _playerReadyToPlay;
@synthesize playerPlayStatChanged          = _playerPlayStatChanged;
@synthesize playerLoadStatChanged          = _playerLoadStatChanged;
@synthesize playerReferer                  = _playerReferer;
@synthesize presentationSizeChanged            = _presentationSizeChanged;

@synthesize seekTime                       = _seekTime;
@synthesize muted                          = _muted;
@synthesize volume                         = _volume;
@synthesize presentationSize               = _presentationSize;
@synthesize isPlaying                      = _isPlaying;
@synthesize rate                           = _rate;
@synthesize isPreparedToPlay               = _isPreparedToPlay;
@synthesize scalingMode                    = _scalingMode;
@synthesize playerPlayFailed               = _playerPlayFailed;

- (void)dealloc {
    [self stop];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scalingMode = ZFPlayerScalingModeAspectFit;
    }
    return self;
}

- (void)prepareToPlay {
    if (!_assetURL) return;
    _isPreparedToPlay = YES;
    [self initializePlayer];
    self.loadState = ZFPlayerLoadStatePrepare;
    if (self.playerPrepareToPlay) self.playerPrepareToPlay(self, self.assetURL);
}

- (void)reloadPlayer {
    [self prepareToPlay];
}

- (void)play {
    if (!_isPreparedToPlay) {
        [self prepareToPlay];
    } else {
        [self.player play];
        self.player.playbackRate = self.rate;
        _isPlaying = YES;
        self.playState = ZFPlayerPlayStatePlaying;
    }
}

- (void)pause {
    [self.player pause];
    _isPlaying = NO;
    self.playState = ZFPlayerPlayStatePaused;
}

- (void)stop {
    [self removeMovieNotificationObservers];
    self.playState = ZFPlayerPlayStatePlayStopped;
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    self.player = nil;
    _assetURL = nil;
    [self.timer invalidate];
    
    self.timer = nil;
    _isPlaying = NO;
    _isPreparedToPlay = NO;
    self->_currentTime = 0;
    self->_totalTime = 0;
    self->_bufferTime = 0;
}

- (void)replay {
    @weakify(self)
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        @strongify(self)
        [self play];
    }];
}

/// Replace the current playback address
- (void)replaceCurrentAssetURL:(NSURL *)assetURL {
    self.assetURL = assetURL;
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    self.player.currentPlaybackTime = time;
    if (completionHandler) completionHandler(YES);
}

- (UIImage *)thumbnailImageAtCurrentTime {
    return [self.player thumbnailImageAtCurrentTime];
}

#pragma mark - private method


-(NSArray*)getTracks{
    return nil;
}

-(id)getManagerAVPlayer{
    return nil;
}
- (void)initializePlayer {
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.assetURL withOptions:self.options];
    [self.player prepareToPlay];
    self.player.shouldAutoplay = NO;
    
    [self.view insertSubview:self.player.view atIndex:1];
    self.player.view.frame = self.view.bounds;
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scalingMode = _scalingMode;
    [self addPlayerNotificationObservers];
}

- (void)addPlayerNotificationObservers {
    /// 准备播放
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    /// 播放完成或者用户退出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    /// 准备开始播放了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    /// 播放状态改变了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieNatureSizeAvailable:)
                                                 name:IJKMPMovieNaturalSizeAvailableNotification
                                               object:_player];
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMovieNaturalSizeAvailableNotification
                                                  object:_player];
}

- (void)update {
    if(self.player.currentPlaybackTime >0 && !isnan(self.player.currentPlaybackTime))
    self->_currentTime = self.player.currentPlaybackTime;
    else{
        self->_currentTime = 0;
    }
    self->_totalTime = self.player.duration;
    self->_bufferTime = self.player.playableDuration;
    if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(self, self.currentTime, self.totalTime);
    if (self.playerBufferTimeChanged) self.playerBufferTimeChanged(self, self.bufferTime);
}

#pragma - notification

/// 播放完成
- (void)moviePlayBackFinish:(NSNotification *)notification {
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded: {
            ZFPlayerLog(@"playbackStateDidChange: 播放完毕: %d\n", reason);
            self.playState = ZFPlayerPlayStatePlayStopped;
            if (self.playerDidToEnd) self.playerDidToEnd(self);
        }
            break;
            
        case IJKMPMovieFinishReasonUserExited: {
            ZFPlayerLog(@"playbackStateDidChange: 用户退出播放: %d\n", reason);
        }
            break;
            
        case IJKMPMovieFinishReasonPlaybackError: {
            ZFPlayerLog(@"playbackStateDidChange: 播放出现错误: %d\n", reason);
            self.playState = ZFPlayerPlayStatePlayFailed;
            if (self.playerPlayFailed) self.playerPlayFailed(self, @(reason));
        }
            break;
            
        default:
            ZFPlayerLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

// 准备开始播放了
- (void)mediaIsPreparedToPlayDidChange:(NSNotification *)notification {
    ZFPlayerLog(@"加载状态变成了已经缓存完成，如果设置了自动播放, 会自动播放");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loadState = ZFPlayerLoadStatePlaythroughOK;
    });
    if (self.isPlaying) {
        [self play];
        self.muted = self.muted;
        if (self.seekTime) {
            [self seekToTime:self.seekTime completionHandler:nil];
            self.seekTime = 0; // 滞空, 防止下次播放出错
            [self play];
        }
    }
    ZFPlayerLog(@"mediaIsPrepareToPlayDidChange");
    if (self.playerPrepareToPlay) self.playerReadyToPlay(self, self.assetURL);
}


#pragma mark - 加载状态改变
/**
 视频加载状态改变了
 IJKMPMovieLoadStateUnknown == 0
 IJKMPMovieLoadStatePlayable == 1
 IJKMPMovieLoadStatePlaythroughOK == 2
 IJKMPMovieLoadStateStalled == 4
 */
- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlayable)) {
        ZFPlayerLog(@"加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全");
        self.loadState = ZFPlayerLoadStatePlayable;
    } else if ((loadState & IJKMPMovieLoadStatePlaythroughOK)) {
        self.loadState = ZFPlayerLoadStatePlaythroughOK;
        // 加载完成，即将播放，停止加载的动画，并将其移除
        ZFPlayerLog(@"加载状态变成了已经缓存完成，如果设置了自动播放, 会自动播放");
    } else if ((loadState & IJKMPMovieLoadStateStalled)) {
        // 可能由于网速不好等因素导致了暂停，重新添加加载的动画
        ZFPlayerLog(@"网速不好等因素导致了暂停");
        self.loadState = ZFPlayerLoadStateStalled;
    } else {
        ZFPlayerLog(@"加载状态变成了未知状态");
        self.loadState = ZFPlayerLoadStateUnknown;
    }
}

- (void)movieNatureSizeAvailable:(NSNotification*)notification{
    if(!CGSizeEqualToSize(_videoSize, self.player.naturalSize)){
        _videoSize = self.player.naturalSize;
        if (self.presentationSizeChanged) {
            self.presentationSizeChanged(_videoSize);
        }
    }
}

// 播放状态改变
- (void)moviePlayBackStateDidChange:(NSNotification *)notification {
    if (notification.object!=self.player) {
        return;
    }
    if (self.player.playbackState == IJKMPMoviePlaybackStatePlaying) {
        // 视频开始播放的时候开启计时器
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }

    NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
    switch (self.player.playbackState) {
        case IJKMPMoviePlaybackStateStopped: {
            ZFPlayerLog(@"播放器的播放状态变了，现在是停止状态 %d: stoped", (int)_player.playbackState);
            // 这里的回调也会来多次(一次播放完成, 会回调三次), 所以, 这里不设置
            self.playState = ZFPlayerPlayStatePlayStopped;
        }
            break;
            
        case IJKMPMoviePlaybackStatePlaying: {
            ZFPlayerLog(@"播放器的播放状态变了，现在是播放状态 %d: playing", (int)_player.playbackState);
            self.playState = ZFPlayerPlayStatePlaying;
            if (self.seekTime) {
                [self seekToTime:self.seekTime completionHandler:nil];
                self.seekTime = 0; // 滞空, 防止下次播放出错
                [self play];
            }
            if (!self.timer) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            }
        }
            break;
            
        case IJKMPMoviePlaybackStatePaused: {
            ZFPlayerLog(@"播放器的播放状态变了，现在是暂停状态 %d: paused", (int)_player.playbackState);
        }
            break;
            
        case IJKMPMoviePlaybackStateInterrupted: {
            ZFPlayerLog(@"播放器的播放状态变了，现在是中断状态 %d: interrupted", (int)_player.playbackState);
        }
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward: {
            ZFPlayerLog(@"播放器的播放状态变了，现在是向前拖动状态:%d forward",(int)self.player.playbackState);
        }
            break;
        case IJKMPMoviePlaybackStateSeekingBackward: {
            ZFPlayerLog(@"放器的播放状态变了，现在是向后拖动状态 %d: backward", (int)_player.playbackState);
        }
            break;
            
        default: {
            ZFPlayerLog(@"播放器的播放状态变了，现在是未知状态 %d: unknown", (int)_player.playbackState);
        }
            break;
    }
}


#pragma mark - getter

- (UIView *)view {
    if (!_view) {
        _view = [[ZFPlayerView alloc] init];
        _view.backgroundColor = [UIColor blackColor];
    }
    return _view;
}

- (float)rate {
    return _rate == 0 ?1:_rate;
}

- (IJKFFOptions *)options {
    if (!_options) {
        _options = [IJKFFOptions optionsByDefault];
        /// 精准seek
        [_options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        NSString *userApp = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1";
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        [IJKFFMoviePlayerController setLogReport:NO];
#if DEBUG
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_ERROR];
#endif
        [_options setFormatOptionValue:userApp  forKey:@"user-agent"];
       /* [_options setFormatOptionValue:@"GET"  forKey:@":method"];
        [_options setFormatOptionValue:@"proxyunblock.site"  forKey:@":authority"];
        [_options setFormatOptionValue:@"https"  forKey:@":scheme"];
        [_options setFormatOptionValue:@"0"  forKey:@"range"];
        [_options setFormatOptionValue:@"/Unblock.php?q=odrX09WfYmHTY19ij9jUYG6en8bNoZ3Sk5vTop7NydmiysjSkMiin5Com5nH1Nafmq-TwsWepc_JcchrbpWayG-el8mblZZrkmNYntbGzXBqblfU0ajYycpx3aKs1dnFnozVyNPanKTGpaWhn97Lpl-jnp6VZJKYm1rRoXTU0pBuztHIzdNqno2loGKWzJuYnaSW2oig2aPGqZCipdOK0K-j0InS0XBmmViXnp-amaCFjoGXyHvWnMxsy4KclK_doKnaidXappWeq6Zby9PPp5ytn8XEo9mjmmyYZGmWlImmz9DIn9uclsahYaLSmYyaoqhu2semjMnRmdJwb5aYnHGamJOI15SmxpSrpcPY2XCym6SHxqjYo5ZtlmlllZqZX9LQ15-WaGeTZmlqlZqfZW5taZSXWdPaomWZaGmXmJdtmZaJyNucop5jWJfHzsqmdm9ll5honp6Ll6GKfKOK17HWoJiXmGRmlGRYntKimJRpaGuVmWuWoJ1ulm1xlorMqcjM19WiY1jGqqKe1MqjZG5rY5eYaZeemFrXo5jTxdCso8zTjs6jlMqmpWHH3dacq5tdysZfz9rGm5CmptbWxp6S1cjT2pykxqWloY7S01-mpF3O1V_T3JGk0F-cypDWrtnGj8vTnKbEqaCZxNXZX6afnsaOms_YkZfQmKWN1sSty8Xc0sampY2Wp6eO0dOnX6mayNCU2tvXmaFse5icm2ydk6iknXd2pHhmd5iZp2xwenSipHWpq6lkpmxwmaiVfaeTkaOVeGKSZml5m5ardn9scpKaZp6cqWWcaHuSm6h-rJmTpqtka5FkammI0Musdq-lmQ" forKey:@"path"];
        
        [_options setFormatOptionValue:@"https://proxyunblock.site/Unblock.php?q=odrX09WfYmHYqalj29Tbp66Ylo_FotOV3JXYlp-g2qBrrrXYw6pgg9qEdw" forKey:@"referer"];*/
        //增加以下代码，可以本地资源可以
        [_options setFormatOptionValue:@"crypto,http,tcp,https,tls,file,cache" forKey:@"protocol_whitelist"];
        [_options setPlayerOptionValue:@"file,http,https,cache" forKey:@"protocol_whitelist"];
        _options.showHudView = NO;
    }
    return _options;
}

#pragma mark - setter

- (void)setPlayState:(ZFPlayerPlaybackState)playState {
    _playState = playState;
    if (self.playerPlayStatChanged) self.playerPlayStatChanged(self, playState);
}

- (void)setLoadState:(ZFPlayerLoadState)loadState {
    _loadState = loadState;
    if (self.playerLoadStatChanged) self.playerLoadStatChanged(self, loadState);
}

- (void)setAssetURL:(NSURL *)assetURL {
    if (self.player) [self stop];
    _assetURL = assetURL;
    [self prepareToPlay];
}

- (void)setRate:(float)rate {
    _rate = rate;
    if (self.player && fabsf(_player.playbackRate) > 0.00001f) {
        self.player.playbackRate = rate;
    }
}

- (void)setMuted:(BOOL)muted {
    /*_muted = muted;
    if (muted) {
        self.lastVolume = self.player.playbackVolume;
        self.player.playbackVolume = 0;
    } else {
        /// Fix first called the lastVolume is 0.
        if (self.lastVolume == 0) self.lastVolume = self.player.playbackVolume;
        self.player.playbackVolume = self.lastVolume;
    }*/
}

- (void)setScalingMode:(ZFPlayerScalingMode)scalingMode {
    _scalingMode = scalingMode;
    switch (scalingMode) {
        case ZFPlayerScalingModeNone:
            self.player.scalingMode = IJKMPMovieScalingModeNone;
            break;
        case ZFPlayerScalingModeAspectFit:
            self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
            break;
        case ZFPlayerScalingModeAspectFill:
            self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
            break;
        case ZFPlayerScalingModeFill:
            self.player.scalingMode = IJKMPMovieScalingModeFill;
            break;
        default:
            break;
    }
}

- (void)setVolume:(float)volume {
    _volume = MIN(MAX(0, volume), 1);
    self.player.playbackVolume = volume;
}

@end

#endif
