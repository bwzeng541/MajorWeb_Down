//
//  MajorGoldManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/21.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorGoldManager.h"
#import "ShareSdkManager.h"
#import "helpFuntion.h"
#import "YYCache.h"
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "MBProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import <BUAdSDK/BUFullscreenVideoAd.h>

#define MajorGoldData [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/golddata",AppSynchronizationDir]]

#define Gold_Video_id_key  @"Gold_Video_id_key"//更具广告id村数据库

//朋友圈
#define Gold_Pyq_key @"Gold_Pyq_key"
//QQ空间
#define Gold_QQ_key @"Gold_QQ_key"
//小说阅读
#define Gold_Nole_key @"Gold_Nole_key"
//激励视频
#define Gold_Video_key @"Gold_Video_key"
//全屏视频
#define Gold_FUll_Video_key @"Gold_FUll_Video_key"

#define Gold_Video_Buy_key @"Gold_Video_Buy_key"


#define Gold_Value_key @"Gold_Value_key"

@interface MajorGoldManager()<BURewardedVideoAdDelegate,BUFullscreenVideoAdDelegate>
@property(strong)NSDictionary *videoAdInfo;
@property(strong)NSDate *timeDate;
@property(strong)BURewardedVideoAd *rewardedVideoAd;
@property(strong)BUFullscreenVideoAd *fullscreenVideoAd;
@property(strong)MBProgressHUD *hubView;
@property(assign)BOOL isVideoVerify;
@property(assign)NSInteger goldNumber;
@end
@implementation MajorGoldManager

+(MajorGoldManager*)getInstance{
    static MajorGoldManager*g= nil;
    if (!g) {
        g = [[MajorGoldManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    NSNumber *number = (NSNumber*)[MajorGoldData objectForKey:Gold_Value_key];
    self.goldNumber  = [number integerValue];
    return self;
}
-(void)initWithDate:(NSDate*)dateTime{
    self.timeDate = dateTime;
    //注册分享成功通知
    NSString *o = [NSString stringWithFormat:@"%ld_gold_notifi",SSDKPlatformSubTypeWechatTimeline];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wechatTimelineCallBack) name:o object:nil];
    o = [NSString stringWithFormat:@"%ld_gold_notifi",(unsigned long)SSDKPlatformSubTypeQZone];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(QZoneCallBack) name:o object:nil];

}

-(void)QZoneCallBack{
    [[helpFuntion gethelpFuntion] isValideOneDay:Gold_QQ_key nCount:1 isUseYYCache:true time:self.timeDate];
    [self addGlod:1];
}

-(void)wechatTimelineCallBack{
    [[helpFuntion gethelpFuntion] isValideOneDay:Gold_Pyq_key nCount:1 isUseYYCache:true time:self.timeDate];
    [self addGlod:1];
}

-(void)unInitWithDate{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)showPyq{
    if([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:Gold_Pyq_key nCount:1 isUseYYCache:YES time:self.timeDate]){
        [[ShareSdkManager getInstance] showShareType:SSDKContentTypeWebPage typeArray:^NSArray *{
            return @[@(SSDKPlatformSubTypeWechatTimeline)];
        } value:^NSString *{
            return nil ;
        } titleBlock:^NSString *{
            return nil;
        } imageBlock:^UIImage *{
            return nil;
        } urlBlock:^NSString  *{
            return nil;
        }shareViewTileBlock:^NSString *{
            return @"已经复制视频地址请分享";
        }];
    }
    else{
        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"今日已领完" duration:2 position:@"center"];
    }
}

-(void)showQQ{
    if([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:Gold_QQ_key nCount:1 isUseYYCache:YES time:self.timeDate]){
        [[ShareSdkManager getInstance] showShareType:SSDKContentTypeWebPage typeArray:^NSArray *{
            return @[@(SSDKPlatformSubTypeQZone)];
        } value:^NSString *{
            return nil ;
        } titleBlock:^NSString *{
            return nil;
        } imageBlock:^UIImage *{
            return nil;
        } urlBlock:^NSString  *{
            return nil;
        }shareViewTileBlock:^NSString *{
            return @"已经复制视频地址请分享";
        }];
    }
    else{
        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"今日已领完" duration:2 position:@"center"];
    }
}

-(void)showFullVideo:(BOOL)isEveryXz{
    if(!isEveryXz || [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:Gold_FUll_Video_key nCount:3 isUseYYCache:YES time:self.timeDate]){
        [self requesFullVideoAd];
    }
    else{//获取广告值和这个里面的比较，不同就成功
        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"今日已领完" duration:2 position:@"center"];
    }
}

-(void)showVideo{
    if([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:Gold_Video_key nCount:4 isUseYYCache:YES time:self.timeDate]){
        [self reqeustVideoAd];
       // [MajorGoldData removeObjectForKey:Gold_Video_id_key];
    }
    else{//获取广告值和这个里面的比较，不同就成功
        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"今日已领完" duration:2 position:@"center"];
    }
}

-(void)showNole{
    
}

-(BOOL)spendGold:(NSInteger)gold uuid:(nonnull NSString *)uuid{
    NSString *key = [NSString stringWithFormat:@"buy_%@",uuid];
    NSString *value = (NSString*)[MajorGoldData objectForKey:key];
    if(value){
        return YES;
    }
    NSNumber *number = (NSNumber*)[MajorGoldData objectForKey:Gold_Value_key];
    NSInteger leve = [number intValue]-gold;
    if (leve>=0) {
        [MajorGoldData setObject:@"0" forKey:key];
        [MajorGoldData setObject:@(leve) forKey:Gold_Value_key];
        self.goldNumber = leve;
        return true;
    }
    [[UIApplication sharedApplication].keyWindow makeToast:@"金币不足，不能离线播放，请在设置页面获得金币" duration:2 position:@"center"];
    return false;
}

-(void)addGlod:(NSInteger)gold{
    [[UIApplication sharedApplication].keyWindow makeToast:@"感谢支持" duration:2 position:@"center"];
    NSNumber *number = (NSNumber*)[MajorGoldData objectForKey:Gold_Value_key];
    NSInteger vv = [number intValue]+gold;
    [MajorGoldData setObject:@(vv) forKey:Gold_Value_key];
    self.goldNumber = vv;
}

-(void)addWaitView{
    self.hubView = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [self.hubView showAnimated:YES];
    self.hubView.removeFromSuperViewOnHide = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.hubView];
}
-(void)removeWaitView{
    [self.hubView hideAnimated:NO];
    self.hubView=nil;
}
#pragma mark --全屏视频

-(void)requesFullVideoAd{
    self.isVideoVerify = false;
    self.fullscreenVideoAd = [[BUFullscreenVideoAd alloc] initWithSlotID:@"908710180"];
    self.fullscreenVideoAd.delegate = self;
    [self addWaitView];
    [self.fullscreenVideoAd loadAdData];
}
#pragma mark --激励视频
-(void)reqeustVideoAd{
    self.isVideoVerify = false;
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:@"900546826" rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self addWaitView];
    [self.rewardedVideoAd loadAdData];
}



- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {

}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"reawrded video did load");
    [self removeWaitView];
    
   /* __weak __typeof__(self) weakSelf = self;
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否显示激励视频" message:nil];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"关闭"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                               }];
    [alertView addAction:v];
    TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"展示激励视频" style:TYAlertActionStyleDefault handler:^(TYAlertAction *action) {*/
        [self.rewardedVideoAd showAdFromRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
   /* }];
    [alertView addAction:v1];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
    */
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video will visible");
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video did close");
    if (self.isVideoVerify) {
        [[helpFuntion gethelpFuntion] isValideOneDay:Gold_Video_key nCount:4 isUseYYCache:true time:self.timeDate];
        [self addGlod:1];
    }
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video did click");
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"rewarded video material load fail");
    self.hubView.label.text = @"获取广告失败";
    [self.hubView hideAnimated:YES afterDelay:2];
    self.hubView = nil;
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"rewarded play error");
    } else {
        NSLog(@"rewarded play finish");
    }
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
    self.isVideoVerify = verify;
    NSLog(@"Demo RewardName == %@", rewardedVideoAd.rewardedVideoModel.rewardName);
    NSLog(@"Demo RewardAmount == %ld", (long)rewardedVideoAd.rewardedVideoModel.rewardAmount);
}


#pragma mark -- 全屏视频

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self removeWaitView];
    [self.fullscreenVideoAd showAdFromRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    self.hubView.label.text = @"获取广告失败";
    [self.hubView hideAnimated:YES afterDelay:2];
    self.hubView = nil;
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error{
    if (!error) {
        self.isVideoVerify = YES;
    }
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd{
    if (self.isVideoVerify) {
        [[helpFuntion gethelpFuntion] isValideOneDay:Gold_FUll_Video_key nCount:3 isUseYYCache:true time:self.timeDate];
        [self addGlod:1];
    }
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
 
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {

}
@end
