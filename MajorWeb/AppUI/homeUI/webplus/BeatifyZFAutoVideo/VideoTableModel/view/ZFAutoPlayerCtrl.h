//
//  ZFAutoPlayerCtrl.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ZFPlayerController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ZFAutoPlayerCtrlLink)(void);
typedef void (^ZFAutoPlayerCtrlSc)(void);
@interface ZFAutoPlayerCtrl : ZFPlayerController
@property(copy)ZFAutoPlayerCtrlLink videoLink;
@property(copy)ZFAutoPlayerCtrlSc videoSc;
@property(retain)id scParam;
- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag ;
+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag;
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView;
-(void)fixSomeControl;
@end

NS_ASSUME_NONNULL_END
