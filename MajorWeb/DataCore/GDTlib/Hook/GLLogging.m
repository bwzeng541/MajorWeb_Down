//
//  LoggingConfig.m
//  Test
//
//  Created by Peng Gu on 12/16/14.
//  Copyright (c) 2014 Peng Gu. All rights reserved.
//

#import "GLLogging.h"
#import "IQUIWindow+Hierarchy.h"
#import "MajorSystemConfig.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
//#import "UINavigationController+FDFullscreenPopGesture.h"
#import "AppDevice.h"
#import "AdvertGdtManager.h"
#import "GdtUserManager.h"
#import "BUDAdManager.h"
@implementation GetStatsMgrPro
+(GetStatsMgrPro*)getInstance{
    static GetStatsMgrPro *g = NULL;
    if (!g) {
        g = [[GetStatsMgrPro alloc] init];
    }
    return g;
}

-(NSString*)getAppid:(id)v{
    NSString *ret = nil;
    Ivar iVar = class_getInstanceVariable([v class], "_appkey");
    id vv = object_getIvar(v, iVar);
    
    return vv;
}

-(void)setNewValue:(id)v key:(id)key value:(id)value
{
    Ivar iVar = class_getInstanceVariable([v class], [key UTF8String]);
    if (value && iVar) {
        object_setIvar(v, iVar, value);
    }
}
@end

static id _g_gdtState = NULL;

static id _view_BecomeFirstResponder=NULL;
static id _view_DoubleTap=NULL;
static id _view_longRecogn=NULL;

static bool g_isCanChangeValue = false;

#ifdef OldGDTSDK

@implementation GDTStatsMgr(vv)//initializeData
+(NSString *)currentDeviceName{//影响qidfa，使用自带的广告追踪符号
    if(![AppDevice getInstance].deviceName)
    {
        return [UIDevice currentDevice].name;
    }
    else{
        return [AppDevice getInstance].deviceName;
    }
}
//3G->27560554496  128G->127989493760  64G-59417452544
+(NSString*)disk{//获取NSHomeDirectory大小 128G的手机大小这个是(这个值要影响qidfa),当使用自带的广告追踪符号
    if(![AppDevice getInstance].deviceDisk){
        if (!deviceDefaultDisk) {
            NSArray *aa = @[@"27560554496",@"127989493760",@"59417452544"];
            return [aa objectAtIndex:arc4random()%aa.count];
        }
        return deviceDefaultDisk;
    }
    else{
        return [AppDevice getInstance].deviceDisk;
    }
}

+(long long)freeDiskSpaceInBytes{//
    if( [AppDevice getInstance].freeDiskSpaceInBytes<10){
        if(devicefreeDiskSpaceInBytes<1){
            return arc4random()% 29544921088;
        }
        return devicefreeDiskSpaceInBytes;
    }
    else{
        return [AppDevice getInstance].freeDiskSpaceInBytes;
    }
 }
@end
#endif

@class  BestTestView;
extern  BestTestView*  g_BestTestView ;

@implementation UINavigationController (overrides)
- (BOOL)shouldAutorotate
{
    return YES;
}
//
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}
@end
/* 新版的sdk才使用
 @implementation NSString (vv)
 -(float)floatValue{
 float v = atof([self UTF8String]) ;
 if (g_isCanChangeValue) {
 if([[UIDevice currentDevice].systemVersion isEqualToString:self]){
 return 8;
 }
 else{
 return v;
 }
 }
 return v;
 }
 @end
 */
@implementation GLLogging
+ (GLLogging*)getInstance{
    static GLLogging *g = NULL;
    if (!g) {
        g = [[GLLogging alloc]init];
    }
    return g;
}

- (id)init
{
    self = [super init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(advert_close_click_notifi:) name:@"Advert_Close_Click_Notifi" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WebLoadNotifi:) name:@"WebLoadNotifi" object:nil];
//    NSBundle *container = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MobileContainerManager.framework"];
//    if ([container load]) {
//        Class appContainer = NSClassFromString(@"MCMAppContainer");
//        id test = [appContainer performSelector:@selector(containerWithIdentifier:error:) withObject:@"com.sdffsd.bfq" withObject:nil];
//
//        [GLLogging runTests:appContainer];
//    }
    return self;
}

+ (void)runTests:(id)inClass
{
    unsigned int count;
    Method *methods = class_copyMethodList([inClass class], &count);
    for (int i = 0; i < count; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        //        if ([name hasPrefix:@"test"])
        NSLog(@"方法 名字 ==== %@",name);
        if (name)
        {
            //avoid arc warning by using c runtime
            //            objc_msgSend(self, selector);
        }
        
        // NSLog(@"Test '%@' completed successfuly", [name substringFromIndex:4]);
    }
}

+(void)dumpView:(UIView *)aView atIndent:(int)indent into:(NSMutableString *)outstring
{
    for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
    aView.backgroundColor = [UIColor clearColor];
    [outstring appendFormat:@"[%2d] %@==%@  frame = %@\n", indent, [[aView class] description],aView.backgroundColor,NSStringFromCGRect(aView.frame)];
    
    for (UIView *view in [aView subviews])
        [self dumpView:view atIndent:indent + 1 into:outstring];
}

typedef void (^AspectHandlerBlock)(id<AspectInfo_App> aspectInfo);



- (void)addjusetLogging:(id)instance{
    /*
    Ivar iVar = class_getInstanceVariable([instance class], "_lpWebView");
    id v = object_getIvar(instance, iVar);
    if ([v isKindOfClass:[UIWebView class]]) {
        UIWebView *vv = (UIWebView*)v;
        vv.mediaPlaybackRequiresUserAction = YES;
        vv.scrollView.maximumZoomScale = 10;
        vv.scrollView.minimumZoomScale = 1;
        NSLog(@"BaiduMobAdWebLPController url = %@",vv.request.URL.absoluteString);
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [vv.scrollView setZoomScale:GetAppDelegate.ipadScale animated:YES];
        }
        else{
            [vv.scrollView setZoomScale:GetAppDelegate.iphoneScale animated:NO];
        }
        [vv.scrollView setContentOffset:CGPointMake(0,0)];
        NSArray *array = GetAppDelegate.jsArray;
        for (int i = 0; i < array.count; i++) {
            NSString *jsMsg =  [array objectAtIndex:i];
            [vv stringByEvaluatingJavaScriptFromString:jsMsg];
        }
        
        if([GetAppDelegate.bdSearchKey length]>0)
        {
            BOOL ret1Xinxliu =GetAppDelegate.isNativeAppViewAttribute;
            BOOL ret2Banner =GetAppDelegate.isBannerAttribute;
            NSString *strKey = @"zbw_xxl";
            if(ret2Banner){
                strKey = @"zbw_bbl";
            }
            NSString *strJs = [NSString stringWithFormat:@"rearch_txt(\"%@\",\"%@\")",GetAppDelegate.bdSearchKey,strKey];
            [vv stringByEvaluatingJavaScriptFromString:strJs];
        }
    }*/
}

- (void)WebLoadNotifi:(NSNotification*)object{
    /*
    BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
    BOOL ret2 =GetAppDelegate.isBannerAttribute;
    if (ret1 || ret2) {
        UIViewController *  ctrl = [[[UIApplication sharedApplication] keyWindow] currentViewController];
        if ([@"BaiduMobAdWebLPController" compare:NSStringFromClass([ctrl class])] == NSOrderedSame) {
            [self addjusetLogging:ctrl];
        }
    }*/
}

-(void)_addBecomeFirstResponder{
    if (_view_BecomeFirstResponder) {
        return;
    }
    _view_BecomeFirstResponder = [NSClassFromString(@"UIView") aspect_hookSelector_App:@selector(becomeFirstResponder) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo_App> aspectInfo){
        NSLog(@"...");
    }error:NULL];
    
    
    _view_DoubleTap = [NSClassFromString(@"UIWebDocumentView") aspect_hookSelector_App:NSSelectorFromString([NSString stringWithFormat:@"_handle%@%@",@"DoubleTap",@"AtLocation:"]) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo_App> aspectInfo){
        NSLog(@"UIWebDocumentView _handleDoubleTapAtLocation");
    }error:NULL];
    
    
    _view_longRecogn = [NSClassFromString(@"UIWebDocumentView") aspect_hookSelector_App:NSSelectorFromString([NSString stringWithFormat:@"_long%@%@",@"Press",@"Recognized:"]) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo_App> aspectInfo){
        NSLog(@"UIWebDocumentView _longPressRecognized");
    }error:NULL];
}

-(void)_removeBecomeFirstResponder{
    [_view_BecomeFirstResponder remove];
    _view_BecomeFirstResponder = NULL;
    [_view_DoubleTap remove];
    _view_DoubleTap = NULL;
    [_view_longRecogn remove];
    _view_longRecogn = NULL;
}

- (void)setupWithConfiguration:(NSDictionary *)configs
{
#ifdef OldGDTSDK

    //-[GDTClickController handleClick:]    __text    000000000000014C    0000043C    000000F0    FFFFFFFFFFFFFFF8    R    .    .    .    B    T    .
    //-[GDTWebViewController webView:shouldStartLoadWithRequest:navigationType:]    __text    00000000000006B4    000000E0    00000040    FFFFFFFFFFFFFFF8    R    .    .    .    B    T    .

    
//    [NSClassFromString(@"WKWebView") aspect_hookSelector_App:@selector(urlSchemeHandlerForURLScheme:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo,id v1){
//        // NSLog(@"relativeToURL v1 = %@",v1);
//        if ([v1 rangeOfString:@"mi.gdt.qq.com/gdt_mview.fcg"].location!=NSNotFound) {
//            NSLog(@"gdt_mvview = %s\n",[v1 UTF8String]);
//        }
//    }error:NULL];
//

   // [GLLogging runTests:NSClassFromString(@"WKWebView")];
   //(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType
//    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"webView:shouldStartLoadWithRequest:navigationType:") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo,id v1,NSMutableURLRequest* v2,UIWebViewNavigationType v3){
//        NSString *url = v2.URL.absoluteString;
//        if (url && [[url lowercaseString] rangeOfString:@"itunes.apple.com"].location!=NSNotFound) {
//            NSInvocation *invocation = aspectInfo.originalInvocation;
//            BOOL retOK = false;//可修改参数
//            [invocation setArgument:&retOK atIndex:2];//
//        }
//        printf("GDTWebViewController shouldStartLoadWithRequest\n");
//    }error:NULL];
    [NSClassFromString(@"NSURL") aspect_hookSelector_App:@selector(initWithString:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo,id v1){
       // NSLog(@"initWithString = %@",v1);
        
    }error:NULL];
    
    [NSClassFromString(@"NSURL") aspect_hookSelector_App:@selector(initWithString:relativeToURL:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo,id v1,id v2){
        //NSLog(@"relativeToURL v1 = %@",v1);
    }error:NULL];
    
    NSString *strMsg = [NSString stringWithFormat:@"%@%@%@%@%@",@"UIWe",@"bGeoloca",@"tionPol",@"icyDe",@"cider"];
    SEL selMsg = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@",@"_exe",@"cuteN",@"extCh",@"alle",@"nge"]);
    [NSClassFromString(strMsg) aspect_hookSelector_App:selMsg withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo_App> aspectInfo){
        NSLog(@"initWithString = %s\n","UIWebGeolocationPolicyDecider");
    }error:NULL];
    
    [NSClassFromString(@"GDTStatsMgr") aspect_hookSelector_App:@selector(initializeData) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){//
        _g_gdtState = aspectInfo.instance;
        if ([MajorSystemConfig getInstance].isGotoUserModel == 2) {
            [AdvertGdtManager getInstance].gdtStatsMgr = _g_gdtState;
            [[AppDevice getInstance]setGDTStatsMgr:_g_gdtState];
            [[AdvertGdtManager getInstance] reSetAppInfo];
        }
        else if ([MajorSystemConfig getInstance].isGotoUserModel==1){
            [GdtUserManager getInstance].gdtStatsMgr = _g_gdtState;
        }
    } error:NULL];
    
    [NSClassFromString(@"GDTStatsMgr") aspect_hookSelector_App:@selector(collectAppInfo:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo,id v1){
        _g_gdtState = aspectInfo.instance;
        
    } error:NULL];
    
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"preparePopupResource") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("preparePopupResource \n");
    }error:NULL];
    
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"notifyDelegateVCWillClose") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("notifyDelegateVCWillClose \n");
    }error:NULL];
    
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"popupDirectClose") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("popupDirectClose \n");
    }error:NULL];
    
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"popupClose") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("popupClose \n");
    }error:NULL];
    
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"notifyDelegateVCClosed") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("notifyDelegateVCClosed \n");
    }error:NULL];
    
    [NSClassFromString(@"GDTStoreProductLoadingController") aspect_hookSelector_App:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("GDTStoreProductLoadingController dealloc\n");
    }error:NULL];
    [NSClassFromString(@"GDTStoreProductController") aspect_hookSelector_App:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("GDTStoreProductController dealloc\n");
    }error:NULL];
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("GDTWebViewController dealloc\n");
    }error:NULL];
    
    [NSClassFromString(@"GDTStoreProductLoadingController") aspect_hookSelector_App:NSSelectorFromString(@"viewDidDisappear:") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("GDTStoreProductLoadingController viewDidDisappear\n");
    }error:NULL];
    
    [NSClassFromString(@"GDTBaseInterstitialDialog") aspect_hookSelector_App:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        printf("GDTBaseInterstitialDialog dealloc\n");
    }error:NULL];
    //end
  
    NSString *strInfo= [NSString stringWithFormat:@"webView:%@%@%@%@%@",@"reso",@"urce:did",@"FinishLo",@"adingFro",@"mDataSource:"];
    [NSClassFromString(@"UIWebView") aspect_hookSelector_App:NSSelectorFromString(strInfo) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){
        /*
        BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
        BOOL ret2 =GetAppDelegate.isBannerAttribute;
        if((ret1 || ret2) && [GetAppDelegate.bdWebDataSourceJs length]>10 && GetAppDelegate.isClickApp){
            UIWebView *v =  (UIWebView*)aspectInfo.instance;
            [v stringByEvaluatingJavaScriptFromString:GetAppDelegate.bdWebDataSourceJs];
            GetAppDelegate.isClickApp = true;
         }*/
    }error:NULL];
    
    //点击banner的时候，不调用web的广告
    [NSClassFromString(@"BaiduMobAdActionComposer") aspect_hookSelector_App:@selector(innerDoActionAPO:withParam:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"did_A_dClickedFromIt" object:nil];
    }error:NULL];//end
    
    /*
    [NSClassFromString(VideoCtrlSystem) aspect_hookSelector_App:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){
        if (GetAppDelegate.isDisplayVideoCtrl) {
            UIViewController* v = aspectInfo.instance;
            if ([v isKindOfClass:[UIViewController class]]) {
                v.view.hidden = YES;
            }
        }
     }error:NULL];*/
    [NSClassFromString(VideoCtrlSystem) aspect_hookSelector_App:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){
      /*  if (GetAppDelegate.isDisplayVideoCtrl) {
            UIViewController* v = aspectInfo.instance;
            if ([v isKindOfClass:[UIViewController class]]) {
                v.view.hidden = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"destroyAvFull" object:nil];
            }
        }*/
    }error:NULL];
    
    [NSClassFromString(@"BaiduMobAdActionComposer") aspect_hookSelector_App:@selector(presentLpController:withNavigationController:withParam:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){
        g_isCanChangeValue = false;
    }error:NULL];
    
    [NSClassFromString(@"BaiduMobAdActionComposer") aspect_hookSelector_App:@selector(presentLpController:withNavigationController:withParam:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){/*
        BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
        BOOL ret2 =GetAppDelegate.isBannerAttribute;
        if (ret1 || ret2) {
            g_isCanChangeValue = true;
        }*/}error:NULL];
    
    [NSClassFromString(@"BaiduMobAdActionComposer") aspect_hookSelector_App:@selector(presentLpController:withNavigationController:withParam:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){
        g_isCanChangeValue = false;
    }error:NULL];
    
    [NSClassFromString(@"BaiduMobAdWebLPController") aspect_hookSelector_App:@selector(webViewDidFinishLoad:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){/*
        BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
        BOOL ret2 =GetAppDelegate.isBannerAttribute;
        if (ret1 || ret2) {
            [self addjusetLogging:aspectInfo.instance];
            
        }*/}error:NULL];
    
    
    [NSClassFromString(@"BaiduMobAdWebLPController") aspect_hookSelector_App:@selector(handleSingleTap:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){/*
        BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
        BOOL ret2 =GetAppDelegate.isBannerAttribute;
        if (ret1 || ret2) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CloseButtonAddStep" object:nil];
            //[MobClick event:@"btn_5"];
            
        }*/}error:NULL];
    
    [UINavigationController aspect_hookSelector_App:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){/*
        BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
        BOOL ret2 =GetAppDelegate.isBannerAttribute;
        printf("ret1 = %d ret2 = %d\n",ret1,ret2);
        if (ret1 ||ret2) {
            UINavigationController *v = aspectInfo.instance;
            UIViewController *topCtrl =  v.visibleViewController;
            topCtrl.fd_prefersNavigationBarHidden = YES;
            [v setNavigationBarHidden:YES];
            [v setToolbarHidden:true];
        }*/
    }error:NULL];
    
    [UINavigationController aspect_hookSelector_App:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo){/*
        BOOL ret1 =GetAppDelegate.isNativeAppViewAttribute;
        BOOL ret2 =GetAppDelegate.isBannerAttribute;
        if (ret1 ||ret2) {//修改整体大小，需要增加标签控制大小
            UINavigationController *v = aspectInfo.instance;
            [v setNavigationBarHidden:YES];
            [v setToolbarHidden:true];
            [self _addBecomeFirstResponder];
            CGSize sizeDevice = GetAppDelegate.appSize;
            int tmp = sizeDevice.height;
            sizeDevice.height = sizeDevice.width;
            sizeDevice.width = tmp;
            NSString *keyPoint = [NSString stringWithFormat:@"%dX%d",(int)sizeDevice.width,(int)sizeDevice.height];
            CGPoint point;
            point.x = point.y = -1;
            NSDictionary *pointInfo = [GetAppDelegate.closePointInfo objectForKey:keyPoint];
            NSString *strPoint = [pointInfo objectForKey:@"navigationOffsetX"];
            NSString *strScale = [pointInfo objectForKey:@"navigationScaleX"];
            NSLog(@"ret1 = %d ret2 = %d keyPoint = %s strPoint = %s strScale = %s\n",ret1,ret2,[keyPoint UTF8String],[strPoint UTF8String],[strScale UTF8String]);
            if (strPoint || strScale) {
                v.view.frame = CGRectMake([strPoint floatValue], 0, GetAppDelegate.appSize.height/[strScale floatValue], GetAppDelegate.appSize.width);
            }
        }*/
    }
                                              error:NULL];
    
    [NSClassFromString(@"BaiduMobAdActionRootController") aspect_hookSelector_App:@selector(presentViewController:animated:completion:)
                                  withOptions:AspectPositionAfter
                                   usingBlock:^(id<AspectInfo_App> aspectInfo,UIViewController *viewControllerToPresent ,BOOL flag,id completion) {/*
                                       //NSInvocation *invocation = aspectInfo.originalInvocation;
                                       //BOOL num = false;可修改参数
                                       //[invocation setArgument:&num atIndex:3];//
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSString *className = NSStringFromClass([[aspectInfo instance] class]);
                                           NSString *pageImp = configs[className][GLLoggingPageImpression];
                                           NSLog(@"viewDidAppear = %@", className);
                                           UIViewController *ctrl = nil;
                                           if (GetAppDelegate.isNativeAppViewAttribute && [className compare:@"BaiduMobAdActionRootController"]==NSOrderedSame) {
                                               ctrl = [[[UIApplication sharedApplication] keyWindow] currentViewController];
#ifndef DEBUG
                                               if (GetAppDelegate.appIsRealseVesion){
                                                   ctrl.view.alpha = 0.012;
                                               }
                                               else
                                               {
                                                   ctrl.view.alpha = 0.9;
                                               }
#else
#endif
                                           }
                                           else  if (GetAppDelegate.isBannerAttribute && [className compare:@"BaiduMobAdActionRootController"]==NSOrderedSame) {
                                               ctrl = [[[UIApplication sharedApplication] keyWindow] currentViewController];
#ifndef DEBUG
                                               if (GetAppDelegate.appIsRealseVesion){
                                                   ctrl.view.alpha = 0.012;
                                               }
                                               else{
                                                   ctrl.view.alpha = 0.9;
                                               }
#else
#endif
                                           }
                                           NSLog(@"presentViewController = %@", className);
                                          
                                       });
                                   */} error:NULL];
    
    

//    [NSClassFromString(@"UIApplication") aspect_hookSelector_App:@selector(openURL:options:completionHandler:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
//
//    }error:NULL];
    [NSClassFromString(@"GDTNativeExpressAdView") aspect_hookSelector_App:@selector(click:antiSpam:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo,id v1,id v2){
        if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
            
        }
    } error:NULL];
    //begin gdt 部分
    [NSClassFromString(@"GDTNativeExpressAdView") aspect_hookSelector_App:@selector(click:antiSpam:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo,id v1,id v2){
        if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
            
        }
     } error:NULL];
    
    [NSClassFromString(@"GDTNativeExpressAdView") aspect_hookSelector_App:@selector(click:antiSpam:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo_App> aspectInfo,id v1,id v2){
        if ([MajorSystemConfig getInstance].isGotoUserModel!=2) {
            
        }
    } error:NULL];
    
    [NSClassFromString(@"GDTStoreProductController") aspect_hookSelector_App:@selector(viewDidAppear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        UIViewController* v = aspectInfo.instance;
        v.view.alpha = 1;
    } error:NULL];
    
    [NSClassFromString(@"GDTStoreProductLoadingController") aspect_hookSelector_App:@selector(viewDidAppear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        UIViewController* v = aspectInfo.instance;
        v.view.alpha = 1;
        
    } error:NULL];
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:@selector(viewDidAppear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        UIViewController* v = aspectInfo.instance;
        v.view.alpha = 1;
        
    } error:NULL];
    [NSClassFromString(@"GDTWebViewController") aspect_hookSelector_App:@selector(viewDidDisappear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo){
        UIViewController* v = aspectInfo.instance;
        v.view.alpha = 1;
    } error:NULL];

    
     [NSClassFromString(@"GDTLoadAdRequestExtData") aspect_hookSelector_App:@selector(setC_pkgname:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo_App> aspectInfo,id v1){
     NSString *pkgname = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"];
     if (([MajorSystemConfig getInstance].gdtPgkType==1) && [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"]) {
         pkgname = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"];
     }
     if (pkgname&&[pkgname length]>4) {
     NSInvocation *invocation = aspectInfo.originalInvocation;
     NSString *buildKey = pkgname;//可修改参数
     [invocation setArgument:&buildKey atIndex:2];//
     }
     } error:NULL];//end
    
    //end
    
    // Hook Events
    for (NSString *className in configs) {
        Class clazz = NSClassFromString(className);
        NSDictionary *config = configs[className];
        
        if (config[GLLoggingTrackedEvents]) {
            for (NSDictionary *event in config[GLLoggingTrackedEvents]) {
                SEL selekor = NSSelectorFromString(event[GLLoggingEventSelectorName]);
                AspectHandlerBlock block = event[GLLoggingEventHandlerBlock];
                
                [clazz aspect_hookSelector_App:selekor
                                   withOptions:AspectPositionBefore
                                    usingBlock:^(id<AspectInfo_App> aspectInfo) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            block(aspectInfo);
                                        });
                                    } error:NULL];
                
            }
        }
    }
#endif
}


-(void)advert_close_click_notifi:(NSNotification*)object{/*
    //模拟发送clickClose:方法自动关闭广告
    UIViewController *ctrl = [[[UIApplication sharedApplication] keyWindow] currentViewController];
    //if ([NSStringFromClass([ctrl class]) compare:@"BaiduMobAdNativeWebLPController"] == NSOrderedSame) {
    NSLog(@"advert_close_click_notifi 1");
    if (!GetAppDelegate.isBannerAttribute && [NSStringFromClass([ctrl class]) compare:@"BaiduMobAdWebLPController"] == NSOrderedSame) {
        [self _removeBecomeFirstResponder];
#ifndef DEBUG
        if (GetAppDelegate.appIsRealseVesion){
            ctrl.view.alpha = 0.012;
        }
        else{
            ctrl.view.alpha = 0.9;
        }
#else
#endif
        NSLog(@"advert_close_click_notifi 2");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(GetAppDelegate.displayAdvertTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMethodSignature *sig=[[ctrl class] instanceMethodSignatureForSelector:@selector(clickClose:)];
            NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:ctrl];
            [invocation setSelector:@selector(clickClose:)];
            // [invocation setArgument:&num atIndex:2];//参数不设置
            [invocation invoke];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recviRemoveNofiti" object:nil];
            //[MobClick event:@"btn_1"];
        });
    }
    else if (GetAppDelegate.isBannerAttribute && [NSStringFromClass([ctrl class]) compare:@"BaiduMobAdWebLPController"] == NSOrderedSame) {
        [self _removeBecomeFirstResponder];
#ifndef DEBUG
        if (GetAppDelegate.appIsRealseVesion){
            ctrl.view.alpha = 0.012;
        }
        else{
            ctrl.view.alpha = 0.9;
        }
#else
#endif
        NSLog(@"advert_close_click_notifi 3");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(GetAppDelegate.displayAdvertTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMethodSignature *sig=[NSClassFromString(@"BaiduMobAdWebLPController") instanceMethodSignatureForSelector:@selector(clickClose:)];
            NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:ctrl];
            [invocation setSelector:@selector(clickClose:)];
            // [invocation setArgument:&num atIndex:2];//参数不设置
            [invocation invoke];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recviRemoveNofiti2" object:nil];
            //[MobClick event:@"btn_2"];
        });
    }
    else if (GetAppDelegate.isBannerAttribute){
        NSLog(@"advert_close_click_notifi 4");
        [self _removeBecomeFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recviRemoveNofiti2" object:nil];
    }
    else{
        [self _removeBecomeFirstResponder];
        NSLog(@"advert_close_click_notifi 5");
    }*/
}


@end




