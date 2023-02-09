//
//  WGameCallbackDelegate.h
//  WSDK
//
//  Created by wuxl on 2018/8/2.
//  Copyright © 2018年 wsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WGameCallbackDelegate <NSObject>

@optional

/**
 登陆、注册、修改密码、绑定账号、游客登录的统一成功回调，APP收到回调就可以继续自己的游戏登录操作
 失败时无需返回，会停留在SDK界面
 */
- (void)loginSuccessBack;


@end
