//
//  M3u8FileAnalyze.m
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import "M3u8FileAnalyze.h"
#import "FileDonwPlus.h"
#import "M3U8SegmentInfo.h"
@implementation M3u8FileAnalyze
+(M3u8FileAnalyze*)getInstance{
    static M3u8FileAnalyze *g = NULL;
    if  (!g){
        g = [[M3u8FileAnalyze alloc]init];
    }
    return g;
}

/*
 
 M3U8DOWNITMEINFOSAVEPATH 下载数据项结构如下
 字典结构:dicDownItem ,键值为唯一id
 
 value == 字典结构
 allDownURl->nsarray->downUrl|saveName;
 videoPath ->nsstring(m3u8视频id):保存路径:M3U8DOWNROOTPATH/vodeoPath/id/saveName
 loaclM3u8File ：本地播放需要的m3u8名字:->保存路径M3U8DOWNROOTPATH/vodeoPath/id.m3u8文件
 
 
*/
//解析m3u8文件
-(NSDictionary*)getM3u8FileDownUrl:(NSString*)strPath m3u8ID:(NSString*)m3u8ID{
    NSString *str = [NSString stringWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
    return [self getM3u8FileDownUrlFromString:str m3u8ID:m3u8ID];
}

-(NSDictionary*)getM3u8FileDownUrlFromString:(NSString*)string m3u8ID:(NSString*)m3u8ID{
    NSMutableDictionary *dic = NULL;
    NSMutableString *localM3u8str = [NSMutableString string];
    if (string) {
        NSString *str = string;
        NSArray *array = [str componentsSeparatedByString:@"\n"];
        NSMutableArray *allDownUrl = [NSMutableArray arrayWithCapacity:10];
        //拷贝
        for (int i = 0,j=0; i<[array count]; i++) {
            NSString *string = [array objectAtIndex:i];
            NSRange range = [string rangeOfString:@"http://" options:NSAnchoredSearch];
            if (range.location != NSNotFound) {
                NSString *strLocalTsPath = [NSString stringWithFormat:@"http://localhost:%d/%@/%@/%d.ts",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,m3u8ID, j+1];
                [localM3u8str appendString:strLocalTsPath];
                string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                NSString *strUrlParam = [NSString stringWithFormat:@"%@|%d.ts",string,j+1];
                j++;
                [allDownUrl addObject:strUrlParam];
            }
            else {
                [localM3u8str appendString:string];
            }
            [localM3u8str appendString:@"\n"];
            
        }
        if ([allDownUrl count]>0&&[localM3u8str length]>0) {
            dic = [NSMutableDictionary dictionary];
            [dic setObject:allDownUrl forKey:M3U8_ALLDOWN_URL];//此段URL数据不保存
            [dic setObject:[NSString stringWithFormat:@"%@.m3u8",m3u8ID] forKey:M3U8_LOCAL_M3U8FILE];
            [dic setObject:[NSString stringWithFormat:@"%@",m3u8ID] forKey:M3U8_VIDEOPATH];
            [dic setObject:[NSNumber numberWithBool:FALSE] forKey:M3U8_DOWN_FINIHES];
            NSString *localM3u8Path = [NSString stringWithFormat:@"%@/%@.m3u8",M3U8DOWNROOTPATH,m3u8ID];
            [localM3u8str writeToFile:localM3u8Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%s dic = %@, localM3u8str = %@",__FUNCTION__,[dic description],[localM3u8str description]);
        }
        else {
            NSLog(@"%s getM3u8FileDownUrl faild",__FUNCTION__);
        }
    }
    
    return dic;

}

-(NSDictionary*)getM3u8FileDownUrlFromArray:(NSArray*)array originalText:(NSString*)originalText m3u8ID:(NSString*)m3u8ID{
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:array.count];
    NSMutableString *localM3u8str = [NSMutableString string];
    if (array.count>0) {
        [localM3u8str appendString:@"#EXTM3U\r\n"];
        [localM3u8str appendString:@"#EXT-X-VERSION:3\r\n"];
        [localM3u8str appendString:@"#EXT-X-TARGETDURATION:3600\r\n"];
        [localM3u8str appendString:@"#EXT-X-MEDIA-SEQUENCE:0\r\n"];
    }
    for (int i = 0; i < array.count; i++) {
        M3U8SegmentInfo *info = [array objectAtIndex:i];
        NSString *strUrlParam = [NSString stringWithFormat:@"%@|%d.ts",[info.mediaURL absoluteString],i+1];
        [arrayRet addObject:strUrlParam];
        [localM3u8str appendFormat:@"#EXTINF:%f,\r\n",info.duration];
        NSString *strLocalTsPath = [NSString stringWithFormat:@"http://localhost:%d/%@/%@/%d.ts\n\r",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,m3u8ID, i+1];
        [localM3u8str appendString:strLocalTsPath];
        
    }
    if (arrayRet.count>0) {
        [localM3u8str appendString:@"#EXT-X-ENDLIST"];
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:arrayRet forKey:M3U8_ALLDOWN_URL];//此段URL数据不保存
        [dic setObject:[NSString stringWithFormat:@"%@.m3u8",m3u8ID] forKey:M3U8_LOCAL_M3U8FILE];
        [dic setObject:[NSString stringWithFormat:@"%@",m3u8ID] forKey:M3U8_VIDEOPATH];
        [dic setObject:[NSNumber numberWithBool:FALSE] forKey:M3U8_DOWN_FINIHES];
        NSString *localM3u8Path = [NSString stringWithFormat:@"%@/%@.m3u8",M3U8DOWNROOTPATH,m3u8ID];
        [localM3u8str writeToFile:localM3u8Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return dic;
    }
    return NULL;
   // [localM3u8str writeToFile:localM3u8Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end
