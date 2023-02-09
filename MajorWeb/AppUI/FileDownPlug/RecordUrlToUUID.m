//
//  RecordUrlToUUID.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "RecordUrlToUUID.h"
#import "YYCache.h"
#import "FileDonwPlus.h"
#import "FTWCache.h"
#import "MajorICloudSync.h"
@interface RecordUrlToUUID()
@property(strong,nonatomic)YYCache *recordCache;
@end
@implementation RecordUrlToUUID
+(RecordUrlToUUID*)getInstance{
    static RecordUrlToUUID *g = nil;
    if (!g) {
        g = [[RecordUrlToUUID alloc] init];
    }
    return g;
}

-(void)reLoadData{
    self.recordCache = nil;
    self.recordCache = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/urluuidconfig",VIDEOCACHESROOTPATH]];
}

-(id)init{
    self  = [super init];
    self.recordCache = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/urluuidconfig",VIDEOCACHESROOTPATH]];
    
    @weakify(self)
    [RACObserve([MajorICloudSync getInstance], isSyncToFinish) subscribeNext:^(id x) {
        @strongify(self)
        if ([MajorICloudSync getInstance].isSyncToFinish) {
             [self reLoadData];
        }
    }];
    return self;
}

-(NSString*)urlFromKey:(NSString*)uuid{
    if (!uuid)return nil;
    NSData *data = (NSData*)[self.recordCache objectForKey:[NSString stringWithFormat:@"%@_url",uuid]];
    if (data) {
        return [FTWCache decryptWithKey:data];
    }
     return nil;
}

-(NSString*)titleFromKey:(NSString*)uuid{
    if (!uuid)return nil;
    NSData *data = (NSData*)[self.recordCache objectForKey:[NSString stringWithFormat:@"%@_name",uuid]];
    if (data) {
        return [FTWCache decryptWithKey:data];
    }
    return nil;
}

-(void)updateVideoTime:(NSString*)uuid playTime:(nonnull NSDictionary *)playInfo{
    if ([self urlFromKey:uuid]) {
        [self.recordCache setObject:playInfo  forKey:[NSString stringWithFormat:@"%@_playTime",uuid]];
    }
}

-(NSDictionary*)playTimeFromKey:(NSString*)uuid{//playTime ,,duration
    NSDictionary *playInfo = (NSDictionary*)[self.recordCache objectForKey:[NSString stringWithFormat:@"%@_playTime",uuid]];
    if ([playInfo isKindOfClass:[NSDictionary class]]) {
        return playInfo;
    }
    return nil;
}

-(void)addUrl:(NSString*)url uuid:(NSString*)uuid title:(NSString*)title{
    if (url && uuid) {
        
        [self.recordCache setObject:[FTWCache encryptWithKeyNomarl:url] forKey:[NSString stringWithFormat:@"%@_url",uuid]];
        title=title?title:@"";
        [self.recordCache setObject:[FTWCache encryptWithKeyNomarl:title] forKey:[NSString stringWithFormat:@"%@_name",uuid]];
    }
}

-(void)removeKey:(NSString*)uuid{
    [self.recordCache removeObjectForKey:[NSString stringWithFormat:@"%@_playTime",uuid]];
    [self.recordCache removeObjectForKey:[NSString stringWithFormat:@"%@_name",uuid]];
    [self.recordCache removeObjectForKey:[NSString stringWithFormat:@"%@_url",uuid]];

}
@end
