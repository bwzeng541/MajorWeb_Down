//
//  QRSystemConfig.h
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/12.
//  Copyright © 2020 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QrMutilLineScanCtrl.h"
NS_ASSUME_NONNULL_BEGIN

@interface QRSystemConfig : NSObject
@property(readonly,nonatomic)CGSize deviceSize;//设备大小
@property(readonly,nonatomic)float topOffset;//顶部偏移
@property(readonly,nonatomic)CGRect scanRect;//扫描
@property(readonly,nonatomic)CGRect rectOfInterest;//AVCaptureMetadataOutput的扫描区域
@property(readonly,nonatomic)UIViewController *qrRootCtrl;
@property(readonly,nonatomic)BOOL indicatorAutoHidden;
@property(strong,nonatomic)NSDictionary *adWhitelist;
@property(strong,nonatomic)NSDictionary *storeWhitelist;
@property(assign,nonatomic)BOOL isTraceUrl;
@property(copy,nonatomic)NSString* appPassword;
@property(readonly,nonatomic)NSMutableDictionary *reportHostlist;
 +(QRSystemConfig*)shareInstance;
#define QRSearchVideoKey @"searchAdKey_20200727175429"
-(BOOL)isSearchVideoAdWatch ;
-(void)watchSearchVideoAd ;
@end

NS_ASSUME_NONNULL_END
