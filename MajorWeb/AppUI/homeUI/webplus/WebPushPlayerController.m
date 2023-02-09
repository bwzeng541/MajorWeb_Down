//
//  MajorPlayerController.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebPushPlayerController.h"


@implementation WebPushPlayerController
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView{
    WebPushPlayerController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}




- (instancetype)initWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
    WebPushPlayerController *player = [self init];
    [player updatePlayerManager:playerManager];
    [player updateContainerView:containerView];
    return player;
}

-(id)init{
    self = [super init];
    return self;
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if (fullScreen) {
        [super enterFullScreen:fullScreen animated:animated];
        [self setStatusBarHidden:true];
     }
    else{
        [super enterFullScreen:fullScreen animated:animated];
        [self setStatusBarHidden:false];
    }
}

@end
