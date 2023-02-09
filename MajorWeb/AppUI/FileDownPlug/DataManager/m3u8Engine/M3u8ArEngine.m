//
//  M3u8ArEngine.m
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import "M3u8ArEngine.h"
#import "M3u8TestItemManager.h"
#import "M3u8FileAnalyze.h"
#import "M3u8ArStateManager.h"
@interface M3u8ArEngine()<M3u8TestItemManagerDelgate>{
    NSMutableDictionary *dicEnginStateItem;//这里只能保存m3u8文件地址。每次启动重启解析数据
    NSMutableDictionary *stateDicChangeNewItem;//20130926增加自动缓存功能
}
@property(copy)NSString *currentUD;
@end;

@implementation M3u8ArEngine

+(M3u8ArEngine*)getInstance{
    static M3u8ArEngine *g = NULL;
    if  (!g){
        g = [[M3u8ArEngine alloc]init];
    }
    return g;
}

-(id)init{
    self = [super init];
  
    //屏蔽自动下载
  //  [self performSelector:@selector(autoStartFromCahes) withObject:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishesM3u8Down:) name:FINISHES_M3U8_ITEM_DOWN object:nil];
    [self loadConfigData];
    return self;
}

-(void)loadConfigData{
    dicEnginStateItem = [[NSMutableDictionary alloc]init];
    [dicEnginStateItem setDictionary:[NSDictionary dictionaryWithContentsOfFile:M3U8DOWNITMEINFOSAVEPATH]];
    stateDicChangeNewItem = [[NSMutableDictionary alloc]init];
    [stateDicChangeNewItem setDictionary:[NSDictionary dictionaryWithContentsOfFile:M3U8CAHESDOWNITMEINFOSAVEPATH]];
    [M3u8TestItemManager getInstance].delegate = self;
}

-(void)autoStartFromCahes{
//    NSMutableDictionary *dicTmp = [stateDicChangeNewItem mutableCopy];
//    [dicTmp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        //创建为下载项，//key为m3u8 obj为文件下载地址
//       NSString *url = [FTWCache decryptWithKey:obj];
//        if (url) {
//            [self setNewStateNode:key url:url];
//            [[M3u8TestItemManager getInstance]addDownItemFromSourceNew:url m3u8ID:key];
//        }
//        if (*stop==TRUE) {
//
//        }
//    }];
//
//    NSLog(@"%s",__FUNCTION__);
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        if ([[stateDicChangeNewItem allKeys] count]>0) {
//            [self set_New_State:[[stateDicChangeNewItem allKeys] objectAtIndex:0]];
//        }
//    });
//
}

-(void)finishesM3u8Down:(NSNotification*)object{
    NSString *m3u8id = object.object;
    NSDictionary *dic = [dicEnginStateItem objectForKey:m3u8id];
    NSLog(@"%s  dic = %@",__FUNCTION__,[dic description]);
    if (dic) {
        NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicNew setObject:[NSNumber numberWithBool:YES] forKey:M3U8_DOWN_FINIHES];
        [dicEnginStateItem setObject:dicNew forKey:m3u8id];
        [dicEnginStateItem writeToFile:M3U8DOWNITMEINFOSAVEPATH atomically:YES];
    }
    [stateDicChangeNewItem removeObjectForKey:m3u8id];
    [stateDicChangeNewItem writeToFile:M3U8CAHESDOWNITMEINFOSAVEPATH atomically:YES];
}
-(BOOL)isStateChangeOver:(NSString*)uuid{
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if  (dic){
       return  [[dic objectForKey:M3U8_DOWN_FINIHES] boolValue];
    }
    return FALSE;
}

-(void)getAllStateInfo:(NSArray**)notFinish finish:(NSArray**)finish{
    NSMutableArray *retArrayNotFinish = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *retArrayFinish = [NSMutableArray arrayWithCapacity:10];
    NSArray *allKey = [dicEnginStateItem allKeys];
    for (int i = 0; i < allKey.count; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[dicEnginStateItem objectForKey:[allKey objectAtIndex:i]]];
        [info setObject:[allKey objectAtIndex:i] forKey:StateUUIDKEY];
        if([self isStateChangeOver:[allKey objectAtIndex:i]]){
            [retArrayFinish addObject:info];
        }
        else{
            [retArrayNotFinish addObject:info];
        }
    }
    *notFinish = retArrayNotFinish;
    *finish = retArrayFinish;
}

//设置的时候，调用M3u8FileAnalyze 解析出文件，生成本地播放需要的m3u8文件，以及所有下载片段列表
-(BOOL)setNewStateNode:(NSString*)m3u8ID url:(NSString*)m3u8Url name:(NSString*)name{
    NSLog(@"%s, m3u8ID = %@, m3u8Url = %@",__FUNCTION__,m3u8ID,m3u8Url);
    NSDictionary *dic = [dicEnginStateItem objectForKey:m3u8ID];
    if (dic) {
        NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dic];
        //加密 m3u8Url
        NSData *data = [FTWCache encryptWithKeyNomarl:m3u8Url];
        [dicNew setObject:data forKey:M3U8_FILE_URL];
        [dicEnginStateItem setObject:dicNew forKey:m3u8ID];
        [dicEnginStateItem writeToFile:M3U8DOWNITMEINFOSAVEPATH atomically:YES];
        [stateDicChangeNewItem setObject:data forKey:m3u8ID];
        [stateDicChangeNewItem writeToFile:M3U8CAHESDOWNITMEINFOSAVEPATH atomically:YES];
        return TRUE;
    }
    else {
        NSData *data = [FTWCache encryptWithKeyNomarl:m3u8Url];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:data,M3U8_FILE_URL,[NSString stringWithFormat:@"%@",m3u8ID] ,M3U8_VIDEOPATH ,[NSNumber numberWithBool:FALSE], M3U8_DOWN_FINIHES,[NSString stringWithFormat:@"%@.m3u8",m3u8ID],M3U8_LOCAL_M3U8FILE,name,M3U8_VIDEO_FILE_NAME,nil];//[[M3u8FileAnalyze getInstance] getM3u8FileDownUrl: m3u8Url m3u8ID:m3u8ID];
        if (dic) {
            [dicEnginStateItem setObject:dic forKey:m3u8ID];
            [dicEnginStateItem writeToFile:M3U8DOWNITMEINFOSAVEPATH atomically:YES];
            [stateDicChangeNewItem setObject:data forKey:m3u8ID];
            [stateDicChangeNewItem writeToFile:M3U8CAHESDOWNITMEINFOSAVEPATH atomically:YES];
            return TRUE;
        }
    }
    return FALSE;
}

-(void)delNewStateNode:(NSString*)m3u8ID{
    NSDictionary *dic = [dicEnginStateItem objectForKey:m3u8ID];
    [[M3u8ArStateManager getInstance]delM3u8Item:m3u8ID];
    //注释删除文件判断
//    if (dic){
        NSLog(@"%s",__FUNCTION__);
        [[M3u8TestItemManager getInstance]delStateFromID:m3u8ID];
        NSString *strSave = [NSString stringWithFormat:@"%@/%@",M3U8DOWNROOTPATH,m3u8ID];
        NSString *tempRootPath = [NSString stringWithFormat:@"%@/%@",M3U8DOWNROOTPATH,m3u8ID];
    
        NSString *localM3u8Path = [NSString stringWithFormat:@"%@/%@.m3u8",M3U8DOWNROOTPATH,m3u8ID];
        [[NSFileManager defaultManager] removeItemAtPath:localM3u8Path error:NULL];
        //删除文件夹
        [[NSFileManager defaultManager]removeItemAtPath:strSave
                                                  error:nil];
        [[NSFileManager defaultManager]removeItemAtPath:tempRootPath error:nil];
        [dicEnginStateItem removeObjectForKey:m3u8ID];
        [dicEnginStateItem writeToFile:M3U8DOWNITMEINFOSAVEPATH atomically:YES];
//    }
    
}

-(void)reDownload:(NSString*)m3u8ID{
    if(m3u8ID){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[dicEnginStateItem objectForKey:m3u8ID]];
        if(dic){
            [dic setObject:[NSNumber numberWithBool:false] forKey:M3U8_DOWN_FINIHES];
            [self delNewStateNode:m3u8ID];
            [dicEnginStateItem setObject:dic forKey:m3u8ID];
            [dicEnginStateItem writeToFile:M3U8DOWNITMEINFOSAVEPATH atomically:YES];
            [self set_New_State:m3u8ID];
        }
    }
}

-(NSString*)getUUIDNotChangeStateString:(NSString*)uuid{
    return   [NSString stringWithFormat:@"%@/%@.m3u8",M3U8DOWNROOTPATH,uuid];
}

-(NSString*)getUUIDStateString:(NSString*)uuid{
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if (dic) {
        if( [[dic objectForKey:M3U8_DOWN_FINIHES] boolValue]){
            return   [NSString stringWithFormat:@"%@/%@.m3u8",M3U8DOWNROOTPATH,uuid];
        }
        return nil;
    }
    return nil;
}

-(NSNumber*)isCanSetState:(NSString*)uuid{
    NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if (dic){
        [[M3u8ArStateManager getInstance]delM3u8Item:uuid];
        return [NSNumber numberWithBool:true];
    }
    else {
        return [NSNumber numberWithBool:false];
    }
}

-(BOOL)isStateChangine:(NSString*)uuid{
    m3u8DownSate v = [[M3u8ArStateManager getInstance] getM3u8State:uuid];
    if (v==m3u8_down_unknow) {
        return false;
    }
    return true;
}

-(NSInteger)getCurrentDownNumber{
    return [[M3u8ArStateManager getInstance] getCurrentDownNumber];
}

-(bool)set_New_State:(NSString*)uuid{
    if([self isStateChangeOver:uuid])return false;
   NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
    if(dic){
        self.currentUD = uuid;
       // [[M3u8ArStateManager getInstance]delM3u8Item:[[M3u8TestItemManager getInstance]getCurrentUUID]];
        [[M3u8ArStateManager getInstance]addM3u8Item:uuid];
        NSString *url =  [FTWCache decryptWithKey:[dic objectForKey:M3U8_FILE_URL]];
        if (url) {
            [[M3u8TestItemManager getInstance]addDownItemFromSourceNew:url m3u8ID:uuid];
            [[M3u8TestItemManager getInstance] startChangeStateFromID:uuid];
            NSLog(@"%s start ok",__FUNCTION__);
            return true;
        }
        else{
            self.currentUD = nil;
            [self delNewStateNode:uuid];
            return false;
        }

    }
    else {
        return false;
    }
}

-(void)reSet_New_State:(NSString*)uuid{
    if (uuid) {
        NSDictionary *dic = [dicEnginStateItem objectForKey:uuid];
        if(dic){
            [[M3u8ArStateManager getInstance]delM3u8Item:uuid];
            [[M3u8TestItemManager getInstance] stopChangeStateFromID:uuid];
        }
    }
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

#pragma mark--M3u8TestItemManagerDelgate
-(void)app_state_change_3:(NSString*)m3u8ID{
    if ([self.delegate respondsToSelector:@selector(app_state_change_3:isAlone:)]) {
        [self.delegate app_state_change_3:m3u8ID isAlone:false];
    }
}

-(void)app_state_change_4:(NSString*)m3u8ID parma0:(float)parma0{
    if ([self.delegate respondsToSelector:@selector(app_state_change_4:parma0:)]) {
        [self.delegate app_state_change_4:m3u8ID parma0:parma0];
    }
}

//所有文件下载完成
-(void)app_state_change_5:(NSString*)m3u8ID {
    if ([self.delegate respondsToSelector:@selector(app_state_change_5:)]) {
        [self.delegate app_state_change_5:m3u8ID];
    }
}

//暂停下载
-(void)app_state_change_2:(NSString*)m3u8ID {
    if ([self.delegate respondsToSelector:@selector(app_state_change_2:)]) {
        [self.delegate app_state_change_2:m3u8ID];
    }
}

//所有文件开始
-(void)app_state_change_1:(NSString*)m3u8ID {
    if ([self.delegate respondsToSelector:@selector(app_state_change_1:)]) {
        [self.delegate app_state_change_1:m3u8ID];
    }
}

-(void)app_state_change_7:(NSString*)m3u8ID{
    if ([self.delegate respondsToSelector:@selector(app_state_change_7:)]) {
        [self.delegate app_state_change_7:m3u8ID];
    }
}

-(void)app_state_change_6:(NSString *)m3u8ID{
    if ([self.delegate respondsToSelector:@selector(app_state_change_6:)]) {
        [self.delegate app_state_change_6:m3u8ID];
    }
}
@end
