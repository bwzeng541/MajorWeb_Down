//
//  MajorPlayerController.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "ZFPlayerController.h"
typedef void (^MajorPlayerControllerClose)(void);
typedef void (^MajorPlayerControllerSmall)(void);
typedef void (^MajorPlayerControllerBackPlay)(void);
typedef void (^MajorPlayerControllerShare)(void);
typedef void (^MajorPlayerControllerVideoDown)(void);
typedef void (^MajorPlayerControllerLink)(void);

@interface MajorPlayerController : ZFPlayerController
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;
@property(copy)MajorPlayerControllerClose closePlay;
@property(copy)MajorPlayerControllerSmall smallPlay;
@property(copy)MajorPlayerControllerBackPlay backPlay;
@property(copy)MajorPlayerControllerShare sharePlay;
@property(copy)MajorPlayerControllerVideoDown videoDownPlay;
@property(copy)MajorPlayerControllerLink videoLink;

-(void)webPushLand;
@end
