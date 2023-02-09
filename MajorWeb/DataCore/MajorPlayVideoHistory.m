//
//  MajorPlayVideoHistory.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/21.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorPlayVideoHistory.h"
#import "NSString+MKNetworkKitAdditions.h"

@interface MajorPlayVideoHistory()
@property(nonatomic,strong)NSString *historyFile;
@property(nonatomic,strong)NSMutableDictionary *videoPlayInfo;
@end
@implementation MajorPlayVideoHistory

+(MajorPlayVideoHistory*)getInstance{
    static MajorPlayVideoHistory*g = nil;
    if (!g) {
        g = [[MajorPlayVideoHistory alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    [self initData];
    return self;
}

-(void)initData{
    self.historyFile = [NSString stringWithFormat:@"%@/%@",AppSynchronizationDir,@"majorPlayInfo"];
    self.videoPlayInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:self.historyFile];
    if (info) {
        [self.videoPlayInfo setDictionary:info];
    }

}

-(NSString*)videoMd5:(NSString*)url{
    return [url md5];
}

-(BOOL)isVideoWatch:(NSString*)url{
    if([self.videoPlayInfo objectForKey:[self videoMd5:url]]){
        return true;
    }
    return false;
}

-(void)addVideoInfo:(NSString*)url{
    NSString *md5 = [self videoMd5:url];
    NSDate *date = [NSDate date];
    [self.videoPlayInfo setObject:[NSDictionary dictionaryWithObjectsAndKeys:date,@"date", nil] forKey:md5];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self.videoPlayInfo writeToFile:self.historyFile atomically:YES];
    });
}
@end
