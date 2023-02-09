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
@end

@protocol FFmpegCmdHlsDelegate<NSObject>
-(void)ffmpegCmdHlsFinish:(NSString*)_uuid_  urlfiles:(NSArray*)array error:(int)errror;
@end


@interface FFmpegCmd : NSObject
+(FFmpegCmd*)getInstace;
@property(weak)id<FFmpegCmdDelegate>delegate;
@property(weak)id<FFmpegCmdConcatDelegate>concatdelegate;
@property(weak)id<FFmpegCmdHlsDelegate>hlsdelegate;

-(void)exitffmpeg;
-(FFmpegCmdState)addVideo:(NSString*)fileID url:(NSString*)url  name:(NSString*)name;
-(FFmpegCmdState)addTsConcat:(NSString*)fileID tsArray:(NSArray*)tsArray  filePath:(NSString*)filePath;
-(FFmpegCmdState)addHlsUrlGetInfo:(NSString*)fileID url:(NSString*)url ;
@end
