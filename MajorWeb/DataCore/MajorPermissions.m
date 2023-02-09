//
//  MajorPermissions.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/5/14.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorPermissions.h"
#import "VideoPlayerManager.h"
#import "VipPayPlus.h"
#import "helpFuntion.h"
#import "AppDelegate.h"
#define MajorPermissions_Times  1

@interface MajorPermissions ()
-(void)checkPressMission:(NSString*)key pressmission:(void(^)(BOOL))pressmission;
@end
@implementation MajorPermissions
+(void)playClickPerMissions:(NSString*)key pressmission:(void(^)(BOOL))pressmission{
    static MajorPermissions*g = NULL;
    if (g==NULL) {
        g = [[MajorPermissions alloc] init];
    }
    [g checkPressMission:key pressmission:pressmission];
}

-(void)checkPressMission:(NSString*)key pressmission:(void(^)(BOOL))pressmission{
    pressmission(true);
    return;
    if ([VipPayPlus getInstance].systemConfig.vip==WatchVideoAd_User ||
        [VipPayPlus getInstance].systemConfig.vip==Recharge_User || ![[VipPayPlus getInstance] isCanPlayVideoAd:false] ) {
        pressmission(true);
        return;
    }
    BOOL ishelp = [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:key nCount:MajorPermissions_Times isUseYYCache:YES time:nil];
    if (!ishelp) {
        pressmission(true);
        return;
    }
    [[VideoPlayerManager getVideoPlayInstance] stop];
    [[VipPayPlus  getInstance] reqeustVideoAd:^(BOOL isSuccess) {
        if (isSuccess) {
            GetAppDelegate.isWatchHomeVideo = YES;
            [[helpFuntion gethelpFuntion] isValideOneDay:key nCount:MajorPermissions_Times isUseYYCache:YES time:nil];
        }
        pressmission(true);
    } isShowAlter:YES isForce:false];
}
@end
