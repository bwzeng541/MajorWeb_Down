//
//  PinUpDataModel.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "PinUpDataModel.h"
#import "NetworkManager.h"
#import "ReactiveCocoa.h"
#import "JSON.h"
#import "YYCache.h"
#import "PicUpPlusDef.h"
#define InitCacheObjectFromKey(key) \
self.cacheObject = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/%@",ReferCachesDir,key]];

static NSMutableDictionary *dataCommendInfo = nil;
@interface PinUpDataModel()
@property(nonatomic,strong)YYCache *cacheObject;
@property(nonatomic,strong)NSURLSessionDataTask * pinUpListTask;
@property(nonatomic,copy)NSString *reqeustKey;
@property(nonatomic,strong)NSMutableArray * datasourcePicList;
@end

@implementation PinUpDataModel

+(PinUpDataModel*)getPinDataModel{
    static PinUpDataModel *g = NULL;
    if (!g) {
        g = [[PinUpDataModel alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    if (![[NSFileManager defaultManager]fileExistsAtPath:ReferCachesDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ReferCachesDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    dataCommendInfo = [[NSMutableDictionary alloc] init];
    return self;
}

-(void)httpTheGetCommend:(NSString*)key{
    if (!key) {
        return;
    }
    if (self.pinUpListTask) {
        [self.pinUpListTask cancel];
    }
    self.reqeustKey = key;
    self.datasourcePicList = [dataCommendInfo objectForKey:key];
    if (self.datasourcePicList) {
        self.updatePinUpList = !self.updatePinUpList;
        return;
    }
    self.datasourcePicList = nil;
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@.%@.%@.%@:%@/%@.json",@"http://",@"47",@"96",@"26",@"202",@"16915",key];
    @weakify(self)
    self.pinUpListTask = [[NetworkManager shareInstance]getInfoFromUrl:requestUrl callback:^(NSDictionary *returnDict) {
        @strongify(self)
        if ([[returnDict objectForKey:@"returnInfo"] boolValue]) {
            NSString *strContent = [[NSString alloc]initWithData:[returnDict objectForKey:@"data"] encoding:NSUTF8StringEncoding];
            id value = [strContent JSONValue];
            if ([value isKindOfClass:[NSArray class]]) {
                self.datasourcePicList = value;
                [dataCommendInfo setObject:value forKey:self.reqeustKey];
            }
            else{
                self.datasourcePicList = nil;
            }
            self.updatePinUpList = !self.updatePinUpList;
        }
        else{
            self.datasourcePicList = nil;
            self.updatePinUpList = !self.updatePinUpList;
        }
    }];
}

-(void)favTheGetCommend:(NSString*)key{
    InitCacheObjectFromKey(key);
    NSArray *allKey = [self.cacheObject allCacheKey];
    NSMutableArray *arrayRet = [[NSMutableArray alloc] init];
    for (int i=0; i < allKey.count; i++) {
        id value =  [self.cacheObject objectForKey:  [allKey objectAtIndex:i]];
        [arrayRet addObject:value];
    }
    self.reqeustKey = key;
    self.datasourcePicList = arrayRet;
    self.updatePinUpList = !self.updatePinUpList;
}

-(BOOL)favTheBoolCommend:(NSString*)key uuid:(NSString*)uuid{
    InitCacheObjectFromKey(key);
    return [self.cacheObject objectForKey:uuid]?true:false;
}

-(void)favTheDelCommend:(NSString*)key uuid:(NSString*)uuid{
    InitCacheObjectFromKey(key);
    [self.cacheObject removeObjectForKey:uuid];
    self.updatePinUpList = !self.updatePinUpList;
}

-(void)favTheAddCommend:(NSString*)key object:(id<NSCopying>)object uuid:(NSString*)uuid{
    InitCacheObjectFromKey(key);
    [self.cacheObject setObject:(id)object forKey:uuid];
    self.updatePinUpList = !self.updatePinUpList;
}
@end
