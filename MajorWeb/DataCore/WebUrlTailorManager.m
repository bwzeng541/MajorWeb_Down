//
//  WebUrlTailor.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/31.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebUrlTailorManager.h"
#import "Record.h"
#import "NSString+MKNetworkKitAdditions.h"

@interface WebUrlTailorManager()
//@property(nonatomic,strong) * serverName;
@property(nonatomic,strong)NSMutableArray *fariteArrayList;
@end

@implementation WebUrlTailorManager
+(WebUrlTailorManager*)getInstance{
    static WebUrlTailorManager*g = nil;
    if (!g) {
        g = [[WebUrlTailorManager alloc] init];
    }
    return g;
}


-(NSArray*)getWebUrlTailorfarite{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < self.fariteArrayList.count; i++) {
        WebTailorFavoriteRecord *vv = (WebTailorFavoriteRecord*)[self.fariteArrayList objectAtIndex:i];
        [array addObject:vv.record];
    }
    return [NSArray arrayWithArray:array];
}

-(BOOL)isWebUrlTailorFarite:(NSString*)key{
    for (int i = 0; i < self.fariteArrayList.count; i++) {
        WebTailorFavoriteRecord *vv = (WebTailorFavoriteRecord*)[self.fariteArrayList objectAtIndex:i];
        if ([vv.key compare:key]==NSOrderedSame) {
            return true;
        }
    }
    return false;
}

-(BOOL)addWebTailorfarite:(WebTailorFavoriteRecord*)recd{
    if (self.fariteArrayList.count>=6) {
        return false;
    }
    [self.fariteArrayList addObject:recd];
    [NSKeyedArchiver archiveRootObject:self.fariteArrayList toFile:TaitlorFarite];
    return true;
}

-(void)delWebTailorfarite:(NSString*)key{
    for (int i = 0; i < self.fariteArrayList.count; i++) {
        WebTailorFavoriteRecord *vv = (WebTailorFavoriteRecord*)[self.fariteArrayList objectAtIndex:i];
        if ([vv.key compare:key]==NSOrderedSame) {
            [self.fariteArrayList removeObject:vv];
            [NSKeyedArchiver archiveRootObject:self.fariteArrayList toFile:TaitlorFarite];
            break;
        }
    }
}

-(id)init{
    self = [super init];
    self.fariteArrayList = [NSMutableArray arrayWithCapacity:1];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:TaitlorFarite];
    if (array.count>0) {
        [self.fariteArrayList addObjectsFromArray:array];
    }
    
    return self;
}

+(void)delWebUrlTailor:(NSString*)title url:(NSString*)url{
    NSString *key = [[NSString stringWithFormat:@"%@%@",title,url] md5];
    [[WebUrlTailorManager getInstance]delWebTailorfarite:key];
}

+(BOOL)isWebUrlTailor:(NSString*)title url:(NSString*)url{
    NSString *key = [[NSString stringWithFormat:@"%@%@",title,url] md5];
    return [[WebUrlTailorManager getInstance]isWebUrlTailorFarite:key];
}

+(BOOL)insertWebUrlTailor:(NSString*)title url:(NSString*)url{
    NSString *key = [[NSString stringWithFormat:@"%@%@",title,url] md5];
    Record *record = [[Record alloc] init];
    record.titleName = title;
    record.webUrl = url;
    WebTailorFavoriteRecord *vv = [[WebTailorFavoriteRecord alloc] init];
    vv.record = record;
    vv.key = key;
   return  [[WebUrlTailorManager getInstance]addWebTailorfarite:vv];
}

+(NSArray*)getWebUrlTailor{
    return  [[WebUrlTailorManager getInstance]getWebUrlTailorfarite];
}

@end
