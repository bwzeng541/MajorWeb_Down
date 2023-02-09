
#import "WebPushVideoControlView.h"
#import "ZFAVPlayerManager.h"
#import "VideoPlayerManager.h"
#import "POP.h"
@interface WebPushVideoControlView ()
/// 封面图
@property (nonatomic, strong) ZFSliderView *sliderView;
/// 加载loading
@property (nonatomic, copy)NSString *url;
@end

@implementation WebPushVideoControlView
@synthesize player = _player;

- (void)dealloc{
    [[VideoPlayerManager getVideoPlayInstance] webPushPlay:nil title:nil webPushBlock:nil];
}

- (void)resetControlView {
    self.portraitControlView.alpha = 0;
    self.landScapeControlView.alpha = 0;
    [super resetControlView];
}

- (void)showControlViewWithAnimated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:animated?ZFPlayerControlViewAutoFadeOutTimeInterval:0 animations:^{
        } completion:^(BOOL finished) {
            [self autoFadeOutControlView];
        }];
    }
    else{
         [self autoFadeOutControlView];
    }
}

-(void)intoFull:(BOOL)isFull title:(NSString *)title{
    if (isFull) {
        self.url = [self.player.currentPlayerManager.assetURL absoluteString];
        CGSize size = self.player.currentPlayerManager.presentationSize;
        NSString *title1 = title?title:@"";
        [[self.player currentPlayerManager]stop];
        __weak __typeof(self)weakSelf = self;
        [[VideoPlayerManager getVideoPlayInstance] webPushPlay:self.url title:title1 webPushBlock:^{
            [weakSelf intoFull:false title:@""];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[VideoPlayerManager getVideoPlayInstance] webPushLand:size];
        });
        self.player.currentPlayerManager.view.hidden = YES;
    }
    else{
        self.player.currentPlayerManager.view.hidden = NO;
        self.player.assetURL = [NSURL URLWithString:self.url];
    }
}

-(void)updateWebMode{
    [_player.currentPlayerManager.view pop_removeAllAnimations];
    POPBasicAnimation *ba = [POPBasicAnimation animationWithPropertyNamed:kPOPViewSize];
    ba.fromValue = [NSValue valueWithCGSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    ba.beginTime = CACurrentMediaTime();
    if (self.webPlayMode==WebPush_Small_Mode) {
        ba.toValue = [NSValue valueWithCGSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    }
    else if (self.webPlayMode==WebPush_Defualt_Mode){
        if (IF_IPAD) {
            ba.toValue = [NSValue valueWithCGSize:CGSizeMake(MY_SCREEN_WIDTH*1.5, MY_SCREEN_HEIGHT*1.5)];
        }
        else{
           ba.toValue = [NSValue valueWithCGSize:CGSizeMake(MY_SCREEN_WIDTH*1.5, MY_SCREEN_HEIGHT*1.5)];
        }
    }
    else if(self.webPlayMode==WebPush_DouYin_Mode){
        if (IF_IPAD) {
            ba.toValue = [NSValue valueWithCGSize:CGSizeMake(MY_SCREEN_WIDTH*2, MY_SCREEN_HEIGHT*2)];
        }
        else{
            ba.toValue = [NSValue valueWithCGSize:CGSizeMake(MY_SCREEN_WIDTH*2.5, MY_SCREEN_HEIGHT*2.5)];
        }
    }
    ba.duration = 0.0;
    [_player.currentPlayerManager.view pop_addAnimation:ba forKey:nil];
}

-(void)updatePlayMode:(WebPushPlayMode)webPlayMode{
    self.webPlayMode = webPlayMode;
    [self updateWebMode];
}

- (void)hideControlViewWithAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated?ZFPlayerControlViewAutoFadeOutTimeInterval:0 animations:^{
       
    } completion:^(BOOL finished) {
     
    }];
}

- (void)gestureChangePinch:(ZFPlayerGestureControl *)gestureControl
                     scale:(float)scale{
}

-(void)gesturePinched:(ZFPlayerGestureControl *)gestureControl scale:(float)scale{

}
@end
