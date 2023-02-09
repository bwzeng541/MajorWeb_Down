//
//  AppDelegate.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "AppDelegate.h"
#import "MajorMain.h"
#import "GCDWebServerDataResponse.h"
#import <RevealServer/RevealServer.h>
#import "VideoPlayerManager.h"
#import <dlfcn.h>
#import <sys/stat.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <AVFoundation/AVFoundation.h>
#import "JsServiceManager.h"
#import "MajorSystemConfig.h"
#import "helpFuntion.h"
#import "MajorICloudSync.h"
#import "Aspects_App.h"
#import "JsServiceManager.h"
#import "FTWCache.h"
#import <StoreKit/StoreKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "AppAdWebView.h"
#import "KHookObjectWrapper.h"
#import "JPUSHService.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "NSString+MKNetworkKitAdditions.h"
#import "YYCache.h"
#import "GDTSplashAd.h"
#import "WebCoreManager.h"
#import "ZYNetworkAccessibity.h"
#import <AdSupport/AdSupport.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#import "MajorFeedbackKit.h"
#endif
#import "AppWtManager.h"
#import "DownApiConfig.h"
//#import "MDMethodTrace.h"
#import "BUDAdManager.h"
#import "VipPayPlus.h"
#import "MarjorWebConfig.h"
#import "FileWebDownLoader.h"
#import "DNLAController.h"
#import "NetworkManager.h"
#import "fishhook.h"
#import "Aspects_App.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import "BUAdSDK/BUSplashAdView.h"
#import "SGWiFiUploadManager.h"
#import "NewVipPay.h"
#import "QRWebBlockManager.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
//#import "JJException.h"
//#import "MajorWeb-Swift.h"
static NSString *str = @"sfjjjAppdeegate_test";
static BOOL isShowAlter = false;
static BOOL isCanCreateAlter = false;
static BOOL isCheckVersionState  = false;
static int  backApplicationDidEnterBackgroundTimes = 0;
#define SpotlightCaches [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/spotlightCache",AppSynchronizationDir ]]
#define App_Local_Push_Key @"majorWeb_xiongmao_ergao_app"


@interface NSObject (Extend)
@end

@implementation NSObject (Extend)
+ (void)load{
    
    SEL originalSelector = @selector(doesNotRecognizeSelector:);
    SEL swizzledSelector = @selector(sw_doesNotRecognizeSelector:);
    
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method swizzledMethod = class_getClassMethod(self, swizzledSelector);
    
    if(class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))){
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)sw_doesNotRecognizeSelector:(SEL)aSelector{
    //处理 _LSDefaults 崩溃问题
    if([[self description] isEqualToString:@"_LSDefaults"] && (aSelector == @selector(sharedInstance))){
        //冷处理...
        return;
    }
    [self sw_doesNotRecognizeSelector:aSelector];
}
@end



@interface MyUIfWindow : UIWindow
@end


@interface MyUIfWindow ()<UIGestureRecognizerDelegate>

@end
@implementation MyUIfWindow : UIWindow
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
   //id value = [self getAppid:event];
   // NSArray *key = [value allKeys];
   // NSLog(@"..");
}


 -(NSString*)getAppid:(id)v{
 NSString *ret = nil;
 Ivar iVar = class_getInstanceVariable([v class], "_keyedTouchesByWindow");
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

@interface AppDelegate ()<BUSplashAdDelegate,GDTSplashAdDelegate,AppAdWebViewDelegate,JPUSHRegisterDelegate/*,JJExceptionHandle*/>{
    void(^stopBackBackgroundTaskBlock)(void);
    int currentTime;
}
@property (nonatomic, strong) BUSplashAdView *splashView;
@property (nonatomic, strong) GDTSplashAd *splashAd;
@property(nonatomic,weak)AppAdWebView *adsWeb;
@property(nonatomic,weak)AppAdWebView *newsWeb;
@property(nonatomic,strong)NSTimer *backTimer;
@property(nonatomic,strong)GCDWebServer *webReadModeServer;
@end

@implementation AppDelegate

-(UIView*)getRootCtrlView{
    return self.window.rootViewController.view;
}

-(void)showWebBoardView
{
    return [(MajorMain*)self.window.rootViewController showWebBoardView];
}

-(void)updateHisotryAndFavorite{
    return [(MajorMain*)self.window.rootViewController updateHisotryAndFavorite];
}

-(void)showAppHomeView
{
    return [(MajorMain*)self.window.rootViewController showAppHomeView];
}

- (void)setSupportRotationDirection:(UIInterfaceOrientationMask)supportRotationDirection{
     _supportRotationDirection = supportRotationDirection;
}

- (UIInterfaceOrientationMask)getSupportRotationDirection{
    return _supportRotationDirection;
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    if ( [[UIDevice currentDevice].systemVersion floatValue]>=13) {
        return;
    }
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


-(void)addSpotlight:(NSString*)title des:(NSString*)des key:(NSString*)key url:(NSString*)url
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        return;
    }
    if (![url isEqualToString:@"about:blank"]) {
        [self addSpotlightByGoup:title des:des key:key url:url group:AddDomainIdentifier];
    }
}

-(void)addSpotlightItem:(NSArray*)items{
    if (@available(iOS 9.0, *)) {
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:items completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"失败%@",error);
            }
            else {
                CSSearchableItem *item = (CSSearchableItem*)[items objectAtIndex:0];
                NSString*uuid = item.uniqueIdentifier;
                [SpotlightCaches setObject:items forKey:uuid ];
                NSLog(@"成功");
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

-(void)addSpotlightByGoup:(NSString*)title des:(NSString*)des key:(NSString*)key url:(NSString*)url group:(NSString*)group{
    
    /*应用内搜索，想搜索到多少个界面就要创建多少个set ，每个set都要对应一个item*/
    if (@available(iOS 9.0, *)) {
        CSSearchableItemAttributeSet *firstSet = [[CSSearchableItemAttributeSet alloc]initWithItemContentType:(NSString*)kUTTypeURL];
        //标题
        firstSet.title = title;
        //详细描述
        firstSet.contentDescription = des;
        //关键字
        firstSet.contactKeywords = @[key];
        firstSet.contentCreationDate = [NSDate date];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/"];
        url = [url stringByTrimmingCharactersInSet:set];
        firstSet.URL = [NSURL URLWithString:url];
        
        NSData *nsdata = [url dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Encode = [nsdata base64EncodedStringWithOptions:0];
        
        NSString *uuid = base64Encode;
        CSSearchableItem *firstItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:uuid domainIdentifier:group attributeSet:firstSet];
        firstItem.expirationDate = [[NSDate date] dateByAddingDays:7];
        NSArray *items = @[firstItem];
        
        //把上面的设置item都添加进入
        [self addSpotlightItem:items];
    } else {
    }
}

- (void)cancelAllLocadNotifi{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)setEveryDataLocadNotifi:(NSString *)timeStr textArray:(NSArray*)testArray{
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    //声明本地通知对象
    if (localArray) {
        for (int i = 0; i< localArray.count;i++) {
            UILocalNotification *noti = [localArray objectAtIndex:i];
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:App_Local_Push_Key];
                if ([inKey isEqualToString:App_Local_Push_Key]) {
                    [app cancelLocalNotification:noti];
                }
            }
        }
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *array = testArray;
    
    NSTimeInterval  interval = 24*60*60*1; //1:天数
    NSDate *date1 = [[NSDate date] initWithTimeIntervalSinceNow:-interval];//前一天
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //  [formatter setFormatterBehavior:NSDateFormatterFullStyle];
    NSDateFormatter *formatterNew = [[NSDateFormatter alloc] init];
    [formatterNew setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for (int i = 0; i < 1; i++) {
        NSTimeInterval  interval = 24*60*60*(i+1); //1:天数
        NSDate *dateNew = [date1 dateByAddingTimeInterval:interval];
        NSString *str = [formatter stringFromDate:dateNew];
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        NSString *strDate1 = [NSString stringWithFormat:@"%@ %@",str,timeStr];
        notification.fireDate=[formatterNew dateFromString:strDate1];//本次开启立即执行的周期
        notification.repeatInterval=NSCalendarUnitDay;//循环通知的周期
        notification.timeZone=[NSTimeZone defaultTimeZone];
        NSDictionary *info = [NSDictionary dictionaryWithObject:App_Local_Push_Key forKey:App_Local_Push_Key];
        notification.alertBody = [array objectAtIndex:arc4random()%[array count]];
        notification.userInfo = info;
        notification.soundName= UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
}


-(void)resigerJSPush:(NSDictionary *)launchOptions{
#if App_Use_OSS_Sycn
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // 3.0.0及以后版本注册
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    BOOL isProduction = true;
#ifdef  DEBUG
    isProduction = false;
#endif
    [JPUSHService setupWithOption:launchOptions appKey:@"792fd7957d1f7b2121acf618"
                          channel:@"AppStore"
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
#endif
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
#if App_Use_OSS_Sycn
    [JPUSHService handleRemoteNotification:userInfo];
#endif
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
#if App_Use_OSS_Sycn
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
#endif
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
#if App_Use_OSS_Sycn
        [JPUSHService handleRemoteNotification:userInfo];
#endif
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    NSString *url = [userInfo objectForKey:@"url"];
    if(url){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSpotLightUrl" object:url];
        });
    }
    completionHandler();  // 系统要求执行这个方法
}
#endif


-(void)showLocalNotifi:(NSString*)msg{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.userInfo = @{@"hehe":@"nidaye"};
        notification.alertBody = msg;
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.fireDate = [[NSDate date]dateByAddingTimeInterval:1];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

/*
- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(nullable NSDictionary*)info{
    NSLog(@"handleCrashException");
}

- (void)handleCrashException:(NSString*)exceptionMessage exceptionCategory:(JJExceptionGuardCategory)exceptionCategory extraInfo:(nullable NSDictionary*)info{
    NSLog(@"handleCrashException exceptionMessage");
}*/

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return self.supportRotationDirection;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef DEBUG
     //JaiBrokenJudge
#else
   // [JJException configExceptionCategory:(JJExceptionGuardAll)];
   // [JJException registerExceptionHandle:self];
   // [JJException startGuardException];
    
#endif
//    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
//    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = App
//    [[SGWiFiUploadManager sharedManager]  startUpLoadServer:ThrowUpLoadHttpServerPort callBack:^(NSString *ip) {
//       //  [weakSelf updateIpLabel:ip];
//    } finshBlock:^(NSString *fileName, NSString *savePath) {
//       //[weakSelf reloadLocalData];
//    }];
//
//    return true;
    [QRWebBlockManager shareInstance];
    
    if (@available(iOS 13.0, *)) {
           UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
       [MajorSystemConfig getInstance].zhiboFixTopH  =statusBarManager.statusBarFrame.size.height;
       }
       else{
         [MajorSystemConfig getInstance].zhiboFixTopH  =[[UIApplication sharedApplication] statusBarFrame].size.height;
       }
        //屏蔽长按c弹出事件
    [NSClassFromString(@"WKActionSheetAssistant") aspect_hookSelector_App:NSSelectorFromString(@"showLinkSheet") withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo_App> aspectInfo){
        NSLog(@"WKActionSheetAssistant showLinkSheet");
    }error:NULL];//end
 
 
    GetAppDelegate.backGroundDownMode = [MarjorWebConfig getInstance].isAllowsBackGroundDownMode;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
 
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i<6; i++) {
            [UIImage imageNamed:[NSString stringWithFormat:@"Brower.bundle/tishi_btn%d.png",i+1]];
        }
    });
    [self resigerJSPush:launchOptions];
     NSDictionary *dictNU = [[NSDictionary alloc] initWithObjectsAndKeys:IosIphoneOldUserAgent, @"UserAgent", nil];
     [[NSUserDefaults standardUserDefaults] registerDefaults:dictNU];
                
    if (![[NSFileManager defaultManager]fileExistsAtPath:AppSynchronizationDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:AppSynchronizationDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager]fileExistsAtPath:AppNotSynchronizationDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:AppNotSynchronizationDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:BeatifyWebPicsViewWebRoot]){
        [[NSFileManager defaultManager] createDirectoryAtPath:BeatifyWebPicsViewWebRoot withIntermediateDirectories:NO attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[BeatifyWebPicsViewWebRoot stringByAppendingPathComponent:BeatifyWebPicsViewPicDirName] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [SpotlightCaches.diskCache setCountLimit:100];
    
    [self addSpotlightByGoup:@"电影电视剧在线" des:@"最新电影电视剧" key:@"最新电影电视剧免费在线" url:@"http://www.lemaotv.net" group:DefalutDomainIdentifier];
    [self addSpotlightByGoup:@"百度视频搜索图片音乐地图" des:@"百度视频搜索图片音乐地图" key:@"百度视频搜索图片音乐地图" url:@"http://www.baidu.com" group:DefalutDomainIdentifier];
    [self addSpotlightByGoup:@"优酷视频电视剧电影" des:@"优酷视频电视剧电影" key:@"优酷视频电视剧电影" url:@"http://www.youku.com" group:DefalutDomainIdentifier];
    [self addSpotlightByGoup:@"淘宝天猫商城购物网站" des:@"淘宝天猫商城购物网站" key:@"淘宝天猫商城购物网站" url:@"http://www.taobao.com" group:DefalutDomainIdentifier];

    //self.isMajorMainShouldAutorotate = YES;
    [self reportSiriShortcuts];
    self.isAppTipsViewTop = -1;
    float ww = [[UIScreen mainScreen] bounds].size.width;
    float hh = [[UIScreen mainScreen] bounds].size.height;
    if (ww<hh) {
        [MajorSystemConfig getInstance].appSize = CGSizeMake(ww, hh);
    }
    else{
        [MajorSystemConfig getInstance].appSize = CGSizeMake(hh, ww);
    }
    [[MajorSystemConfig getInstance] updateBannerZeor:false];
    [[MajorSystemConfig getInstance] setBannerRect];
    [self initShareSdk];
    [MajorICloudSync getInstance];
    [JsServiceManager getInstance];
    [MajorICloudSync getInstance];
    
   
    self.webReadModeServer = [[GCDWebServer alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.webReadModeServer addDefaultHandlerForMethod:@"GET"
                             requestClass:[GCDWebServerRequest class]
                             processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {                                 return [GCDWebServerDataResponse responseWithHTML:weakSelf.readBodyReturn];
                                 
                             }];
    [self.webReadModeServer startWithPort:ReadModeServerPort bonjourName:nil];
    self.supportRotationDirection = UIInterfaceOrientationMaskPortrait;
    [DKColorTable sharedColorTable].file = @"AppMain.bundle/MajorColorTable.txt";
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.window = [[MyUIfWindow alloc] initWithFrame:rect];
    self.window.rootViewController = [[MajorMain alloc]init];
    //self.window.rootViewController = [[DebugCtrl alloc]init];
    [self.window makeKeyAndVisible];
#if Finger_mover==0
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 100, 100, 50);
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"新闻" forState:UIControlStateNormal];
    [self.window addSubview:btn];
    [btn addTarget:self action:@selector(createNewWeb) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnWeb = [UIButton buttonWithType:UIButtonTypeCustom];
    btnWeb.frame = CGRectMake(0, 150, 100, 50);
    btnWeb.backgroundColor = [UIColor blackColor];
    [btnWeb setTitle:@"广告" forState:UIControlStateNormal];
    [self.window addSubview:btnWeb];
    [btnWeb addTarget:self action:@selector(createAdsWeb) forControlEvents:UIControlEventTouchUpInside];
#endif
    UIApplication *app = [UIApplication sharedApplication];
    if([app respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
        [app beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showRequest20180927];
    });
    
    @weakify(self)
    [RACObserve([MajorICloudSync getInstance], isSyncToFinish) subscribeNext:^(id x) {
        @strongify(self)
        if ([MajorICloudSync getInstance].isSyncToFinish) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self loadSyncSpotlight];
            });
        }
    }];
    
    [ZYNetworkAccessibity setAlertEnable:YES];
    
    [ZYNetworkAccessibity setStateDidUpdateNotifier:^(ZYNetworkAccessibleState state) {
        NSLog(@"setStateDidUpdateNotifier > %zd", state);
        if (state == ZYNetworkAccessible ) {
            [[MajorFeedbackKit getInstance] updateUnreadCount];
            if (!isCheckVersionState) {
                [self PostpathAPPStoreVersion];
            }
            static BOOL isAddSync = false;
            if (!isAddSync) {
                [[MajorICloudSync getInstance] syncNetToLoalInMainThread:nil failure:nil];
                isAddSync = true;
            }
        }
    }];
    [ZYNetworkAccessibity start];
    
    if (![self checkInitMaxApp]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"重要提示" message:@"请保留官方版本，此版本可能随时用不了"];
            TYAlertAction *v  = [TYAlertAction actionWithTitle:@"取消"
                                                         style:TYAlertActionStyleCancel
                                                       handler:^(TYAlertAction *action) {
                                                           
                                                       }];
            TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"下载官方"
                                                          style:TYAlertActionStyleDestructive
                                                        handler:^(TYAlertAction *action) {
                                                            NSString *ss = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8",PRODUCTID];
                                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ss]];
                                                        }];
            [alertView addAction:v1];
            [alertView addAction:v];
            [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
        });
    }
//    [[BUDAdManager getInstance] initBudParam];
    [[VipPayPlus getInstance] initPlus];
#ifdef DEBUG
   // [[GHConsole sharedConsole] startPrintLog];
#endif
    [self startDownFileServer];
    //
    [AppWtManager getInstanceAndInit];
    [[NSNotificationCenter defaultCenter] postNotificationName:[DownApiConfig apiConfig].msgappOverall object:[DownApiConfig apiConfig].msgappf1];
    //end
    [self showWebTishi];
    [self startSplash2];
    return YES;
}

-(void)showWebTishi{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    [self.window.rootViewController.view addSubview: backView];
    backView.backgroundColor = RGBCOLOR(0, 0, 0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(@"url_web_qidong")];
    //750X666;
    float w = MY_SCREEN_WIDTH;
    float h = 666.0/750*MY_SCREEN_WIDTH;
    imageView.frame = CGRectMake(0, (MY_SCREEN_HEIGHT-h)/2, w, h);
    [backView addSubview:imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [backView removeFromSuperview];
    });
}

-(void)startDownFileServer{
    NSString* documentsPath = VIDEOCACHESROOTPATH;
         // 创建webServer,设置根目录
         self.fileWebDown = [[FileWebDownLoader alloc] initWithUploadDirectory:documentsPath];
         // 设置代理
         self.fileWebDown.allowHiddenItems = YES;
         // 开启
         if ([_fileWebDown start]) {
                // NSString *ipString = [SJXCSMIPHelper deviceIPAdress];
                // NSLog(@"ip地址为：%@", ipString);
              } else {
                     NSLocalizedString(@"GCDWebServer not running!", nil);
                 }
    
    NSString *tmpOldDir = [NSString stringWithFormat:@"%@/VideoDownCaches",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]];
    NSString *tt = [NSString stringWithFormat:@"%@_old",documentsPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpOldDir]){
        [[NSFileManager defaultManager] moveItemAtPath:tmpOldDir toPath:tt error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tmpOldDir error:nil];
    }
}

-(BOOL)checkInitMaxApp{
    return true;
    NSURL *url = [NSURL URLWithString:@"majorWeb://"];
    BOOL ret =  [[UIApplication sharedApplication]canOpenURL:url];
    return ret;
}

-(void)loadSyncSpotlight
{
    NSArray *array = [SpotlightCaches allCacheKey];
    for (int i = 0; i < array.count; i++) {
        [self addSpotlightItem:[SpotlightCaches objectForKey:[array objectAtIndex:i ]]];
    }
}

-(void)willRemoveFromSuperView:(BOOL)isMode{
    if (isMode) {
        self.newsWeb = nil;
    }
    else{
        self.adsWeb = nil;
    }
}

#if Finger_mover==0
-(void)createNewWeb{
    if (!self.newsWeb) {
        self.newsWeb = [[AppAdWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
        [self.window addSubview:self.newsWeb];
        self.newsWeb.delegate = self;
        [self.newsWeb loadUrl:@"https://cpu.baidu.com/1021/a4198c12?scid=18407" isNewMode:true];
    }
}

- (void)createAdsWeb{
    if (!self.adsWeb) {
        self.adsWeb = [[AppAdWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
        [self.window addSubview:self.adsWeb];
        self.adsWeb.delegate = self;
        [self.adsWeb loadUrl:@"https://cpu.baidu.com/1021/a4198c12?scid=18407" isNewMode:false];
    }
}
#endif

- (void)showRequest20180927
{
    return;
    NSString *key = @"showRequest20180927";
   id v = [FTWCache objectForKey:key useKey:YES];
    if (!v) {
       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
       int number = [[defaults objectForKey:key] intValue];
       [defaults setObject:[NSNumber numberWithInt:number+1] forKey:key];
       [defaults synchronize];
        if (number>4) {
            [FTWCache setObject:[@"dd" dataUsingEncoding:NSUTF8StringEncoding] forKey:key useKey:YES];
            if (@available(iOS 10.3, *)) {
                [SKStoreReviewController requestReview];
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
//耳机线控模式
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[VideoPlayerManager getVideoPlayInstance]playPause];
                   break;
            case UIEventSubtypeRemoteControlPlay:
                [[VideoPlayerManager getVideoPlayInstance]play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [[VideoPlayerManager getVideoPlayInstance]pause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                 break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                 break;
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [UIApplication sharedApplication].idleTimerDisabled = false;
    backApplicationDidEnterBackgroundTimes++;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    currentTime = 0;
    [self startSystemBackgroundTask];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [application setApplicationIconBadgeNumber:0];
    [self.backTimer invalidate];
    self.backTimer = nil;
    [self stopSystemBackgroundTask];
    //[self showUpdateAlter:isCanCreateAlter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZYNetworkAccessibleState state =[ZYNetworkAccessibity currentState];
        if (state == ZYNetworkUnknown || state==ZYNetworkRestricted) {
            [ZYNetworkAccessibity showNetworkAlert];
        }
    });
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:str nCount:1 isUseYYCache:true time:nil]) {
        [[helpFuntion gethelpFuntion] isValideOneDay:str nCount:1 isUseYYCache:true time:nil];
    }
}


-(void )initShareSdk{
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeWechat),@(SSDKPlatformTypeQQ)]  onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wxaa7013e307d9cb97"
                                      appSecret:@"499ff025348ee15c6efb99725faa3027"];
                break;
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:@"1107924397" appKey:@"JQEDT0I9Jc1WTFaW" authType:SSDKAuthTypeBoth];
                break;
                
        }
    }];
}

-(void) startSystemBackgroundTask
{
#if TARGET_OS_IPHONE
    __block UIBackgroundTaskIdentifier backgroundTaskId = UIBackgroundTaskInvalid;
    
    
    backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
                        {
                            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                            backgroundTaskId = UIBackgroundTaskInvalid;
                        }];
    
    stopBackBackgroundTaskBlock = [^
                                   {
                                       if (backgroundTaskId != UIBackgroundTaskInvalid)
                                       {
                                           [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                                           backgroundTaskId = UIBackgroundTaskInvalid;
                                       }
                                   } copy];
    
    self.backTimer = [NSTimer scheduledTimerWithTimeInterval:(1) target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [self.backTimer fire];
#endif
}

-(void) stopSystemBackgroundTask
{
#if TARGET_OS_IPHONE
    if (stopBackBackgroundTaskBlock != NULL)
    {
        stopBackBackgroundTaskBlock();
        stopBackBackgroundTaskBlock = NULL;
    }
#endif
}

-(void)updateTime{
     if (currentTime++>20&& backApplicationDidEnterBackgroundTimes>=2&&[[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:str nCount:1 isUseYYCache:true time:nil]) {
        if(true){
         //   printf("will kill currentTime = %d backApplicationDidEnterBackgroundTimes = %d\n",currentTime,backApplicationDidEnterBackgroundTimes);
            [[helpFuntion gethelpFuntion] isValideOneDay:str nCount:1 isUseYYCache:true time:nil];
            NSDate *currentDate = [NSDate date];
            NSDateFormatter*df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"HH"];//格式化
            NSInteger vv = [[df stringFromDate:currentDate] intValue];
            if( vv>=0 && !isShowAlter){//记录当前的值
                [self showUpdateAlter:true];
            }
        }
    }
    
  //  printf("currentTime = %d backApplicationDidEnterBackgroundTimes = %d backgroundTimeRemaining =%f\n ",currentTime,backApplicationDidEnterBackgroundTimes,[UIApplication sharedApplication].backgroundTimeRemaining);
}

-(void)showUpdateAlter:(BOOL)isCanCreate{
    return;
    if (!isShowAlter && isCanCreate) {
        isShowAlter = true;
        abort();/*
        UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据已经更新完成，重启后生效" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重启", nil];
        [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==0) {
                isShowAlter = false;
                isCanCreateAlter = true;
            }
            else if (buttonIndex==1){
                [[helpFuntion gethelpFuntion] isValideOneDay:str nCount:1];
                UIWindow *window = GetAppDelegate.window;
                [UIView animateWithDuration:0.4f animations:^{
                    window.alpha = 0;
                    CGFloat y = window.bounds.size.height;
                    window.frame = CGRectMake(0, y, 0, 0);
                } completion:^(BOOL finished) {
                    exit(0);
                }];
            }
        }];*/

    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * ret))restorationHandler {
    NSLog(@"continueUserActivity");
    if ([userActivity.activityType isEqualToString:@"com.iperfectapp.guangchangwu.open"]) {
        // 做自己的业务逻辑
    }
    if (@available(iOS 9.0, *)) {
        if ([[userActivity activityType] isEqualToString:CSSearchableItemActionType]) {
            //获取唯一ID，在MarkDisk中，它即是文件的相对路径
            NSString *uniqueIdentifier = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
            NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:uniqueIdentifier options:0];
            //Decode NSString from NSData
            NSString *base64Decode = [[NSString alloc]initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
            //显示对应的文件，代码略
            NSString *url = base64Decode;
            NSArray *value  = (NSArray*)[SpotlightCaches objectForKey :uniqueIdentifier];
            if (value.count>0) {
               CSSearchableItem * item = [value firstObject];
                CSSearchableItemAttributeSet *setValue =item.attributeSet;
                if(setValue.URL){
                    url = [setValue.URL absoluteString];
                }
                NSLog(@"uniqueIdentifier");
            }
           if (![self.penFromSpotLightUrl isEqualToString:url]) {
                self.penFromSpotLightUrl = url;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSpotLightUrl" object:self.penFromSpotLightUrl];
            }
        }
    } else {
        // Fallback on earlier versions
    }
    return YES;
}

-(void)reportSiriShortcuts{
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.iperfectapp.guangchangwu.open"];
    if (@available(iOS 9.0, *)) {
        userActivity.eligibleForSearch = YES;
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 12.0, *)) // 如果要支持老版本，加上判断
    {
        userActivity.eligibleForPrediction = YES;
    }
    userActivity.title = @"动起来";
    userActivity.userInfo = @{@"testKey" : @"hi！兄弟！好东西给你准备好了！身体准备好了么"};
    self.userActivity = userActivity;
}


- (void)networkDidSetup:(NSNotification *)notification {
     NSLog(@"network DidSetup已连接");
}

//长连接关闭
- (void)networkDidClose:(NSNotification *)notification {
     NSLog(@"network DidClose未连接");
 }

//注册成功
- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"networkDidRegister %@", [notification userInfo]);
}

//登录成功
- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"networkDidLogin 已登录");
}

//客户端收到自定义消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSUInteger messageID = [[userInfo valueForKey:@"_j_msgid"] unsignedIntegerValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\nmessage:%ld\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, [self logDic:extra],(unsigned long)messageID];
    NSLog(@"%@", currentContent);
}

- (void)serviceError:(NSNotification *)notification {

}
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

//不通过这里判断
- (void)PostpathAPPStoreVersion
{
    return;
    // 这是获取appStore上的app的版本的url
    if (isCheckVersionState) {
        return;
    }
    NSString *appStoreUrl = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%@",PRODUCTID];
    
    
    NSURL *url = [NSURL URLWithString:appStoreUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([[receiveDic valueForKey:@"resultCount"] intValue]>0) {
                
                [receiveStatusDic setValue:@"1" forKey:@"status"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"]   forKey:@"version"];
            }else{
                
                [receiveStatusDic setValue:@"-1" forKey:@"status"];
            }
        }else{
            [receiveStatusDic setValue:@"-1" forKey:@"status"];
        }
        
        [self performSelectorOnMainThread:@selector(receiveData:) withObject:receiveStatusDic waitUntilDone:NO];
    }];
    
}

-(void)receiveData:(id)sender
{
    isCheckVersionState = true;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 手机当前APP软件版本  比如：1.0.2
    NSString *nativeVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *storeVersion  = sender[@"version"];
    
    NSLog(@"本地版本号curV=%@", nativeVersion);
    NSLog(@"商店版本号appV=%@", sender[@"version"]);
    
    float n1 = [nativeVersion floatValue];
    float n2 = [storeVersion floatValue];
    if (n1<n2) {
        UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"有新版本是否更新" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
        [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==0) {
             }
            else if (buttonIndex==1){
                NSString *ss = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8",PRODUCTID];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ss]];
                
            }
        }];
    }
}


-(void)startSplash1{
    CGRect rect = [[UIScreen mainScreen] bounds];
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:@"826154313" frame:rect];
    // tolerateTimeout = CGFLOAT_MAX , The conversion time to milliseconds will be equal to 0
    splashView.tolerateTimeout = 5;
    splashView.delegate = self;
    UIWindow *keyWindow = self.window;
    [splashView loadAdData];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
 }

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    printf("didFailWithError %s\n",[[error description] UTF8String]);
    [splashAd removeFromSuperview];
 }

-(void)startSplash2{
    self.splashAd = [[GDTSplashAd alloc] initWithAppId:@"1109675609"
                                           placementId:@"5080788339020365"];
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 5;
    UIImage *splashImage = [UIImage imageNamed:@"SplashNormal"];
    if (isIPhoneXSeries()) {
        splashImage = [UIImage imageNamed:@"SplashX"];
    } else if ([UIScreen mainScreen].bounds.size.height == 480) {
        splashImage = [UIImage imageNamed:@"SplashSmall"];
    }
    self.splashAd.backgroundImage = splashImage;
    self.splashAd.backgroundImage.accessibilityIdentifier = @"splash_ad";
    
    CGFloat logoHeight = 184;
    UIView *bottomView = nil;
    if (logoHeight > 0 && logoHeight <= [[UIScreen mainScreen] bounds].size.height * 0.25) {
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, logoHeight)];
        bottomView.backgroundColor = [UIColor whiteColor];
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashLogo"]];
        logo.accessibilityIdentifier = @"splash_logo";
        logo.frame = CGRectMake(0, 0, 311, 47);
        logo.center = bottomView.center;
        [bottomView addSubview:logo];
    } else {
         return;
    }
    UIWindow *fK = [[UIApplication sharedApplication] keyWindow];
    [self.splashAd loadAdAndShowInWindow:fK withBottomView:bottomView skipView:nil];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    NSLog(@"%s%@",__FUNCTION__,error);
    self.splashAd = nil;
    GetAppDelegate.isGdtNativewShow = true;
 }


- (void)splashAdClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    self.splashAd = nil;
    GetAppDelegate.isGdtNativewShow = true;
 }
@end
