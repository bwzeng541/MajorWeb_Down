#import "ThrowAssetController.h"
#import "ThrowFloatView.h"
#import "AppDelegate.h"
#import "helpFuntion.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "UIAlertView+NSCookbook.h"
//#import "BeatfiyShare.h"


@interface ThrowAssetController()
@end
@implementation ThrowAssetController
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView{
    ThrowAssetController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)addDeviceOrientationObserver {
    [super addDeviceOrientationObserver];
}

- (void)removeDeviceOrientationObserver {
    [super removeDeviceOrientationObserver];
 }


- (instancetype)initWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
    ThrowAssetController *player = [self init];
    [player updatePlayerManager:playerManager];
    [player updateContainerView:containerView];
    return player;
}

- (void)closePlayController
{
    if (self.closePlay) {
        self.closePlay();
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



-(BOOL)isAlter{
    return false;
    /*
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

-(void)showAlter2{
    /*
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

-(void)webPushLand{
    [super enterFullScreen:true animated:true];
    [self setStatusBarHidden:true];
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

@end
