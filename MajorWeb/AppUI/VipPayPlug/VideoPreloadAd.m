//
//  VideoPreloadAd.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VideoPreloadAd.h"
#import <AdSupport/AdSupport.h>
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "MajorSystemConfig.h"
@interface VideoPreloadAd()<BURewardedVideoAdDelegate>
@property(copy,nonatomic)void(^successVideoAdBlock)(id adObject);
@property(strong,nonatomic)BURewardedVideoAd *rewardedVideoAd;
@property(strong,nonatomic)NSTimer *checkChangeTimer;
@property(assign,nonatomic)BOOL isCanSetVipPayPlus;
@end

@implementation VideoPreloadAd
-(void)start:(void (^)(id _Nonnull))successVideoAdBlock{
    if (!self.rewardedVideoAd) {
        self.successVideoAdBlock = successVideoAdBlock;
        self.isCanSetVipPayPlus  =true;
        [self loadAdReqeust];
    }
}

-(void)loadAdReqeust{
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *adID = [MajorSystemConfig getInstance].buDVideoID?[MajorSystemConfig getInstance].buDVideoID:@"000";
//#if DEBUG
  //  adID = @"910477648";
//#endif
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:adID rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

-(void)stop{
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
    if (self.rewardedVideoAd) {
         self.rewardedVideoAd.delegate = NULL;
        self.rewardedVideoAd = NULL;
        self.isCanSetVipPayPlus  = false;
    }
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"VideoPreLoad Success");
    if (self.successVideoAdBlock && self.isCanSetVipPayPlus) {
        self.successVideoAdBlock(self.rewardedVideoAd);
    }
    self.rewardedVideoAd.delegate = NULL;
    self.rewardedVideoAd = NULL;
    [self.checkChangeTimer invalidate];
    self.checkChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1200 target:self selector:@selector(changeAdVideo) userInfo:nil repeats:YES];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
    self.checkChangeTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(changeAdVideo) userInfo:nil repeats:YES];
 }

-(void)changeAdVideo
{
    if (self.isCanSetVipPayPlus) {
        self.rewardedVideoAd.delegate = NULL;
        self.rewardedVideoAd = NULL;
        [self loadAdReqeust];
    }
}

@end
