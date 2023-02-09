//
//  OnlineAdManager.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "OnlineAdManager.h"
#import "helpFuntion.h"
#import "GdtUserManager.h"
#import "AppDelegate.h"
#define OnlineAdManager20180717  @"On_l_i_yned_Mn_ar20180717"
@interface OnlineAdManager()

@end

@implementation OnlineAdManager

+(OnlineAdManager*)getInstance{
    static OnlineAdManager*g = nil;
    if (!g) {
        g = [[OnlineAdManager alloc] init];
    }
    return g;
}

-(void)updateClickInfo{
    NSDictionary *info = [[GdtUserManager getInstance] getExpressInfo];
    if (info) {
        NSString *appkey = [info objectForKey:@"appkey"];//@"1105344611";//
        NSString *placementId =  [info objectForKey:@"placementId"];//@"
        [[helpFuntion gethelpFuntion] isValideOneDay:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",appkey,placementId])) nCount:1 isUseYYCache:false time:nil];
    }
    [[helpFuntion gethelpFuntion] isValideOneDay:eveyrDayClickGDTAdertTimes(OnlineAdManager20180717) nCount:1 isUseYYCache:false time:nil];
}

//20%点击控制
-(BOOL)isCanShowAd{//判断当前id在今天是否点击过，没有则弹出，否则查找一个没有点击过的id，进行切换，所有id都点击过就不切换
//#if DEBUG
//    return true;
//#endif
    
   BOOL ret = [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:eveyrDayClickGDTAdertTimes(OnlineAdManager20180717) nCount:1 isUseYYCache:false time:nil];
    if (!ret)
    {
        return false;
    }
    
    NSDictionary *info = [[GdtUserManager getInstance] getExpressInfo];
    if (info) {
        NSString *appkey = [info objectForKey:@"appkey"];//@"1105344611";//
        NSString *placementId =  [info objectForKey:@"placementId"];//@"5030722621265924";//
       
       BOOL ret = [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:eveyrDayClickGDTAdertTimes(([NSString stringWithFormat:@"%@%@",appkey,placementId])) nCount:1 isUseYYCache:false time:nil];
        if (ret){
            return true;
        }
        else{//找到一个未点击的项目,暂时不处理
            return false;
        }
    }
    return false;
}
@end
