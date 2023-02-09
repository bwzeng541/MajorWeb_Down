//
//  ContentWebView+PlayLocalCaches.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/9.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "ContentWebView+PlayLocalCaches.h"
#import "YTKNetworkPrivate.h"
#import "VideoPlayerManager.h"
#import "VideoPlayerManager+Down.h"
@implementation ContentWebView (PlayLocalCaches)

-(BOOL)isPlayCacheFileSuccess:(NSString*)url title:(NSString*)title{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf2];
    NSString *uuid = [YTKNetworkUtils md5StringFromString:url];
    [info setObject:[NSArray arrayWithObject:uuid] forKey:@"param4"];
    NSString *file =[[AppWtManager getInstanceAndInit] getWtCallBack:info];
    if([file length]>4){//调用播放
        if ([file rangeOfString:@"/Web/videopath"].location!=NSNotFound) {
            file = [VideoPlayerManager tryToPathConvert:file uuid:uuid];
        }
        if(![[NSFileManager defaultManager] fileExistsAtPath:file]){
            return false;
        }
        file = [[NSURL fileURLWithPath:file] absoluteString];
        if ([VideoPlayerManager tryToTestLocalCanPlay:file]!=Video_Play_Enough_Gold) {
            [[VideoPlayerManager getVideoPlayInstance] playWithUrl:file title:title referer:nil saveInfo:nil replayMode:false  rect:CGRectZero throwUrl:nil isUseIjkPlayer:false];
            return true;
        }
    }
    return false;
}

@end
