//
//  VipManager.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/5.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WelfareManager.h"
#import "JSON.h"
#import "helpFuntion.h"
#import "Toast+UIView.h"
#import "SFHFKeychainUtils.h"
#import "AppDelegate+extern.h"
#import "UIAlertView+NSCookbook.h"
#import "MKStoreKit.h"
#import "YSCHUDManager.h"
#define WelfareSupreViewValue @"WelfareSupreViewValue"


#define VipSubOneDay20180705 @"SubOneDay20180705"

#define VipConfigFile @"20180705_file1"

//使用时间秒
#define VipUseTimeKey @"vip_use_time"
//分享次数
#define VipUseShareTimesKey @"vip_share_times"
//点击广告次数
#define VipClickAdTimesKey @"vip_click_ad_times"

//剩余多少天
#define VipUseRemainDayKey @"vip_remain_day"

@interface WelfareManager()
@property(retain)NSDate *backTime;
@property(retain)NSMutableDictionary *vipInfo;
@end
@implementation WelfareManager
+(WelfareManager*)getInstance{
    static WelfareManager *g = nil;
    if (!g) {
        g = [[WelfareManager alloc] init];
    }
    return g;
}

-(id)init{
    self =[super init];
    self.vipInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSData *data =[FTWCache objectForKey:VipConfigFile useKey:YES];
    if (data) {
        self.vipInfo = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] JSONValue];
    }
    NSLog(@"WelfareManager init vipInfo = %@",[self.vipInfo description]);
    NSNotificationCenter *v = [NSNotificationCenter defaultCenter];
    [v addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [v addObserver:self selector:@selector(productsAvailableNotification:) name:kMKStoreKitProductsAvailableNotification object:nil];
    [v addObserver:self selector:@selector(productPurchasedNotification:) name:kMKStoreKitProductPurchasedNotification object:nil];
    [v addObserver:self selector:@selector(productPurchaseFailedNotification:) name:kMKStoreKitProductPurchaseFailedNotification object:nil];
    [v addObserver:self selector:@selector(restoredPurchasesNotification:) name:kMKStoreKitRestoredPurchasesNotification object:nil];
    [v addObserver:self selector:@selector(restoringPurchasesFailedNotification:) name:kMKStoreKitRestoringPurchasesFailedNotification object:nil];
    [[MKStoreKit sharedKit] startProductRequest];
    return self;
}

-(void)productsAvailableNotification:(NSNotification*)object{
    NSLog(@"kMKStoreKitProductsAvailableNotification %@ ",[object description]);
}

-(void)productPurchasedNotification:(NSNotification*)object{//购买成功
    [SFHFKeychainUtils storeUsername:WelfareSupreViewValue andPassword:@"1" forServiceName:ServeNameAccessManager updateExisting:YES error:nil];
    [YSCHUDManager hideHUDOnKeyWindow];
    UIAlertView  *v =[[UIAlertView alloc] initWithTitle:@"" message:@"购买成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [v show];
    NSLog(@"kMKStoreKitProductPurchasedNotification %@ ",[object description]);
}

-(void)productPurchaseFailedNotification:(NSNotification*)object{//购买失败
    [YSCHUDManager hideHUDOnKeyWindow];
    UIAlertView  *v =[[UIAlertView alloc] initWithTitle:@"" message:@"购买失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [v show];
    NSLog(@"kMKStoreKitProductPurchaseFailedNotification %@ ",[object description]);
}

-(void)restoredPurchasesNotification:(NSNotification*)object{//恢复购买成功
    [SFHFKeychainUtils storeUsername:WelfareSupreViewValue andPassword:@"1" forServiceName:ServeNameAccessManager updateExisting:YES error:nil];
    [YSCHUDManager hideHUDOnKeyWindow];
    NSLog(@"kMKStoreKitRestoredPurchasesNotification %@ ",[object description]);
}

-(void)restoringPurchasesFailedNotification:(NSNotification*)object{//恢复购买失败
    [YSCHUDManager hideHUDOnKeyWindow];
    UIAlertView  *v =[[UIAlertView alloc] initWithTitle:@"" message:@"购买失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [v show];
    NSLog(@"kMKStoreKitRestoringPurchasesFailedNotification %@ ",[object description]);
}

-(void)enterForeground{
    if (self.backTime&&GetAppDelegate.isAddressleg) {
        NSDate *now = [NSDate date];
        NSTimeInterval offset  =   [now timeIntervalSinceDate:self.backTime];
        if (offset>10) {//增加金币奖励
            NSString *value = [SFHFKeychainUtils getPasswordForUsername:kAppVserion_isPress andServiceName:ServeNameAccessManager error:nil];
            if (!value) {
                [SFHFKeychainUtils storeUsername:kAppVserion_isPress andPassword:@"1" forServiceName:ServeNameAccessManager updateExisting:YES error:nil];
            }
            if (self.assetSuccess) {
                self.assetSuccess();
            }
        }
        else{
            if (self.assetFaild) {
                self.assetFaild();
            }
            else
            {
                [self showAlter:@"评价失败" msg:@"你未填写评论,抱歉不能进入" btn1Title:@"取消" btn2Title:@"填写"];
            }
        }
        self.backTime = nil;
    }
}

-(void)showAlter:(NSString*)title msg:(NSString*)msg btn1Title:(NSString*)btn1Title btn2Title:(NSString*)btn2Title{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:msg
                              delegate:nil
                              cancelButtonTitle:btn1Title
                              otherButtonTitles:btn2Title , nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView,
                                    NSInteger buttonIndex) {
        
        switch (buttonIndex) {
            case 0: {
                NIDINFO(@"Rate");
                if (self.assetFaild) {
                    self.assetFaild();
                }
                break;
            }
            case 1: {
                self.backTime = [NSDate date];
                NSURL *url = [NSURL URLWithString:[RFRateMe getAppstoreUrl]];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
                else{
                    if (self.assetFaild) {
                        self.assetFaild();
                    }
                }
                break;
            }
            case 2: {
                if (self.assetFaild) {
                    self.assetFaild();
                }
                break;
            }
        }
    }];
}

-(void)shareAppAssessUI
{
    [self showAlter:@"评价后才能进入" msg:@"填写5星好评，好评后--系统会自动确认--完成状态" btn1Title:@"下一次" btn2Title:@"写好评"];
}

//自动兑换会员会员
-(void)exchangeSupreVip{
    if([self isAppAssess] && ![self isWelfSupreVip] && GetAppDelegate.isAddressleg)//非会员的情况下，才兑换
    {
        NSInteger totalTime = [[self.vipInfo objectForKey:VipUseTimeKey] integerValue];
        NSInteger shareTimes = [[self.vipInfo objectForKey:VipUseShareTimesKey] integerValue];
        if (shareTimes>=3 && totalTime>=(3600*3)) {//三个小时
            //开始兑换
            [self.vipInfo removeObjectForKey:VipUseTimeKey];
            [self.vipInfo removeObjectForKey:VipUseShareTimesKey];
            [self.vipInfo setObject:[NSNumber numberWithInteger:2] forKey:VipUseRemainDayKey];
            [self syncLocal];
            //弹出提示
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"提示" message:@"恭喜你达到福利值，获得2日会员" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [v show];
             });
            NSLog(@"exchangeSupreVip ok");
        }
        else{
            NSLog(@"exchangeSupreVip faild");
        }
    }
}

-(BOOL)isBuySupreVip{
    NSString *value = [SFHFKeychainUtils getPasswordForUsername:WelfareSupreViewValue andServiceName:ServeNameAccessManager error:nil];
    if (value) {
        return true;
    }
    return false;
}
//使用天数需要减一
-(BOOL)isWelfSupreVip
{
    if (GetAppDelegate.isOpen) {
        printf("ceshi isWelfSupreVip\n");
        return true;
    }
    if ([self isBuySupreVip]) {
        return true;
    }
    NSNumber *number =  [self.vipInfo objectForKey:VipUseRemainDayKey];
    NSInteger remainDay = [number integerValue];
    if (number && GetAppDelegate.isAddressleg && [[helpFuntion gethelpFuntion] isValideOneDay:VipSubOneDay20180705 nCount:1]) {
        [self.vipInfo setObject:[NSNumber numberWithInteger:remainDay-1] forKey:VipUseRemainDayKey];
        [self syncLocal];
    }
    if(number && remainDay>=0)
    {
        NSLog(@"isWelfSupreVip remainDay = %ld true",(long)remainDay);
        return true;
    }
    else
    {
        NSLog(@"isWelfSupreVip remainDay = %ld false number=null",(long)remainDay);
        return false;
    }
}

-(NSString*)getWelfareTimes
{
    NSInteger totalTime = [[self.vipInfo objectForKey:VipUseShareTimesKey] integerValue];
    if(totalTime>0)
    {
        return  [NSString stringWithFormat:@"当前福利值:%ld", totalTime*(totalTime+1)];
    }
    return @"当前福利值0";
}

-(void)addShareTimes{
    if(!GetAppDelegate.isOpen && ![self isWelfSupreVip] && GetAppDelegate.isAddressleg)
    {
        //一天最多分享有效次数2次
        if([[helpFuntion gethelpFuntion] isValideCommonDay:@"add20180709" nCount:2 intervalDay:1]){
            NSInteger shareTimes = [[self.vipInfo objectForKey:VipUseShareTimesKey] integerValue];
            ++shareTimes;
            NSLog(@"addShareTimes shareTimes = %ld ",(long)shareTimes);
            [self.vipInfo setObject:[NSNumber numberWithInteger:shareTimes] forKey:VipUseShareTimesKey];
            [self syncLocal];
        }
        UIAlertView *v = [[UIAlertView alloc]initWithTitle:@"提示" message:@"感谢你的分享，你将累计一次福利。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [v show];
    }
}

-(void)addUsrTime:(int)addSceond
{
    if(!GetAppDelegate.isOpen && ![self isWelfSupreVip])
    {
        NSInteger totalTime = [[self.vipInfo objectForKey:VipUseTimeKey] integerValue];
        totalTime+=addSceond;
        NSLog(@"addUsrTime totalTime = %ld ",(long)totalTime);
        [self.vipInfo setObject:[NSNumber numberWithInteger:totalTime] forKey:VipUseTimeKey];
        [self syncLocal];
    }
}

-(void)syncLocal{
        NSData *data = [[self.vipInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [FTWCache setObject:data forKey:VipConfigFile useKey:YES];
}

-(BOOL)isAppAssess{
    NSString *value = [SFHFKeychainUtils getPasswordForUsername:kAppVserion_isPress andServiceName:ServeNameAccessManager error:nil];
    if (value) {
        return true;
    }
    return false;
}

-(void)showUnVaildBuyUI{
    [[UIApplication sharedApplication].keyWindow makeToast:@"抱歉，此功能针对会员开放" duration:2 position:@"center"];
    return;
    NSString *msg = @"删除广告\n提供更多视频格式\n提供视频截图到相册功能\n给好友提供在线视频播放";
    if (!GetAppDelegate.isOpen) {
        msg = @"更多大福利！更多老司机资源！更多你想不到的渴望";
    }
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"会员功能"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"12元购买终身会员",
                               @"恢复购买", nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView,
                                    NSInteger buttonIndex) {
        
        switch (buttonIndex) {
            case 0: {
                break;
            }
            case 1: {
                [YSCHUDManager showHUDOnKeyWindow];
                [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"huiyuan_lanren"];
                break;
            }
            case 2: {
                [YSCHUDManager showHUDOnKeyWindow];
                [[MKStoreKit sharedKit]restorePurchases];
                break;
            }
        }
    }];
}
@end
