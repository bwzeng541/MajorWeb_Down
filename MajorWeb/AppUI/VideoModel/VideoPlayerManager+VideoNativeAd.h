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

@interface VideoPlayerManager(VideoNativeAd)<BUNativeAdsManagerDelegate, BUVideoAdViewDelegate,BUNativeAdDelegate,UITableViewDelegate,UITableViewDataSource>
-(void)startVideoNative;
-(void)stopVideoNative;
@end

NS_ASSUME_NONNULL_END
