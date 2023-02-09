//
//  VideoPlayerManager+Down.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <BUAdSDK/BUAdSDK.h>
#import "PicUpIconsView.h"
NS_ASSUME_NONNULL_BEGIN

@interface PicUpIconsView(VideoNativeAd)<BUNativeAdsManagerDelegate, BUVideoAdViewDelegate,BUNativeAdDelegate,UITableViewDelegate,UITableViewDataSource>
-(void)startVideoNative;
-(void)stopVideoNative;
-(BOOL)isVaild:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
