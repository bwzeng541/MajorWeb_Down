#import "AppNewStateManager.h"
#import "FileDonwPlus.h"
@interface AppNewStateManager()
@property(strong)NSMutableDictionary *info;
@end
@implementation AppNewStateManager

-(id)init{
    self = [super init];
    self.info = [NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}
+(AppNewStateManager*)getInstance{
    static AppNewStateManager*g = nil;
    if (!g) {
        g = [[AppNewStateManager alloc] init];
    }
    return g;
}

-(NSDictionary*)getInfoFromUUID:(NSString*)uuid{
    NSDictionary *retInfo = [self.info objectForKey:uuid];
    if (!retInfo) {
        return [NSDictionary dictionary];
    }
    return retInfo;
}


-(NSString*)getMaxCreateTime{
    __block NSString *uuid = nil;
    __block NSTimeInterval sub = 0;
    NSDate *date = [NSDate date];
    [self.info bk_apply:^(id key, id obj) {
        NSDate *time = [obj objectForKey:@"startTime"];
        if (time) {
            NSTimeInterval v = [date timeIntervalSinceDate:time];
            if (v>sub) {
                sub = v;
                uuid = key;
            }
        }
    }];
    return uuid;
}

-(NSNumber*)checkIsDown{
    NSArray*keyall = [self.info allKeys];
    BOOL re = false;
    for (int i = 0; i < keyall.count; i++) {
      id value = [[self.info objectForKey:[keyall objectAtIndex:i]] objectForKey:@"startTime"];
        if (value) {
            re = true;
            break;
        }
    }
    return [NSNumber numberWithBool:re];
}

-(BOOL)isInCachesState:(NSString*)uuid{
    id v = [[self.info objectForKey:uuid] objectForKey:@"startTime"];
    return v?true:false;
}

-(void)updateValueFaild:(NSString*)uuid{
    NSMutableDictionary *retNew = [NSMutableDictionary dictionaryWithDictionary:[self getInfoFromUUID:uuid]];
    [retNew setObject:UnKnownDespc_fileDown forKey:@"faildValue"];
    [self.info setObject:retNew forKey:uuid];
}

-(void)updateValueSuccess:(NSString*)uuid{
    [self.info removeObjectForKey:uuid];
}

-(void)updateValueState2:(NSString*)uuid isStartTime:(BOOL)isStartTime{
    NSMutableDictionary *retNew = [NSMutableDictionary dictionaryWithDictionary:[self getInfoFromUUID:uuid]];
    if (isStartTime) {
        [retNew setObject:[NSDate date] forKey:@"startTime"];
    }
    else{
        [retNew removeObjectForKey:@"startTime"];
    }
    [self.info setObject:retNew forKey:uuid];
}

-(void)updateValueState1:(NSString*)uuid value:(NSString*)value{
    NSMutableDictionary *retNew = [NSMutableDictionary dictionaryWithDictionary:[self getInfoFromUUID:uuid]];
    [retNew setObject:value forKey:@"progress"];
    [self.info setObject:retNew forKey:uuid];
}


-(NSString*)getValueFaild:(NSString*)uuid{
    NSMutableDictionary *retNew = [NSMutableDictionary dictionaryWithDictionary:[self getInfoFromUUID:uuid]];
    NSString *vv = [retNew objectForKey:@"faildValue"];
    if (vv) {
        return vv;
    }
    return @"";
}

-(NSString*)getDownProgress:(NSString*)uuid{
    NSMutableDictionary *retNew = [NSMutableDictionary dictionaryWithDictionary:[self getInfoFromUUID:uuid]];
    NSString *vv = [retNew objectForKey:@"progress"];
    if (vv) {
        return vv;
    }
    return @"";
}
@end
