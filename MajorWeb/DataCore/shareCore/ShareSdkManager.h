//
//  ShareSdkManager.h
//  Tricky
//
//  Created by zengbiwang on 14-8-16.
//  Copyright (c) 2014年 zengbiwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import "MainMorePanel.h"
typedef void (^isForceShareBlock)(BOOL ret);
#define CONTENT   @"★可以屏蔽网页广告，看电影电视剧的苹果手机软件★"

/*
 我天天都用这个APP下载各种~国外~国内~电影~电视剧
 给你们推荐一个可以下载和在线看电影的苹果手机软件
 这是一款可以下载任何网页视频的手机APP
 各种~最新~电影~电视剧~都可以在这里看~
 */
#define TITLE [NSString stringWithFormat:@"★%@★",[@[@"各种~最新~电影~电视剧~都可以在这里看~",@"这是一款可以下载任何网页视频的手机APP",@"给你们推荐一个可以下载和在线看电影的苹果手机软件",@"我天天都用这个APP下载各种~国外~国内~电影~电视剧"]objectAtIndex:arc4random()%4]]
#define kAppUrl ([MainMorePanel getInstance].morePanel.shareurl?[MainMorePanel getInstance].morePanel.shareurl:@"https://softhome.oss-cn-hangzhou.aliyuncs.com/max/im/down.html")
@interface ShareSdkManager : NSObject
+(ShareSdkManager*)getInstance;

//SSDKPlatformType typeArray的数组
-(id)showShareType:(SSDKContentType)type typeArray:(NSArray*(^)(void))typeArray  value:(NSString*(^)(void) )msgBlock titleBlock:(NSString*(^)(void))titleBlock imageBlock:(UIImage*(^)(void))imageBlock urlBlock:(NSString*(^)(void))urlBlock shareViewTileBlock:(NSString*(^)(void))shareTitleBlock;

-(void)showShareTypeFixType:(SSDKContentType)shareType typeArray:(NSArray*(^)(void))typeArray  value:(NSString*(^)(void) )msgBlock titleBlock:(NSString*(^)(void))titleBlock imageBlock:(UIImage*(^)(void))imageBlock urlBlock:(NSString*(^)(void))urlBlock shareViewTileBlock:(NSString*(^)(void))shareTitleBlock;

-(BOOL)isForceShare2:(SSDKPlatformType)type msg:(NSString*)msg image:(UIImage *)_image forceShareBlock:(isForceShareBlock)forceShareBlock;

-(BOOL)isForceShare:(SSDKPlatformType)type msg:(NSString*)msg image:(UIImage *)_image forceShareBlock:(isForceShareBlock)forceShareBlock;
-(void)clearForceShareBlock;
-(void)shareHomeWithContent:(SSDKPlatformType)type msg:(NSString*)msg title:(NSString*)title contentType:(SSDKContentType)contentType image:(UIImage*)image url:(NSString*)url;
-(void)shareHome:(SSDKPlatformType)type;
-(void)shareContent:(UIViewController*)ctrl context:(NSString *)context imagePath:(NSString*)imagePath shareType:(SSDKPlatformType)type isShareImage:(BOOL)isShareImage isGif:(BOOL)isGif;
-(void)shareContentVideo:(UIViewController*)ctrl context:(NSString *)context image:(UIImage*)image videoPath:(NSString*)videoPath shareType:(SSDKPlatformType)type;

-(void)shareContentQQ:(UIViewController*)ctrl context:(NSString *)context image:(UIImage*)image gifPath:(NSString*)gifPath shareType:(SSDKPlatformType)type;
@end
