//
//  MajorSystemConfig.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/17.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorSystemConfig : NSObject
+(MajorSystemConfig*)getInstance;
@property(copy,nonatomic)NSString *lelinkAppId;
@property(copy,nonatomic)NSString *lelinkAppSecretKey;
@property(copy)NSString *newVesionMsg;
@property(retain)NSString *appVersion;
@property(retain)NSString *appInitUrl;

@property(assign)float zhiboFixTopH;
@property(assign)BOOL appIsRealseVesion;
@property(assign)BOOL isReqestFinish;
@property(assign)BOOL isOpen;

@property(copy)NSString *buDname;
@property(copy)NSString *buDappPackAge;
@property(copy)NSString *buDxxlID;
@property(copy)NSString *buDAdappKey;
@property(copy)NSString *buDVideoID;
@property(copy)NSString *bukaipinID;
@property(copy)NSString *buqpxxlID;

@property(assign)int  apiState;//0 1控制
@property(assign)int gdtPgkType;
@property(assign)CGSize appSize;
@property(assign)BOOL isDebugMode;
@property(assign)BOOL appUserDebugAdID;
@property(assign)int initDeviceIDCount;
@property(assign)int deviceRetention;
@property(strong)NSDictionary *msgappSaInfo;

@property(assign)BOOL isUrlSchemeNil;
//0 不跑广告 1 正常点击 2自动点击
@property(assign)int isGotoUserModel;//用户正常点击模式
//GDT广告参数
@property(retain)id gdtUserInfo;
@property(retain)id gdtUserBannerInfo;
@property(retain)id gdtUserKaiKaiPinInfo;
@property(retain)id gdtUserInterstitial;
@property(retain)id gdtUserExpressInfo;
@property(nonatomic,assign)BOOL fix_qq_Apl;//在2的模式下强制不自动点击
@property(nonatomic, assign)BOOL is_qq_Apl;//是否自动点击
@property(assign)BOOL is_save_old_qq_Apl;//保存原来的值
@property(retain)NSDictionary *gdtAdInfo;//广告参数信息流
@property(retain)NSDictionary *gdtBannerAdInfo;//广告参数信息流
@property(retain)NSDictionary *gdtKaiPinAdInfo;//广告参数信息流
@property(retain)NSDictionary *gdtExpressAdInfo;
@property(retain)NSDictionary *gdtInterstitialAdInfo;//
@property(assign)float gdtDelayDisplayTime;//自动消失时间
@property(assign)int everyGDTDayTime;//每天最多少次
@property(assign)float gdtUpdateNativeTime;
@property(assign)float gdtClickOvertime;//超时时间
@property(assign)BOOL isExcApla;//是否执行isExcApla
@property(assign)float changeAdvertIdTime;
@property(retain,nonatomic)UIViewController *gdtRootCtrl;
@property(retain,nonatomic)UIViewController *gdtBannerRootCtrl;
@property(retain,nonatomic)UIViewController *gdtInterstitialRootCtrl;
@property(assign)int maxClickTimeValue;
@property(retain)NSArray *gdtWebfilterArray;
@property(assign)BOOL isDelGdtCreateDir;//是否删除sdk创建的目录
@property(assign)BOOL isParallelClick;
//end
@property(assign)BOOL isEeveryDayReStart;

@property(assign)BOOL isStartVideoAdLoadfinish;
//当前是否wifi
@property(assign,readonly)AFNetworkReachabilityStatus isWifiState;

//adappwebview 参数
@property(strong)NSArray  *adAppUrlArray;
@property(assign)int  everyAdAppDayTime;//
@property(assign)int  intervalAdAppDay;//间隔多少天
@property(copy)NSString  *adJsConfig;//

//网络时间值
@property(strong)NSDate *netDateTime;

@property(strong)NSArray *param8;
@property (nonatomic,copy)NSDictionary *param13;
@property(readonly,nonatomic)CGRect bannerAdRect;
-(void)setBannerRect;
-(void)updateBannerZeor:(BOOL)isZeor;
@end
