//
//  WGamePlatform.h
//  WSDK
//
//  Created by wuxl on 2018/8/1.
//  Copyright © 2018年 wsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WGameCallbackDelegate.h"

/**
WSDK使用示例：
 
#import <WSDK/WGamePlatform.h>
#import <WSDK/WGameCallbackDelegate.h>

@interface DemoViewController()<WGameCallbackDelegate>{
    WGamePlatform *wSdkPlatform;
}

@end
 
@implementation DemoViewController
 
//初始化WSDK
- (void)init_WSDK{
     if (!wSdkPlatform){
        wSdkPlatform = [WGamePlatform shareInstance];
     }
     wSdkPlatform.rootVC = self;
     wSdkPlatform.delegate = self;
     wSdkPlatform.deviceID = @"123";
     wSdkPlatform.appId = 1;
     
     [wSdkPlatform initWGamePlatform];
}
 
//登录
- (void)login_WSDK{
    [wSdkPlatform loginWGamePlatform];
}

//注销
- (void)logout_WSDK{
    [wSdkPlatform logoutWGamePlatform];
}

//显示zhifu选择界面
- (void)showZhifu_WSDK:(NSInteger)productID attach:(NSString *)attach{
    wSdkPlatform.productID = productID;
    wSdkPlatform.attach = attach;
    [wSdkPlatform testByWGamePlatform];
}

#pragma WGameCallbackDelegate 实现登陆、注册、修改密码、绑定账号、游客登录的统一成功回调
- (void)loginSuccessBack{
    NSLog(@"loginSuccessBack");
 
    //APP收到回调就可以继续自己的游戏服登录了
    ......
}

@end

*/

@interface WGamePlatform : NSObject

/**
 以下三个必传和一个非必传参数，在调用initWGamePlatform前赋值
 */
@property (nonatomic, assign) id<WGameCallbackDelegate> delegate;
@property (nonatomic, strong) UIViewController* rootVC;//根试图控制器（必传参数）
@property (nonatomic, copy) NSString *deviceID;//设备唯一标志符（必传参数）
@property (nonatomic) NSInteger appId;//游戏ID(非必传参数)

/**
 以下两个必传参数，在调用testByWGamePlatform前赋值
 */
@property (nonatomic, assign) NSInteger productID;//计费点ID（必传参数,zhifu前传入参数）
@property (nonatomic, copy) NSString *attach;//透传参数（必传参数,zhifu前传入参数,CP通过这个参数来对应用户ID）

/**
 实例化
 @return WSdkPlatform对象
 */
+ (WGamePlatform*)shareInstance;


/**
 初始化
 */
- (void)initWGamePlatform;


/**
 显示登录界面，非第一次登录会自动登录
 */
- (void)loginWGamePlatform;


/**
 打开zhifu界面
 */
- (void)testByWGamePlatform;

/**
 注销当前缓存账号，进入登录界面重新登录
 */
- (void)logoutWGamePlatform;


@end
