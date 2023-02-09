//
//  VideoPlayerManager+Down.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "VideoPlayerManager+Down.h"
#import "MajorGoldManager.h"
#import "NSString+MKNetworkKitAdditions.h"
@implementation VideoPlayerManager(Down)
+(VideoPlayFileType)tryToTestLocalCanPlay:(NSString*)file{
    VideoPlayFileType ret = Video_Play_UnKown;
    NSRange range = [file rangeOfString:@"VideoDownCaches"];
    if (range.location!=NSNotFound) {//取消金币消耗功能
        if ([[MajorGoldManager getInstance] spendGold:0 uuid:[[file substringFromIndex:range.location] md5]]) {
            ret = Video_Play_On_Gold;
        }
        else{
            ret = Video_Play_Enough_Gold;
        }
    }
     return ret;
}

+(NSString*)tryToGetLocalUUID:(NSString*)file{
    NSRange range = [file rangeOfString:@"VideoDownCaches"];
    if (range.location!=NSNotFound) {
         return  [[file lastPathComponent] stringByDeletingPathExtension];
    }
    return  nil;
}

+(NSString*)tryToPathConvert:(NSString*)file uuid:(NSString*)uuid{
    if ([file rangeOfString:@"/Web/videopath"].location!=NSNotFound) {
        file = [file stringByReplacingOccurrencesOfString:@".m3u8" withString:[NSString stringWithFormat:@"/%@.mp4",uuid]];
    }
    return file;
}
@end
