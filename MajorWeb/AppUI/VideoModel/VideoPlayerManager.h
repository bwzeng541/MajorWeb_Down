//
//  VideoPlayerManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/26.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFPlayerController.h"
#import "MajorSystemConfig.h"
#define ClickVideoPlayerManagerCloseEvent @"clickVideoPlayerManagerCloseEvent"
#define DefalutVideoRect CGRectMake(0, ([MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height), MY_SCREEN_WIDTH, MY_SCREEN_WIDTH * 9/16)
@interface VideoPlayerManager : NSObject
+(VideoPlayerManager*)getVideoPlayInstance;
@property (nonatomic, readonly)BOOL isOldFull;
@property (nonatomic, readonly) ZFPlayerController *player;
@property (nonatomic, readonly) CGRect smallFloatRect;
@property (nonatomic, readonly) BOOL isPushState ;
-(BOOL)playWithUrl:(NSString*)url title:(NSString*)title referer:(NSString*)referer saveInfo:(NSDictionary*)saveInfo replayMode:(BOOL)replayMode  rect:(CGRect)rect  throwUrl:(NSString*)throwUrl isUseIjkPlayer:(BOOL)isUseIjkPlayer;
-(void)playWithPlayerInterface:(id)playerInterface title:(NSString*)title saveInfo:(NSDictionary*)saveInfo isMustSeekBegin:(BOOL)isMustSeekBegin;
-(void)playPause;
-(void)play;
-(void)pause;
-(void)stop;
-(void)tryToPause;
-(void)tryToPlay;
-(void)webPushPlay:(NSString*)url title:(NSString*)title webPushBlock:(void(^)(void))webPushBlock;
-(void)webPushLand:(CGSize)videoSize;
-(void)updatePlayAlpha:(float)alpha;
-(void)updateVideoArrayUrl:(NSArray*)array;
-(void)showAdVideoAndExitFull;
-(void)exitAdVideoAndEnterFull;
@end
