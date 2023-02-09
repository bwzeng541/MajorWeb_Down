//
//  VideoPlayerManager+Down.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "VideoPlayerManager.h"
#import <BUAdSDK/BUAdSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerManager(NativeAd)<BUNativeAdDelegate>
-(void)initNativeAdRACObserve;
-(void)unitNaitveAdRACObserve;
@end

NS_ASSUME_NONNULL_END
