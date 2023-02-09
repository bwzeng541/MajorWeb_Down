//
//  VipPayPlus.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/3.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VipPayPlus.h"
#import<CoreTelephony/CTTelephonyNetworkInfo.h>
#import<CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>
#import "FTWCache.h"
#import <WebKit/WebKit.h>
#import "IQUIWindow+Hierarchy.h"
#import "Toast+UIView.h"
#import "VipEncryption.h"
#import "YYModel.h"
#import "VipWebView.h"
#import "MKNetworkKit.h"
#import "MajorSetView.h"
#import "ZYNetworkAccessibity.h"
#import "MBProgressHUD.h"
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "TYAlertView.h"
#import "UIView+TYAlertView.h"
#import "VideoPlayerManager.h"
#import "BUDAdManager.h"
#import "MajorSystemConfig.h"
#import "NSDate+DateTools.h"
#import "helpFuntion.h"
#import "ShareSdkManager.h"
#import "AppDelegate.h"
#import "OSSManager.h"
#import "OSSWrapper.h"
#import "FTWCache.h"
#import "BUPlayer.h"
#import "VideoPreloadAd.h"
#import "NewVipPay.h"
#import "FullVideoPreloadAd.h"
#import "ZFAutoPlayerViewController.h"
#define VipConfigInfo [NSString stringWithFormat:@"%@/vipconfig",AppSynchronizationDir]
#define VipDeviceUUID [NSString stringWithFormat:@"%@/vipconfig2",AppSynchronizationDir]

#define VipPayUUIDPhone @"vip_plus_uuid"
#define VipPayUUIDPassword @"vip_plus_password"
#define VipPayUUIDEndTime @"vip_plus_EndTime"
#define VipWatchVideoTimes @"vip_plus_watch_video_times"
#define VipWatchVideoTimesVaildCount  10
#define VipWatchVideoCickIntervalDay 1

//1->200
#define WatchAdvertWhenPauseAndForeground @"20190905174850_key"
#define WatchAdvertTimes 200

//2->200
#define MaxPlayTimes 200
#define AdUrlWebTiJiaoDir [[NSString oss_documentDirectory] stringByAppendingPathComponent:@"tijiao"]

@interface VipSystemConfig()
@property(weak,nonatomic)VipPayPlus *vipPlus;
@end
@implementation VipSystemConfig : NSObject
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"vipID"  : @"id"};
}

-(_VipType)vip{
    if(_vip)
       {
           NSLog(@"getVip = %d",Recharge_User);
           return Recharge_User;
       }
    
    if(![[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:WatchVideoAdEveryDay4TimesKey nCount:WatchVideoAdEveryDay4Times  isUseYYCache:NO  time:nil])
    {
        NSLog(@"WatchVideoAdEveryDay4TimesKey finish");
        return Recharge_User;
    }
    if (_vipPlus && [_vipPlus getAssetVipValue]) {
        NSLog(@"getVip = %d",WatchVideoAd_User);
        return WatchVideoAd_User;
    }
    if ([NewVipPay getInstance].isVip) {
        return Recharge_User;
    }
    if(_vip)
    {
        NSLog(@"getVip = %d",Recharge_User);
        return Recharge_User;
    }
    if ([MajorSystemConfig getInstance].netDateTime) {
        
        BOOL ret = [[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:VipWatchVideoTimes nCount:VipWatchVideoTimesVaildCount intervalDay:VipWatchVideoCickIntervalDay isUseYYCache:false time:[MajorSystemConfig getInstance].netDateTime];
       // BOOL ret = [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:VipWatchVideoTimes nCount:VipWatchVideoTimesVaildCount isUseYYCache:NO time:[MajorSystemConfig getInstance].netDateTime];
        if(!ret){
            NSLog(@"getVip = %d",WatchVideoAd_User);
            return WatchVideoAd_Click_User;
        }
        NSLog(@"getVip = %d",General_User);
        if (GetAppDelegate.isWatchHomeVideo) {
            NSLog(@"getVip = %d",WatchVideoAd_User);
            return WatchVideoAd_User;
        }
        return General_User;
    }
    if (GetAppDelegate.isWatchHomeVideo) {
        NSLog(@"getVip = %d",WatchVideoAd_User);
        return WatchVideoAd_User;
    }
    NSLog(@"getVip = %d",General_User);
    return General_User;
}
@end
@interface VipPayPlus()<BURewardedVideoAdDelegate>{
    MKNetworkEngine *netWork;
    MKNetworkOperation *operation;
    dispatch_queue_t _queue;
    NSInteger  _index;
    NSInteger  _playSuccessTimes;//播放次数
}
@property(copy,nonatomic)NSString *uploadAsset;
@property(assign,nonatomic)BOOL isPlayState;
@property(strong,nonatomic)NSDate *currentTime;
@property(strong,nonatomic)VideoPreloadAd *preloadAdVideo;
@property(copy,nonatomic)NSString *feeBackUrl ;
@property(copy,nonatomic)void(^stopVideoAdBlock)(BOOL isSuccess);
@property(copy,nonatomic)void(^stopFullVideoAdBlock)(void);
@property(assign,nonatomic)BOOL isAccessVip;
@property(strong,nonatomic)NSMutableDictionary *videoReadInfo;
@property(strong,nonatomic)VipWebView *webView;
@property(strong,nonatomic)VipSystemConfig *systemConfig;
@property(assign,nonatomic)BOOL isLogin;
@property(assign,nonatomic)BOOL isVideoVerify;
@property(assign,nonatomic)BOOL isVideoSuccess;
@property(assign,nonatomic)BOOL isShowAlter;
@property(assign,nonatomic)BOOL isPreloadSuccess;
@property(copy,nonatomic)NSString *typeKey;
@property(strong,nonatomic)NSMutableDictionary *vipConfig;
@property(strong,nonatomic)MBProgressHUD *hubView;
@property(strong,nonatomic)BURewardedVideoAd *preloadVideoAd;
@property(strong,nonatomic)BURewardedVideoAd *rewardedVideoAd;
@property(strong,nonatomic)FullVideoPreloadAd *fullVideoAd;
@property (nonatomic, strong) OSSClient *client;
@property(strong,nonatomic)NSTimer *adChaoshiTimer;
@property(assign,nonatomic)BOOL isShowVideoState;
@property(assign,nonatomic)BOOL isShowFullVideo;
@end

@implementation VipPayPlus

+(VipPayPlus*)getInstance{
    static VipPayPlus *g = NULL;
    if (!g) {
        g = [[VipPayPlus alloc] init];
        [BUPlayer hook];
    }
    return g;
}

//成功才调用此函数
-(NSInteger)updateWatchVideoTimes{
    
       [[helpFuntion gethelpFuntion] isValideOneDay:NewVipWatchVideoTimesVaildCountKey nCount:NewVipWatchVideoTimesVaildCount isUseYYCache:YES time:nil];
    if ([MajorSystemConfig getInstance].netDateTime) {
       // [[helpFuntion gethelpFuntion] isValideOneDay:VipWatchVideoTimes nCount:VipWatchVideoTimesVaildCount+1 isUseYYCache:NO time:[MajorSystemConfig getInstance].netDateTime];
        [[helpFuntion gethelpFuntion] isValideCommonDay:VipWatchVideoTimes nCount:VipWatchVideoTimesVaildCount intervalDay:VipWatchVideoCickIntervalDay isUseYYCache:false time:[MajorSystemConfig getInstance].netDateTime];
        return [self getWatchVideoTimes];
    }
    return 0;
}

-(NSInteger)getWatchVideoTimes{
 
    if ([MajorSystemConfig getInstance].netDateTime) {//
        NSInteger v =  VipWatchVideoTimesVaildCount - [[helpFuntion gethelpFuntion] isVaildOneDayNotAutoAddExcTimes:VipWatchVideoTimes nCount:VipWatchVideoTimesVaildCount intervalDay:VipWatchVideoCickIntervalDay isUseYYCache:false time:[MajorSystemConfig getInstance].netDateTime ];
        return v;
    }
    return 0;
}

-(id)init{
    self  = [super init];
    self.systemConfig = [[VipSystemConfig alloc] init];
    self.systemConfig.vipPlus = self;
    self.videoReadInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    _isLogin = false;
    [self updateVipConfig];
    [self login];
#if App_Use_OSS_Sycn
    [[NSFileManager defaultManager] removeItemAtPath:AdUrlWebTiJiaoDir error:nil];
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
#endif
    _queue = dispatch_queue_create("com.urlfeedBack.com", DISPATCH_QUEUE_CONCURRENT);

     return self;
}

- (void) putTestDataWithKey: (NSString *)key withClient: (OSSClient *)client withBucket: (NSString *)bucket
{
#if App_Use_OSS_Sycn
    NSString *objectKey = key;
    NSString *filePath = [AdUrlWebTiJiaoDir stringByAppendingPathComponent:objectKey];
    
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucket;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    request.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
    OSSTask * task = [client putObject:request];
    [task waitUntilFinished];
#endif
}

-(void)showWithUrlAndFeeAlter:(NSString*)url{
    //[MobClick event:@"adup_btn"];
    self.feeBackUrl = url;
    [self tryToSumbit];
}

-(void)tryToSumbit{
     if(_index<3){
        NSString *msg = @"提交给开发者屏蔽，当天就屏蔽广告，看三个视频广告后，提交网址";
        if(_index==1){
            msg = @"感谢你的支持，继续观看第二个广告";
        }
        else if(_index==2){
            msg = @"看完这最后一个广告，将提交广告网址";
        }
        TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"屏蔽此网站广告" message:msg];
        alertView.buttonFont = [UIFont systemFontOfSize:14];
        TYAlertAction *quxiao  = [TYAlertAction actionWithTitle:@"取消"
                                                          style:TYAlertActionStyleCancel
                                                        handler:^(TYAlertAction *action) {
                                                        }];
        [alertView addAction:quxiao];
        
        TYAlertAction * chongxia  = [TYAlertAction actionWithTitle:@"提交"
                                                             style:TYAlertActionStyleDefault
                                                           handler:^(TYAlertAction *action) {
                                                               if([[VipPayPlus getInstance] isCanPlayVideoAd2])
                                                               {
                                                                   self->_index++;
                                                                   [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
                                                                   [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                                       [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                                                                       [self tryToSumbit];
                                                                   } isShowAlter:YES isForce:true];
                                                               }
                                                               else{
                                                                   [self tryToSumbit];
                                                                   [[UIApplication sharedApplication].keyWindow makeToast:@"等待2秒后在提交" duration:2 position:@"center"];
                                                               }
                                                           }];
        [alertView addAction:chongxia];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
    }
    else{
        self->_index = 0;
        [self showUpdateAlter];
    }
}

-(void)showUpdateAlter{
    if (self.feeBackUrl) {
        NSString *filemd5 = [self.feeBackUrl md5];
        [[NSFileManager defaultManager] createDirectoryAtPath:AdUrlWebTiJiaoDir withIntermediateDirectories:NO attributes:nil error:nil];
        [self.feeBackUrl writeToFile:[AdUrlWebTiJiaoDir stringByAppendingPathComponent:filemd5] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(_queue, ^{
            [self putTestDataWithKey:filemd5 withClient:self->_client withBucket:OSS_BUCKET_PRIVATE];
        });
    }

    [[UIApplication sharedApplication].keyWindow makeToast:@"此网站已提交" duration:2 position:@"center"];
}

-(BOOL)isCanPlayVideoAd2{
    if (self.fullVideoAd && self.fullVideoAd.isShowState) {
        return false;
    }
    if (self.preloadVideoAd) {
        return true;
    }
    return false;
}

-(BOOL)isCanPlayVideoAdTows{
    if (self.fullVideoAd && self.fullVideoAd.isShowState) {
           return false;
       }
  if (self.rewardedVideoAd || !self.preloadVideoAd) {
      return false;
    }
    return true;
}

-(BOOL)isCanPlayVideoAd:(BOOL)isFromEnterForeground{
    if (self.fullVideoAd && self.fullVideoAd.isShowState) {
           return false;
       }
    if (self.currentTime && [[NSDate date] timeIntervalSinceDate:self.currentTime]<600) {
        return false;
    }
    if (_playSuccessTimes>=MaxPlayTimes) {
        return false;
    }
    if (![[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:NewVipWatchVideoTimesVaildCountKey nCount:NewVipWatchVideoTimesVaildCount  isUseYYCache:YES  time:nil]) {
      //  return false;
    }
    if(self.systemConfig.vip==Recharge_User)return false;
    if( GetAppDelegate.isPressShare)return false;
 #if UseInterstitialAd==1
    if (self.interstitialAd && self.interstitialAd.isAdValid) {
        return true;
    }
#else
    if (self.preloadVideoAd && (!isFromEnterForeground || [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:WatchAdvertWhenPauseAndForeground nCount:WatchAdvertTimes isUseYYCache:NO time:nil])) {
        return true;
    }
#endif
    return false;
}

-(void)tryPlayVideoFinish{
    [[helpFuntion gethelpFuntion] isValideOneDay:WatchAdvertWhenPauseAndForeground nCount:WatchAdvertTimes isUseYYCache:NO time:nil];
    [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜获得福利" duration:3 position:@"center"];
}

-(void)tryPlayVideoAd:(BOOL)isFromEnterForeground isUseTimeLimit:(BOOL)isUseTimeLimit block:(void(^)(BOOL isSuccess))stopVideoAdBlock{
#if UseInterstitialAd==1
    if ([self isCanPlayVideoAd] && !isCanShowAd) {
        self.stopVideoAdBlock = stopVideoAdBlock;
        isCanShowAd = true;
        UIViewController *ctrl = [GetAppDelegate.window currentViewController];
        BOOL isShow = [self.interstitialAd showAdFromRootViewController:ctrl];
        NSLog(@"tryPlayVideoAd = %d",isShow);
    }
    if (![self isCanPlayVideoAd]) {
        [self reloadInterstitialAd];
    }
#else
    if (((isUseTimeLimit && [self isCanPlayVideoAd:isFromEnterForeground])||(!isUseTimeLimit && [self isCanPlayVideoAd2]) )&& (!isFromEnterForeground || [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:WatchAdvertWhenPauseAndForeground nCount:WatchAdvertTimes isUseYYCache:NO time:nil])) {
        self.stopVideoAdBlock = stopVideoAdBlock;
        [self reqeustVideoAd:stopVideoAdBlock isShowAlter:false isForce:false];
    }
#endif
}

#pragma mark--
-(void)addWaitView{
    self.hubView = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow.currentViewController.view];
    [self.hubView showAnimated:YES];
    self.hubView.removeFromSuperViewOnHide = YES;
    [[UIApplication sharedApplication].keyWindow.currentViewController.view addSubview:self.hubView];
}

-(void)removeWaitView{
    [self.hubView hideAnimated:NO];
    self.hubView=nil;
    if (self.stopVideoAdBlock) {
        if (self.isVideoSuccess && self.isShowAlter) {
             [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜你获得此功能" duration:2 position:@"center"];
        }
        self.stopVideoAdBlock(self.isVideoSuccess);
        self.stopVideoAdBlock = NULL;
    }
}


-(void)stopVideoAd{
    self.isPlayState = false;
    [self.adChaoshiTimer invalidate];self.adChaoshiTimer =nil;
    [self removeWaitView];
    if (self.rewardedVideoAd) {
        [[BUDAdManager getInstance] updateTime:[NSDate date]];
    }
    self.rewardedVideoAd.delegate = NULL;
    self.rewardedVideoAd = NULL;
    if (self.stopVideoAdBlock) {
        if (self.isVideoSuccess && self.isShowAlter) {
            [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜你获得此功能" duration:2 position:@"center"];
        }
        self.stopVideoAdBlock(self.isVideoSuccess);
        self.stopVideoAdBlock = NULL;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadAd) object:nil];
    [self performSelector:@selector(preloadAd) withObject:nil afterDelay:5];
}

-(void)preloadAd{
     if (!self.preloadAdVideo) {
         self.preloadAdVideo = [[VideoPreloadAd alloc] init];
    }
    if ([self.delegate respondsToSelector:@selector(vipPlayPlusDelegateLoadStart)]) {
        [self.delegate vipPlayPlusDelegateLoadStart];
    }
    __weak __typeof(self)weakSelf = self;
    if (false && !self.fullVideoAd) {
        self.fullVideoAd= [[FullVideoPreloadAd alloc] init];
        [self.fullVideoAd start:^() {
            weakSelf.isShowFullVideo = false;
            if(  weakSelf.stopFullVideoAdBlock){
                weakSelf.stopFullVideoAdBlock();
            }
        }];
    }
  
    self.isPreloadSuccess = false;
    [self.preloadAdVideo start:^(id  _Nonnull adObject) {
        weakSelf.preloadVideoAd = adObject;
        weakSelf.isPreloadSuccess = true;
        if ([weakSelf.delegate respondsToSelector:@selector(vipPlayPlusDelegateLoadFinish)]) {
            [weakSelf.delegate vipPlayPlusDelegateLoadFinish];
        }
    }];
}

-(BOOL)isCanShowFullVideo{
    if (!self.fullVideoAd) {
        return false;
    }
    if (self.systemConfig.vip==Recharge_User) {
        return false;
    }
    if (self.isShowVideoState) {
        return false;
    }
    if (self.isShowFullVideo) {
        return false;
    }
    return self.fullVideoAd.isVaild;
}

-(void)tryShowFullVideo:(void(^)(void))stopFullVideoAdBlock{
    if (self.fullVideoAd.isVaild) {
        self.isShowFullVideo = true;
        self.stopFullVideoAdBlock = stopFullVideoAdBlock;
        [self.fullVideoAd show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:@"此广告可以跳过" duration:5 position:@"center"];
        });
     }
 }

-(bool)reqeustVideoAd:(void(^)(BOOL isSuccess))stopVideoAdBlock isShowAlter:(BOOL)isShowAlter isForce:(BOOL)isForce{
    if ([self.delegate respondsToSelector:@selector(vipPlayPlusDelegateLoadStart)]) {
        [self.delegate vipPlayPlusDelegateLoadStart];
    }
    if (self.rewardedVideoAd) {
        return false;
    }
    if (!isForce) {
         if(self.systemConfig.vip==Recharge_User){
               stopVideoAdBlock(true);return false;
           }
    }
    self.currentTime = [NSDate date];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadAd) object:nil];
    [self.preloadAdVideo stop];
    self.isVideoSuccess = false;
    self.isShowAlter = isShowAlter;
    self.stopVideoAdBlock = stopVideoAdBlock;
    [[BUDAdManager getInstance] updateTime:[NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]]];
    self.isVideoVerify = false;
    [self.adChaoshiTimer invalidate];
    self.adChaoshiTimer = [NSTimer scheduledTimerWithTimeInterval:9 target:self selector:@selector(checkAdVaild:) userInfo:nil repeats:YES];
    if (self.preloadVideoAd) {
        self.rewardedVideoAd = self.preloadVideoAd;
        self.rewardedVideoAd.delegate = self;
        self.preloadVideoAd = nil;
        [self rewardedVideoAdVideoDidLoad:self.rewardedVideoAd];
        self.isPreloadSuccess = false;
    }
    else{
        BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
        model.userId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSString *adID = [MajorSystemConfig getInstance].buDVideoID?[MajorSystemConfig getInstance].buDVideoID:@"000";
//#if DEBUG
        //adID = @"932840472";
//#endif
        self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:adID rewardedVideoModel:model];
        self.rewardedVideoAd.delegate = self;
        [self addWaitView];
        [self.rewardedVideoAd loadAdData];
    }
    return true;
}

-(void)checkAdVaild:(NSTimer*)timer{
    [self.adChaoshiTimer invalidate];self.adChaoshiTimer =nil;
    [self stopVideoAd];
}

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"reawrded video did load");
    self.isShowVideoState = true;
    [self.hubView hideAnimated:NO];
    self.hubView=nil;
    self.isPlayState = true;
    [self.rewardedVideoAd showAdFromRootViewController:[UIApplication sharedApplication].keyWindow.currentViewController];
    [self.adChaoshiTimer invalidate];self.adChaoshiTimer =nil;
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd{
    
    [[VideoPlayerManager getVideoPlayInstance] tryToPause];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video will visible");
    [[VideoPlayerManager getVideoPlayInstance] tryToPause];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video did close");
    [self closeAdAndUpdateState];
    [[VideoPlayerManager getVideoPlayInstance] exitAdVideoAndEnterFull];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video did click");
   // [self updateWatchVideoTimes];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if ([MajorSystemConfig getInstance].buDVideoID && [MajorSystemConfig getInstance].buDAdappKey) {
        NSLog(@"rewarded video material load fail");
        self.hubView.label.text = @"获取广告失败";
        [self.hubView hideAnimated:YES afterDelay:2];
        self.hubView = nil;
        [[BUDAdManager getInstance] updateTime:[NSDate date]];
        [self stopVideoAd];
    }
    else {
        [self rewardedVideoAdServerRewardDidSucceed:nil verify:YES];
        [self rewardedVideoAdDidClose:nil];
    }
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"rewarded play error");
    } else {
        NSLog(@"rewarded play finish");
    }
    [[VideoPlayerManager getVideoPlayInstance] showAdVideoAndExitFull];
    [ZFAutoPlayerViewController showAdVideoAndExitFull];
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded verify failed");
    [self removeWaitView];
    NSLog(@"Demo RewardName == %@", rewardedVideoAd.rewardedVideoModel.rewardName);
    NSLog(@"Demo RewardAmount == %ld", (long)rewardedVideoAd.rewardedVideoModel.rewardAmount);
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    NSLog(@"rewarded verify succeed");
    NSLog(@"verify result: %@", verify ? @"success" : @"fail");
    if (verify && self.typeKey) {//设置
        [self.videoReadInfo setObject:@"1" forKey:self.typeKey];
    }
    self.isVideoVerify = verify;
    NSLog(@"Demo RewardName == %@", rewardedVideoAd.rewardedVideoModel.rewardName);
    NSLog(@"Demo RewardAmount == %ld", (long)rewardedVideoAd.rewardedVideoModel.rewardAmount);
}
//end

-(void)showPlayAdVideo{
    if(!self.stopVideoAdBlock)
    if([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:@"showClickAdView_Vip" nCount:1 isUseYYCache:NO time:nil]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showClickAdView" object:nil];
    }
}

-(void)initPlus
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkState:) name:ZYNetworkAccessibityChangedNotification object:nil];
}

-(void)_willEnterForeground:(NSNotification*)object{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(login) object:nil];
    [self performSelector:@selector(login) withObject:nil afterDelay:3];
    [self showPlayAdVideo];
}

-(void)netWorkState:(NSNotification*)object{
    if(ZYNetworkAccessible==[ZYNetworkAccessibity currentState]){
        [self login];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:ZYNetworkAccessibityChangedNotification object:nil];
    }
}

-(BOOL)getAssetVipValue{
    return _isAccessVip;
}

-(void)setAccessVipValue:(BOOL)isVip{
    self.isAccessVip = isVip;
}

-(BOOL)isVaildOperationCheck:(NSString*)plugKey{
    if (plugKey && [self.videoReadInfo objectForKey:plugKey]) {
        return true;
    }
    return false;
}

-(void)setVaildOperationCheck:(NSString*)plugKey{
    if (plugKey) {
        [self.videoReadInfo setObject:@"1" forKey:plugKey];
    }
}

-(BOOL)isVaildOperation:(BOOL)isRemoveTmpSetView isShowAlter:(BOOL)isShowAlter plugKey:(NSString*)plugKey stopVideoAdBlock:(void(^)(BOOL isSuccess))stopVideoAdBlock{
    if (isShowAlter) {
        [self isVaildOperation:isRemoveTmpSetView plugKey:plugKey];
    }
    else{
        self.typeKey = plugKey;
        self.isVideoVerify = false;
        [self reqeustVideoAd:stopVideoAdBlock isShowAlter:true isForce:false];
    }
    return true;
}

-(void)show:(BOOL)isRemoveTmpSetView{
    if (!isRemoveTmpSetView) {
        MajorSetView *v = [[MajorSetView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        [[UIApplication sharedApplication].keyWindow.currentViewController.view addSubview:v];
    }
}

-(BOOL)isVaildOperation:(BOOL)isRemoveTmpSetView plugKey:(NSString*)plugKey{
    self.typeKey = plugKey;
    self.isVideoVerify = false;
    if (self.typeKey && [self.videoReadInfo objectForKey:self.typeKey]) {
        return true;
    }
    if ([VipPayPlus getInstance].systemConfig.vip == General_User) {
        TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"此功能需要会员" message:nil];
        alertView.buttonFont = [UIFont systemFontOfSize:14];
        TYAlertAction *quxiao  = [TYAlertAction actionWithTitle:@"取消"
                                                          style:TYAlertActionStyleCancel
                                                        handler:^(TYAlertAction *action) {
                                                            
                                                        }];
        [alertView addAction:quxiao];
        ZFPlayerController *player =  [VideoPlayerManager getVideoPlayInstance].player;
        BOOL isAdd = true;
        if (player && player.isFullScreen) {
            isAdd = false;
        }
        TYAlertAction *chongxia  = [TYAlertAction actionWithTitle:@"开通会员"
                                                            style:TYAlertActionStyleDefault
                                                          handler:^(TYAlertAction *action) {
                                                              [self show:isRemoveTmpSetView];
                                                          }];
        if (isAdd) {
            [alertView addAction:chongxia];
        }
        BOOL isAddVideo = false;
        if (IF_IPHONE && (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]||[MajorSystemConfig getInstance].isOpen)) {
            isAddVideo = true;
        }
        if (!isAddVideo && [[NSDate date] isWeekend] && [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:@"ss_cc_20190128_" nCount:1 isUseYYCache:false time:nil]) {
            isAddVideo = false;
        }
        else{
            isAddVideo = true;
        }
        if (isAddVideo || IF_IPAD ||![[NSDate date] isWeekend]) {
            TYAlertAction *jili  = [TYAlertAction actionWithTitle:@"看完广告获得功能"
                                                            style:TYAlertActionStyleDefault
                                                          handler:^(TYAlertAction *action) {
                                                              [self reqeustVideoAd:^(BOOL isSuccess) {
                                                                  if(isSuccess){
                                                                      
                                                                  }
                                                              }isShowAlter:true isForce:false];
                                                          }];
            [alertView addAction:jili];
        }
        else{
            TYAlertAction *jili  = [TYAlertAction actionWithTitle:@"分享一次获得功能"
                                                            style:TYAlertActionStyleDefault
                                                          handler:^(TYAlertAction *action) {
                                                              [[ShareSdkManager getInstance] isForceShare2:SSDKPlatformSubTypeWechatTimeline msg:nil image:nil forceShareBlock:^(BOOL ret) {
                                                                  self.isVideoVerify = true;
                                                                  [self closeAdAndUpdateState];
                                                                  [[helpFuntion gethelpFuntion] isValideOneDay:@"ss_cc_20190128_" nCount:1 isUseYYCache:false time:nil];
                                                              }];
                                                          }];
            [alertView addAction:jili];
        }
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
        return false;
    }
    return true;
}

-(void)closeAdAndUpdateState{
    self.isShowVideoState = false;
    if (self.isVideoVerify && self.typeKey) {//设置
        [self.videoReadInfo setObject:@"1" forKey:self.typeKey];
    }
    if (self.isVideoVerify) {
        [self updateWatchVideoTimes];
    }
    
    NSInteger w = [[helpFuntion gethelpFuntion] isVaildOneDayNotAutoAddExcTimesfixBug:NewVipWatchVideoTimesVaildCountKey nCount:NewVipWatchVideoTimesVaildCount intervalDay:1 isUseYYCache:YES time:nil];
   NSInteger le =  w;
    NSString *msgContent = @"今日没有广告了~";
    if (le==2) {
         msgContent = @"今日只有—2—次广告了~";
    }
    else if(le==1){
        msgContent = @"今日只有—1—次广告了";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     //   [[UIApplication sharedApplication].keyWindow makeToast:msgContent duration:7 position:@"center"];
    });
    
    _playSuccessTimes++;
    if (_playSuccessTimes==MaxPlayTimes) {
      //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //    [[UIApplication sharedApplication].keyWindow makeToast:@"本次已经没有视频广告了" duration:7 position:@"center"];
        //});
    }
    self.typeKey = NULL;
    [[VideoPlayerManager getVideoPlayInstance] tryToPlay];
    [[BUDAdManager getInstance] updateTime:[NSDate date]];
    self.isVideoSuccess =true;
    [self stopVideoAd];
}

-(void)updateVipConfig{
    if (!self.vipConfig) {
        self.vipConfig = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    NSString *saveKey =  [FTWCache decryptWithKey:[NSData dataWithContentsOfFile:VipConfigInfo]];
    if(saveKey){
        NSDictionary *info = [saveKey JSONValue];
        if (info) {
            self.systemConfig.tel = [info objectForKey:VipPayUUIDPhone];
            self.systemConfig.password = [info objectForKey:VipPayUUIDPassword];
            self.systemConfig.endTime = [info objectForKey:VipPayUUIDEndTime];
            [self.vipConfig setDictionary:info];
        }
    }
}

-(void)loadWeb:(NSString*)url{
    if (!self.webView) {
        __weak __typeof(self)weakSelf = self;
        self.webView = [[VipWebView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) url:url buyBlock:^(NSString *res) {
            weakSelf.webView=nil;
            [self buyFinish:res];
        } loginBlock:^(NSString* res) {
            [self pareseWebStr:res];
            weakSelf.webView=nil;
        } closeBlock:^{
            [self closeFromWeb];
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:self.webView];
    }
}

-(void)showBuyWeb{
    [self loadWeb:@"http://biezhi360.cn:345/vip.aspx"];
}

-(void)showLoginWeb{
    [self loadWeb:@"http://biezhi360.cn:345/register.aspx"];
}


-(NSString*)getDeviceUUID{
    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    NSString *saveKey =  [FTWCache decryptWithKey:[NSData dataWithContentsOfFile:VipDeviceUUID]];
    if (!saveKey) {
        CFUUIDRef cfuuid =CFUUIDCreate(kCFAllocatorDefault);
        saveKey =(NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        [[FTWCache encryptWithKeyNomarl:saveKey] writeToFile:VipDeviceUUID atomically:YES];
    }
    return saveKey;
}

-(void)updateLoginState:(BOOL)state{
    self.isLogin = state;
}

-(void)closeFromWeb{
    self.webView=nil;
    [self login];
}

-(void)buyFinish:(NSString*)msg{
    RemoveViewAndSetNil(self.webView);
    [self login];
}

-(void)pareseWebStr:(NSString*)msg{
    NSString *str = [VipEncryption decryptString:msg];
    id value = [VipSystemConfig yy_modelWithJSON:str];
    if ([value isKindOfClass:[VipSystemConfig class]]) {
        [self.vipConfig setObject:((VipSystemConfig*)value).tel forKey:VipPayUUIDPhone];
        [self.vipConfig setObject:((VipSystemConfig*)value).password forKey:VipPayUUIDPassword];
        [self.vipConfig setObject:((VipSystemConfig*)value).endTime forKey:VipPayUUIDEndTime];
        [[FTWCache encryptWithKeyNomarl:[self.vipConfig jsonEncodedKeyValueString]] writeToFile:VipConfigInfo atomically:YES];
        [self login];
    }
    RemoveViewAndSetNil(self.webView);
}
//页面登陆了成功,还需要和uuid绑定
-(void)pareseLoginStr:(NSString*)msg{
    if (!msg) {
        [self loginOut];
        return;
    }
    NSString *str = [VipEncryption decryptString:msg];
    id value = [VipSystemConfig yy_modelWithJSON:str];
    if ([value isKindOfClass:[VipSystemConfig class]]) {
        self.systemConfig = value;
        self.systemConfig.vipPlus = self;
        [self.vipConfig setObject:self.systemConfig.tel forKey:VipPayUUIDPhone];
        [self.vipConfig setObject:self.systemConfig.password forKey:VipPayUUIDPassword];
        [self.vipConfig setObject:self.systemConfig.endTime forKey:VipPayUUIDEndTime];
        [[FTWCache encryptWithKeyNomarl:[self.vipConfig jsonEncodedKeyValueString]] writeToFile:VipConfigInfo atomically:YES];
        [self updateLoginState:true];
        //self.systemConfig.vip = ((VipSystemConfig*)value).vip;
    }
}

-(void)login{
    NSString *uuid = [self.vipConfig objectForKey:VipPayUUIDPhone];
    NSString *key = [self.vipConfig objectForKey:VipPayUUIDPassword];
    NSString *deviceUUID = [self getDeviceUUID];
    if (uuid && key && deviceUUID) {
        if (!netWork) {
            netWork = [[MKNetworkEngine alloc] init];
        }
        if (!operation) {
            operation = [netWork operationWithURLString:[NSString stringWithFormat:@"http://www.biezhi360.cn:345/mmLogin.aspx?tel=%@&password=%@&idfa=%@",uuid,key,deviceUUID] params:nil httpMethod:@"GET" timeOut:4];
            [operation onCompletion:^(MKNetworkOperation *completedOperation) {
                self->operation = nil;
                [self pareseLoginStr:completedOperation.responseString];
            } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
                self->operation = nil;
                [self pareseLoginStr:nil];
            }];
            [netWork enqueueOperation:operation];
        }
    }
    else{
        [self loginOut];
    }
}

-(void)loginOut{
    self.systemConfig.vip = General_User;
    self.systemConfig = [[VipSystemConfig alloc] init];
    self.systemConfig.vipPlus = self;
    [[NSFileManager defaultManager] removeItemAtPath:VipConfigInfo error:nil];
    [self updateLoginState:false];
}



@end
