//
//  AppStateInfoManager.m
//  IJKMediaDemo
//
//  Created by zengbiwang on 2017/12/18.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#if DoNotKMPLayerCanShareVideo
#else
#import "AppStateInfoManager.h"
#import "M3u8ArEngine.h"
#import "AloneStateEngine.h"
#import "YTKNetworkPrivate.h"
#import  <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "Toast+UIView.h"
#import "NSArray+CrashGuard.h"
#import "GuanliManager1.h"
#import "Reachability.h"
#import "FileDonwPlus.h"
#import "AppDelegate.h"
#import "AppNewStateManager.h"
#import "VipPayPlus.h"
#import "M3u8ArStateManager.h"
#import "MajorSystemConfig.h"
#import "MarjorWebConfig.h"
#import "MajorICloudSync.h"
#import "AFNetworkReachabilityManager.h"
#import "HuanCunCtrl.h"
#define FileARPlayerManagerKeySAVEPATH [NSString stringWithFormat:@"%@/uuidkeyArray.info",VIDEOCACHESROOTPATH]

@interface AppStateInfoManager()<FFmpegCmdDelegate,AppStateChangeDelegate>
@property(strong)NSMutableArray *allCacheArray;
@property(strong)NSMutableArray *infoNewKeyArray;
@property(assign)NSInteger indePos;
@property(assign)AFNetworkReachabilityStatus  isWifiState;
@property(copy)NSString *currentID;
@property(strong)NSDate *localPushTime;

@property(strong)NSMutableDictionary *shiBInfo;
@end
@implementation AppStateInfoManager
+(AppStateInfoManager*)getInstance{
    static AppStateInfoManager *g = NULL;
    if (!g) {
        g = [[AppStateInfoManager alloc] init];
#ifdef DEBUG
        [[FFmpegCmd getInstace]setFFmpegCmdLog:true];
#endif
        [FFmpegCmd getInstace].delegate = g;
        [AloneStateEngine getInstance].delegate = g;
        [M3u8ArEngine getInstance].delegate = g;
        g.delegate = [GuanliManager1 getInstance];
        NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
        [def addObserver:g
                selector:@selector(applicationDidEnterForeground:)
                    name:UIApplicationDidBecomeActiveNotification
                  object:[UIApplication sharedApplication]];
        
        [def addObserver:g
                selector:@selector(startToBatchVideoCaches)
                    name:@"startToBatchVideoCaches"
                  object:[UIApplication sharedApplication]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g autoExcte];
        });
    }
    return g;
}

-(void)startToBatchVideoCaches{
    if (self.currentID) {
        [self setStateFromUser:self.currentID];
    }
    else{
        [self checkFrom0:nil];
    }
    //后台返回到前台简单最大下载个数
    NSInteger downCount = MaxDownParallelNumber -[[M3u8ArEngine getInstance] getCurrentDownNumber]-[[AloneStateEngine getInstance] getCurrentDownNumber];
    [self getAllStateKeyArray];
    for (int i=0; i<downCount; i++) {
        [self checkFrom0:nil];
    }
}

-(void)applicationDidEnterForeground:(NSNotification*)object{
    [self startToBatchVideoCaches];
}

-(void)stopAllItemDown{
    NSArray *m3u8Array =  [[M3u8ArStateManager getInstance] getAllDownM3u8UUID];
    NSArray *aloneArray = [[AloneStateEngine getInstance] getAllDownAloneUUID] ;
    for (int i = 0; i < m3u8Array.count; i++) {
        [[M3u8ArEngine getInstance] reSet_New_State:[m3u8Array objectAtIndex:i]];
    }
    for (int i = 0; i < aloneArray.count; i++) {
        [[AloneStateEngine getInstance] reSet_New_State:[aloneArray objectAtIndex:i]];
    }
}

-(void)autoExcte{
//    static BOOL isStart = false;
//    if (!isStart) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self getAllStateInfo];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                for (int i = 0; i <5;i++) {
//                    [self checkFrom0:nil];
//                }
//            });
//        });
//    }
//    isStart = true;
}

-(id)init{
    self = [super init];
    self.shiBInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    self.infoNewKeyArray = [NSMutableArray arrayWithCapacity:10];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceMsgFromApp:) name:@"postMsgFromApp" object:nil];
   
    self.isWifiState = AFNetworkReachabilityStatusNotReachable;
    @weakify(self)
    [RACObserve([MajorICloudSync getInstance], isSyncToFinish) subscribeNext:^(id x) {
        @strongify(self)
        if ([MajorICloudSync getInstance].isSyncToFinish) {
            [HuanCunCtrl sycnSortTable];
            [self loadConfigData];
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initNetWorkNotifi];
    });
    [self loadConfigData];
    return self;
}

-(void)loadConfigData{
    [[AloneStateEngine getInstance] loadConfigData];
    [[M3u8ArEngine getInstance] loadConfigData];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:FileARPlayerManagerKeySAVEPATH];
    if (array.count>0) {
        [self.infoNewKeyArray addObjectsFromArray:array];
    }
    [self getAllStateInfo];
}

-(void)initNetWorkNotifi{
    @weakify(self)
    
    [RACObserve([MajorSystemConfig getInstance], isWifiState) subscribeNext:^(id x) {
        @strongify(self)
        AFNetworkReachabilityStatus ret = [MajorSystemConfig getInstance].isWifiState;
        if (AFNetworkReachabilityStatusReachableViaWiFi == ret && self.isWifiState!=ret) {//wifi状态
            self.isWifiState = ret;
            [self applicationDidEnterForeground:nil];
            if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                if (!self.localPushTime || [[NSDate date] minutesFrom:self.localPushTime]>=30) {
                    UILocalNotification *notification = [[UILocalNotification alloc]init];
                    notification.userInfo = @{@"hehe":@"nidaye"};
                    notification.alertBody = @"你已经连接WIFI~》》正在开始下载未完成的视频";
                    notification.soundName= UILocalNotificationDefaultSoundName;
                    notification.fireDate = [[NSDate date]dateByAddingTimeInterval:2];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    self.localPushTime = [NSDate date];
                }
            }
        }
        else if(AFNetworkReachabilityStatusReachableViaWWAN == ret && self.isWifiState!=ret){//
            self.isWifiState = ret;
            if(![MarjorWebConfig getInstance].isAllows4GDownMode){
                [self stopAllItemDown];
            }
            else{
                [self applicationDidEnterForeground:nil];
            }
        }
    }];
    
    [RACObserve([MarjorWebConfig getInstance], isAllows4GDownMode) subscribeNext:^(id x) {
        @strongify(self)
        BOOL ret = [x boolValue];
        if (ret && self.isWifiState == AFNetworkReachabilityStatusReachableViaWWAN) {
            [self applicationDidEnterForeground:nil];
        }
        else if(!ret && self.isWifiState == AFNetworkReachabilityStatusReachableViaWWAN){
            [self stopAllItemDown];
        }
    }];
}

-(void)reviceMsgFromApp:(NSNotification*)object{
   NSString *parma0 = [object.object objectForKey:@"parma0"];
   NSString *parma1 = [object.object objectForKey:@"parma1"];
   NSString *parma2 = [object.object objectForKey:@"parma3"];
    NSNumber *duarTime = [object.object objectForKey:@"parma4"];
    if (parma0&&parma1&&parma2 && duarTime) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf3];
        [info setValue:[NSArray arrayWithObjects:parma0,parma1,parma2,duarTime, nil] forKey:@"param4"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];
    }
}

-(void)addKeyFromUUID:(NSString*)uuid{
    [self.infoNewKeyArray removeObject:uuid];//防止重复
    [self.infoNewKeyArray addObject:uuid];
    [self.infoNewKeyArray writeToFile:FileARPlayerManagerKeySAVEPATH atomically:YES];
}

-(void)delKeyFromUUID:(NSString*)uuid{
    [self.infoNewKeyArray removeObject:uuid];
    [self.infoNewKeyArray writeToFile:FileARPlayerManagerKeySAVEPATH atomically:YES];
}

-(void)reDownload:(NSString*)uuid{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf25];
    [info setObject:@[uuid] forKey:@"param4"];
    [[AppWtManager getInstanceAndInit]getWtCallBack:info];
    info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf26];
    [info setObject:@[uuid] forKey:@"param4"];
    [[AppWtManager getInstanceAndInit]getWtCallBack:info];
}

//判断单独文件或者文件夹.mp4 m3u8
-(NSString*)getStateFromUser:(NSString*)uuid{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf20];
    [info setObject:@[uuid] forKey:@"param4"];
    NSString *fishPath1 = [[AppWtManager getInstanceAndInit]getWtCallBack:info];
    NSString *fishPath2 = [[AloneStateEngine getInstance]getStateNewWjRootPath:uuid];
    if (fishPath1) {
        return fishPath1;
    }
    if (fishPath2) {
        return fishPath2;
    }
    return nil;
}

-(NSNumber*)delStateFromUser:(NSString*)uuid{
    BOOL isDel = false;
    for (NSInteger i=0; i < self.allCacheArray.count; i++) {
        NSString *_uuid  = [[self.allCacheArray objectAtIndex:i] objectForKey:StateUUIDKEY];
        if ([_uuid compare:uuid]==NSOrderedSame) {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf22];
            [info setObject:@[uuid] forKey:@"param4"];
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];

            [[AloneStateEngine getInstance] delNewStateNode:uuid];
            isDel= true;
            break;
        }
    }
    [[AppNewStateManager getInstance] updateValueSuccess:uuid];
    [self.shiBInfo removeObjectForKey:uuid];
    [self delKeyFromUUID:uuid];
    self.currentID = nil;
    [[FFmpegCmd getInstace]exitffmpeg:uuid];
    return [NSNumber numberWithBool:isDel];
}

-(void)showManagerMessage:(NSString*)msg{
    [[UIApplication sharedApplication].keyWindow makeToast:msg duration:1 position:@"center" ];
}

-(NSNumber*)isNodeInArray:(NSString*)uuid{
    if (self.currentID && [self.currentID compare:uuid] == NSOrderedSame) {
        return [NSNumber numberWithBool:true];
    }
    return [NSNumber numberWithBool:false];
}

-(NSNumber*)isAddCaches:(NSString*)uuid{
    NSMutableDictionary *info1 = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf21];
    [info1 setObject:@[uuid] forKey:@"param4"];
    return [NSNumber numberWithBool:[[[AppWtManager getInstanceAndInit] getWtCallBack:info1] boolValue] || [[[AloneStateEngine getInstance]isCanSetState:uuid] boolValue]];
}

-(void)addStateFromUser:(NSString*)param1  param2:(NSString*)param2 coutmUUID:(NSString*)uuid{
    NSString *_param2 = param2;
    NSString *_param1 = param1;
    NSLog(@"addStateFromUser param1 = %@ param2 = %@ uuid =%@",param1,param2,uuid);
    if (!_param2) {
        NSLog(@"fileName = %@ uuid = %@ error url = nil",_param1,uuid);
        return;
    }
    NSString *file1 =  [self getStateFromUser:uuid];
    if (file1) {
        NSString *msg = @"该视频已下载完成";
        NSLog(@"fileName = %@ uuid = %@ %@",_param1,uuid,msg);
        if (![self.delegate notofi_state_msg:msg uuid:uuid])
            [self showManagerMessage:msg];
        return;
    }
  
    if ([[self isAddCaches:uuid] boolValue]) {
        NSString *msg = @"该视频已加入下载";
        NSLog(@"fileName = %@ uuid = %@ %@",_param1,uuid,msg);
        if (![self.delegate notofi_state_msg:msg uuid:uuid])
            [self showManagerMessage:msg];
#if (CanDownMutileFileOneTime==0)
        if(!self.currentID){
            [self setStateFromUser:uuid];
        }
#else
        [self setStateFromUser:uuid];
#endif
        return;
    }
    FFmpegCmdState state= FFmpegCmdState_Exist;
    if ((([[_param2.pathExtension lowercaseString] rangeOfString:@"m3u8"].location != NSNotFound)&&
         [_param2.pathExtension length]==4)||
        ([_param2 rangeOfString:[NSString stringWithFormat:@"%@%@%@%@%@m",@"cac",@"he.m",@".iq",@"iy",@"i.co"]].location != NSNotFound)){
        [[M3u8ArEngine getInstance] setNewStateNode:uuid url:_param2 name:_param1];
        [self addKeyFromUUID:uuid];
#if (CanDownMutileFileOneTime==0)
        if(!self.currentID){
            [self setStateFromUser:uuid];
        }
#else
        [self setStateFromUser:uuid];
#endif
    }//mov,mp4,m4a,3gp,3g2,mj2
    else if(([_param2.pathExtension length]<=4) &&([[_param2.pathExtension lowercaseString] rangeOfString:@"mp4"].location != NSNotFound ||
            [[_param2.pathExtension lowercaseString] rangeOfString:@"mov"].location != NSNotFound ||
            [[_param2.pathExtension lowercaseString] rangeOfString:@"m4a"].location != NSNotFound ||
            [[_param2.pathExtension lowercaseString] rangeOfString:@"3gp"].location != NSNotFound ||
            [[_param2.pathExtension lowercaseString] rangeOfString:@"3gp2"].location != NSNotFound ||
             [[_param2.pathExtension lowercaseString] rangeOfString:@"mj2"].location != NSNotFound))
    {
        [self ffmpegCmdFinish:uuid msg:[_param2.pathExtension lowercaseString] fileName:_param1 url:_param2 error:0];
    }
    else {
        NSString *url = [[RecordUrlToUUID getInstance] urlFromKey:uuid];
        state = [[FFmpegCmd getInstace] addVideo:uuid url:_param2 name:_param1 referUrl:url];
    }
    if (state==FFmpegCmdState_Exist) {
        NSString *msg = @"该视频已加入下载";
        if (![self.delegate notofi_state_msg:msg uuid:uuid])
            [self showManagerMessage:msg];
    }
    else{
        NSString *msg = @"添加下载成功";
        if (![self.delegate notofi_state_msg:msg uuid:uuid])
            [self showManagerMessage:msg];
    }
}

+(NSString*)getVideoUUIDFrom:(NSString*)webUrl videoUrl:(NSString*)url durtime:(NSNumber*)durtime{
    NSString *uuid = nil;
    if (!webUrl) {//视频地址
        uuid =  [YTKNetworkUtils md5StringFromString:url];
    }
    else{//网页
        uuid =  [YTKNetworkUtils md5StringFromString:webUrl];
    }
    //更具param3时间参数修改uuid值
    if (durtime && [durtime floatValue]<600) {
        uuid = [YTKNetworkUtils md5StringFromString:url];//现在地址做uuid
    }
    return uuid;
}

-(void)addStateNode:(NSString*)param0 param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSNumber*)param3{
    NSString *uuid = [AppStateInfoManager getVideoUUIDFrom:param2 videoUrl:param1 durtime:param3];
    [[RecordUrlToUUID getInstance] addUrl:param2 uuid:uuid title:param0];
    NSLog(@"addStateNode param0 = %@ param1 = %@ param2 = %@ param3 = %@",param0,param1,param2,param3);
   // [[RecordUrlToUUID getInstance] addUrl:param2 uuid:uuid];
    [self addStateFromUser:param0 param2:param1 coutmUUID:uuid];
}

-(void)clearAllState{
    self.currentID = nil;
    [[M3u8ArEngine getInstance] clearEngineState];
    [[AloneStateEngine getInstance] clearEngineState];
}

-(void)clearStateFromUser:(NSString*)uuid{
    NSString *_uuid =  uuid;
    self.currentID = nil;
    [[M3u8ArEngine getInstance] reSet_New_State:_uuid];
    [[AloneStateEngine getInstance] reSet_New_State:_uuid];
}


-(NSArray*)getAllStateInfo{
    NSArray *finsh1 ,*finsh2,*notfinsh1,*notfinsh2;
    [[M3u8ArEngine getInstance] getAllStateInfo:&notfinsh1  finish:&finsh1];
    [[AloneStateEngine getInstance] getAllStateInfo:&notfinsh2  finish:&finsh2];
    self.allCacheArray = [NSMutableArray arrayWithCapacity:100];
    [self.allCacheArray addObjectsFromArray:finsh1];
    [self.allCacheArray addObjectsFromArray:finsh2];
    [self.allCacheArray addObjectsFromArray:notfinsh1];
    [self.allCacheArray addObjectsFromArray:notfinsh2];
    return [NSArray arrayWithArray:_allCacheArray];
}

-(NSArray*)getAllStateKeyArray{
  //  if (self.infoNewKeyArray.count!=self.allCacheArray.count) {//这里肯定是相等的
        [self.infoNewKeyArray removeAllObjects];
        for (int i = 0; i < self.allCacheArray.count; i++) {
          [self.infoNewKeyArray addObject:[[self.allCacheArray objectAtIndex:i] objectForKey:StateUUIDKEY]];
        }
        [self.infoNewKeyArray writeToFile:FileARPlayerManagerKeySAVEPATH atomically:YES];
    //    NSLog(@"rest Set getAllStateKeyArray some error");
    //}
    return [NSArray arrayWithArray:_infoNewKeyArray];
}

//金币值检查
-(NSNumber*)setStateFromUser:(NSString *)uuid{
    NSLog(@"%s %d",__FUNCTION__,__LINE__);//最大d下载队列数在这里？
    self.indePos = [self.infoNewKeyArray indexOfObject:uuid];
    NSInteger downCount = [[M3u8ArEngine getInstance] getCurrentDownNumber]+[[AloneStateEngine getInstance] getCurrentDownNumber];
    if (downCount>=MaxDownParallelNumber /*|| (![VipPayPlus getInstance].systemConfig.vip && ![[VipPayPlus getInstance] isVaildOperationCheck:@"HuanCunCtrl"] )*/) {//去除vip限制
       NSString *uuid = [[AppNewStateManager getInstance] getMaxCreateTime];
        [[M3u8ArEngine getInstance] reSet_New_State:uuid];
        [[AloneStateEngine getInstance] reSet_New_State:uuid];
    }
    BOOL ret1 = [[M3u8ArEngine getInstance] set_New_State:uuid];
    BOOL ret2 = [[AloneStateEngine getInstance] set_New_State:uuid];
    if (ret1||ret2) {
        self.currentID = uuid;
    }
    return [NSNumber numberWithBool:ret1 || ret2];
}

-(void)showMsgContent:(NSString*)msg uuid:(NSString*)uuid{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
         NSArray *array = [self getAllStateInfo];
        for (int i = 0; i < array.count; i++) {
             NSDictionary *info = [array objectAtIndex:i];
            if ([[info objectForKey:StateUUIDKEY] compare:uuid]==NSOrderedSame) {
                NSString *key = nil;
                if ([info objectForKey:ALONE_FILE_URL]) {
                    key = ALONE_VIDEO_SHOW_NAME;
                }
                else{
                    key = M3U8_VIDEO_FILE_NAME;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@"%@%@",[info objectForKey:key],msg] duration:3 position:@"top"];
                    [GetAppDelegate showLocalNotifi:[NSString stringWithFormat:@"%@%@",[info objectForKey:key],msg]];
                });
                break;
            }
        }
    });
}

-(void)moveStateToWifi:(NSString*)uuid{
    for(int i = 0; i < self.allCacheArray.count;i++){
        NSDictionary *info = [self.allCacheArray objectAtIndex:i];
       NSString *v =  [info objectForKey:StateUUIDKEY];
        if (uuid && v && [v compare:uuid]==NSOrderedSame) {
            NSString *name = [info objectForKey:ALONE_VIDEO_SHOW_NAME];
            NSString *dd =   [self getStateFromUser:uuid];
            if ([name length]>=1 && [dd length]>3) {
                NSFileManager *manager = [NSFileManager defaultManager];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *wifiDirectory = [documentsDirectory stringByAppendingPathComponent:@"wifi"];
                NSString *movePath = [wifiDirectory stringByAppendingPathComponent:name];
                [manager moveItemAtPath:dd toPath:movePath error:nil];
            }
            break;
        }
    }
}
#pragma FFmpegCmdDelegate
-(void)ffmpegCmdFinish:(NSString*)_uuid_  msg:(NSString*)msg fileName:(NSString*)fileName url:(NSString *)url error:(int)errror
{
         if (errror==0) {
            if ([msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"mo",@"v"]].location != NSNotFound ||
                [msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"mp",@"4"]].location != NSNotFound ||
                [msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"m4",@"a"]].location != NSNotFound ||
                [msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"3",@"gp"]].location != NSNotFound ||
                [msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"3",@"g2"]].location != NSNotFound ||
                [msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"m",@"j2"]].location != NSNotFound)
            {
                [[AloneStateEngine getInstance] setNewStateNode:_uuid_ url:url name:fileName];
                [self addKeyFromUUID:_uuid_];
                //[[AloneStateEngine getInstance] set_New_State:videoID];
            }
            else if ([msg rangeOfString:[NSString stringWithFormat:@"%@%@",@"hl",@"s"]].location != NSNotFound){
                [[M3u8ArEngine getInstance] setNewStateNode:_uuid_ url:url name:fileName];
                [self addKeyFromUUID:_uuid_];
                //[[M3u8ArEngine getInstance] set_New_State:videoID];
            }
        }
        else{
            NSString *error = [NSString stringWithFormat:@"%@:%@ %@",@"视频",fileName,@"不能下载"];
            if ([self.delegate notofi_state_msg:error uuid:_uuid_]) {
               // [self showManagerMessage:error];
            }
            NSLog(@"下载有错误");
           // [self checkFrom0];//检查下一个视频?
        }
    if (!self.currentID) {
        [self checkFrom0:nil];//自动下载
    }
    [self.delegate notofi_state_callBack:_uuid_ error:errror];
}

-(void)app_state_change_3:(NSString*)_uuid_ isAlone:(BOOL)isAlone{
    
}

//停止下载
-(void)app_state_change_2:(NSString*)_uuid_{
    [[AppNewStateManager getInstance] updateValueState2:_uuid_ isStartTime:false];
    [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state2_info_key:[NSNumber numberWithBool:true]}];
}

//开始下载
-(void)app_state_change_1:(NSString*)_uuid_{
    [[AppNewStateManager getInstance] updateValueState2:_uuid_ isStartTime:true];
      [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state1_info_key:[NSNumber numberWithBool:true]}];
}

-(void)app_state_change_4:(NSString*)_uuid_ parma0:(float)parma0{
    [[AppNewStateManager getInstance] updateValueState1:_uuid_ value:[NSString stringWithFormat:@"%@%0.2f%%",@"下载进度",parma0*100]];
    [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state4_info_key:[NSNumber numberWithFloat:parma0]}];
}

//这里完成之后，需要通知GuanliManager1删除改项目
-(void)app_state_change_5:(NSString*)_uuid_{
    [[AppNewStateManager getInstance] updateValueSuccess:_uuid_];
    [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state5_info_key:[NSNumber numberWithBool:true]}];
    [self showMsgContent:@"下载成功" uuid:_uuid_];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@_VideoPlayerNotifi",_uuid_] object:[self getStateFromUser:_uuid_]];
    if ([self.delegate respondsToSelector:@selector(notofi_state_success:)]) {
        [self.delegate notofi_state_success:_uuid_];
    }
    [self checkFrom0:_uuid_];
    
    //查找下一个视频，开始下载//从第一个开始下载
    if (false/*GetAppDelegate.isOpen*/) {//需要移动到docment的wifi目录，并修改文件名字，从AppStateInfoManager里面删除配置文件，postui更新
        [self moveStateToWifi:_uuid_];
        [[GuanliManager1 getInstance] deletZNodeUUID:_uuid_];
        [[AppStateInfoManager getInstance] delStateFromUser:_uuid_];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDataChange" object:nil];
    }
}

-(void)exchangeFaildToLast:(NSString*)faildUUID{//在后台的时候不加入错误值
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        self.currentID= nil;
        [[AppNewStateManager getInstance] updateValueFaild:faildUUID];
       //不需要加入失败判断 [self.shiBInfo setObject:@"1" forKey:faildUUID];
        if ([self.delegate respondsToSelector:@selector(notofi_state_error:)]) {
            [self.delegate notofi_state_error:faildUUID];
        }
    }
}

-(void)app_state_change_6:(NSString *)_uuid_{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state6_info_key:[NSNumber numberWithBool:true]}];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state3_info_key:[NSNumber numberWithBool:true]}];
    }
    [self exchangeFaildToLast:_uuid_];
    [self checkFrom0:_uuid_];
}

-(void)app_state_change_7:(NSString*)_uuid_
{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state7_info_key:[NSNumber numberWithBool:true]}];
    }
    else{
          [[NSNotificationCenter defaultCenter] postNotificationName:_uuid_ object:@{state3_info_key:[NSNumber numberWithBool:true]}];
    }
    [self exchangeFaildToLast:_uuid_];
    [self checkFrom0:_uuid_];
}

-(void)checkFrom0:(NSString*)old_uuid_{
    if([MajorSystemConfig getInstance].isWifiState == AFNetworkReachabilityStatusReachableViaWWAN && ![MarjorWebConfig getInstance].isAllows4GDownMode){//非wifi状态，禁止4g下载
        return;
    }
    old_uuid_=nil;
    self.currentID = nil;
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    if (![mgr isReachable]) {//无网络
        return;
    }
    //后台并且不是vip，禁止自动下下一个视频
    if ([UIApplication sharedApplication].applicationState!=UIApplicationStateActive && [VipPayPlus getInstance].systemConfig.vip==General_User) {
        return;
    }//end
    BOOL ret = false;
    int startPos = (self.indePos==NSNotFound?0:self.indePos);
    NSInteger totoalCount = self.infoNewKeyArray.count;
    for (int i = 0; i < totoalCount; i++) {
        int pos = (startPos+1)%self.infoNewKeyArray.count;
        NSString *cuuuid =  [self.infoNewKeyArray objectAtIndexWithCheck:pos];
        startPos = pos;
        if ([self.shiBInfo objectForKey:cuuuid]) {
            continue;
        }
        BOOL retInto = [[AppNewStateManager getInstance] isInCachesState:cuuuid];
        if (retInto) {
            continue;
        }
        NSString *file1 =  [self getStateFromUser:cuuuid];
        if (!file1) {//重下，必须重请求网页
            NSString *uuid = [self.infoNewKeyArray objectAtIndex:startPos];
            NSNumber *retValue = [self setStateFromUser:uuid];
            if([retValue intValue]==1){//
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf8];
                [info setObject:@[cuuuid] forKey:@"param4"];
                if(![[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue]){
                    info =  [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf17];
                    [info setObject:@[cuuuid] forKey:@"param4"];
                    [[AppWtManager getInstanceAndInit] getWtCallBack:info];
                }
            }
            ret = true;
            break;
        }
    }
    if (!ret) {
        if ([self.delegate respondsToSelector:@selector(notofi_state_change:)]) {
            [self.delegate notofi_state_change:old_uuid_];
        }
        if ([self.delegate respondsToSelector:@selector(notofi_state_next:)]) {
            [self.delegate notofi_state_next:old_uuid_];
        }
    }
}
@end

#endif
