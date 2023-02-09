//
//  FFmpegCmd.m
//  IJKMediaDemo
//
//  Created by zengbiwang on 2017/12/18.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import "FFmpegCmd.h"
#define FFmpegFileIDKey  @"FFmpegFileIDKey"
#define FFmpegFileUrlKey  @"FFmpegFileUrlKey"
#define FFmpegFileNameKey  @"FFmpegFileNameKey"
#define FFmpegFileRequestKey  @"FFmpegFileRequestKey"
#define FFmpegFileArrayKey  @"FFmpegFileArrayKey"

typedef enum FFMpegRequestType{
    FFMpeg_Start_Type,
    FFMpeg_GetInfo_Type,
    FFMpeg_Concatfile_Type,
    FFMpeg_GetHlsfile_Type,
    FFMpeg_End_Type,
}_FFMpegRequestType;

@interface FFmpegCmd()
@property(strong,nonatomic)id streamInfo;
@property(strong)NSDictionary *currentInfo;
@property(assign)_FFMpegRequestType reqeustType;
@property(strong)NSTimer *checkArrayTimer;
@property(strong)NSMutableArray *array;
@end


@implementation FFmpegCmd
+(FFmpegCmd*)getInstace{
    static FFmpegCmd*g = NULL;
    if (!g) {
        g = [[FFmpegCmd alloc] init];
        [g initNofiti];
    }
    return g;
}

-(void)initNofiti{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jik_ffmpeg_cmd_getInfo_notifi:) name:IJK_FFMPEG_CMD_GETINFO_Notification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jik_ffmpeg_cmd_stop_notifi:) name:IJK_FFMPEG_CMD_STOP_Notification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jik_ffmpeg_cmd_concatinfo_notifi:) name:IJK_FFMPEG_CMD_CONCANTINFO_Notification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jik_ffmpeg_cmd_gethlsinfo_notifi:) name:IJK_FFMPEG_CMD_GETHLSINFO_Notification object:nil];
    self.reqeustType  = FFMpeg_End_Type;
    self.array = [NSMutableArray arrayWithCapacity:1];
}

-(void)jik_ffmpeg_cmd_stop_notifi:(NSNotification*)object
{
    BOOL isForce = [object.object integerValue]==ForceExitFFMpegCode;
    if (self.reqeustType == FFMpeg_GetInfo_Type)
    {
        NSLog(@"self.streamInfo = %@",self.streamInfo);
        if ([self.delegate respondsToSelector:@selector(ffmpegCmdFinish:msg:fileName:url:error:)]) {
            [self.delegate ffmpegCmdFinish:[self.currentInfo objectForKey:FFmpegFileIDKey] msg:self.streamInfo fileName:[self.currentInfo objectForKey:FFmpegFileNameKey] url:[self.currentInfo objectForKey:FFmpegFileUrlKey]error:isForce?1:0];
        }
    }
    else if(self.reqeustType == FFMpeg_Concatfile_Type){
        NSLog(@"ffmpeg FFMpeg_Concatfile_Type sss");
        if ([self.concatdelegate respondsToSelector:@selector(ffmpegCmdConCatFinish:files:error:)]) {
            NSString *ret = self.streamInfo;
            [self.concatdelegate ffmpegCmdConCatFinish:[self.currentInfo objectForKey:FFmpegFileIDKey] files:[self.currentInfo objectForKey:FFmpegFileArrayKey] error:isForce?ForceExitFFMpegCode:(ret?[ret intValue]:1)];
        }
    }
    else if(self.reqeustType == FFMpeg_GetHlsfile_Type){
        if ([self.hlsdelegate respondsToSelector:@selector(ffmpegCmdHlsFinish:urlfiles:error:)]) {
            NSArray *ret = self.streamInfo;
            [self.hlsdelegate ffmpegCmdHlsFinish:[self.currentInfo objectForKey:FFmpegFileIDKey] urlfiles:ret error:isForce?ForceExitFFMpegCode:(ret?0:1)];
        }
    }
    else
    {
        NSLog(@"ffmpeg getinfo error");
        if ([self.delegate respondsToSelector:@selector(ffmpegCmdFinish:msg:fileName:url:error:)]) {
            [self.delegate ffmpegCmdFinish:[self.currentInfo objectForKey:FFmpegFileIDKey] msg:@"" fileName:nil url:nil error:-1];
        }
    }
    self.reqeustType = FFMpeg_End_Type;
    self.streamInfo = nil;
}

-(void)jik_ffmpeg_cmd_gethlsinfo_notifi:(NSNotification*)object{
    self.reqeustType = FFMpeg_GetHlsfile_Type;
    self.streamInfo = object.object;
}

-(void)jik_ffmpeg_cmd_concatinfo_notifi:(NSNotification*)object{
    self.reqeustType = FFMpeg_Concatfile_Type;
    self.streamInfo = object.object;
}

-(void)jik_ffmpeg_cmd_getInfo_notifi:(NSNotification*)object
{
    self.reqeustType = FFMpeg_GetInfo_Type;
    self.streamInfo = object.object;
}

-(BOOL)isCanAdd:(NSString*)fileID{
    if (!self.checkArrayTimer) {
        self.checkArrayTimer  = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkArray:) userInfo:nil repeats:YES];
    }
    for(int i =0;i<self.array.count;i++){
        if ([fileID compare:[[self.array objectAtIndex:i] objectForKey:FFmpegFileIDKey]]==NSOrderedSame) {
            return false;
        }
    }
    return true;
}

-(FFmpegCmdState)addVideo:(NSString*)fileID url:(NSString*)url  name:(NSString*)name{
    if ([self isCanAdd:fileID]) {
        [self.array addObject:@{FFmpegFileIDKey:fileID,FFmpegFileUrlKey:url,FFmpegFileNameKey:name,FFmpegFileRequestKey:@(FFMpeg_GetInfo_Type)}];
        return FFmpegCmdState_Ok;
    }
    return FFmpegCmdState_Exist;
}

-(FFmpegCmdState)addHlsUrlGetInfo:(NSString*)fileID url:(NSString*)url{
    if ([self isCanAdd:fileID]) {
        NSDictionary *info = @{FFmpegFileIDKey:fileID,FFmpegFileUrlKey:url,FFmpegFileRequestKey:@(FFMpeg_GetHlsfile_Type)};
        if ([self.array count]==0) {
            [self.array addObject:info];
        }
        else{
            [self.array insertObject:info atIndex:0];
        }
        return FFmpegCmdState_Ok;
    }
    return FFmpegCmdState_Exist;
}

-(FFmpegCmdState)addTsConcat:(NSString*)fileID tsArray:(NSArray*)tsArray  filePath:(NSString*)filePath{
    if ([self isCanAdd:fileID]) {
        NSDictionary *info = @{FFmpegFileIDKey:fileID,FFmpegFileNameKey:filePath,FFmpegFileRequestKey:@(FFMpeg_Concatfile_Type),FFmpegFileArrayKey:tsArray};
        if ([self.array count]==0) {
            [self.array addObject:info];
        }
        else{
            [self.array insertObject:info atIndex:0];
        }
        return FFmpegCmdState_Ok;
    }
    return FFmpegCmdState_Exist;
}

-(void)checkArray:(NSTimer*)timer
{
    if (self.reqeustType == FFMpeg_End_Type && self.array.count > 0) {
        self.reqeustType = FFMpeg_Start_Type;
        self.currentInfo =  [self.array objectAtIndex:0];
        [self.array removeObjectAtIndex:0];
        [self performSelectorInBackground:@selector(requestInfo) withObject:nil];
    }
}

-(void)requestInfo{
    FFMpegRequestType type = (FFMpegRequestType)[[self.currentInfo objectForKey:FFmpegFileRequestKey] integerValue];
    if (type==FFMpeg_GetInfo_Type) {
        [IJKFFMpeg IJK_ffmpeg_getUrlInfo:[[self.currentInfo objectForKey:FFmpegFileUrlKey] UTF8String]];
    }
    else if(type==FFMpeg_Concatfile_Type){
        [IJKFFMpeg IJK_ffmpeg_concat:[self.currentInfo objectForKey:FFmpegFileArrayKey] outFile:[self.currentInfo objectForKey:FFmpegFileNameKey]];
    }
    else if(type==FFMpeg_GetHlsfile_Type){
        [IJKFFMpeg IJK_ffmpeg_gethlsInfo:[[self.currentInfo objectForKey:FFmpegFileUrlKey] UTF8String]];
        
    }
}

-(void)exitffmpeg{
    if  (_reqeustType != FFMpeg_End_Type)
        [IJKFFMpeg forceExitFFmpeg];
}
@end
