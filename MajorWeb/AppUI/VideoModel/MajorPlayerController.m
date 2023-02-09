//
//  MajorPlayerController.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorPlayerController.h"
#import "MarjorFloatView.h"
#import "AppDelegate.h"
#import "MarjorWebConfig.h"
#import "YSCHUDManager.h"
#import "ShareSdkManager.h"
#import "helpFuntion.h"
#import "MajorSystemConfig.h"
#import "VipPayPlus.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "VideoPlayerManager.h"
#define Major_Close_Video_20190725  @"Major_Close_Video_20190725"
#define Major_Close_Video_Times 1
static UIView *viewAdMaskView=nil;
@interface MajorPlayerController()
@end
@implementation MajorPlayerController
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView{
    MajorPlayerController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)addDeviceOrientationObserver {
    if ([MarjorWebConfig getInstance].isPlayVideoAutoRotate) {
        [self.orientationObserver addDeviceOrientationObserver];
    }
}

- (void)removeDeviceOrientationObserver {
    [self.orientationObserver removeDeviceOrientationObserver];
}


- (instancetype)initWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
    MajorPlayerController *player = [self init];
    [player updatePlayerManager:playerManager];
    [player updateContainerView:containerView];
    return player;
}

- (void)showPlayAdAlter{
    if (!viewAdMaskView) {
         viewAdMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        viewAdMaskView.backgroundColor = [UIColor blackColor];
        UIButton *btnVipMask = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        float h = MY_SCREEN_HEIGHT;
        float w = MY_SCREEN_HEIGHT*(1242/2208.0);
        [btnVipMask setFrame:CGRectMake((MY_SCREEN_WIDTH-w)/2, 0, w, h)];
        [btnVipMask setImage:UIImageFromNSBundlePngPath(@"main_load_ad_alter1") forState:UIControlStateNormal];
        [btnVipMask addTarget:self action:@selector(clickAd:) forControlEvents:UIControlEventTouchUpInside];
        [viewAdMaskView addSubview:btnVipMask];
        [[UIApplication sharedApplication].keyWindow addSubview:viewAdMaskView];
        [[VideoPlayerManager getVideoPlayInstance]updatePlayAlpha:0];
        [self.currentPlayerManager pause];
    }
}
-(void)clickAd:(id)sender{
   
    viewAdMaskView.hidden = YES;
    [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
        if (isSuccess) {
            [[helpFuntion gethelpFuntion] isValideOneDay:Major_Close_Video_20190725 nCount:Major_Close_Video_Times isUseYYCache:NO time:nil];
        }
        [viewAdMaskView removeFromSuperview];viewAdMaskView = nil;
        [[VideoPlayerManager getVideoPlayInstance]updatePlayAlpha:1];
        if (self.closePlay) {
            self.closePlay();
        }
    } isShowAlter:YES isForce:false];
}

- (void)closePlayController
{
    //这里加载一天一次,预加载成功已经自动那个视频完成以后才点
    /*if ([VipPayPlus getInstance].systemConfig.vip!=Recharge_User && [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:Major_Close_Video_20190725 nCount:Major_Close_Video_Times isUseYYCache:NO time:nil] && [MajorSystemConfig getInstance].isStartVideoAdLoadfinish && [VipPayPlus getInstance].isPreloadSuccess)
    {
        [self showPlayAdAlter];
    }
    else{*/
        if (self.closePlay) {
            self.closePlay();
        }
    //}
}

-(void)changeReplayMode
{
    if(self.isReplayMode){
        [YSCHUDManager showHUDThenHideOnView:[UIApplication sharedApplication].keyWindow message:@"打开循环播放" afterDelay:1];
    }
    else{
        [YSCHUDManager showHUDThenHideOnView:[UIApplication sharedApplication].keyWindow message:@"关闭循环播放" afterDelay:1];
    }
}

- (void)videoCachesDown{
    if (self.videoDownPlay) {
        self.videoDownPlay();
    }
}

- (void)shareZplayerUrl{
    if (self.sharePlay) {
        self.sharePlay();
    }
}

-(void)intoSamlleController{
    if (self.smallPlay) {
        self.smallPlay();        
    }
}

-(void)intoBackPlayController{
    if (self.backPlay) {
        self.backPlay();
    }
}

-(void)intoLinkPlayController{
    if (self.videoLink) {
        self.videoLink();
    }
}

-(id)init{
    self = [super init];
    return self;
}

-(BOOL)isShowAlter{
#if Debug
    return false;
#endif
#if DoNotKMPLayerCanShareVideo==0
    if ([VipPayPlus getInstance].systemConfig.vip !=Recharge_User &&  [ShareSDK isClientInstalled:SSDKPlatformTypeWechat] && ![MajorSystemConfig getInstance].isOpen && [[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:@"ss_cc_20180615_"nCount:1 intervalDay:7 isUseYYCache:true time:nil])
    {
        //判断第二次点击才用
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int number = [[defaults objectForKey:@"ss_cc_20180615_flag"] intValue];
        if (IF_IPHONE && number>=2) {
            UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"提示" message:@"分享后，才能全屏" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"分享", nil];
            [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==0) {
                    [self showAlter2];
                }
                else if (buttonIndex==1){
                    BOOL ret = [[ShareSdkManager getInstance] isForceShare:SSDKPlatformSubTypeWechatTimeline msg:nil image:nil forceShareBlock:^(BOOL ret) {
                        if (ret) {
                            [super enterFullScreen:YES animated:YES];
                        }
                        else {
                            [self showAlter2];
                        }
                    }];
                    if (!ret) {
                        [super enterFullScreen:YES animated:YES];
                    }
                }
            }];
            return true;
        }
        else{
            [defaults setObject:[NSNumber numberWithInt:number+1] forKey:@"ss_cc_20180615_flag"];
            [defaults synchronize];
        }
    }
    return false;
#else
    return false;
#endif
}

-(void)showAlter2{
    UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"只需要~分享一次" message:@"就可以全屏观看~谢谢，支持~" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"分享", nil];
    [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==0) {
            
        }
        else if (buttonIndex==1){
            BOOL ret = [[ShareSdkManager getInstance] isForceShare:SSDKPlatformSubTypeWechatTimeline msg:nil image:nil forceShareBlock:^(BOOL ret) {
                if (ret) {
                    [super enterFullScreen:YES animated:YES];
                }
                else {
                    [self showAlter2];
                }
            }];
            if (!ret) {
                [super enterFullScreen:YES animated:YES];
            }
        }
    }];
}


-(void)webPushLand{
    [super enterFullScreen:true animated:true];
    [self setStatusBarHidden:true];
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if (fullScreen) {
        if([self isShowAlter]){
            
        }
        else{
            [super enterFullScreen:fullScreen animated:animated];
            [self setStatusBarHidden:true];
        }
    }
    else{
        [super enterFullScreen:fullScreen animated:animated];
        [self setStatusBarHidden:false];
    }
}

- (ZFFloatView *)smallFloatView {
    MarjorFloatView *smallFloatView = objc_getAssociatedObject(self, _cmd);
    if (!smallFloatView) {
        smallFloatView = [[MarjorFloatView alloc] init];
        smallFloatView.parentView = GetAppDelegate.window;//[UIApplication sharedApplication].keyWindow;
        smallFloatView.hidden = YES;
        self.smallFloatView = smallFloatView;
    }
    if (GetAppDelegate.videoPlayMode != 2) {
        smallFloatView.parentView = GetAppDelegate.window;//[UIApplication sharedApplication].keyWindow;
    }
    else{
        smallFloatView.parentView = GetAppDelegate.getRootCtrlView;
    }
    return smallFloatView;
}

@end
