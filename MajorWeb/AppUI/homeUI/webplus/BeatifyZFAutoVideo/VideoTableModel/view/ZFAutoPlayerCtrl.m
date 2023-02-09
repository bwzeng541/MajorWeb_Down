//
//  ZFAutoPlayerCtrl.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ZFAutoPlayerCtrl.h"
#import "ThrowFloatView.h"
#import "helpFuntion.h"
#import <ShareSDK/ShareSDK.h>
//#import "BeatfiyShare.h"
#import "UIAlertView+NSCookbook.h"
#import "AppDelegate.h"
#import "BeatifyAssetControlView.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>
@implementation ZFAutoPlayerCtrl

- (ZFFloatView *)smallFloatView {
    ZFFloatView *smallFloatView = objc_getAssociatedObject(self, _cmd);
    if (!smallFloatView) {
        smallFloatView = [[ThrowFloatView alloc] init];
        smallFloatView.parentView = [UIApplication sharedApplication].keyWindow;
        smallFloatView.hidden = YES;
        self.smallFloatView = smallFloatView;
    }
    return smallFloatView;
}

-(void)fixSomeControl{
    BeatifyAssetControlView *v = (BeatifyAssetControlView*)self.controlView;
    v.portraitControlView.newcloseBtn.hidden =
    v.portraitControlView.backPlayBtn.hidden =
    v.portraitControlView.backBtn.hidden =
    v.portraitControlView.shareBtn.hidden =
    v.portraitControlView.newsmallBtn.hidden = true;
    v.bottomPgrogress.alpha = 0;
    v.portraitControlView.bottomToolView.hidden = YES;
    v.portraitControlView.scBtn.alpha = 1;
    v.portraitControlView.newbackBtn.hidden = NO;//GetAppDelegate.param4?false:true;
    [v removeFixBtn];
}

-(void)intoLinkPlayController{
    if (self.videoLink) {
        self.videoLink();
    }
}

- (void)assetsc{
    if (self.videoSc) {
        self.videoSc();
    }
}

+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView
{
    ZFAutoPlayerCtrl *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    self = [super initWithScrollView:scrollView playerManager:playerManager containerViewTag:containerViewTag];
    return self;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag{
    ZFAutoPlayerCtrl *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerViewTag:containerViewTag];
    return player;
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if(fullScreen){
        if([self isAlter]){
            
        }
        else{
            [super enterFullScreen:fullScreen animated:animated];
        }
    }
    else{
        [super enterFullScreen:fullScreen animated:animated];
    }
}

-(BOOL)isAlter{
    return false;/*
    if ([ShareSDK isClientInstalled:SSDKPlatformTypeWechat] &&  [[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:ForceShareApp nCount:1 intervalDay:7 isUseYYCache:true time:nil]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int number = [[defaults objectForKey:ForceShareAppTimes] intValue];
        if (IF_IPHONE && number>=2) {
            UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"提示" message:@"分享后，才能全屏" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"分享", nil];
            [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==0) {
                    [self showAlter2];
                }
                else if (buttonIndex==1){
                    BOOL ret = [[BeatfiyShare getInstance] isForceShare:SSDKPlatformSubTypeWechatTimeline msg:nil image:nil forceShareBlock:^(BOOL ret) {
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
            [defaults setObject:[NSNumber numberWithInt:number+1] forKey:ForceShareAppTimes];
            [defaults synchronize];
        }
    }
    return false;*/
}

-(void)showAlter2{/*
    UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"只需要~分享一次" message:@"就可以全屏观看~谢谢，支持~" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"分享", nil];
    [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==0) {
            
        }
        else if (buttonIndex==1){
            BOOL ret = [[BeatfiyShare getInstance] isForceShare:SSDKPlatformSubTypeWechatTimeline msg:nil image:nil forceShareBlock:^(BOOL ret) {
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
    }];*/
}
@end
