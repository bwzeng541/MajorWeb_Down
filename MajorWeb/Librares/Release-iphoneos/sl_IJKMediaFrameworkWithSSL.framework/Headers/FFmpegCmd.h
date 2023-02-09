//
//  FFmpegCmd.h
//  IJKMediaDemo
//
//  Created by zengbiwang on 2017/12/18.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import <IJKMediaFrameworkWithSSL/IJKMsgDef.h>

typedef NS_ENUM(NSUInteger, FFmpegCmdState) {
    FFmpegCmdState_Exist,
    FFmpegCmdState_Ok
};
//判断文件格式
@protocol FFmpegCmdDelegate<NSObject>
-(void)ffmpegCmdFinish:(NSString*)_uuid_  msg:(NSString*)msg fileName:(NSString*)fileName url:(NSString*)url error:(int)errror;
@end

@protocol FFmpegCmdConcatDelegate<NSObject>
-(void)ffmpegCmdConCatFinish:(NSString*)_uuid_  files:(NSArray*)array error:(int)errror;
-(void)ffmpegCmdConCatProgress:(NSString*)_uuid_  currentTime:(float)currentTime;
@end

@protocol FFmpegCmdHlsDelegate<NSObject>
-(void)ffmpegCmdHlsFinish:(NSString*)_uuid_  urlfiles:(NSArray*)array keyData:(NSData*)keyData viData:(NSData*)viData error:(int)errror;
@end

//所有ffmpeg命令和下载必须添加referer头
@interface FFmpegCmd : NSObject
+(FFmpegCmd*)getInstace;
@property(weak)id<FFmpegCmdDelegate>delegate;
-(void)setFFmpegCmdLog:(BOOL)isCmdLog;

-(void)exitffmpeg:(NSString*)uuid;

-(void)removeConcateObject:(id<FFmpegCmdConcatDelegate>)delegate;
-(void)removeHlsObject:(id<FFmpegCmdHlsDelegate>)delegate;

-(FFmpegCmdState)addVideo:(NSString*)fileID url:(NSString*)url  name:(NSString*)name referUrl:(NSString*)referUrl;

-(FFmpegCmdState)addTsConcat:(NSString*)fileID tsArray:(NSArray*)tsArray  filePath:(NSString*)filePath concatDelegate:(id<FFmpegCmdConcatDelegate>)delegate;
-(FFmpegCmdState)addTsConcat2:(NSString*)fileID m3u8LocalUrl:(NSString*)m3u8LocalUrl  filePath:(NSString*)filePath concatDelegate:(id<FFmpegCmdConcatDelegate>)delegate;
-(FFmpegCmdState)addHlsUrlGetInfo:(NSString*)fileID url:(NSString*)url referUrl:(NSString*)referUrl hlsgetDelegate:(id<FFmpegCmdHlsDelegate>)delegate;

+(NSData*)ase_128_decry:(void*)byte datalen:(NSInteger)dateLaen key:(void*)key keyLen:(NSInteger)keyLen;
@end
