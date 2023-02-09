//
//  BuDNativeAdManager.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/11/6.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BuDNativeAdManager.h"
#import "BUDFeedAdTableViewCell.h"
#import "BUPlayer.h"
#import "helpFuntion.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "AppDelegate.h"
#import "VipPayPlus.h"
#import <BUAdSDK/BUNativeExpressAdManager.h>
#import <BUAdSDK/BUNativeExpressAdView.h>
#import "MajorSystemConfig.h"
//#define BuDnativeVideoClickKey @"20191108171306_key"
static BOOL isClickBuDNativeAdManager = false;
@interface BuDNativeAdManager()<GDTNativeExpressAdDelegete,BUNativeExpressAdViewDelegate, BUVideoAdViewDelegate,BUNativeAdDelegate>
@property (nonatomic, strong)UIView *videoAdView;
@property (nonatomic, strong) BUNativeExpressAdManager *adManager;
@property (nonatomic, strong) BUNativeExpressAdView *nativeAd;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, weak) UIView *playParentView;
@property (nonatomic, weak) UIView *videoView;
@property (nonatomic, strong) NSTimer *delayTimer;
@property (nonatomic, assign) _BuDNativeAdManagerAdPos posType;
//广点通
@property (nonatomic, strong) NSArray *expressAdViews;
@property (nonatomic, strong) UIView *rightGdtAdView;
@property (nonatomic, assign) BOOL isClickGdt;
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@end


@implementation BuDNativeAdManager
+(BuDNativeAdManager*)getInstance{
    static BuDNativeAdManager *g = nil;
    if (!g) {
        g = [[BuDNativeAdManager alloc] init];
    }
    return g;
}

- (void)loadNativeAds {
     BUAdSlot *slot1 = [[BUAdSlot alloc] init];
      slot1.ID = [MajorSystemConfig getInstance].buDxxlID?[MajorSystemConfig getInstance].buDxxlID:@"000";
      slot1.AdType = BUAdSlotAdTypeFeed;
      slot1.position = BUAdSlotPositionFeed;
      slot1.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
      slot1.isSupportDeepLink = YES;
      
      float ww =  [MajorSystemConfig getInstance].appSize.width;
      if (IF_IPAD && self.posType==BuDNativeAdManagerAdPos_ParentView_Bottom) {
          ww /=2;
      }
       if (!self.adManager) {
          self.adManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(ww, 0)];
      }
      self.adManager.adSize = CGSizeMake(ww, 0);
      self.adManager.delegate = self;
      [self.adManager loadAd:3];
}

-(void)updateVideoDuration:(NSNotification*)object{
    NSLog(@"object %@",[object.object description]);
}

-(void)parenViewFrameUpdate:(CGPoint)center{
    if (self.posType!=BuDNativeAdManagerAdPos_ParentView_Bottom) {
        return;
    }
    if (self.parentView) {
        self.parentView.center = CGPointMake(center.x,center.y+self.videoView.frame.size.height/2+self.parentView.frame.size.height/2);
//       CGRect rect = self.rightGdtAdView.frame ;
//        rect.origin.y = self.parentView.frame.origin.y;
//        self.rightGdtAdView.frame= rect;
    }
}

-(void)startNative:(UIView*)videoView pos:(_BuDNativeAdManagerAdPos)pos{
//    if (!GetAppDelegate.appPackAge || [GetAppDelegate.appPackAge length]<5) {
//        return;
//    }
    if([VipPayPlus getInstance].systemConfig.vip==Recharge_User)return;
    if(self.adManager)return;
    self.posType = pos;
//    if (![[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:BuDnativeVideoClickKey nCount:1 isUseYYCache:NO time:nil]) {
//        return;
//    }
    if (isClickBuDNativeAdManager) {
        return;
    }
//    if (!GetAppDelegate.underAdVideoID) {
//        return;
//    }
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    if (self.posType==BuDNativeAdManagerAdPos_ParentView_Bottom) {
        @weakify(self)
        [RACObserve(videoView,center) subscribeNext:^(id x) {
            @strongify(self)
            [self parenViewFrameUpdate:[x CGPointValue]];
        }];
    }
    self.videoView = videoView;
    self.playParentView =[UIApplication sharedApplication].keyWindow.rootViewController.view;
    [self.parentView removeFromSuperview];
    if(self.posType==BuDNativeAdManagerAdPos_ParentView_Bottom){
          CGRect rect = CGRectMake(0, videoView.frame.origin.y+videoView.frame.size.height, videoView.frame.size.width, videoView.frame.size.height);
              if (IF_IPAD) {
                  rect = CGRectMake(videoView.frame.size.width/4, videoView.frame.origin.y+videoView.frame.size.height, videoView.frame.size.width/2, videoView.frame.size.height);
              }
              self.parentView = [[UIView alloc] initWithFrame:rect];
       //  self.rightGdtAdView = [[UIView alloc] initWithFrame:CGRectMake(videoView.frame.size.width/2, videoView.frame.origin.y+videoView.frame.size.height, videoView.frame.size.width/2, videoView.frame.size.height)];
       // self.rightGdtAdView.backgroundColor = [UIColor clearColor];
       // [self loadGDTAD];
    }
    else if(self.posType==BuDNativeAdManagerAdPos_ParentView_LeftBottom){
        self.parentView = [[UIView alloc] initWithFrame:CGRectMake(0,MY_SCREEN_HEIGHT-200-(GetAppDelegate.appStatusBarH-20), MY_SCREEN_WIDTH, 200)];
    }
    else if (self.posType==BuDNativeAdManagerAdPos_ParentView_Top){
        self.parentView = [[UIView alloc] initWithFrame:CGRectMake((MY_SCREEN_WIDTH -MY_SCREEN_WIDTH/1)/2,MY_SCREEN_WIDTH, MY_SCREEN_WIDTH/1, 200)];
    }
    else if (self.posType==BuDNativeAdManagerAdPos_ParentView_RightBottom){
        self.parentView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 200, 200)];
        self.playParentView = self.videoView;
    }
    self.parentView.backgroundColor = [UIColor whiteColor];
     [self.videoAdView removeFromSuperview];self.videoAdView = nil;
     [self loadNativeAds];
}

-(void)loadGDTAD{
    if (!self.nativeExpressAd) {//800X1200
       float adw = self.rightGdtAdView.frame.size.width;
          CGSize adSize = CGSizeMake(adw,adw*(800.0/1200));
          self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:@"1109675609"
                                                               placementId:@"3000084667109591"
                                                                    adSize:adSize];
      }
      self.expressAdViews = nil;
      self.nativeExpressAd.delegate = self;
      [self.nativeExpressAd loadAd:1];
}

-(void)stopNative{
    if ([self.delegate respondsToSelector:@selector(budnativeClose)]) {
          [self.delegate budnativeClose];
      }
    self.delegate = nil;
    [self.delayTimer invalidate];
    self.delayTimer = nil;
     [self.videoAdView removeFromSuperview];self.videoAdView = nil;
    self.videoView = nil;
    self.nativeAd = nil;
    _adManager.delegate = nil;
    self.adManager = nil;
    [self.parentView removeFromSuperview];
    self.parentView = nil;
    [self.rightGdtAdView removeFromSuperview];self.rightGdtAdView=nil;
    self.nativeExpressAd = nil;
}

-(void)buildNativeView{
    [self.videoAdView removeFromSuperview];self.videoAdView = nil;
    if (self.parentView) {
        self.videoAdView = [[UIView alloc] init];
              self.videoAdView.backgroundColor = [UIColor blackColor];
               float hh = self.nativeAd.frame.size.height;
              self.videoAdView.frame = CGRectMake(0, 0, self.parentView.frame.size.width,hh);
              self.parentView.frame = CGRectMake(self.parentView.frame.origin.x, self.parentView.frame.origin.y,self.parentView.frame.size.width,hh);
              if (BuDNativeAdManagerAdPos_ParentView_RightBottom==self.posType) {
                  NSLog(@"..");
              }
              else if (BuDNativeAdManagerAdPos_ParentView_LeftBottom==self.posType) {
              self.parentView.frame = CGRectMake(self.parentView.frame.origin.x, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-hh-50,self.parentView.frame.size.width,hh);
              }
               self.nativeAd.frame = CGRectMake(0, 0, self.nativeAd.frame.size.width, self.nativeAd.frame.size.height);
               [self.videoAdView addSubview:self.nativeAd];
              [self.parentView addSubview:self.videoAdView];
              self.videoAdView.clipsToBounds = YES;
              [self.playParentView addSubview:self.parentView];
              [self.playParentView addSubview:self.rightGdtAdView];
               if ([self.delegate respondsToSelector:@selector(budnativeSuccessToLoad:videoAdView:)]) {
                        [self.delegate budnativeSuccessToLoad:self.parentView.frame videoAdView:self.parentView];
                    }
              self.parentView.clipsToBounds = YES;
    }
}

- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (views.count) {
         self.nativeAd = [views objectAtIndex:arc4random()%views.count];
         self.nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
         [ self.nativeAd render];
     }
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *_Nullable)error{

}
          
- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    [self buildNativeView];
}


- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"%s",__FUNCTION__);
    isClickBuDNativeAdManager = true;
   // [[helpFuntion gethelpFuntion] isValideOneDay:BuDnativeVideoClickKey nCount:1 isUseYYCache:NO time:nil];
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords{
    [self stopNative];
}

- (void)nativeExpressAdViewPlayerDidPlayFinish:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error
 {
    NSLog(@"videoAdView didPlayFinish");
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    if (self.posType!=BuDNativeAdManagerAdPos_ParentView_Top && !self.isClickGdt) {
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(stopNative) userInfo:nil repeats:YES];
    }
}

 /*
#pragma mark gdt
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views{
    NSLog(@"%s",__FUNCTION__);
    //随机交换
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = GetAppDelegate.window.rootViewController;
            [expressView render];
            NSLog(@"eCPM:%ld eCPMLevel:%@", [expressView eCPM], [expressView eCPMLevel]);
        }];
    }
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"%s",__FUNCTION__);
    if (!nativeExpressAdView.superview) {
        UIView *paretView = nil;
        if(self.rightGdtAdView.subviews.count==0){
            paretView = self.rightGdtAdView;
        }
        if (nativeExpressAdView.frame.size.height<paretView.frame.size.height) {
            paretView.frame = CGRectMake( paretView.frame.origin.x,  paretView.frame.origin.y,  paretView.frame.size.width, nativeExpressAdView.frame.size.height);
        }
        [paretView addSubview:nativeExpressAdView];
        [nativeExpressAdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(paretView);
        }];
    }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView{
    self.isClickGdt = true;
}

-(void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView{
    
}

-(void)beatifyNativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    
}
*/
@end
