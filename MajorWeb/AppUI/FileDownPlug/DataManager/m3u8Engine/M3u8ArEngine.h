//
//  M3u8ArEngine.h
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppStateChangeDelegate.h"
@interface M3u8ArEngine : NSObject
+(M3u8ArEngine*)getInstance;
@property(assign)id<AppStateChangeDelegate>delegate;
-(void)clearEngineState;
-(void)clearAllState;//清除所有下载的数据
-(BOOL)setNewStateNode:(NSString*)m3u8ID url:(NSString*)m3u8Url name:(NSString*)name;
-(void)delNewStateNode:(NSString*)m3u8ID;
-(void)reDownload:(NSString*)m3u8ID;
-(NSInteger)getCurrentDownNumber;
-(bool)set_New_State:(NSString*)uuid;
-(void)reSet_New_State:(NSString*)uuid;
-(BOOL)isStateChangeOver:(NSString*)uuid;
-(NSNumber*)isCanSetState:(NSString*)uuid;
-(NSString*)getUUIDNotChangeStateString:(NSString*)uuid;
-(NSString*)getUUIDStateString:(NSString*)uuid;

-(void)getAllStateInfo:(NSArray**)notFinish finish:(NSArray**)finish;

-(BOOL)isStateChangine:(NSString*)uuid;
-(void)loadConfigData;
@end
