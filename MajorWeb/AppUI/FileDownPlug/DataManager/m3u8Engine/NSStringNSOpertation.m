//
//  NSStringNSOpertation.m
//  WatchApp
//
//  Created by zengbiwang on 2018/5/3.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "NSStringNSOpertation.h"

@interface NSStringNSOpertation()
@property(copy)NSStringNSOpertationBlock blockRet;
@property(assign)int port;
@property(copy)NSString *videoID;
@property(copy)NSString *url;
@property(copy)NSString *localDir;
@end

@implementation NSStringNSOpertation

-(NSStringNSOpertation*)initWithUrl:(NSString*)url localDir:(NSString*)localDir port:(int)port videoID:(NSString*)videoID block:(NSStringNSOpertationBlock)block
{
    self = [super init];
    self.url = url;self.localDir = localDir;self.port = port;
    self.videoID = videoID;self.blockRet = block;
    return self;
}


- (void)main {
    @autoreleasepool {
        if (self.isCancelled){
            NSLog(@"NSStringNSOpertation cancelled1");
            return;
        }
        NSError *error;
        VideoPlaylistModel*  model = [[[VideoPlaylistModel alloc] initWithURL:[NSURL URLWithString:_url] localDir:_localDir port:_port videoID:_videoID  error: &error] autorelease];
        if(self.blockRet && !self.isCancelled){
            self.blockRet(model);
        }
        else{
            NSLog(@"NSStringNSOpertation cancelled2");
        }
    }
}

@end
