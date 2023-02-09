//
//  BuDNativeAdManager.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/11/6.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum BuDNativeAdManagerAdPos{
    BuDNativeAdManagerAdPos_ParentView_Bottom,
    BuDNativeAdManagerAdPos_ParentView_Top,
    BuDNativeAdManagerAdPos_ParentView_LeftBottom,
    BuDNativeAdManagerAdPos_ParentView_RightBottom,
}_BuDNativeAdManagerAdPos;
@protocol BuDNativeAdManagerDelegate <NSObject>
-(void)budnativeSuccessToLoad:(CGRect)videoAdRect videoAdView:(UIView*)videAdView;
-(void)budnativeClose;
@end
@interface BuDNativeAdManager : NSObject
+(BuDNativeAdManager*)getInstance;
-(void)startNative:(UIView*)videoView pos:(_BuDNativeAdManagerAdPos)pos;
-(void)stopNative;
@property(weak,nonatomic)id<BuDNativeAdManagerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
