//
//  VideoPlayerManager+Down.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "VideoPlayerManager+Banner.h"
#import "AppDelegate.h"
#import "MajorSystemConfig.h"
static BUBannerAdView *carouselBannerView = nil;
static BOOL isClickBuBanner = false;
static BUSize *buSize = NULL;

@implementation VideoPlayerManager(Banner)
-(void)startVideoBanner{
    return;
     if (([MajorSystemConfig getInstance].isGotoUserModel!=2) && carouselBannerView == nil && !isClickBuBanner) {
         if (!buSize) {
             buSize = [BUSize sizeBy:BUProposalSize_Banner600_90];
         }
        carouselBannerView = [[BUBannerAdView alloc] initWithSlotID:@"908710922" size:buSize rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController interval:30];
        const CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        const CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
                CGFloat bannerHeight = screenWidth * buSize.height / buSize.width;
        carouselBannerView.frame = CGRectMake(0, screenHeight*0.4, screenWidth, bannerHeight);
        carouselBannerView.delegate = self;
        @weakify(self)
        [RACObserve(self.player.smallFloatView,center) subscribeNext:^(id x) {
            @strongify(self)
            if (GetAppDelegate.videoPlayMode==0) {
                [self startVideoBanner];
                if (carouselBannerView) {
                    if(!carouselBannerView.superview){
                        [self.player.smallFloatView.superview addSubview:carouselBannerView];
                        [carouselBannerView loadAdData];
                        [self adJustBannerPos];
                    }
                }
            }
            else{
                [self stopVideoBanner];
            }
        }];
    }
    else if(carouselBannerView){
    }
}

-(void)adJustBannerPos{
    return;
    const CGFloat screenWidth = CGRectGetWidth(self.player.smallFloatView.frame);
    CGFloat bannerHeight = screenWidth * buSize.height / buSize.width;
    [carouselBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(screenWidth);
        make.height.mas_equalTo(bannerHeight);
        make.centerX.equalTo(self.player.smallFloatView);
        make.top.equalTo(self.player.smallFloatView.mas_bottom);
    }];
}

-(void)stopVideoBanner{
    return;
    [carouselBannerView removeFromSuperview];
    carouselBannerView = nil;
}
/**
 bannerAdView 广告位加载成功
 
 @param bannerAdView 视图
 @param nativeAd 内部使用的NativeAd
 */
- (void)bannerAdViewDidLoad:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd{
    
}
/**
 bannerAdView 广告位展示新的广告
 
 @param bannerAdView 当前展示的Banner视图
 @param nativeAd 内部使用的NativeAd
 */
- (void)bannerAdViewDidBecomVisible:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd{
    
}
/**
 bannerAdView 广告位点击
 
 @param bannerAdView 当前展示的Banner视图
 @param nativeAd 内部使用的NativeAd
 */
- (void)bannerAdViewDidClick:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd{
    isClickBuBanner = true;
    [self performSelector:@selector(stopVideoBanner) withObject:nil afterDelay:10];
}
/**
 bannerAdView 广告位发生错误
 
 @param bannerAdView 当前展示的Banner视图
 @param error 错误原因
 */
- (void)bannerAdView:(BUBannerAdView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error{
    
}
/**
 bannerAdView 广告位点击不喜欢
 
 @param bannerAdView 当前展示的Banner视图
 @param filterwords 选择不喜欢理由
 */
- (void)bannerAdView:(BUBannerAdView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords{
    
}
@end
