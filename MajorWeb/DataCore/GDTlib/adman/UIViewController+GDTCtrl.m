//
//  UIViewController.m
//  GDTMobSample
//
//  Created by zengbiwang on 2017/11/11.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "UIViewController+GDTCtrl.h"
#import <objc/message.h>
#import "GDtRootCtrl.h"
#import "MajorSystemConfig.h"
#import <AdSupport/AdSupport.h>
#import "AppDevice.h"
#import "GLLogging.h"
#import "ClickManager.h"
#ifdef OldGDTSDK

@interface GDTClickManager:NSObject
@end
@implementation GDTClickManager(exter)
-(void)originahandleClick:(id)clickParam{
    [self originahandleClick:clickParam];
}

-(void)customahandleClick:(id)clickParam{
    if([clickParam isKindOfClass:NSClassFromString(@"GDTClickParam")]){
        Ivar oldValue = class_getInstanceVariable([clickParam class], "_deepLinkParams");
        id v = object_getIvar(clickParam, oldValue);
        if ([v isKindOfClass:[NSDictionary class]] && [v objectForKey:@"urlScheme"] && [v objectForKey:@"adid"])
        {
             NSLog(@"urlScheme = %@",[v objectForKey:@"urlScheme"]);
            if([MajorSystemConfig getInstance].isGotoUserModel==2 && [MajorSystemConfig getInstance].isUrlSchemeNil){
                NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:v];
                [newDic setObject:@"<null>" forKey:@"urlScheme"];
                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:newDic];
                object_setIvar(clickParam, oldValue, dic);
            }
        }
    }
    [self originahandleClick:clickParam];
}


-(void)originahandleOpenUrlScheme:(id)clickParam{
    [self originahandleOpenUrlScheme:clickParam];
}

-(void)customahandleOpenUrlScheme:(id)clickParam{
    [self originahandleOpenUrlScheme:clickParam];
}

-(void)originadeepLinkFinished:(BOOL)clickParam{
    [self originadeepLinkFinished:clickParam];
}

-(void)customadeepLinkFinished:(BOOL)clickParam{
    [self originadeepLinkFinished:clickParam];
}
@end
#endif

#ifdef OldGDTSDK
@interface GDTWebViewMgr:NSObject

@end

@implementation GDTWebViewMgr(exter)

+(id)webViewWithFrame:(CGRect)rect version:(NSString*)v{
    id vv = nil; 
   if (false && [MajorSystemConfig getInstance].isGotoUserModel!=2) {//强制使用
        vv =  [[NSClassFromString(@"GDTAdWKWebView") alloc]initWithFrame:rect];
    }
    else {
        vv = [[NSClassFromString(@"GDTAdWebView") alloc]initWithFrame:rect];
    }
    return vv;
}
@end

@implementation  GDTStatsMgr(Extend)
-(NSString*)originamd6
{
    NSString *fier = [self originamd6];
    return fier;
}
-(NSString*)customamd6{
    NSString *fier = [self originamd6];//这个原始数据
    if ([AppDevice getInstance].isWiFi && [AppDevice getInstance].deviceMd6) {
        fier = [AppDevice getInstance].deviceMd6;
    }
    return fier;
}
@end

@implementation GDTSettingMgr(Extend)

-(id)originaAppObjectForKey:(NSString*)appkey{
    return  [self originaAppObjectForKey:appkey];
}

-(id)customaAppObjectForKey:(NSString*)appkey{
    if ([MajorSystemConfig getInstance].isGotoUserModel==2) {
        if ([appkey compare:@"iOSSafari"] == NSOrderedSame) {
            return [NSNumber numberWithInteger:0];
        }
    }
    return  [self originaAppObjectForKey:appkey];
}

-(NSString*)originasuid
{
    NSString *fier = [self originasuid];
    return fier;
}
-(NSString*)customasuid{
    NSString *suid = [self originasuid];
    NSString *bundleKey = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"];
    if (bundleKey && [suid length]>0) {
        NSData *data = [FTWCache objectForKey:[NSString stringWithFormat:@"%@_suid",bundleKey] useKey:YES];
        if ([data length]>0) {
            suid = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }
        else{
            suid = @"";
        }
    }
    NSLog(@"customasuid = %@ packname = %@",suid,bundleKey);
    return suid;
}

-(void)originaupdateSuid:(NSString*)suid{
    [self originaupdateSuid:suid];
}

-(void)customaupdateSuid:(NSString*)suid{
    //更新数据
    NSString *bundleKey = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"];
    if (bundleKey && [suid length]>0) {
        [FTWCache setObject:[suid dataUsingEncoding:NSUTF8StringEncoding] forKey:[NSString stringWithFormat:@"%@_suid",bundleKey] useKey:YES];
    }
    [self originaupdateSuid:suid];
}
@end

@implementation ASIdentifierManager (Extend)
-(NSUUID*)originaladvertisingIdentifier
{
    NSUUID *fier = [self originaladvertisingIdentifier];
    return fier;
}

-(NSUUID*)customadvertisingIdentifier{
    
    NSUUID *fier = [self originaladvertisingIdentifier];//这个原始数据
    NSString *newUUID = [AppDevice getInstance].deviceUID;
    NSUUID *uuid;
    if (newUUID) {
          uuid = [[NSUUID alloc]initWithUUIDString:newUUID];//这个是需要更改的数据
    }
    else{
        uuid = fier;
    }
    return uuid;
}

@end
#endif
@implementation UIViewController(GDTCtrl)

- (void)customPresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
#ifdef OldGDTSDK
    if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
        [self originalPresentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    NSString *name = NSStringFromClass([self class]);
    if  ([name compare:@"GDtRootCtrl"] == NSOrderedSame || [name compare:@"GDtBannerRootCtrl"] == NSOrderedSame || [name compare:@"GDtInterstitialRootCtrl"] == NSOrderedSame || [name compare:@"GDTInterstitialOver8Dialog"] == NSOrderedSame)
    {
        if ([name compare:@"GDTInterstitialOver8Dialog"] != NSOrderedSame) {
            [(GDtRootCtrl*)self addPushCtrl:viewControllerToPresent];
            [self.view addSubview:viewControllerToPresent.view];
        }
        else {
            [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtInterstitialRootCtrl).view addSubview:viewControllerToPresent.view];
            [((GDtRootCtrl*)[MajorSystemConfig getInstance].gdtInterstitialRootCtrl) addPushCtrl:viewControllerToPresent];
        }
        [[ClickManager getInstance] updateClickKey:[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"]];
        viewControllerToPresent.view.frame = self.view.bounds;
        completion();
    }
    else
    {
        [self originalPresentViewController:viewControllerToPresent animated:flag completion:completion];
    }
#endif
}

- (void)originalPresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
    NSLog(@"originalPresentViewController");
}

-(void)customDismissViewControllerAnimated :(BOOL)flag completion: (void (^ __nullable)(void))completion
{
#ifdef OldGDTSDK
    if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
        [self originalDismissViewControllerAnimated:flag completion:completion];
        return;
    }
    NSString *name = NSStringFromClass([self class]);
    if  ([name compare:@"GDtBannerRootCtrl"] == NSOrderedSame || [name compare:@"GDtRootCtrl"] == NSOrderedSame || [name compare:@"GDTWebViewController"] == NSOrderedSame || [name compare:@"GDtInterstitialRootCtrl"] == NSOrderedSame || [name compare:@"GDTInterstitialOver8Dialog"] == NSOrderedSame){
        
        completion();
    }
    else{
        [self originalDismissViewControllerAnimated:flag completion:completion];
    }
#endif
}

-(void)originalDismissViewControllerAnimated :(BOOL)flag completion: (void (^ __nullable)(void))completion
{
    NSLog(@"originalDismissViewControllerAnimated");
}

+(void)hookViewController{
#ifdef OldGDTSDK
    Method customPresent = class_getInstanceMethod([UIViewController class], @selector(customPresentViewController:animated:completion:));
    Method present = class_getInstanceMethod([UIViewController class], @selector(presentViewController:animated:completion:));
    Method originalPresent = class_getInstanceMethod([UIViewController class], @selector(originalPresentViewController:animated:completion:));
    method_exchangeImplementations(present, originalPresent);
    method_exchangeImplementations(present, customPresent);
    
    Method customDismiss = class_getInstanceMethod([UIViewController class], @selector(customDismissViewControllerAnimated:completion:));
    Method dismiss = class_getInstanceMethod([UIViewController class], @selector(dismissViewControllerAnimated:completion:));
    Method originalDismiss = class_getInstanceMethod([UIViewController class], @selector(originalDismissViewControllerAnimated:completion:));
    method_exchangeImplementations(dismiss, originalDismiss);
    method_exchangeImplementations(dismiss, customDismiss);
    
    //hook 广告标识符
    if([MajorSystemConfig getInstance].initDeviceIDCount>0){
        Method customIdentifier = class_getInstanceMethod([ASIdentifierManager class], @selector(customadvertisingIdentifier));
        Method identifier = class_getInstanceMethod([ASIdentifierManager class], @selector(advertisingIdentifier));
        Method originalIdentifier = class_getInstanceMethod([ASIdentifierManager class], @selector(originaladvertisingIdentifier));
        method_exchangeImplementations(identifier, originalIdentifier);
        method_exchangeImplementations(identifier, customIdentifier);
        
        Method customMd6 = class_getInstanceMethod([GDTStatsMgr class], @selector(customamd6));
        Method md6 = class_getInstanceMethod([GDTStatsMgr class], @selector(m6));
        Method originalMd6 = class_getInstanceMethod([GDTStatsMgr class], @selector(originamd6));
        method_exchangeImplementations(md6, originalMd6);
        method_exchangeImplementations(md6, customMd6);
    }
    
    Method customAppObjectForKey = class_getInstanceMethod([GDTSettingMgr class], @selector(customaAppObjectForKey:));
    Method AppObjectForKey = class_getInstanceMethod([GDTSettingMgr class], @selector(appObjectForKey:));
    Method originalAppObjectForKey = class_getInstanceMethod([GDTSettingMgr class], @selector(originaAppObjectForKey:));
    method_exchangeImplementations(AppObjectForKey, originalAppObjectForKey);
    method_exchangeImplementations(AppObjectForKey, customAppObjectForKey);
    
    //updateSuid
    Method customUpdateSuid = class_getInstanceMethod([GDTSettingMgr class], @selector(customaupdateSuid:));
    Method updateSuid = class_getInstanceMethod([GDTSettingMgr class], @selector(updateSuid:));
    Method originalUpdateSuid = class_getInstanceMethod([GDTSettingMgr class], @selector(originaupdateSuid:));
    method_exchangeImplementations(updateSuid, originalUpdateSuid);
    method_exchangeImplementations(updateSuid, customUpdateSuid);
    
    Method customSuid = class_getInstanceMethod([GDTSettingMgr class], @selector(customasuid));
    Method suid = class_getInstanceMethod([GDTSettingMgr class], @selector(suid));
    Method originalSuid = class_getInstanceMethod([GDTSettingMgr class], @selector(originasuid));
    method_exchangeImplementations(suid, originalSuid);
    method_exchangeImplementations(suid, customSuid);

    Method customClick = class_getInstanceMethod([GDTClickManager class], @selector(customahandleClick:));
    Method handleClick = class_getInstanceMethod([GDTClickManager class], @selector(handleClick:));
    Method originalhandleClick = class_getInstanceMethod([GDTClickManager class], @selector(originahandleClick:));
    method_exchangeImplementations(handleClick, originalhandleClick);
    method_exchangeImplementations(handleClick, customClick);
    
    Method customOpenUrlScheme = class_getInstanceMethod([GDTClickManager class], @selector(customahandleOpenUrlScheme:));
    Method openUrlScheme = class_getInstanceMethod([GDTClickManager class], @selector(openUrlScheme:));
    Method originalhandleOpenUrlScheme = class_getInstanceMethod([GDTClickManager class], @selector(originahandleOpenUrlScheme:));
    method_exchangeImplementations(openUrlScheme, originalhandleOpenUrlScheme);
    method_exchangeImplementations(openUrlScheme, customOpenUrlScheme);
    
    Method customDeepLinkFinished = class_getInstanceMethod([GDTClickManager class], @selector(customadeepLinkFinished:));
    Method opendeepLinkFinished = class_getInstanceMethod([GDTClickManager class], @selector(deepLinkFinished:));
    Method originaldeepLinkFinished = class_getInstanceMethod([GDTClickManager class], @selector(originadeepLinkFinished:));
    method_exchangeImplementations(opendeepLinkFinished, originaldeepLinkFinished);
    method_exchangeImplementations(opendeepLinkFinished, customDeepLinkFinished);
#endif
}
@end
