//
//  M3u8TestItemManager.h
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3u8TestItem.h"

@protocol M3u8TestItemManagerDelgate<NSObject>
@optional
-(void)app_state_change_3:(NSString*)m3u8ID;
-(void)app_state_change_4:(NSString*)m3u8ID parma0:(float)parma0;
//所有文件下载完成
-(void)app_state_change_5:(NSString*)m3u8ID ;
-(void)app_state_change_1:(NSString*)m3u8ID ;
-(void)app_state_change_2:(NSString*)m3u8ID ;
-(void)app_state_change_7:(NSString*)m3u8ID;
-(void)app_state_change_6:(NSString *)m3u8ID;//下载失败
@end

@interface M3u8TestItemManager : NSObject<M3u8TestItemDelgate>
+(M3u8TestItemManager*)getInstance;
-(NSString*)getCurrentUUID;
@property(assign)id<M3u8TestItemManagerDelgate>delegate;

-(void)addDownItemFromSourceNew:(NSString*)m3u8Url m3u8ID:(NSString*)m3u8ID;

-(void)startChangeStateFromID:(NSString*)strM3u8ID;
-(void)stopChangeStateFromID:(NSString*)strM3u8ID;

-(void)delStateFromID:(NSString*)strM3u8ID;

@end
