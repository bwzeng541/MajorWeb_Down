//
//  AppStateInfoManager.h
//  IJKMediaDemo
//
//  Created by zengbiwang on 2017/12/18.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#if DoNotKMPLayerCanShareVideo
#else
#import <Foundation/Foundation.h>


@protocol AppStateInfoManagerDelegate<NSObject>
-(void)notofi_state_change:(NSString*)uuid;
-(void)notofi_state_next:(NSString*)uuid;
-(void)notofi_state_success:(NSString*)uuid;
-(BOOL)notofi_state_msg:(NSString*)msg uuid:(NSString*)uuid;
-(void)notofi_state_callBack:(NSString*)uuid error:(int)error;
-(void)notofi_state_error:(NSString*)uuid;
@end

@interface AppStateInfoManager : NSObject
+(AppStateInfoManager*)getInstance;
@property(assign)id<AppStateInfoManagerDelegate>delegate;
-(NSNumber*)isNodeInArray:(NSString*)uuid;

-(void)autoExcte;

-(NSString*)getStateFromUser:(NSString*)uuid;
-(NSNumber*)delStateFromUser:(NSString*)uuid;
-(void)reDownload:(NSString*)uuid;
-(void)clearAllState;
-(NSNumber*)isAddCaches:(NSString*)uuid;
-(void)addStateFromUser:(NSString*)param1 param2:(NSString*)param2 coutmUUID:(NSString*)uuid;
-(void)addStateNode:(NSString*)param0 param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSNumber*)param3;
-(void)clearStateFromUser:(NSString*)uuid;
-(NSArray*)getAllStateInfo;
-(NSArray*)getAllStateKeyArray;
//0成功，1需要添加，2金币值不够
-(NSNumber*)setStateFromUser:(NSString *)uuid;

+(NSString*)getVideoUUIDFrom:(NSString*)webUrl videoUrl:(NSString*)url durtime:(NSNumber*)durtime;
@end
#endif
