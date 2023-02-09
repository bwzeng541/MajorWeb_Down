//
//  BUPlayer.m
//  BUADDemo
//
//  Created by zengbiwang on 2019/10/16.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "BUPlayer.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ZFAutoPlayerViewController.h"
#import "VideoPlayerManager.h"
#import "MajorSystemConfig.h"
static id bupPlayerValue = nil;

@interface BURewardedVideoWebViewController :UIViewController

@end

@interface BURewardedVideoWebViewController(ee)
+(void)hook;
@end

@implementation BURewardedVideoWebViewController(ee)
+(void)hook{
    Method customsetmute  = class_getInstanceMethod([BURewardedVideoWebViewController class], @selector(customsetMute:));
    Method setMute = class_getInstanceMethod([BURewardedVideoWebViewController class], @selector(setMute:));
    Method originalmute = class_getInstanceMethod([BURewardedVideoWebViewController class], @selector(originalsetMute:));
    method_exchangeImplementations(setMute, originalmute );
    method_exchangeImplementations(setMute, customsetmute);
}

-(void)customsetMute:(BOOL)v{
    if (bupPlayerValue) {
        [self originalsetMute:false];
    }
    else{
        [self originalsetMute:v];
    }
}

-(void)originalsetMute:(BOOL)v{
    
}
@end

@interface BUApp :NSObject

@end

@interface BUApp(ee)
+(void)hook;
@end

@implementation BUApp(ee)
+(void)hook{
    Method customsetsetName  = class_getInstanceMethod([BUApp class], @selector(costomsetName:));
          Method setName = class_getInstanceMethod([BUApp class], @selector(setName:));
          Method originalsetName = class_getInstanceMethod([BUApp class], @selector(originalsetName:));
          method_exchangeImplementations(setName, originalsetName);
          method_exchangeImplementations(setName, customsetsetName);
    
    Method customsetsetPackageName  = class_getInstanceMethod([BUApp class], @selector(costomsetPackageName:));
    Method setPackageName = class_getInstanceMethod([BUApp class], @selector(setPackageName:));
    Method originalsetPackageName = class_getInstanceMethod([BUApp class], @selector(originalsetPackageName:));
    method_exchangeImplementations(setPackageName, originalsetPackageName);
    method_exchangeImplementations(setPackageName, customsetsetPackageName);
}

-(void)costomsetName:(NSString*)name{
    name = [MajorSystemConfig getInstance].buDname?[MajorSystemConfig getInstance].buDname: @"浏览器Max";
    [self originalsetName:name];
}

-(void)originalsetName:(NSString*)name{
    
}

-(void)costomsetPackageName:(NSString*)packAge{
    packAge = [MajorSystemConfig getInstance].buDappPackAge?[MajorSystemConfig getInstance].buDappPackAge:@"com.iperfectapp.guangchangwu";
    [self originalsetPackageName:packAge];
}

-(void)originalsetPackageName:(NSString*)name{
    
}

@end
@interface UIDevice(ee)
+(void)hook;
@end

@implementation UIDevice(ee)
+(void)hook{
    NSString *selmsg = [@"setOrientation:" stringByAppendingString:@"animated:"];
    Method customsetOrientation  = class_getInstanceMethod([UIDevice class], @selector(customsetOrientation:animated:));
       Method setOrientation = class_getInstanceMethod([UIDevice class], NSSelectorFromString(selmsg));
       Method originalsetOrientation = class_getInstanceMethod([UIDevice class], @selector(originalsetOrientation:animated:));
       method_exchangeImplementations(setOrientation, originalsetOrientation);
       method_exchangeImplementations(setOrientation, customsetOrientation);
}

-(void)originalsetOrientation:(UIInterfaceOrientation)a1 animated:(BOOL)a2{
    
}

-(void)customsetOrientation:(UIInterfaceOrientation)a1 animated:(BOOL)a2{
   
}
@end

@interface BURewardedVideoAdViewController :UIViewController

@end
@interface BURewardedVideoAdViewController(ee)
+(void)hook;
@end
@implementation BURewardedVideoAdViewController(ee)
+(void)hook{

    Method customViewLayoutSubviews = class_getInstanceMethod([BURewardedVideoAdViewController class], @selector(customviewWillLayoutSubviews));
    Method viewWillLayout = class_getInstanceMethod([BURewardedVideoAdViewController class], @selector(viewWillLayoutSubviews));
    Method originalViewWillLayout = class_getInstanceMethod([BURewardedVideoAdViewController class], @selector(originalviewWillLayoutSubviews));
    method_exchangeImplementations(viewWillLayout, originalViewWillLayout);
    method_exchangeImplementations(viewWillLayout, customViewLayoutSubviews);
    
    Method customviewload = class_getInstanceMethod([BURewardedVideoAdViewController class], @selector(customviewDidLoad));
    Method viewload = class_getInstanceMethod([BURewardedVideoAdViewController class], @selector(viewDidLoad));
    Method originalviewload = class_getInstanceMethod([BURewardedVideoAdViewController class], @selector(originalviewDidLoad));
    method_exchangeImplementations(viewload, originalviewload);
    method_exchangeImplementations(viewload, customviewload);
    
}

-(void)customviewDidLoad{
    [self originalviewDidLoad];
    [BUPlayer sendToBack];
}

-(void)originalviewDidLoad{
    
}

-(void)originalviewWillLayoutSubviews{
    
}

-(void)customviewWillLayoutSubviews{
    [self originalviewWillLayoutSubviews];
    self.view.superview.alpha = 0;
    [BUPlayer sendToBack];
}

@end
//viewWillLayoutSubviews  viewDidLoad
@implementation BUPlayer(ee)

+(BOOL)sendToBack{
    BOOL isfind = false;
    UIView *view =   [UIApplication sharedApplication].keyWindow;
    NSArray *array =  [view subviews];
    for (int i =0; i < array.count && !isfind; i++) {
        UIView *view1 =  [array objectAtIndex:i];
        if ([view1 isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            NSArray *arrayvvv = [view1 subviews];
            for(int i = 0;i<arrayvvv.count && !isfind;i++){
                UIView *childView =   [arrayvvv objectAtIndex:i];
                Ivar iVar = class_getInstanceVariable([childView class], "_viewDelegate");
                if (iVar) {
                    id value = object_getIvar(childView, iVar);
                    if ([value isKindOfClass:NSClassFromString(@"BURewardedVideoAdViewController")]) {
                        isfind = true;
                        view1.alpha = 1;
                        [view sendSubviewToBack:view1];
                    }
                }
            }
        }
    }
    return true;
}

+(void)reSetMute:(BOOL)f{
    if (bupPlayerValue) {
        Ivar iVar = class_getInstanceVariable([bupPlayerValue class], "_player");
        if (iVar) {
            AVPlayer * vv = object_getIvar(bupPlayerValue, iVar);
            if (vv) {
                [vv setMuted:f];
            }
        }
    }
}

+(void)hook{
    Method customReadyToPlay = class_getInstanceMethod([BUPlayer class], @selector(customZf_playerViewReadyToPlay:));
    Method readyToPlay = class_getInstanceMethod([BUPlayer class], @selector(zf_playerViewReadyToPlay:));
    Method originalReadyToPlay = class_getInstanceMethod([BUPlayer class], @selector(originalZf_playerViewReadyToPlay:));
    method_exchangeImplementations(readyToPlay, originalReadyToPlay);
    method_exchangeImplementations(readyToPlay, customReadyToPlay);
    
    Method customPlayFinish = class_getInstanceMethod([BUPlayer class], @selector(customZf_playerViewDidPlayFinish:error:));
    Method playFinish = class_getInstanceMethod([BUPlayer class], @selector(zf_playerViewDidPlayFinish:error:));
    Method originalPlayFinish = class_getInstanceMethod([BUPlayer class], @selector(originalZf_playerViewDidPlayFinish:error:));
    method_exchangeImplementations(playFinish, originalPlayFinish);
    method_exchangeImplementations(playFinish, customPlayFinish);
    
    Method customMute = class_getInstanceMethod([BUPlayer class], @selector(customMute));
    Method mute = class_getInstanceMethod([BUPlayer class], @selector(mute));
    Method originalMute = class_getInstanceMethod([BUPlayer class], @selector(originalMute));
    method_exchangeImplementations(mute, originalMute);
    method_exchangeImplementations(mute, customMute);
    
    [BURewardedVideoAdViewController hook];
    [UIDevice hook];
    [BUApp hook];
    [BURewardedVideoWebViewController hook];
}
-(void)customZf_playerViewDidPlayFinish:(id)arg1 error:(id)arg2{
    [self originalZf_playerViewDidPlayFinish:arg1 error:arg2];
    bupPlayerValue = nil;
}
-(void)originalZf_playerViewDidPlayFinish:(id)arg1 error:(id)arg2{
    NSLog(@"originalZf_playerViewDidPlayFinish");
}
- (void)originalZf_playerViewReadyToPlay:(id)arg
{
    NSLog(@"originalZf_playerViewReadyToPlay");
}
- (void)customZf_playerViewReadyToPlay:(id)arg{
    if (![ZFAutoPlayerViewController isInitUI]) {
        bupPlayerValue = arg;
    }
    else{
        if ([ZFAutoPlayerViewController isFull]) {
            bupPlayerValue = arg;
        }
    }
    if ([VideoPlayerManager getVideoPlayInstance].player.isFullScreen || [ZFAutoPlayerViewController isFull]) {
        [BUPlayer reSetMute:true];
    }
    
    [self originalZf_playerViewReadyToPlay:arg];
}

-(BOOL)originalMute{
    return NO;
}

-(BOOL)customMute{
    return [self originalMute];
}
@end
@interface BUPlayer(v)
@end
@implementation BUPlayer (v)

@end
