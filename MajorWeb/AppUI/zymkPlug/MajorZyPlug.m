#import "MajorZyPlug.h"
#import "YYCache.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "YSCHUDManager.h"
static  YYCache* MajorZyFuntionCaches = NULL;
static  NSString*MajorYYCacheName = NULL;
@interface MajorZyPlug:NSObject

@end

@implementation MajorZyPlug
+(void)initYYCache{
    if (!MajorZyFuntionCaches) {
        MajorZyFuntionCaches = [YYCache cacheWithName:MajorYYCacheName];
    }
}
@end

void initYYCache(NSString*name){//
    MajorZyFuntionCaches = NULL;
    MajorYYCacheName = [[NSString alloc] initWithString:name];
}

void updateCartoonTime(NSString*cartName,NSString *typeKey,NSString *dataSource) {
    [MajorZyPlug initYYCache];
    NSString *md5 = [[cartName stringByAppendingString:dataSource] md5];
    NSString *time = [NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970];
    NSDictionary *timeINfo = @{@"key":md5,@"time":time,@"dataSource":(dataSource?dataSource:@"")};
    NSDictionary *arrayInfoS =  (NSDictionary*)[MajorZyFuntionCaches objectForKey:typeKey];
    NSMutableDictionary *arrayInfo= [NSMutableDictionary dictionaryWithCapacity:1];
    if (arrayInfoS.count>0) {
        [arrayInfo setDictionary:arrayInfoS];
    }
    [arrayInfo setObject:timeINfo forKey:md5];
    [MajorZyFuntionCaches setObject:arrayInfo forKey:typeKey withBlock:^{
        
    }];
}

void syncCartoonFavourite(NSString*cartName,NSString *dataSource){
    [MajorZyPlug initYYCache];
    updateCartoonTime(cartName ,@"favourite_array",dataSource);
    [YSCHUDManager showHUDThenHideOnView:[UIApplication sharedApplication].keyWindow message:@"添加成功" afterDelay:1];
}

NSArray *getAllArrayFromTypeKey(NSString*key){
    [MajorZyPlug initYYCache];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    NSDictionary *info = (NSDictionary*)[MajorZyFuntionCaches objectForKey:key];
    NSArray *arryKey = [info allKeys];
    if (arryKey.count>0) {
        [array addObjectsFromArray:arryKey];
    }
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *info1 = (NSDictionary*)[info objectForKey:obj1];
        NSDictionary *info2 = (NSDictionary*)[info objectForKey:obj2];
        double value1 = [[info1 objectForKey:@"time"] doubleValue];
        double value2 = [[info2 objectForKey:@"time"] doubleValue];
        if (value1<value2) {
            return NSOrderedDescending;
        }else if (value1 == value2){
            return NSOrderedSame;
        }
        else{return NSOrderedAscending;
        }
    }];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < array.count; i++) {
       [retArray addObject:[info objectForKey:[array objectAtIndex:i]]] ;
    }
    return [NSArray arrayWithArray:retArray];
}

NSArray* getCartoonFavouriteKey(void){
    return getAllArrayFromTypeKey(@"favourite_array");
}
//[MajorZyFuntionCaches objectForKey:[NSString stringWithFormat:@"%@_name",[showName md5]]];
//列表
//[MajorZyFuntionCaches objectForKey:[NSString stringWithFormat:@"%@_list",[showName md5]]];

void syncCartoonList(NSArray *arraylist ,NSString*cartName, NSString *dataSource){
    [MajorZyPlug initYYCache];
    if (arraylist.count>0 && [cartName length]>0) {
        NSString *md5 = [[cartName stringByAppendingString:dataSource] md5];
        getCartList(md5);
        getCartName(md5);
        getCartoonHistory(md5);

        [MajorZyFuntionCaches setObject:arraylist forKey:[NSString stringWithFormat:@"%@_list",md5] withBlock:^{
            
        }];
        [MajorZyFuntionCaches setObject:cartName forKey:[NSString stringWithFormat:@"%@_name",md5]];
        updateCartoonTime(cartName ,@"key_array" ,dataSource);
    }
}

void syncCartoonHistory(NSString*url ,NSString*cartName,NSString *dataSource){
    [MajorZyPlug initYYCache];
    NSString *md5 = [[cartName stringByAppendingString:dataSource] md5];
    [MajorZyFuntionCaches setObject:url forKey:[NSString stringWithFormat:@"%@_history",md5] withBlock:^{
        
    }];
}

void delCartoonFavouriteKey(NSString*key){
    [MajorZyPlug initYYCache];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[MajorZyFuntionCaches objectForKey:@"favourite_array"]];
    [info removeObjectForKey:key];
    [MajorZyFuntionCaches setObject:info forKey:@"favourite_array"];
}

NSString* getCartoonHistory(NSString *key){
    [MajorZyPlug initYYCache];
    NSString*url = (NSString*)[MajorZyFuntionCaches objectForKey:[NSString stringWithFormat:@"%@_history",key]];
    return url;
}

//通过漫画key找列表
NSArray* getCartList(NSString*key){
    [MajorZyPlug initYYCache];
    NSArray *array = (NSArray*)[MajorZyFuntionCaches objectForKey:[NSString stringWithFormat:@"%@_list",key]];
    return array;
}
//通过漫画key找名字
NSString* getCartName(NSString*key){
    [MajorZyPlug initYYCache];
    NSString *name = (NSString*)[MajorZyFuntionCaches objectForKey:[NSString stringWithFormat:@"%@_name",key]];
    return name;
}

NSArray* getAllCartKey(){
    return getAllArrayFromTypeKey(@"key_array");
}
