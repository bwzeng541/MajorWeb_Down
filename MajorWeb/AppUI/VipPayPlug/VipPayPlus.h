//
//  VipPayPlus.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/3.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WatchVideoAdEveryDay4TimesKey @"201909171720"
#define WatchVideoAdEveryDay4Times 2


//一天最多少次,最新使用这个
#define NewVipWatchVideoTimesVaildCountKey @"20200404192153_key"
#define NewVipWatchVideoTimesVaildCount  3
 //end


@protocol VipPayPlusPreLoadDelegate <NSObject>
-(void)vipPlayPlusDelegateLoadFinish;
-(void)vipPlayPlusDelegateLoadStart;
@end
NS_ASSUME_NONNULL_BEGIN
typedef enum VipType{
    General_User,//一般用户
    WatchVideoAd_User,//看了广告的会员
    WatchVideoAd_Click_User,//看点击的会员
    Recharge_User//充值会员
}_VipType;

@interface VipSystemConfig : NSObject
@property(nonatomic,copy)NSString *vipID;
@property(nonatomic,copy)NSString *tel;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,assign)_VipType vip;
@property(nonatomic,copy)NSString *beginTime;
@property(nonatomic,copy)NSString *endTime;
@property(nonatomic,assign)NSInteger score;
//@property(nonatomic,copy)NSInteger score;
@property(nonatomic,copy)NSString* notes;
@end
/*
 {"id":391163,"tel":"18683521205","password":"123456","vip":false,"beginTime":"2019-01-03T18:11:42.3142835+08:00","endTime":"2019-01-03T18:11:42.3142835+08:00","score":0,"operator":null,"notes":"lilei"
 
 */
@interface VipPayPlus : NSObject
@property(weak,nonatomic)id<VipPayPlusPreLoadDelegate>delegate;
@property(readonly,nonatomic)VipSystemConfig *systemConfig;
@property(readonly,nonatomic)BOOL isVideoVerify;
@property(readonly,nonatomic)BOOL isLogin;
@property(readonly,assign)BOOL isPreloadSuccess;
@property(readonly,assign)BOOL isPlayState;
+(VipPayPlus*)getInstance;
-(void)initPlus;
-(void)login;
-(void)loginOut;
-(void)showLoginWeb;
-(void)showBuyWeb;
-(BOOL)isVaildOperation:(BOOL)isRemoveTmpSetView plugKey:(NSString*)plugKey;
-(BOOL)isVaildOperation:(BOOL)isRemoveTmpSetView isShowAlter:(BOOL)isShowAlter plugKey:(NSString*)plugKey stopVideoAdBlock:(void(^)(BOOL isSuccess))stopVideoAdBlock;

-(BOOL)isVaildOperationCheck:(NSString*)plugKey;
-(void)setVaildOperationCheck:(NSString*)plugKey;
-(void)setAccessVipValue:(BOOL)isVip;
-(BOOL)getAssetVipValue;

-(void)preloadAd;
-(bool)reqeustVideoAd:(void(^)(BOOL isSuccess))stopVideoAdBlock isShowAlter:(BOOL)isShowAlter isForce:(BOOL)isForce;
-(void)stopVideoAd;
-(void)show:(BOOL)isRemoveTmpSetView;
-(void)showWithUrlAndFeeAlter:(NSString*)url;
-(NSInteger)updateWatchVideoTimes;
-(NSInteger)getWatchVideoTimes;
-(void)tryPlayVideoAd:(BOOL)isFromEnterForeground isUseTimeLimit:(BOOL)isUseTimeLimit block:(void(^)(BOOL isSuccess))stopVideoAdBlock;
-(void)tryPlayVideoFinish;
-(BOOL)isCanPlayVideoAd:(BOOL)isFromEnterForeground;
-(BOOL)isCanPlayVideoAdTows;
-(BOOL)isCanPlayVideoAd2;

//true 展示成功
-(BOOL)isCanShowFullVideo;
-(void)tryShowFullVideo:(void(^)(void))stopFullVideoAdBlock;
@end

NS_ASSUME_NONNULL_END
