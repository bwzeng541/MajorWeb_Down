//
//  WelfareManager.h
//  WatchApp
//
//  Created by zengbiwang on 2018/7/5.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WelfareManagerAssetFaild)(void);
typedef void (^WelfareManagerAssetSuccess)(void);

@interface WelfareManager : NSObject
+(WelfareManager*)getInstance;
@property(copy)WelfareManagerAssetFaild assetFaild;
@property(copy)WelfareManagerAssetSuccess assetSuccess;
-(void)addUsrTime:(int)addSceond;
-(void)addShareTimes;
-(NSString*)getWelfareTimes;
-(BOOL)isWelfSupreVip;
-(BOOL)isBuySupreVip;
-(void)exchangeSupreVip;
-(BOOL)isAppAssess;//表示是否已经评价
-(void)shareAppAssessUI;
-(void)showUnVaildBuyUI;
@end
