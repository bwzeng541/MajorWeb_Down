//
//  VideoPlayerManager+Down.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "VideoPlayerManager.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum VideoPlayFileType{
    Video_Play_UnKown,//未知
    Video_Play_On_Gold,//足够的金币
    Video_Play_Enough_Gold//金币不够
}VideoPlayFileType;
@interface VideoPlayerManager(Down)
+(VideoPlayFileType)tryToTestLocalCanPlay:(NSString*)file;
+(NSString*)tryToGetLocalUUID:(NSString*)file;
+(NSString*)tryToPathConvert:(NSString*)file uuid:(NSString*)uuid;
@end

NS_ASSUME_NONNULL_END
