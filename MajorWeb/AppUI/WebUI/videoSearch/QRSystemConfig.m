//
//  QRSystemConfig.m
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/12.
//  Copyright © 2020 cxh. All rights reserved.
//
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

#define ScanWH 220

#define TOP (SCREEN_HEIGHT-ScanWH)/2
#define LEFT (SCREEN_WIDTH-ScanWH)/2

#define IS_IPhoneX_All ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

#define APPURL @"http://max77.cn"

#import "QRSystemConfig.h"
#import "SAMKeychain.h"
#import <AdSupport/ASIdentifierManager.h>
#import "RegexKitLite.h"
#import "Toast+UIView.h"
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/utsname.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import "helpFuntion.h"
static NSString *webTitle = nil;
static QRSystemConfig *__qrSystemConfig;
@interface QRSystemConfig()
@property(assign,nonatomic)CGSize deviceSize;//设备大小
@property(assign,nonatomic)float topOffset;//顶部偏移
@property(assign,nonatomic)CGRect scanRect;//扫描
@property(assign,nonatomic)CGRect rectOfInterest;//AVCaptureMetadataOutput的扫描区域
@property(strong,nonatomic)UIViewController *qrRootCtrl;
@property(assign,nonatomic)BOOL indicatorAutoHidden;
@property(strong,nonatomic)NSMutableDictionary *reportHostlist;
@end
@implementation QRSystemConfig
@synthesize isTraceUrl =_isTraceUrl;
@synthesize appPassword = _appPassword;
+(QRSystemConfig*)shareInstance{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __qrSystemConfig = [[QRSystemConfig alloc]init];
    });
    return __qrSystemConfig;
}

-(id)init{
    self = [super init];
     return self;
}

 #define QRSearchVideoKey @"searchAdKey_20200727175429"
 -(BOOL)isSearchVideoAdWatch{
     if ([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:QRSearchVideoKey nCount:1 isUseYYCache:YES time:nil]) {
           return false;
       } return true;
 }

 -(void)watchSearchVideoAd{
     [[helpFuntion gethelpFuntion] isValideOneDay:QRSearchVideoKey nCount:1 isUseYYCache:YES time:nil];
 }

@end
