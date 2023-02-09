//
//  MajorSystemConfig.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/17.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorSystemConfig.h"
#import "SFHFKeychainUtils.h"
#import "MKNetworkEngine.h"
#import "AdVertUrlConfig.h"
#import "MajorSchemeHelper.h"
#import "AdvertGdtInterstitialManager.h"
#import "AdvertGdtBannerManager.h"
#import "AdvertGdtManager.h"
#import "ClickManager.h"
#import "WebCoreManager.h"
#import "AppDelegate.h"
#import "AppAdManager.h"
#include <string>
#import "BeatifyAliOssManager.h"
#import <AdSupport/AdSupport.h>

#import "KSCrashReportFilterSets.h"
#import "KSCrashReportFilter.h"
#import "KSCrashReportFilterAppleFmt.h"
#import "KSCrashReportFilterBasic.h"
#import "KSCrashReportFilterGZip.h"
#import "KSCrashReportFilterJSON.h"
#import "KSCrashReportSinkConsole.h"
#import "KSCrashReportSinkEMail.h"
#import "KSCrashReportSinkQuincyHockey.h"
#import "KSCrashReportSinkStandard.h"
#import "KSCrashReportSinkVictory.h"
#import "KSCrash.h"
#import "KSCrashC.h"
#import "OSSManager.h"
#import "OSSWrapper.h"
#import <BUAdSDK/BUAdSDK.h>
#define LOCALBTNINFO @"watchsf_d"
#define NEWLOCALBTNINFO [NSString stringWithFormat:@"new2018_watchsf_d_%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]

#define UpDateProxState        dispatch_async(dispatch_get_global_queue(0, 0), ^{ \
NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings()); \
NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings))); \
NSDictionary *settings = proxies[0]; \
if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) \
{ \
    dispatch_async(dispatch_get_main_queue(), ^{ \
        GetAppDelegate.isProxyState = false; \
    });\
} \
else{ \
    dispatch_async(dispatch_get_main_queue(), ^{ \
        GetAppDelegate.isProxyState = true; \
    }); \
} \
});

void CommonHelp_delChar(std::string *s,const char *del){
    size_t index =  s->find(del);
    while (index!=std::string::npos) {
        s->erase(index,1);
        index = s->find(del);
    }
}

int  stringToInt(std::string str){
    std::string strNew=str;
    CommonHelp_delChar(&strNew, ".");
    return atoi(strNew.c_str());
}

@interface MajorSystemConfig(){
    OSSClient *_client;
    float _bannerHeight;
    float _bannerWidth;
}
@property(assign,nonatomic)CGRect bannerAdRect;
@property(nonatomic,strong)MKNetworkEngine *netWorkTimeEngine;
@property(nonatomic,assign)AFNetworkReachabilityStatus isWifiState;
@end
@implementation MajorSystemConfig

+(MajorSystemConfig*)getInstance{
    static MajorSystemConfig*g = nil;
    if (!g) {
        g = [[MajorSystemConfig alloc] init];
    }
    return g;
}

-(void)setIs_qq_Apl:(BOOL)is_qq_Apl{
    if(self.fix_qq_Apl){
        _is_qq_Apl = false;
    }
    else{
        _is_qq_Apl = is_qq_Apl;
    }
}

-(void)updateBannerZeor:(BOOL)isZeor{
    _bannerWidth = 375;
    if (isZeor) {
        _bannerHeight = 0;
    }
    else{
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat bannerHeigh = screenWidth/375*60;
        if (IF_IPAD) {
            screenWidth = screenWidth/2;
            _bannerWidth = screenWidth;
             bannerHeigh = screenWidth/375*60;

        }
        _bannerHeight = bannerHeigh;
        //BUSize *size = [BUSize sizeBy:BUProposalSize_Banner600_90];
        //const CGFloat screenWidth =  self.appSize.width;
        //_bannerHeight = screenWidth * size.height / size.width;
    }
}

-(void)setBannerRect{
    self.bannerAdRect  = CGRectMake((self.appSize.width-_bannerWidth)/2, GetAppDelegate.appStatusBarH, _bannerWidth, _bannerHeight);
}

-(id)init{
    self = [super init];
    self.isDebugMode = false;
    
    self.appIsRealseVesion = true;
    self.appUserDebugAdID = false;
    self.isEeveryDayReStart = false;
    self.isExcApla = true;self.isGotoUserModel = 2;
    self.changeAdvertIdTime = 10*3600;
    self.gdtPgkType = 1;
    self.maxClickTimeValue = 5;
    self.apiState = -1;
    self.isDelGdtCreateDir = true;
    self.isOpen = YES;
    self.gdtWebfilterArray = @[@"itms-appss",@"itunes.apple.com"];
    self.lelinkAppId = @"13197";
    self.lelinkAppSecretKey = @"dfd7176400b4b2db8488271951891edb";
    self.param8 = @[@{@"url":@"https://www.huya.com/g/2135",@"name":@"影视直播"},@{@"url":@"https://m.huya.com/g/2168",@"name":@"美女直播"}];
     self.param13 = @{@"endPoint":OSS_ENDPOINT,@"bucket":OSS_BUCKET_PRIVATE,@"js":@"https://softhome.oss-cn-hangzhou.aliyuncs.com/max/help/test/ckplayer/ckplayer.js",@"dns":@"http://share.max77.cn/"};
    self.adAppUrlArray = nil;
    self.everyAdAppDayTime = 1;
    self.intervalAdAppDay = 2;
    
    [self gogogo];
    [self requestConfig];
    [NSTimer bk_scheduledTimerWithTimeInterval:10 block:^(NSTimer *timer) {
 UpDateProxState
    } repeats:YES];
    UpDateProxState
    [self startMonitoring];
    [self startReqeustNetWorkTime];
#if App_Use_OSS_Sycn
    //bug 提交初始化
    OSSPlainTextAKSKPairCredentialProvider *provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 3;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    conf.maxConcurrentRequestCount = 5;
    
    // switches to another credential provider.
    _client = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT
                               credentialProvider:provider
                              clientConfiguration:conf];
    [self installCrashHandler];
    //end
#endif
    return self;
}

-(void)startReqeustNetWorkTime{
    if (!self.netWorkTimeEngine) {
        self.netWorkTimeEngine = [[MKNetworkEngine alloc] init];
    }
    MKNetworkOperation *timeOperation = [self.netWorkTimeEngine operationWithURLString:@"http://quan.suning.com/getSysTime.do" timeOut:3];
    [timeOperation onCompletion:^(MKNetworkOperation *completedOperation) {
        NSInteger code= completedOperation.HTTPStatusCode;
        if (code>=200&& code<300) {
            id value = [completedOperation.responseString JSONValue];
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSString *v = [value objectForKey:@"sysTime2"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
#ifdef DEBUG
               // v = @"2019-05-15 20:20:20";
                self.netDateTime  = [NSDate date];
#else
                self.netDateTime =  [dateFormatter dateFromString:v];
#endif
                if (!self.netDateTime) {
 
                }
                else{
                 }
            }
        }
        else{
         }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self performSelector:@selector(startReqeustNetWorkTime) withObject:nil afterDelay:3];
     }];
    [self.netWorkTimeEngine enqueueOperation:timeOperation];
}

- (void) startMonitoring{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.isWifiState = status;
        NSLog(@"AFNetworkReachabilityStatus===%ld", (long)status);
    }];
}

-(void)gogogo{
    UpDateProxState
}

//当前版本比旧版本的高，赠送金币
-(bool)giveGoldVersion:(NSString *)strOldVersion isCompare:(BOOL)flag{
    BOOL ret = true;
    if (flag) {
        int oldVersion = stringToInt([strOldVersion UTF8String]);
        int  newVersion = stringToInt([kAppVersion UTF8String]);
        if (newVersion<=oldVersion) {
            ret = false;
        }
        //printf("%s  oldVersion = %d,newVersion = %d \n",__FUNCTION__,oldVersion,newVersion);
    }
    if (ret) {
        //赠送
        
    }
    return ret;
}

-(void)sycnVersion{
    NSString *str = [SFHFKeychainUtils getPasswordForUsername:kApp_Version_old andServiceName:ServeNameAccessManager error:nil];
    if (!str) {
        [SFHFKeychainUtils storeUsername:kApp_Version_old andPassword:kAppVersion forServiceName:ServeNameAccessManager updateExisting:YES error:nil];
        [self giveGoldVersion:str isCompare:false];
    }
    else {
        if ([kAppVersion isEqualToString:str]) {
            
        }
        else {
            bool ret = [self giveGoldVersion:str isCompare:true];//低版本到高版本才能评价
            if (ret) {
               // [RFRateMe resetRFRateRecords];
                [FTWCache removeObject:LOCALBTNINFO];
                [FTWCache removeObject:NEWLOCALBTNINFO];
                [SFHFKeychainUtils storeUsername:kApp_Version_old andPassword:kAppVersion forServiceName:ServeNameAccessManager updateExisting:YES error:nil];
                [SFHFKeychainUtils deleteItemForUsername:kAppVserion_isPress andServiceName:ServeNameAccessManager error:nil];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)requestConfig{//每次版本更新的时候，修改NEWLOCALBTNINFO 的值
     if(![FTWCache objectForKey:NEWLOCALBTNINFO useKey:YES]&&false){//新用户或者旧版本升级的用户，这个值是没有的
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];//删除gdt目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"tencent_gdtmob"] error:NULL] ;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [FTWCache removeObject:LOCALBTNINFO];
        [FTWCache removeObject:NEWLOCALBTNINFO];
        [SFHFKeychainUtils deleteItemForUsername:kApp_Version_old andServiceName:ServeNameAccessManager error:nil];
         if (GetAppDelegate.isAppTipsViewTop==-1) {
             GetAppDelegate.isAppTipsViewTop=0;
         }
    }
    else{
        if (GetAppDelegate.isAppTipsViewTop==-1) {
            GetAppDelegate.isAppTipsViewTop=1;
        }
    }
    [self sycnVersion];
    //[MobClick setCrashReportEnabled:false];
   // [UMConfigure initWithAppkey:UMFeedbackID channel:@"nil"];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc]initWithHostName:@"maxdownapp.oss-cn-hangzhou.aliyuncs.com/"];
    MKNetworkOperation *op = [engine operationWithPath:PINJIAURL params:nil httpMethod:@"GET" ssl:true timeOut:5];
    [op onCompletion:^ (MKNetworkOperation *completedOperation) {
        NSString *response = [FTWCache decryptWithKey:completedOperation.responseData];
        [FTWCache setObject:[response dataUsingEncoding:NSUTF8StringEncoding] forKey:NEWLOCALBTNINFO useKey:YES];
        NSDictionary *dicInfo = [response JSONValue];
        [self pareApiInfo:dicInfo];
    } onError:^(NSError *error ,MKNetworkOperation *completedOperation) {
        NSData *state = [FTWCache objectForKey:NEWLOCALBTNINFO useKey:YES];
        if (state) {
            NSString *stateEncoding = [[[NSString alloc]initWithData:state encoding:NSUTF8StringEncoding] autorelease];
            NSDictionary *dicInfo = [stateEncoding JSONValue];
            [self pareApiInfo:dicInfo];
        }
        else {
             self.isOpen = YES;
            self.isReqestFinish = true;
            //请求失败的时候，还需要请求
            //GetAppDelegate.isReqestFaild = true;
            [self performSelector:@selector(requestConfig) withObject:nil afterDelay:0.5];
        }
        BOOL ret = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isPressAccessTime"] boolValue];
        if (ret) {
        }
        [engine release];
    }];
    [engine enqueueOperation:op];
}

-(void)pareApiInfo:(NSDictionary*)dicInfo{
    NSString*strSeriveApi = [dicInfo objectForKey:@"serverapiurl"];
    if (strSeriveApi ){//走api解析流程
       // [[AdVertUrlConfig getInstance] start:^(NSString *configUrl) {
       //     [self requestConfig2:configUrl];
       // } serviceUrl:strSeriveApi urlArray:[dicInfo objectForKey:@"adUrl"]];
        [self requestConfig2:[[dicInfo objectForKey:@"adUrl"]objectAtIndex:0]];
    }
}

-(void)requestConfig2:(NSString*)configUrl{
   // printf("requestConfig2 configUrl = %s\n",[[configUrl description] UTF8String]);
    MKNetworkEngine *engine = [[MKNetworkEngine alloc]initWithHostName:@"softhome.oss-cn-hangzhou.aliyuncs.com"];
    MKNetworkOperation *op = [engine operationWithURLString:configUrl params:nil httpMethod:@"GET" timeOut:5];
    [op onCompletion:^ (MKNetworkOperation *completedOperation) {
        NSString *response = [FTWCache decryptWithKey:completedOperation.responseData];
        [FTWCache setObject:[response dataUsingEncoding:NSUTF8StringEncoding] forKey:LOCALBTNINFO useKey:YES];
        NSDictionary *dicInfo = [response JSONValue];
        [self pareAppInfo:dicInfo];
        // [[infoMessageNotiView getInstance] hideWaitView:self.view];
        
        [engine release];
        //[self pressStart:nil];
        
    } onError:^(NSError *error ,MKNetworkOperation *completedOperation) {
        NSData *state = [FTWCache objectForKey:LOCALBTNINFO useKey:YES];
        //[[infoMessageNotiView getInstance] hideWaitView:self.view];
        if (state) {
            NSString *stateEncoding = [[[NSString alloc]initWithData:state encoding:NSUTF8StringEncoding] autorelease];
            NSDictionary *dicInfo = [stateEncoding JSONValue];
            [self pareAppInfo:dicInfo];
        }
        else {
             self.isOpen = YES;
            self.isReqestFinish = true;
            //请求失败的时候，还需要请求
            //GetAppDelegate.isReqestFaild = true;
            [self performSelector:@selector(requestConfig2:) withObject:configUrl afterDelay:0.5];
        }
        BOOL ret = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isPressAccessTime"] boolValue];
        if (ret) {
        }
        [engine release];
    }];
    [engine enqueueOperation:op];
}

-(void)pareAppInfo:(NSDictionary*)dicInfo{
#ifdef DEBUG
    //NSString *jjj = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"xia_max_config1.2_new" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
   //dicInfo = [jjj JSONValue];
#endif
    if (GetAppDelegate.isProxyState) {
        dicInfo = nil;
    }
    NSString *strPingJiaOpen = [dicInfo objectForKey:@"gamelist"];
    if([strPingJiaOpen isEqualToString:@"0"])
    {
        self.isOpen = NO;//上架
    }
    else {
        self.isOpen = YES;//审核状态标记
    }
    
    NSString*lelinkAppId= [dicInfo objectForKey:@"lelinkAppId"];
    NSString*lelinkAppSecretKey = [dicInfo objectForKey:@"lelinkAppSecretKey"];
    if (lelinkAppId && lelinkAppSecretKey) {
        self.lelinkAppId = lelinkAppId;
        self.lelinkAppSecretKey = lelinkAppSecretKey;
    }
    self.appVersion = [dicInfo objectForKey:@"appVersion"];
    self.appInitUrl = [dicInfo objectForKey:@"appInitUrl"];
    self.newVesionMsg = [dicInfo objectForKey:@"newVesionMsg"];
    if ([dicInfo objectForKey:@"fullk"]) {
        self.param8 = [dicInfo objectForKey:@"fullk"];
    }
    id value9 = [dicInfo objectForKey:@"fullp"];
    if (value9 && [value9 isKindOfClass:[NSDictionary class] ]) {
        self.param13 = value9;
        [[BeatifyAliOssManager getInstance] initAssetOssClient];
    }
    NSString *strIsUrlSchemeNil = [dicInfo objectForKey:@"isUrlSchemeNil"];
    if([strIsUrlSchemeNil isEqualToString:@"0"])
    {
        self.isUrlSchemeNil = YES;//
    }
    else {
        self.isUrlSchemeNil = NO;
    }
    
    self.buDAdappKey = [dicInfo objectForKey:@"buDAdappKey"];
    self.buDVideoID  = [dicInfo objectForKey:@"buDVideoID"];
    self.buDxxlID  = [dicInfo objectForKey:@"buDxxlID"];
    self.buDname  = [dicInfo objectForKey:@"buDname"];
    self.buDappPackAge  = [dicInfo objectForKey:@"buDappPackAge"];
    self.bukaipinID = [dicInfo objectForKey:@"bukaipinID"];
    self.buqpxxlID = [dicInfo objectForKey:@"buqpxxlID"];
    NSString *strisEeveryDayReStart = [dicInfo objectForKey:@"isEeveryDayReStart"];
    if ([strisEeveryDayReStart isEqualToString:@"0"]) {
        self.isEeveryDayReStart = true;
    }
    else{
        self.isEeveryDayReStart = false;
    }
    //gdt 配置
    NSString *strisParallelClick = [dicInfo objectForKey:@"isParallelClick"];
    if ([strisParallelClick isEqualToString:@"0"]) {
        self.isParallelClick = true;
    }
    else{
        self.isParallelClick = false;
    }
    NSString *strisDelGdtCreateDir = [dicInfo objectForKey:@"isDelGdtCreateDir"];
    if ([strisDelGdtCreateDir isEqualToString:@"0"]) {
        self.isDelGdtCreateDir = true;
    }
    else{
        self.isDelGdtCreateDir = false;
    }
    NSString *strIs_qq_apl = [dicInfo objectForKey:@"is_Gdt_Apl"];
    if ([strIs_qq_apl isEqualToString:@"0"]) {
        self.is_qq_Apl = true;
    }
    else{
        self.is_qq_Apl = false;
    }
    id tmpGdtInfo = [dicInfo objectForKey:@"gdtAdInfo"];
    //gdtAdInfo是数组，需要计算gdtAdInfo值
    NSString *strisExcApla = [dicInfo objectForKey:@"isExcApla"];
    if ([strisExcApla isEqualToString:@"0"]) {
        self.isExcApla = true;
    }
    if ([tmpGdtInfo isKindOfClass:[NSArray class]])
    {
        self.gdtUserInfo = tmpGdtInfo;
        [[AdvertGdtManager getInstance] initAdvertArray:self.gdtUserInfo];
    }
    tmpGdtInfo = [dicInfo objectForKey:@"gdtBannerAdInfo"];
    if ([tmpGdtInfo isKindOfClass:[NSArray class]])
    {
        self.gdtUserBannerInfo = tmpGdtInfo;
        [[AdvertGdtBannerManager getInstance] initAdvertArray:self.gdtUserBannerInfo];
    }
    self.gdtUserExpressInfo = [dicInfo objectForKey:@"gdtExpressAdInfo"];
    self.isGotoUserModel = [[ClickManager getInstance]isAllInfoClick:tmpGdtInfo];
    
    //adWebView
    {
    id value1 = [dicInfo objectForKey:@"adAppUrlArray"];
    if (value1) {
        self.adAppUrlArray = value1;
    }
    value1 = [dicInfo objectForKey:@"everyAdAppDayTime"];
    if (value1) {
        self.everyAdAppDayTime = [value1 intValue];
    }
    value1 = [dicInfo objectForKey:@"intervalAdAppDay"];
    if (value1) {
        self.intervalAdAppDay = [value1 intValue];
    }
    self.adJsConfig = [dicInfo objectForKey:@"adJsConfig"];
    }
    //end
    
    if(self.is_qq_Apl){
        if(self.apiState==1){//服务器控制透明点击开关
            self.is_qq_Apl = false;
        }
        else if(self.apiState==0 && ((NSArray*)tmpGdtInfo).count>0)//服务器控制透明点击开关,强制转换点击模式,清除点击状态
        {
            [[ClickManager getInstance] clearAllClickInfo];
            self.isGotoUserModel = 2;
            self.is_qq_Apl = true;
        }
    }
    self.is_save_old_qq_Apl = self.is_qq_Apl;
    printf("isGotoUserModel = %d\n",self.isGotoUserModel);
    tmpGdtInfo = [dicInfo objectForKey:@"gdtInterstitialAdInfo"];
    if ([tmpGdtInfo isKindOfClass:[NSArray class]])
    {
        self.gdtUserInterstitial = tmpGdtInfo;
        [[AdvertGdtInterstitialManager getInstance] initAdvertArray:self.gdtUserInterstitial];
    }
    tmpGdtInfo = [dicInfo objectForKey:@"gdtUserKaiKaiPinInfo"];
    if ([tmpGdtInfo isKindOfClass:[NSArray class]])
    {
        self.gdtUserKaiKaiPinInfo = tmpGdtInfo;
     }
    //
    
    NSString *strdeviceRetention = [dicInfo objectForKey:@"deviceRetention"];
    if (strdeviceRetention) {
        self.deviceRetention = [strdeviceRetention intValue];
    }
    NSString *strinitDeviceIDCount = [dicInfo objectForKey:@"initDeviceIDCount"];
    if (strinitDeviceIDCount) {
        self.initDeviceIDCount = [strinitDeviceIDCount intValue];
    }
    NSString *strgdtDelayDisplayTime = [dicInfo objectForKey:@"gdtDelayDisplayTime"];
    if (strgdtDelayDisplayTime) {
        self.gdtDelayDisplayTime = [strgdtDelayDisplayTime floatValue];
    }
    NSString *streveryGDTDayTime = [dicInfo objectForKey:@"everyGDTDayTime"];
    if (streveryGDTDayTime) {
        self.everyGDTDayTime = [streveryGDTDayTime floatValue];
    }
    NSString *strupdateNativeTime = [dicInfo objectForKey:@"gdtUpdateNativeTime"];
    if (strupdateNativeTime) {
        self.gdtUpdateNativeTime = [strupdateNativeTime floatValue];
    }
    NSString *strgdtClickOvertime = [dicInfo objectForKey:@"gdtClickOvertime"];
    if (strgdtClickOvertime) {
        self.gdtClickOvertime = [strgdtClickOvertime floatValue];
    }
    NSString *strchangeAdvertTime = [dicInfo objectForKey:@"changeAdvertIdTime"];
    if (strchangeAdvertTime) {
        self.changeAdvertIdTime = [strchangeAdvertTime floatValue];
    }
    else{
        self.changeAdvertIdTime = 30;
    }
    NSString *strmaxClickTimeValue = [dicInfo objectForKey:@"maxClickTimeValue"];
    if (strmaxClickTimeValue) {
        self.maxClickTimeValue = [strmaxClickTimeValue intValue];
    }
    else{
        self.maxClickTimeValue = 5;
    }
    //end
    tmpGdtInfo = [dicInfo objectForKey:@"gdtWebfilterArray"];
    if ([tmpGdtInfo isKindOfClass:[NSArray class]]){
        self.gdtWebfilterArray = tmpGdtInfo;
    }
    [[MajorSchemeHelper sharedHelper]addPrefixes:self.gdtWebfilterArray];
    NSString *icClearCookie = [dicInfo objectForKey:@"isClearCookie"];
    if(icClearCookie && [icClearCookie boolValue]){
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    }

    NSString *mm1 = [dicInfo objectForKey:@"safer1"];
    NSString *mm2 = [dicInfo objectForKey:@"safer2"];
    NSString *mm3 = [dicInfo objectForKey:@"safer3"];
    if (mm1&&mm2&&mm3) {
        self.msgappSaInfo = [NSDictionary dictionaryWithObjectsAndKeys:mm1,@"param1",mm2,@"param2",mm3,@"param3", nil];
    }
    [[AppAdManager getInstance] startConfigUrl:self.adJsConfig isDebugMode:self.isDebugMode];
#if DoNotKMPLayerCanShareVideo
#else
  
#if DEBUG
    self.msgappSaInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"SFBrowserRemoteViewController",@"param1",@"willDismissServiceViewController",@"param2",@"_remoteViewController",@"param3", nil];
#endif

#if DEBUG
#endif
   
#endif
#if DEBUG
    if(true){
#else
        if (self.appUserDebugAdID) {
#endif
            self.appUserDebugAdID = false;
            self.gdtUpdateNativeTime = 60;
        }
        self.isReqestFinish = true;
        
        [self checkVersion];
}

-(void)checkVersion{
#if DEBUG
    return;
#endif
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *buildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    printf("appVersion = %f buildVersion = %f\n",[self.appVersion floatValue],[buildVersion floatValue]);
    if ((self.appVersion && self.appInitUrl && [self.appVersion floatValue] >[buildVersion floatValue])) {
        UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"有新版本是否更新" message:self.newVesionMsg delegate:nil cancelButtonTitle:@"退出" otherButtonTitles:@"更新", nil];
        [v showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==0) {
                [self exitAPP];
            }
            else if (buttonIndex==1){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appInitUrl]];
                [self exitAPP];
            }
        }];
    }
}
    
-(void)exitAPP{
        UIWindow *window = GetAppDelegate.window;
        [UIView animateWithDuration:0.4f animations:^{
            window.alpha = 0;
            CGFloat y = window.bounds.size.height;
            window.frame = CGRectMake(0, y, 0, 0);
        } completion:^(BOOL finished) {
            exit(0);
        }];
}
    
    
#pragma mark --异常处理

- (void) installCrashHandler
    {
        KSCrash* handler = [KSCrash sharedInstance];
        handler.deadlockWatchdogInterval = 5.0f;
        handler.catchZombies = NO;
        handler.addConsoleLogToReport = YES;
        //    handler.printPreviousLog = YES;
        handler.onCrash = nil;
        handler.userInfo = nil;
        handler.sink = [KSCrashReportFilterPipeline filterWithFilters:
                        [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicated],
                        nil];
        handler.deleteBehaviorAfterSendAll = KSCDeleteNever;
        [handler install];
        [handler sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
            if (filteredReports.count>0) {
                NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"crash_bug"];
                if([filteredReports writeToFile:filePath  atomically:YES]){
                    NSString *keyUUID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                    NSDate *time = [NSDate date];
                   NSString *key =  [NSString stringWithFormat:@"%@/%d%_%d_%d_%d_%d_%d.txt",keyUUID,time.year,time.month,time.day,time.hour,time.minute,time.second];
                    NSString *crashMsg = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                    if ([crashMsg rangeOfString:@"AppDelegate updateTime"].location==NSNotFound) {
                        printf("%s\n",[crashMsg UTF8String]);
                        [self putTestDataWithKey:key withClient:_client withBucket:@"maxbug" filePath:filePath];
                    }
                    else{
                        kscrash_deleteAllReports();
                    }
                }
            }
        }];
}
    
 

- (void) putTestDataWithKey: (NSString *)key withClient: (OSSClient *)client withBucket: (NSString *)bucket filePath:(NSString*)filePath
    {
#if App_Use_OSS_Sycn
        NSString *objectKey = key;
        NSURL * fileURL = [NSURL fileURLWithPath:filePath];
        
        OSSPutObjectRequest * request = [OSSPutObjectRequest new];
        request.bucketName = bucket;
        request.objectKey = objectKey;
        request.uploadingFileURL = fileURL;
        request.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
        OSSTask * task = [client putObject:request];
        // [task waitUntilFinished];
        [task continueWithExecutor:[OSSExecutor defaultExecutor] withBlock:^id _Nullable(OSSTask * _Nonnull task) {
            NSLog(@"同步数据到服务error = %@",[task.error description]);
            kscrash_deleteAllReports();
            return nil;
        }];
#endif
}

@end
