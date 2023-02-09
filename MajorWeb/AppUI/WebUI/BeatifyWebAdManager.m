//
//  BeatifyWebAdManager.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyWebAdManager.h"
#import "YYCache.h"
#import "NSString+MKNetworkKitAdditions.h"
@interface BeatifyWebAdManager()
@property(nonatomic,strong)YYCache *yyCache;
@property(nonatomic,strong)NSMutableArray *currentDomArray;
@property(nonatomic,copy)NSString *currentHost;
@end


@implementation BeatifyWebAdManager

+(BeatifyWebAdManager*)getInstance{
    static BeatifyWebAdManager *g = NULL;
    if(!g){
        g = [[BeatifyWebAdManager alloc] init];
    }
    return g;
}

-(NSString*)hostMd5FromUrl:(NSString*)url{
    return [[[NSURL URLWithString:url] host] md5];
}

-(id)init{
    self = [super init];
    self.yyCache=[YYCache cacheWithName:@"WebAdCache"];
    self.currentDomArray = [NSMutableArray arrayWithCapacity:10];
    return self;
}

-(void)addAdDom:(NSString*)url domCss:(NSString*)domCss{
    if (url && domCss) {
        self.currentHost = nil;
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self getAdDomCssAndTime:url]];
        domCss = [NSString stringWithFormat:@"'%@'",domCss];
        NSString *time = [[NSDate date] formattedDateWithFormat:@"yyyy年MM月dd日 HH:mm:ss"];
        [array addObject:@{WebAdDomCssKey:domCss,WebAdDomTimeKey:time}];
        [self.yyCache setObject:array forKey:[self hostMd5FromUrl:url]];
     }
}

-(void)removeAdDom:(NSString*)url domCss:(NSString*)domCss{
    if (url && domCss) {
        self.currentHost = nil;
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self getAdDomCssAndTime:url]];
        domCss = [NSString stringWithFormat:@"%@",domCss];
        for (int i = 0; i < array.count; i++) {
            NSString *dd = [[array objectAtIndex:i] objectForKey:WebAdDomCssKey];
            if([dd compare:domCss]==NSOrderedSame){
                [array removeObjectAtIndex:i];
                break;
            }
        }
        [self.yyCache setObject:array forKey:[self hostMd5FromUrl:url]];
     }
}

-(NSArray*)getAdDomCssAndTime:(NSString*)url{
    if (!url) {
        return [NSArray array];
    }
    NSString *host = [self hostMd5FromUrl:url];
    if (host) {
       NSArray *temp = (NSArray*)[self.yyCache objectForKey:host];
        return  temp?temp:[NSArray array];
    }
    return [NSArray array];
}


-(NSArray*)getAdDomCss:(NSString*)url{
    if (self.currentHost && [self.currentHost compare:url] == NSOrderedSame) {
        return [NSArray arrayWithArray:_currentDomArray];
    }
    self.currentHost = [self hostMd5FromUrl:url];
    [_currentDomArray removeAllObjects];
    NSArray *array = [self getAdDomCssAndTime:url];
    for (int i = 0; i < array.count; i++) {
       [_currentDomArray addObject:[[array objectAtIndex:i] objectForKey:WebAdDomCssKey]] ;
    }
    return [NSArray arrayWithArray:_currentDomArray];
}
@end
