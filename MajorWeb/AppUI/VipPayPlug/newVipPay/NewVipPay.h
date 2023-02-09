//
//  NewVipPay.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/12/24.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewVipPay : NSObject
@property(nonatomic,readonly)NSString *vipData;
@property(nonatomic,readonly)NSString *account;
@property(nonatomic,readonly)BOOL isVip;
+(NewVipPay*)getInstance;
-(void)autoLogin;
-(void)loginSever:(NSString*)account password:(NSString*)password isShowMsg:(BOOL)showMsg;
-(void)regSever:(NSString*)account password:(NSString*)passowrd;
-(NSString*)getAccount;
-(NSString*)password;
@end

NS_ASSUME_NONNULL_END
