//
//  BeatifyNativeAdManager.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/27.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#define AdVertWW 800.0
#define AdVertHH 1200.0
NS_ASSUME_NONNULL_BEGIN


@interface NSMutableArray (Shuffling)

// 随机打乱元素次序
- (void)shuffle;

@end


@protocol BeatifyNativeAdManagerDelegate <NSObject>
-(void)beatifyNativeExpressAdSuccessToLoad:(NSArray*)adArray;
-(void)beatifyNativeRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView;
-(void)beatifyNativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView;
-(void)beatifyNativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView;
-(void)beatifyNativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView;
-(void)beatifyNativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView;
-(void)beatifyNativeExpressAdViewWillDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView;
-(void)beatifyNativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView;
@end

@interface BeatifyNativeAdManager : NSObject
+(BeatifyNativeAdManager*)getInstance;
@property(weak)id<BeatifyNativeAdManagerDelegate>delegate;
@property(readonly,nonatomic)BOOL isAdReady;
@property(readonly,nonatomic)NSMutableArray *expressAdViews;

-(void)startReqeust:(BOOL)isFull;
@end

NS_ASSUME_NONNULL_END
