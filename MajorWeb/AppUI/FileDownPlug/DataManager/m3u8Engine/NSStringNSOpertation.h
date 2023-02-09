//
//  NSStringNSOpertation.h
//  WatchApp
//
//  Created by zengbiwang on 2018/5/3.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPlaylistModel.h"
typedef void (^NSStringNSOpertationBlock)(VideoPlaylistModel *model);
@interface NSStringNSOpertation : NSOperation
{
    
}
-(NSStringNSOpertation*)initWithUrl:(NSString*)url localDir:(NSString*)localDir port:(int)port videoID:(NSString*)videoID block:(NSStringNSOpertationBlock)block;
@end
