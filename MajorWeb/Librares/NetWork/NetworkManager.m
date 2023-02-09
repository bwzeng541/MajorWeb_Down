//
//  NetworkManager.m
//  qiangche
//
//  Created by ios-mac on 15/8/19.
//
//

#import "NetworkManager.h"

#import "YYModel.h"
#import "AFNetworking.h"

@implementation NetworkManager {
    
    NSMutableDictionary *taskDic;
}

__strong static NetworkManager *networkInstance = nil;



+ (NetworkManager *)shareInstance
{
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        networkInstance = [[super allocWithZone:NULL] init];
    });
    
    return networkInstance;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        taskDic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self shareInstance];
}



- (void)GETInfo:(ReturnBlock)infoBlock param:(NSDictionary *)paramDict URL:(NSString *)url
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    manager.requestSerializer.timeoutInterval = 10;
//    [manager GET:url parameters:paramDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
//        [dict setObject:@(YES) forKey:@"returnInfo"];
//        
//        self.returnBlock = infoBlock;
//        self.returnBlock(dict);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSDictionary *dict = @{@"returnInfo" : @NO,@"returnCode":@(error.code)};
//        self.returnBlock = infoBlock;
//        self.returnBlock(dict);
//    }];
}


- (NSURLSessionDataTask *)getNewInfoAboutFilterTagsType:(ReturnBlock)infoBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 10;
    return [manager GET:@"http://47.96.26.202:18989/api/v1/video/category" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        [dict setObject:@(YES) forKey:@"returnInfo"];
        
        self.returnBlock = infoBlock;
        self.returnBlock(dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *dict = @{@"returnInfo" : @NO,@"returnCode":@(error.code)};
        self.returnBlock = infoBlock;
        self.returnBlock(dict);
    }];
 }

- (NSURLSessionDataTask *)getInfoAboutFilmsListWithType:(NSInteger)type Area:(NSInteger)area Kind:(NSInteger)kind Year:(NSInteger)year Page:(NSInteger)page Count:(NSInteger)count callback:(ReturnBlock)infoBlock
{
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    
//    [param setObject:kMethodGetProgramList forKey:@"Method"];
//    
//    
//    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
//    [bodyDic setObject:[NSNumber numberWithInteger:type] forKey:@"Type"];
//    [bodyDic setObject:[NSString stringWithFormat:@"%ld",area] forKey:@"AreaIds"];
//    [bodyDic setObject:[NSString stringWithFormat:@"%ld",kind] forKey:@"KindIds"];
//    [bodyDic setObject:[NSString stringWithFormat:@"%ld",year] forKey:@"PubYear"];
//    [bodyDic setObject:[NSNumber numberWithInteger:page] forKey:@"PageIndex"];
//    [bodyDic setObject:[NSNumber numberWithInteger:count] forKey:@"PageSize"];
//    NSString *bodyStr = [bodyDic yy_modelToJSONString];
//    [param setObject:bodyStr forKey:@"Body"];
//    
//    [self appendCommomHead:param sessionKey:nil];
//    return [self POSTInfo:infoBlock param:param URL:kAMPSMainURL];
    return NULL;
}

- (NSURLSessionDataTask *)httpTheContentWithSearchNewFile:(NSInteger)type  Kind:(NSString*)kind  callback:(ReturnBlock)infoBlock{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    manager.requestSerializer.timeoutInterval = 10;
//    NSString* strType = [kind URLEncodeString];
//    NSString *url = [NSString stringWithFormat:@"http://42.121.14.168:18989/api/v1/video/list?utype=%d&pre=2000&&name=%@",(int)type,strType];
//    return [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
//        [dict setObject:@(YES) forKey:@"returnInfo"];
//        
//        self.returnBlock = infoBlock;
//        self.returnBlock(dict);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSDictionary *dict = @{@"returnInfo" : @NO,@"returnCode":@(error.code)};
//        self.returnBlock = infoBlock;
//        self.returnBlock(dict);
//    }];
    return NULL;
}

- (NSURLSessionDataTask *)getInfoFromUrl:(NSString *)url callback:(ReturnBlock)infoBlock{
       AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 5;
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        return [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
            [dict setObject:@(YES) forKey:@"returnInfo"];
            [dict setObject:responseObject forKey:@"data"];
            self.returnBlock = infoBlock;
            self.returnBlock(dict);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSDictionary *dict = @{@"returnInfo" : @NO,@"returnCode":@(error.code)};
            self.returnBlock = infoBlock;
            self.returnBlock(dict);
        }];
}

- (NSURLSessionDataTask *)getInfoNewAboutFilmsListWithType:(NSInteger)type  Kind:(NSString*)kind  Page:(NSInteger)page  Country:(NSString*)country Count:(NSInteger)count callback:(ReturnBlock)infoBlock
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    manager.requestSerializer.timeoutInterval = 10;
//    //http://42.121.14.168:18989/api/v1/video/list?utype=1&page=2&category=科幻
//    NSString* strType = [kind URLEncodeString];
//    NSString* strCountTry = [country URLEncodeString];
//    NSString *url = [NSString stringWithFormat:@"http://42.121.14.168:18989/api/v1/video/list?utype=%d&page=%d&category=%@&guojia=%@",(int)type,(int)page,strType,strCountTry];
//    return [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
//        [dict setObject:@(YES) forKey:@"returnInfo"];
//        
//        self.returnBlock = infoBlock;
//        self.returnBlock(dict);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSDictionary *dict = @{@"returnInfo" : @NO,@"returnCode":@(error.code)};
//        self.returnBlock = infoBlock;
//        self.returnBlock(dict);
//    }];
    return NULL;
}





@end
