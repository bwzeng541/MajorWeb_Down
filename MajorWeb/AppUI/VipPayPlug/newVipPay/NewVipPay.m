//
//  NewVipPay.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/12/24.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "NewVipPay.h"
#import "AFNetworking.h"
#import "SAMKeychain.h"
#import <AdSupport/AdSupport.h>
#import "AppDelegate.h"
#import "YSCHUDManager.h"
#define GGBrowerServiceKey @"NewVipPay.service"
#define GGBrowerDeviceKey @"NewVipPayDevice"
#define GGBrowerAccountKey @"NewVipPayAccount"
#define GGBrowerPasswordKey @"NewVipPayPassword"

@interface NewVipPay()
@property(nonatomic,copy)NSString *vipData;
@property(nonatomic,assign)BOOL isVip;
@property(nonatomic,copy)NSString *account;
@property(nonatomic,strong)AFHTTPSessionManager *httpLoginSessionManager;
@property(nonatomic,strong)AFHTTPSessionManager *httpRegSessionManager;
@end
@implementation NewVipPay
+(NewVipPay*)getInstance{
    static NewVipPay *g = NULL;
    if (!g) {
        g = [[NewVipPay alloc] init];
    }
    return g;
}

-(void)autoLogin{
    static BOOL isGo = false;
    if (!isGo) {
        isGo = true;
        NSString *name = [self getAccount];
        NSString *password = [self password];
        if ([name length]>0&&[password length]>0) {
            [self loginSever:name password:password isShowMsg:YES];
        }
        else{
            
        }
    }
}
/*
 reg
 如果注册过了，就返回code: 500,message: "对不起，您已经注册过了
 否则返回 code:200,user 信息
 service  15:26:06
 login
 如果没有注册，返回 code: 500,message: "对不起，您还没有注册"
 如果注册了，密码不对，code: 500,
           data: {},
           message: "对不起，您的密码不对"
 如果正确：
 返回200，及用户信息，是否VIP，和到期时间 exp_time
 */

-(void)regSever:(NSString*)account password:(NSString*)passowrd{
    if(!GetAppDelegate.isProxyState){
        [YSCHUDManager showHUDOnKeyWindowWithMesage:@"注册中..."];
        self.httpRegSessionManager = [AFHTTPSessionManager manager];
           self.httpRegSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *params = @{@"user[username]":account,
                             @"user[password]":passowrd,
                             @"user[device]":[self getDeviceUUID]
    };
    self.httpRegSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.httpRegSessionManager POST:@"http://47.101.154.106:19801/register/reg" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [YSCHUDManager hideHUDOnKeyWindow];
        if ([[responseObject objectForKey:@"code"] intValue]==200) {
            [self updateAccoutAndPassword:account password:passowrd];
            [GetAppDelegate.window makeToast:@"注册成功" duration:1.5 position:@"center"];
        }
        else{
            [GetAppDelegate.window makeToast:[responseObject objectForKey:@"message"] duration:1.5 position:@"center"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [YSCHUDManager hideHUDOnKeyWindow];
        [GetAppDelegate.window makeToast:[error description] duration:1.5 position:@"center"];
    }];
    }
}

-(void)loginSever:(NSString*)account password:(NSString*)password isShowMsg:(BOOL)showMsg{
    if(!GetAppDelegate.isProxyState){
        if (showMsg) {
            [YSCHUDManager showHUDOnKeyWindowWithMesage:@"登录中..."];
        }
    self.httpLoginSessionManager = [AFHTTPSessionManager manager];
           self.httpLoginSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = @{@"user[username]":account,
                             @"user[password]":password,
                             @"user[device]":[self getDeviceUUID]
    };
    self.httpLoginSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.httpLoginSessionManager POST:@"http://47.101.154.106:19801/register/login" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [YSCHUDManager hideHUDOnKeyWindow];
        
        if ([[responseObject objectForKey:@"code"] intValue]==200) {
           NSDictionary *info = [responseObject objectForKey:@"data"];
           self.isVip = [[info objectForKey:@"isvip"] intValue] == 1?true:false;
            self.vipData = self.isVip?[info objectForKey:@"exp_time"]:@"";
            [self updateAccoutAndPassword:account password:password];
        }
        [GetAppDelegate.window makeToast:[responseObject objectForKey:@"message"] duration:1.5 position:@"center"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [YSCHUDManager hideHUDOnKeyWindow];
        [GetAppDelegate.window makeToast:[error description] duration:1.5 position:@"center"];
    }];
    }
}

-(NSString*)getAccount{
     return  [SAMKeychain passwordForService:GGBrowerServiceKey account:GGBrowerAccountKey];
}

-(NSString*)password{
    return  [SAMKeychain passwordForService:GGBrowerServiceKey account:GGBrowerPasswordKey];
}


-(void)updateAccoutAndPassword:(NSString*)accout password:(NSString*)password{
    if ([accout length]>0&&[password length]>0) {
        [SAMKeychain setPassword:accout forService:GGBrowerServiceKey account:GGBrowerAccountKey];
        [SAMKeychain setPassword:password forService:GGBrowerServiceKey account:GGBrowerPasswordKey];
        self.account = accout;
    }
}


-(NSString*)getDeviceUUID{
    NSString *oldUUID = [SAMKeychain passwordForService:GGBrowerServiceKey account:GGBrowerDeviceKey];
    if (oldUUID) {
        return oldUUID;
    }
    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
        NSString *vv = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [SAMKeychain setPassword:vv forService:GGBrowerServiceKey account:GGBrowerDeviceKey];
        return vv;
    }
    if (oldUUID) {
        return oldUUID;
    }
    CFUUIDRef puuid = CFUUIDCreate( nil );
       CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
       NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    [SAMKeychain setPassword:result forService:GGBrowerServiceKey account:GGBrowerDeviceKey];
    return result;
}

@end
