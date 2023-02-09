//
//  M3u8ArStateManager.m
//  babeKingdom
//
//  Created by zengbiwang on 13-9-22.
//
//


/*
 
 
 
*/
#define  M3U8DOWNSTATE  @"M3U8DOWNSTATE"
#define  M3U8DOWNPRGORESS  @"M3U8DOWNPRGORESS"
#define  M3U8DOWNSTARTTIME  @"M3U8DOWNSTARTTIME"

#import "M3u8ArStateManager.h"
@interface M3u8ArStateManager(){
    NSMutableDictionary *dicItem;
}
@end

@implementation M3u8ArStateManager

+(M3u8ArStateManager*)getInstance{
    static M3u8ArStateManager *g = nil;
    if (!g) {
        g = [[M3u8ArStateManager alloc] init];
    }
    return g;
}

-(id)init{
    self  =  [super init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(upPrgoress:) name:UPPROGROESSM3U8 object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downFinishes:) name:DOWNFINISHESM3U8 object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downFaild:) name:DOWNFAILDM3U8 object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downStart:) name:DOWNSTARTM3U8 object:nil];
    dicItem = [[NSMutableDictionary dictionary]retain];
    return self;
}

-(NSInteger)getCurrentDownNumber{
    return [dicItem count];
}

-(NSArray*)getAllDownM3u8UUID{
    NSArray *keyArray = [dicItem allKeys];
    if (keyArray.count>0) {
        return keyArray;
    }
    return [NSArray array];
}

-(m3u8DownSate)getM3u8State:(NSString*)m3u8ID{
    NSDictionary *dic = (NSDictionary*)[dicItem objectForKey:m3u8ID];
    if (dic) {
        return (m3u8DownSate)[[dic objectForKey:M3U8DOWNSTATE] integerValue];
    }
    return m3u8_down_unknow;
}

-(NSNumber*)getM3u8Progress:(NSString *)m3u8ID{
    NSDictionary *dic = (NSDictionary*)[dicItem objectForKey:m3u8ID];
    if (dic) {
        return [dic objectForKey:M3U8DOWNPRGORESS];
    }
    return [NSNumber numberWithFloat:0];
}

-(void)addM3u8Item:(NSString*)m3u8ID{
    if (![dicItem objectForKey:m3u8ID]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:m3u8_Waiting_down],M3U8DOWNSTATE,
           [NSNumber numberWithFloat:0],M3U8DOWNPRGORESS,[NSDate date],M3U8DOWNSTARTTIME,nil];
        [dicItem setObject:dic forKey:m3u8ID];
        NSLog(@"%s",__FUNCTION__);
    }
}

-(void)delM3u8Item:(NSString*)m3u8ID{
    if (!m3u8ID) {
        return;
    }
    [dicItem removeObjectForKey:m3u8ID];
    NSLog(@"%s",__FUNCTION__);
}


-(void)downFinishes:(NSNotification*)object{
    NSDictionary *dic = (NSDictionary*)object.object;
    [self delM3u8Item:[dic objectForKey:@"M3U8ID"]];
    NSLog(@"%s",__FUNCTION__);
}

-(void)upPrgoress:(NSNotification*)object{
    NSDictionary *dic = (NSDictionary*)object.object;
    NSMutableDictionary *retDic = [dicItem objectForKey:[dic objectForKey:@"M3U8ID"]];
    if (retDic) {
        [retDic setObject:[dic objectForKey:@"PROGRESS"] forKey:M3U8DOWNPRGORESS];
    }
}

-(void)downFaild:(NSNotification*)object{
    NSLog(@"%s",__FUNCTION__);
    [self delM3u8Item:[object.object objectForKey:@"M3U8ID"]];
}

-(void)downStart:(NSNotification*)object{
    NSDictionary *dic = (NSDictionary*)object.object;
    NSMutableDictionary *retDic = [dicItem objectForKey:[dic objectForKey:@"M3U8ID"]];
    if (retDic) {
        NSLog(@"%s",__FUNCTION__);
        [retDic setObject:[NSNumber numberWithInt:m3u8_downing] forKey:M3U8DOWNSTATE];
    }
}
@end
