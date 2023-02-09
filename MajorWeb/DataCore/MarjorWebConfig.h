//
//  MajorWebConfig.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/27.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarjorWebConfig : NSObject
+(MarjorWebConfig*)getInstance;
@property(assign,nonatomic)BOOL isAutoPlay;//自动播放
@property(assign,nonatomic)BOOL isNightMode;//夜间模式
@property(assign,nonatomic)BOOL isSuspensionMode;//悬浮
@property(assign,nonatomic)BOOL isShowPicMode;//无图模式
@property(assign,nonatomic)BOOL isScaleWeb;//方法缩小
@property(assign,nonatomic)BOOL isCleanMode;//无痕模式
@property(assign,nonatomic)BOOL isBackClear;//切换新标签时，是否移除未使用的web
@property(assign,nonatomic)BOOL isOpenLocaNotifi;//本地通知推送
@property(assign,nonatomic)NSInteger  webFontSize;//网页字体百分比

@property(assign,nonatomic)BOOL isSyncICloud;//iCloud同步
@property(copy,nonatomic)NSString *overHeadKey;

@property(assign,nonatomic)BOOL isRemoveAd;//移除广告()
@property(assign,nonatomic)BOOL isCanReadMode;//是否打开阅读模式()
@property(assign,nonatomic)BOOL isPlayVideoAutoRotate;//是否自动旋转()
@property(assign,nonatomic)BOOL isAllowsBackForwardNavigationGestures;//是手势返回()

@property(assign,nonatomic)BOOL isAllowsAutoCachesVideoWhenPlay;//是否自动下载视频
@property(assign,nonatomic)BOOL isAllowsBackGroundDownMode;//是否后台下载视频
@property(assign,nonatomic)BOOL isAllows4GDownMode;//是否允许非WIfi下下载

@property(assign,nonatomic)BOOL updateConfig;

@property(strong,nonatomic)NSArray *webItemArray;

-(NSArray*)getSearchHotsArray;
-(void)addSearchHots:(NSString*)key;
-(void)initConfig;
-(void)addOpenInAppStoreDisable:(NSString*)host;
-(void)removeOpenInAppStoreDisable:(NSString*)host;
-(BOOL)isCanOpenInAppStore:(NSString*)host;
-(void)removeSearchHots;
//网也合法性判断
+ (void)isUrlValid:(NSString*)urlString callBack:(void(^)(BOOL validValue, NSString *result))callBack;

+(void)addFavorite:(NSString*)_title iconUrl:(NSString*)iconUrl  requestUrl:(NSString*)_requestUrl;
//历史记录
+ (void)updateDB:(NSString *)theTitle withFavicon:(NSString *)ico withUrl:(NSString *)strUrl;

+(void)saveVideoHistory:(NSString *)strUrl theTitle:(NSString*)theTitle videoImg:(NSString*)videoImg webUrl:(NSString *)webUrl;
+(void)saveUserHomeMain:(NSString *)strUrl theTitle:(NSString*)theTitle  webUrl:(NSString *)webUrl;

+ (NSArray*)getFavoriteOrHistroyData:(BOOL)isHistory;
+ (NSArray*)getVideoHistoryAndUserTableData:(NSString*)tableName;
+ (NSString*)getLastHistoryUrl;
+(void)clearAllCache;


//0数组，1字段
+(id)convertIdFromNSString:(NSString*)msg type:(NSInteger)type;
//时间有效性a1开始时间 a2结束时间
+(BOOL)isValid:(NSString*)a1 a2:(NSString*)a2;
@end
