//
//  MajorPlayerController.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "ZFPlayerController.h"

@interface WebPushPlayerController : ZFPlayerController
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;

@end
