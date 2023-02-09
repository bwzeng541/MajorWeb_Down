//
//  AloneStateEngine.m
//  WatchApp
//
//  Created by zengbiwang on 2017/6/23.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "AloneStateEngine.h"
#import "FileDonwPlus.h"
#import "AloneOenItem.h"
#import "FTWCache.h"

@interface AloneStateEngine()<AloneOenItemDelegate>
@property(copy)NSString *currentStateID;
@end

@implementation AloneStateEngine
{
    NSMutableDictionary *dicEnginStateItem;
    NSMutableDictionary *stateDicChangeNewItem;
    
    
    NSMutableDictionary *allStateItem;
}
+(AloneStateEngine*)getInstance{
    static AloneStateEngine *g = NULL;
    if (!g) {
        g = [[AloneStateEngine alloc]init];
    }
    return g;
}

-(void)checkAllAppClear{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSArray* tempArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ALONEDOWNROOTPATH error:nil];
        for (NSString *subPath in tempArray) {
             NSString *filePath = [ALONEDOWNROOTPATH stringByAppendingPathComponent:subPath];
            if ([filePath.pathExtension compare:@"tmp"] == NSOrderedSame) {
                NSString *savefile =  [filePath substringToIndex:[filePath rangeOfString:@".tmp" options:NSBackwardsSearch].location];
                if ([[NSFileManager defaultManager] fileExistsAtPath:savefile]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            }
        }
    });
}

-(id)init{
    self = [super init];
    [self loadConfigData];
    return self;
}

-(void)loadConfigData{
    stateDicChangeNewItem = [[NSMutableDictionary alloc]init];
    dicEnginStateItem = [[NSMutableDictionary alloc]init];
    allStateItem = [[NSMutableDictionary alloc]init];
    [dicEnginStateItem setDictionary:[NSDictionary dictionaryWithContentsOfFile:ALONEDOWNITMEINFOSAVEPATH]];
    [stateDicChangeNewItem setDictionary:[NSDictionary dictionaryWithContentsOfFile:ALONECAHESDOWNITMEINFOSAVEPATH]];
}

-(void)getAllStateInfo:(NSArray**)notFinish finish:(NSArray**)finish{
    NSMutableArray *retArrayNotFinish = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *retArrayFinish = [NSMutableArray arrayWithCapacity:10];
    NSArray *allKey = [dicEnginStateItem allKeys];
    for (int i = 0; i < allKey.count; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[dicEnginStateItem objectForKey:[allKey objectAtIndex:i]]];
        [info setObject:[allKey objectAtIndex:i] forKey:StateUUIDKEY];
        if ([self isStateChangeOver:[allKey objectAtIndex:i]]) {
            [retArrayFinish addObject:info];
        }
        else{
            [retArrayNotFinish addObject:info];
        }
    }
    *notFinish = retArrayNotFinish;
    *finish = retArrayFinish;
}

-(void)clearEngineState{
    NSArray *arrayKey = [dicEnginStateItem allKeys];
    for (int i=0; i < arrayKey.count; i++)
        [self reSet_New_State:[arrayKey objectAtIndex:i]];
}

-(void)clearAllState{
    NSArray *arrayKey = [dicEnginStateItem allKeys];
    for (int i=0; i < arrayKey.count; i++) {
        [self reSet_New_State:[arrayKey objectAtIndex:i]];
        [self delNewStateNode:[arrayKey objectAtIndex:i]];
    }
    [dicEnginStateItem removeAllObjects];
    [stateDicChangeNewItem removeAllObjects];
}

-(BOOL)setNewStateNode:(NSString*)uuid url:(NSString*)fileUrl name:(NSString*)name{
    NSLog(@"%s, m3u8ID = %@, m3u8Url = %@",__FUNCTION__,uuid,fileUrl);
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if (dic) {
        NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dic];
        //加密 m3u8Url
        NSData *data = [FTWCache encryptWithKeyNomarl:fileUrl];
        [dicNew setObject:data forKey:ALONE_FILE_URL];
        [dicEnginStateItem setObject:dicNew forKey:uuid];
        [dicEnginStateItem writeToFile:ALONEDOWNITMEINFOSAVEPATH atomically:YES];
        [stateDicChangeNewItem setObject:data forKey:uuid];
        [stateDicChangeNewItem writeToFile:ALONECAHESDOWNITMEINFOSAVEPATH atomically:YES];
        return TRUE;
    }
    else {
        NSData *data = [FTWCache encryptWithKeyNomarl:fileUrl];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:data,ALONE_FILE_URL,[NSString stringWithFormat:@"%@",uuid] ,ALONE_VIDEOPATH ,[NSNumber numberWithBool:FALSE], ALONE_DOWN_FINIHES,[NSString stringWithFormat:@"%@.mp4",uuid],ALONE_LOCAL_ALONEFILE,name,ALONE_VIDEO_SHOW_NAME,nil];//[[M3u8FileAnalyze getInstance] getM3u8FileDownUrl: m3u8Url m3u8ID:m3u8ID];
        if (dic) {
            [dicEnginStateItem setObject:dic forKey:uuid];
            [dicEnginStateItem writeToFile:ALONEDOWNITMEINFOSAVEPATH atomically:YES];
            [stateDicChangeNewItem setObject:data forKey:uuid];
            [stateDicChangeNewItem writeToFile:ALONECAHESDOWNITMEINFOSAVEPATH atomically:YES];
            return TRUE;
        }
    }
    return FALSE;
}

-(void)delNewStateNode:(NSString*)uuid{
    [self reSet_New_State:uuid];
    //注释删除文件判断
    //    if (dic){
    NSLog(@"%s",__FUNCTION__);
    NSString *strSave = [NSString stringWithFormat:@"%@/%@.mp4.tmp",ALONEDOWNROOTPATH,uuid];
    NSString *tempRootPath = [NSString stringWithFormat:@"%@/%@.mp4",ALONEDOWNROOTPATH,uuid];
    //删除文件夹
    [[NSFileManager defaultManager]removeItemAtPath:strSave
                                              error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:tempRootPath error:nil];
    [dicEnginStateItem removeObjectForKey:uuid];
    [dicEnginStateItem writeToFile:ALONEDOWNITMEINFOSAVEPATH atomically:YES];
}

-(NSArray*)getAllDownAloneUUID{
    NSArray *keyAll = allStateItem.allKeys;
    if (keyAll.count>0) {
        return keyAll;
    }
    return [NSArray array];
}

-(NSInteger)getCurrentDownNumber{
    return allStateItem.count;
}

-(bool)set_New_State:(NSString*)uuid{
    if ([self isStateChangeOver:uuid]) {
        return false;
    }
    [self reSet_New_State:uuid];
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if(dic){
        NSLog(@"%s start ok",__FUNCTION__);
        if (![allStateItem objectForKey:uuid])
        {
            AloneOenItem *downItem = [[[AloneOenItem alloc]init] autorelease];
            downItem.fileUrl = [FTWCache decryptWithKey:[dic objectForKey:ALONE_FILE_URL]];
            downItem.uuid = uuid;
            downItem.delegate = self;
            self.currentStateID =uuid;
            downItem.saveRootPath = [NSString stringWithFormat:@"%@/%@",ALONEDOWNROOTPATH,[dic objectForKey:ALONE_LOCAL_ALONEFILE]];
            downItem.tmpRootPath = [self getStateWjTmpRootPath:uuid];
            [allStateItem setObject:downItem forKey:uuid];
            [downItem start];
        }
        return true;
    }
    else {
        return false;
        NSLog(@"%s start failed",__FUNCTION__);
    }
}

-(void)reSet_New_State:(NSString*)uuid{
    if (!uuid) {
        return ;
    }
    if ([allStateItem objectForKey:uuid])
    {
        AloneOenItem *item = [allStateItem objectForKey:uuid];
        [item stop];
        [allStateItem removeObjectForKey:uuid];
    }
}

-(BOOL)isStateChangeOver:(NSString*)uuid{
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if  (dic){
        return  [[dic objectForKey:ALONE_DOWN_FINIHES] boolValue];
    }
    return FALSE;
}

-(BOOL)isStateChangine:(NSString*)uuid{
    BOOL isRet  = false;
    if (allStateItem && [allStateItem objectForKey:uuid]) {
        isRet = true;
    }
    return isRet;
}

-(NSNumber*)isCanSetState:(NSString*)uuid{
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if (dic){//
        //[[M3u8ArStateManager getInstance]delM3u8Item:m3u8ID];
         return [NSNumber numberWithBool:true];
     }
    else {
        return [NSNumber numberWithBool:false];
    }
}

-(void)reDownload:(NSString*)m3u8ID{
    if (m3u8ID && [dicEnginStateItem objectForKey:m3u8ID]) {
        NSMutableDictionary *dicInfo =  [NSMutableDictionary dictionaryWithDictionary:[dicEnginStateItem objectForKey:m3u8ID]];
        [dicInfo setObject:[NSNumber numberWithBool:NO] forKey:ALONE_DOWN_FINIHES];
        [self delNewStateNode:m3u8ID];
        [dicEnginStateItem setObject:dicInfo forKey:m3u8ID];
        [dicEnginStateItem writeToFile:ALONEDOWNITMEINFOSAVEPATH atomically:YES];
        [self set_New_State:m3u8ID];
    }
 }

-(NSString*)getStateNewWjRootPath:(NSString*)uuid{
    NSString *path = [NSString stringWithFormat:@"%@/%@.mp4",ALONEDOWNROOTPATH,uuid];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return nil;
//    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
//    if (dic) {
//        if( [[dic objectForKey:ALONE_DOWN_FINIHES] boolValue]){
//            return   [NSString stringWithFormat:@"%@/%@.mp4",ALONEDOWNROOTPATH,uuid];
//        }
//        return nil;
//    }
//    return nil;
}

-(NSString*)getStateWjTmpRootPath:(NSString*)uuid{
    return   [NSString stringWithFormat:@"%@/%@.mp4.tmp",ALONEDOWNROOTPATH,uuid];
}

#pragma mark --notifi

-(void)app_state_change_1:(NSString *)_uuid_{
    if ([self.delegate respondsToSelector:@selector(app_state_change_1:)]) {
        [self.delegate app_state_change_1:_uuid_];
    }
}

-(void)app_state_change_3:(NSString*)_uuid_{
    if ([self.delegate respondsToSelector:@selector(app_state_change_3:isAlone:)]) {
        [self.delegate app_state_change_3:_uuid_ isAlone:YES];
    }
}

-(void)app_state_change_4:(NSString*)_uuid_ parma0:(float)parma0{
    if ([self.delegate respondsToSelector:@selector(app_state_change_4:parma0:)]) {
        [self.delegate app_state_change_4:_uuid_ parma0:parma0];
    }
}

-(void)app_state_change_2:(NSString*)_uuid_ {
    if ([self.delegate respondsToSelector:@selector(app_state_change_2:)]) {
        [self.delegate app_state_change_2:_uuid_];
    }
}

-(void)app_state_change_5:(NSString*)_uuid_ {
    NSDictionary *dic = [dicEnginStateItem objectForKey:_uuid_];
    NSLog(@"%s  dic = %@",__FUNCTION__,[dic description]);
    if (dic) {
        NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicNew setObject:[NSNumber numberWithBool:YES] forKey:ALONE_DOWN_FINIHES];
        [dicEnginStateItem setObject:dicNew forKey:_uuid_];
        [dicEnginStateItem writeToFile:ALONEDOWNITMEINFOSAVEPATH atomically:YES];
    }
    [stateDicChangeNewItem removeObjectForKey:_uuid_];
    [stateDicChangeNewItem writeToFile:ALONECAHESDOWNITMEINFOSAVEPATH atomically:YES];
    [allStateItem removeObjectForKey:_uuid_];
    if ([self.delegate respondsToSelector:@selector(app_state_change_5:)]) {
        [self.delegate app_state_change_5:_uuid_];
    }
}

-(void)app_state_change_6:(NSString *)_uuid_{
    if ([self.delegate respondsToSelector:@selector(app_state_change_6:)]) {
        [self.delegate app_state_change_6:_uuid_];
    }
    [allStateItem removeObjectForKey:_uuid_];
}


@end
