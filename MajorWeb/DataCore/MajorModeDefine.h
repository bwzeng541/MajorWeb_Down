//
//  MajorModeDefine.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  OnePlayKey @"OnePlayKey"
#define  OneHeaderStringKey  @"OneHeaderStringKey"

@class WebConfigItem;
//在网页请求中，每次开始请求的时候，需要进行域名比较得到conifg值
/*
 //在所有config未NO的时候才判断
 -(void)exchangeWebConfig:(NSString*)host url:(NSString*)reqesetUrl{
 if (self.currentHost &&[host isEqualToString:self.currentHost]) {
 return;
 }
 BOOL isFind = false;
 for(查找){//找到后
 self.webUserConfig = conifg.conifg;
 self.webUserConfig.url = reqesetUrl;
 }
 }
 }
 if (!isFind) {
 self.currentHost = nil;
 NSLog(@"exchangeWebConfig faild");
 self.webUserConfig = [[WebConfigItem alloc] init];
 }
 }
 */
//使用中
@interface notConfig:NSObject
@property(nonatomic,strong) NSString *host;
@property(nonatomic,strong) WebConfigItem *conifg;
@end


//通过历史收藏等打开url
@interface homeFristItem : NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@end

//
@interface newProfessional : NSObject
@property(nonatomic,strong)NSString *beginTime;
@property(nonatomic,strong)NSString *endTime;
@property(nonatomic,strong)NSString *url;
@end

//使用中
//程序启动完成后检查，这个字段（ios端用webview打开，会弹出提示安装软件对话框）
@interface TjLiance  : NSObject
@property(nonatomic,strong)NSString *beginTime;
@property(nonatomic,strong)NSString *endTime;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *vesion;
@property(nonatomic,strong)NSString *fireTime;
@end


@interface WeiXinBtnInfo : NSObject
@property(nonatomic,strong)NSString *beginTime;
@property(nonatomic,strong)NSString *endTime;
@end

//使用中 是否强制点击NO按钮调用广告（）
@interface HomeAdShow : NSObject
@property(nonatomic,strong)NSString *beginTime;
@property(nonatomic,strong)NSString *endTime;
@end

//使用中 强制使用api时间，在isUseApi有效的时候才检查
@interface forceFireTime : NSObject
@property(nonatomic,strong)NSString *btime;
@property(nonatomic,strong)NSString *etime;
@end

//使用中，api解析项，标题和url
@interface searchWebInfo:NSObject
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *url;
@end

@interface huyaNodeInfo:NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@end


@interface webDataLiveInfo:NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSArray *array;
@end

@interface manhuaurlInfo:NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *key;
@end

@interface ZyMkInfo:NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *isPage;
@end

//
@interface SpuerLeaguer:NSObject
@property(nonatomic,strong)NSString *btime;
@property(nonatomic,strong)NSString *etime;
@end

//使用中(重要)
@interface morePanel : NSObject
@property (nonatomic,strong) NSArray *fullr;
@property (nonatomic,strong) NSArray *fulld;
@property (nonatomic,strong) WeiXinBtnInfo *wxBtnInfo;//(加微信的btn)
@property (nonatomic,strong) SpuerLeaguer *leaguer;//(android 保留)
@property (nonatomic,strong) NSDictionary *maskBtn;//(android 保留)

@property (nonatomic,strong) NSArray *apiUrlArray;//通用api(searchWebInfo数据类型)
@property (nonatomic,strong) NSArray *apiUrlArraysohu;//搜狐api
@property (nonatomic,strong) NSArray *apiUrlArrayqq;//qq Api
@property (nonatomic,strong) NSArray *apiUrlArraymg;//芒果api
@property (nonatomic,strong) NSArray *apiUrlArrayaiqy;//爱奇艺api

@property (nonatomic,strong) NSArray *huyaurl;//(android 保留)
@property (nonatomic,strong) NSArray *webDataLiveInfo;//(android 保留)
@property (nonatomic,strong) NSArray *manhuaurl;//(android 保留)
@property (nonatomic,strong) NSArray *zyMkArray;//(android 保留)
@property (nonatomic,strong) NSDictionary *manhuaParseInfo;//(android 保留)
@property (nonatomic,strong) forceFireTime *forceFireTime;//通用api
@property (nonatomic,strong) NSString *shareurl;
@property (nonatomic,strong) NSString *toolsurl;
@property (nonatomic,strong) NSArray *morePanel;//(morePanelInfo数据类型)
@property (nonatomic,strong) NSArray *notConfig;//通过历史收藏等打开url（notConfig 数据类型）
@property (nonatomic,assign) NSString* appJumpValue;//(android 保留)//2  _WKNavigationActionPolicyAllowWithoutTryingAppLink = WKNavigationActionPolicyAllow + 2;
@property (nonatomic,strong) homeFristItem *homeItem;//(android 保留)//通过历史收藏等打开url
@property (nonatomic,strong) newProfessional *professional;//(android 保留)//通过历史收藏等打开url
@property (nonatomic,strong) TjLiance *tjLiance;//详见声明
@property (nonatomic,strong) HomeAdShow *homeADshow;//详见声明
@property (nonatomic,strong) NSString *RewardStep;//
@end

//使用中
@interface morePanelInfo : NSObject
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *des;//
@property (nonatomic,strong) NSString *beginTime;//
@property (nonatomic,strong) NSString *endTime;//
@property (nonatomic,strong) NSString *color_R;
@property (nonatomic,strong) NSString *color_G;
@property (nonatomic,strong) NSString *color_B;
@end


@interface arraySort:NSObject//allCellDataArray objectIndex:(morePanelInfo->type )
@property (nonatomic,strong) NSArray *arraySort;
@property (nonatomic,strong) NSArray *forceOpenThird;
@property (nonatomic,strong) NSString *showName;
@end

@interface onePanel : NSObject
@property (nonatomic,strong)NSString *iconurl;
@property (nonatomic,strong)NSString *headerName;
@property (nonatomic,strong)NSArray *array;
@end


@interface WebConfigItem : NSObject<NSCoding>
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *btnIconUrl;
@property (nonatomic,strong)NSArray *rule;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString* beginTime;
@property (nonatomic,strong)NSString* endTime;
@property (nonatomic,assign)BOOL isUseApi;
@property (nonatomic,assign)BOOL isAuToPlay;

@property (nonatomic,assign)BOOL isNoPcWeb;
@property (nonatomic,assign)BOOL isVip;
@property (nonatomic,assign)BOOL isGoToWebVideoUrl;
@property (nonatomic,assign)BOOL isDelAdsJs;
@property (nonatomic,assign)BOOL viewlist;
@property (nonatomic,assign)BOOL isAlwaysAds;
@property (nonatomic,assign)BOOL isCustom;//是否用户自己输入

@property (nonatomic,copy)NSString *userAgent;
@property (nonatomic,assign)BOOL isForceUseIjk;
@end

