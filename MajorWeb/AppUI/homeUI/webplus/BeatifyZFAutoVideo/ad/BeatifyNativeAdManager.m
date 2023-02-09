//
//  BeatifyNativeAdManager.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/27.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyNativeAdManager.h"
#import "MajorSystemConfig.h"
#import "AppDelegate.h"

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}
@end


@interface BeatifyNativeAdManager()<GDTNativeExpressAdDelegete>
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic, strong) NSMutableArray *expressAdViews;
@end

@implementation BeatifyNativeAdManager

+(BeatifyNativeAdManager*)getInstance{
    static BeatifyNativeAdManager *g = NULL;
    if (!g) {
        g = [[BeatifyNativeAdManager alloc] init];
    }
    return g;
}

-(void)startReqeust:(BOOL)isFull{
    if (isFull && self.expressAdViews.count>0) {
        if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdSuccessToLoad:)]) {
            [self.delegate beatifyNativeExpressAdSuccessToLoad:self.expressAdViews];
        }
        return;
    }
    if (!self.nativeExpressAd) {//800X1200
        CGSize adSize= CGSizeMake([MajorSystemConfig getInstance].appSize.width,[MajorSystemConfig getInstance].appSize.width*(AdVertHH/AdVertWW));
        self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:@"1109675609"
                                                             placementId:@"3000084667109591"
                                                                  adSize:adSize];
    }
    self.expressAdViews = nil;
    self.nativeExpressAd.delegate = self;
    [self.nativeExpressAd loadAd:10];
}

- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
    NSLog(@"%s",__FUNCTION__);
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = GetAppDelegate.window.rootViewController;
            [expressView render];
            NSLog(@"eCPM:%ld eCPMLevel:%@", [expressView eCPM], [expressView eCPMLevel]);
        }];
    }
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdSuccessToLoad:)]) {
        [self.delegate beatifyNativeExpressAdSuccessToLoad:self.expressAdViews];
    }
}


/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView
{
    printf("%s\n",__FUNCTION__);
    NSLog(@"%s",__FUNCTION__);
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    printf("%s\n",__FUNCTION__);
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"Express Ad Load Fail : %@",error);
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView{
    printf("%s\n",__FUNCTION__);
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView
{
    printf("%s\n",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(beatifyNativeRenderSuccess:)]) {
        [self.delegate beatifyNativeRenderSuccess:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView
{
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdViewClicked:)]) {
        [self.delegate beatifyNativeExpressAdViewClicked:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    [self.expressAdViews removeObject:nativeExpressAdView];
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdViewClosed:)]) {
        [self.delegate beatifyNativeExpressAdViewClosed:nativeExpressAdView];
    }
}

/**
 * 点击原生模板广告以后即将弹出全屏广告页
 */
- (void)nativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    printf("%s\n",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdViewWillPresentScreen:)]) {
        [self.delegate beatifyNativeExpressAdViewWillPresentScreen:nativeExpressAdView];
    }
}
/**
 * 点击原生模板广告以后弹出全屏广告页
 */
- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    printf("%s\n",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdViewDidPresentScreen:)]) {
        [self.delegate beatifyNativeExpressAdViewDidPresentScreen:nativeExpressAdView];
    }
}
/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewWillDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    printf("%s\n",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdViewWillDissmissScreen:)]) {
        [self.delegate beatifyNativeExpressAdViewWillDissmissScreen:nativeExpressAdView];
    }
}
/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    printf("%s\n",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(beatifyNativeExpressAdViewDidDissmissScreen:)]) {
        [self.delegate beatifyNativeExpressAdViewDidDissmissScreen:nativeExpressAdView];
    }
}
@end
