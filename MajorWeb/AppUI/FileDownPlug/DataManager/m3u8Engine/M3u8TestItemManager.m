//
//  M3u8TestItemManager.m
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import "M3u8TestItemManager.h"
#import "M3u8ArStateManager.h"

#define M3u8RetryTimeKey  @"M3u8RetryTimeKey"
@interface M3u8TestItemManager(){
    NSMutableDictionary *stateTestDic;
    BOOL   isItemStart_;//串行下载
}
@property(copy)NSString *currentStateFormID;
@end

@implementation M3u8TestItemManager



+(M3u8TestItemManager*)getInstance{
    static M3u8TestItemManager *g = NULL;
    if (!g) {
        g = [[M3u8TestItemManager alloc]init];
    }
    return g;
}

-(id)init{
    self = [super init];isItemStart_= FALSE;
    stateTestDic = [[NSMutableDictionary dictionary] retain];
    return self;
    
}

-(void)addDownItemFromSourceNew:(NSString*)m3u8Url m3u8ID:(NSString*)m3u8ID{
    if (![stateTestDic objectForKey:m3u8ID]) {//M3u8TestItem 对象里面必须下载m3u8ID文件，解析数据
        M3u8TestItem *m3u8Item = [[[M3u8TestItem alloc] init]autorelease];
        m3u8Item.delegate=self;
        NSDictionary *dicNew = [NSDictionary dictionaryWithObjectsAndKeys:m3u8Item,M3U8_DOWNITEM_TAG, m3u8Url, M3U8_FILE_URL,[NSNumber numberWithInt:0],M3u8RetryTimeKey,nil];
       // m3u8Item.allArrayDown = [dic objectForKey:M3U8_ALLDOWN_URL];
        m3u8Item.saveRootPath = [NSString stringWithFormat:@"%@/%@",M3U8DOWNROOTPATH,m3u8ID];
        m3u8Item.tempRootPath = [NSString stringWithFormat:@"%@/%@",M3U8DOWNROOTPATH,m3u8ID];
        m3u8Item.m3u8ID=m3u8ID;
        m3u8Item.m3u8Url =m3u8Url;
        [stateTestDic setObject:dicNew forKey:m3u8ID];
    }
}

-(NSString*)getCurrentUUID{
    return self.currentStateFormID;
}

-(void)startChangeStateFromID:(NSString*)strM3u8ID{
    NSDictionary *dic = [stateTestDic objectForKey:strM3u8ID];
    if (self.currentStateFormID && false) //可以多个文件下载(CanDownMutileFileOneTime == 0)
    {
        isItemStart_ = false;
        [self stopChangeStateFromID:self.currentStateFormID];
        [[NSNotificationCenter defaultCenter]postNotificationName:DOWNPAUSEM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.currentStateFormID,@"M3U8ID" ,nil]];
    }
    self.currentStateFormID = strM3u8ID;
    if  (dic&&!isItemStart_){
        if (false){ //(CanDownMutileFileOneTime == 0)
            isItemStart_ = TRUE;//可以多个文件下载
        }
        M3u8TestItem *down = (M3u8TestItem*)[dic objectForKey:M3U8_DOWNITEM_TAG];
        [down start];
    }
}

-(void)stopChangeStateFromID:(NSString*)strM3u8ID{
    NSDictionary *dic = [stateTestDic objectForKey:strM3u8ID];
    if  (dic){
        isItemStart_ = FALSE;
        M3u8TestItem *down = (M3u8TestItem*)[dic objectForKey:M3U8_DOWNITEM_TAG];
        [down stop];
    }
    if([self.delegate respondsToSelector:@selector(app_state_change_2:)]){
        [self.delegate app_state_change_2:strM3u8ID];
    }
}

-(void)startNextItem{
    NSArray *arrayKey  = [stateTestDic allKeys];
    NSLog(@"%s",__FUNCTION__);
    if ([arrayKey count]>0) {
        [self startChangeStateFromID:[arrayKey objectAtIndex:0]];
    }
}

-(void)delStateFromID:(NSString*)strM3u8ID{
    NSDictionary *dic = [stateTestDic objectForKey:strM3u8ID];
    if  (dic){
        M3u8TestItem *down = (M3u8TestItem*)[dic objectForKey:M3U8_DOWNITEM_TAG];
        [down stop];
        [stateTestDic removeObjectForKey:strM3u8ID];
    }
}


#pragma mark --M3u8TestItemDelegate
-(void)app_state_change_3:(NSString*)m3u8ID
{
    if ([self.delegate respondsToSelector:@selector(app_state_change_3:)]) {
        [self.delegate app_state_change_3:m3u8ID];
    }
}

-(void)app_state_change_4:(NSString*)m3u8ID parma0:(float)parma0
{
    if ([self.delegate respondsToSelector:@selector(app_state_change_4:parma0:)]) {
        [self.delegate app_state_change_4:m3u8ID parma0:parma0];
    }
}

-(void)app_state_change_5:(NSString*)m3u8ID {
    [[NSNotificationCenter defaultCenter]postNotificationName:FINISHES_M3U8_ITEM_DOWN object:m3u8ID];
    isItemStart_ = FALSE;
    [self delStateFromID:m3u8ID];
    self.currentStateFormID=nil;
    NSLog(@"%s",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(app_state_change_5:)]) {
        [self.delegate app_state_change_5:m3u8ID];
    }
   // [self startNextItem];//自动下载下一首通过AppStateInfoManager控制
}

-(void)app_state_change_1:(NSString*)m3u8ID{
    if ([self.delegate respondsToSelector:@selector(app_state_change_1:)]) {
        [self.delegate app_state_change_1:m3u8ID];
    }
}

-(void)app_state_change_7:(NSString*)m3u8ID{
    //必须通知ui失败
    isItemStart_ = FALSE;
    NSLog(@"%s",__FUNCTION__);
    [self delStateFromID:m3u8ID];
    if ([self.delegate respondsToSelector:@selector(app_state_change_7:)]) {
        [self.delegate app_state_change_7:m3u8ID];
    }
    // [self startNextItem];//自动下载下一首通过AppStateInfoManager控制
}

-(void) app_state_change_6:(NSString *)m3u8ID{
    NSLog(@"%s",__FUNCTION__);
    isItemStart_ = FALSE;
    if ([[[stateTestDic objectForKey:m3u8ID] objectForKey:M3u8RetryTimeKey] integerValue]>3) {//重试3次
        [self app_state_change_7:m3u8ID];
    }
    else{
        [self reCacle:m3u8ID];
    }
    return;
    [self delStateFromID:m3u8ID];
    if ([self.delegate respondsToSelector:@selector(app_state_change_6:)]) {
        [self.delegate app_state_change_6:m3u8ID];
    }
    [self startNextItem];//自动下载下一首
}

-(void)reCacle:(NSString*)m3u8ID{
    NSDictionary *dic = [stateTestDic objectForKey:m3u8ID];
    int newtimes = [[dic objectForKey:M3u8RetryTimeKey] intValue]+1;
    M3u8TestItem *down = (M3u8TestItem*)[dic objectForKey:M3U8_DOWNITEM_TAG];
    NSString*url = down.m3u8Url;
    [self delStateFromID:m3u8ID];
    [self addDownItemFromSourceNew:url m3u8ID:m3u8ID];
    [self startChangeStateFromID:m3u8ID];
    //自动jia1
    NSMutableDictionary *infoNre = [NSMutableDictionary dictionaryWithDictionary:[stateTestDic objectForKey:m3u8ID]];
    [infoNre setObject:[NSNumber numberWithInt:newtimes] forKey:M3u8RetryTimeKey];
    [stateTestDic setObject:infoNre forKey:m3u8ID];
}
@end
