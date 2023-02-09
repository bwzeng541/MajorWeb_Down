//
//  AloneStateEngine.h
//  WatchApp
//
//  Created by zengbiwang on 2017/6/23.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppStateChangeDelegate.h"

@interface AloneStateEngine : NSObject
+(AloneStateEngine*)getInstance;
-(void)getAllStateInfo:(NSArray**)notFinish finish:(NSArray**)finish;
@property(assign)id<AppStateChangeDelegate>delegate;
-(void)loadConfigData;
-(void)checkAllAppClear;
-(void)clearEngineState;
-(void)clearAllState;
-(BOOL)setNewStateNode:(NSString*)uuid url:(NSString*)fileUrl name:(NSString*)name;
-(void)delNewStateNode:(NSString*)uuid;
-(NSInteger)getCurrentDownNumber;
-(bool)set_New_State:(NSString*)uuid;
-(void)reSet_New_State:(NSString*)uuid;
-(void)reDownload:(NSString*)m3u8ID;
-(NSArray*)getAllDownAloneUUID;
-(BOOL)isStateChangeOver:(NSString*)uuid;
-(NSNumber*)isCanSetState:(NSString*)uuid;

-(NSString*)getStateWjTmpRootPath:(NSString*)uuid;
-(NSString*)getStateNewWjRootPath:(NSString*)uuid;

//是否正在do
-(BOOL)isStateChangine:(NSString*)uuid;
@end
