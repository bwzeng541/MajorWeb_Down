//
//  QrByteVideoAd.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/14.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QrByteVideoAd.h"
#import <BUAdSDK/BURewardedVideoAd.h>
#import "ByteDancePreload.h"
@interface QrByteVideoAd()<BURewardedVideoAdDelegate>
@property(strong)ByteDancePreload *preloadAdVideo;
@property(strong)BURewardedVideoAd *preloadVideoAd;
@property(strong)BURewardedVideoAd *rewardedVideoAd;
@property(copy,nonatomic)void(^clickVideoAdBlock)(void);
@property(weak)UIViewController *rootCtrl;
@end

@implementation QrByteVideoAd

-(void)dealloc{
#ifdef DEBUG
    printf("%s\n",__FUNCTION__);
#endif
}

-(id)initWithRootCtrl:(UIViewController*)ctrl{
    self = [super init];
    self.rootCtrl = ctrl;
    [self loadAd];
    return self;
}

-(void)loadAd{
    if (!self.preloadAdVideo) {
        self.preloadAdVideo = [[ByteDancePreload alloc] init];
    }
    __weak __typeof(self)weakSelf = self;
    [self.preloadAdVideo start:^(id  _Nonnull adObject) {
               weakSelf.preloadVideoAd = adObject;
         }];
}

-(void)stop{
    [self.preloadAdVideo stop];
       self.preloadAdVideo = nil;
       self.rewardedVideoAd.delegate = NULL;
       self.rewardedVideoAd = NULL;
       self.preloadVideoAd.delegate = NULL;
       self.preloadVideoAd = NULL;
    self.clickVideoAdBlock = nil;
}

-(BOOL)start:(void (^)(void))clickVideoAdBlock{
    if (self.preloadVideoAd) {
        self.clickVideoAdBlock = clickVideoAdBlock;
           [self.preloadAdVideo stop];
           self.rewardedVideoAd = self.preloadVideoAd;
           self.rewardedVideoAd.delegate = self;
           self.preloadVideoAd = nil;
           [self rewardedVideoAdVideoDidLoad:self.rewardedVideoAd];
        return true;
    }
    return false;
}

#pragma mark --BURewardedVideoAdDelegate
- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
   #ifdef DEBUG
   NSLog(@"reawrded video did load");
   #endif
    [self.rewardedVideoAd showAdFromRootViewController:self.rootCtrl];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    if (self.clickVideoAdBlock) {
        self.clickVideoAdBlock();
    }
   [self loadAd];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self loadAd];
}

@end
