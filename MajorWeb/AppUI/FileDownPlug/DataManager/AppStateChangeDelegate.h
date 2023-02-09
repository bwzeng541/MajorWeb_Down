//
//  AppStateChangeDelegate.h
//  WatchApp
//
//  Created by zengbiwang on 2017/6/23.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AppStateChangeDelegate <NSObject>
@optional
-(void)app_state_change_1:(NSString*)uuid;
-(void)app_state_change_2:(NSString*)uuid;
-(void)app_state_change_3:(NSString*)uuid isAlone:(BOOL)isAlone;
-(void)app_state_change_4:(NSString*)uuid parma0:(float)parma0;
-(void)app_state_change_5:(NSString*)uuid ;
-(void)app_state_change_6:(NSString *)uuid;
-(void)app_state_change_7:(NSString*)uuid;
@end
