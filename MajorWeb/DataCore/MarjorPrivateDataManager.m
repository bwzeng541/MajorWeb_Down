//
//  MarjorPrivateDataManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/8.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MarjorPrivateDataManager.h"
#import "MainMorePanel.h"
#import "YYModel.h"
#import "FTWCache.h"
#import "OSSManager.h"
#import "OSSWrapper.h"
#import <AdSupport/AdSupport.h>
#import "MKNetworkKit.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "SDWebImageDownloader.h"
#import "AppDelegate.h"
#define Marjor_Private_Show_Name @"show_name"
#define Marjor_Private_Show_Data @"show_Data"

#define MarjorPrivateConfigInfoDir [NSString stringWithFormat:@"%@/privateConfig",AppSynchronizationDir]
@interface MarjorPrivateDataManager(){
    OSSClient *_client;
    dispatch_queue_t _queue ;
    MKNetworkEngine *_netWorkEngine;
    SDWebImageDownloader *_downloader;
    NSDate *_succueTime;
}
@property(nonatomic,strong)UIImage *imageData;
@property(nonatomic,strong)NSMutableArray *allSortArray;
@property(nonatomic,strong)arraySort *arraySort;
@property(nonatomic,strong)NSString *privateInfo;
@property(nonatomic,strong)NSString *currentKey;
@end
@implementation MarjorPrivateDataManager
+(MarjorPrivateDataManager*)getInstance{
    static  MarjorPrivateDataManager*g = NULL;
    if (!g) {
        g = [[MarjorPrivateDataManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:MarjorPrivateConfigInfoDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:MarjorPrivateConfigInfoDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    _downloader = [SDWebImageDownloader sharedDownloader];
 #if App_Use_OSS_Sycn
    OSSPlainTextAKSKPairCredentialProvider *provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 3;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    conf.maxConcurrentRequestCount = 5;
    
    // switches to another credential provider.
    _client = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT
                               credentialProvider:provider
                              clientConfiguration:conf];
#endif
    _queue = dispatch_queue_create("com.MajorPrivate.com", DISPATCH_QUEUE_CONCURRENT);
    [self updatePrivateData];
    self.allSortArray = [NSMutableArray arrayWithCapacity:10];
    [self initAllSortArray];
    return self;
}

-(void)reqeustNewImageData{
    if (!GetAppDelegate.isProxyState) {
        BOOL isCanReqest = self.imageData?false:true;
        if (!isCanReqest && _succueTime && [[ NSDate date] timeIntervalSinceDate:_succueTime]>3600) {
            isCanReqest = true;
        }
        if (!isCanReqest) {
            [self.delegate finish_update_pic_config:self.imageData];
            return;
        }
        [self.delegate start_update_pic_config];
        _succueTime = [ NSDate date];
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@.jpg",@"http://softho",@"me.os",@"s-cn-hangzhou.aliy",@"uncs.com",@"/m",@"a",@"x",@"/v",@"i",@"p"];
        [_downloader downloadImageWithURL:[NSURL URLWithString:url]   options:SDWebImageDownloaderLowPriority progress:nil  completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
           if (!error) {
               self.imageData = image;
           }
           else{
               self.imageData = nil;
           }
            [self.delegate finish_update_pic_config:self.imageData];}];
    }
}

-(void)initAllSortArray{
    [self.allSortArray removeAllObjects];
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:MarjorPrivateConfigInfoDir error:nil];
    for (int i =0;i<subPathArr.count; i++) {
        NSString *key = [subPathArr objectAtIndex:i];
        NSData *data = [NSData dataWithContentsOfFile:[self getConfigPath:key]];
        NSString *strDesy =  [FTWCache decryptWithKey:data];
        if ([strDesy length]>10) {
             arraySort *item  = [arraySort yy_modelWithDictionary:[strDesy JSONValue]];
            if (item) {
                [self.allSortArray addObject:@{@"key":key,@"object":item}];
            }
        }
    }
}

-(void)addNewSortItem:(NSString*)key object:(id)object {
    if (!key) {
        return;
    }
    NSFileManager *fileD = [NSFileManager defaultManager];
    NSString *filePath = [self getConfigPath:key];
    if (![fileD fileExistsAtPath:filePath]) {
        NSString *saveStr = [object yy_modelToJSONString];
        NSData *enData=  [FTWCache encryptWithKeyNomarl:saveStr];
        [enData writeToFile:filePath atomically:YES];
    }
    [self.allSortArray addObject:@{@"key":key,@"object":object}];
}

-(BOOL)delSortItemIfCurrent:(NSString*)key{
    BOOL isMustReload = false;
    for (int i = 0; i<self.allSortArray.count && key; i++) {
         NSDictionary *info = [self.allSortArray objectAtIndex:i];
         NSString *key1 = [info objectForKey:@"key"];
        if ([key1 compare:key] ==NSOrderedSame) {
            if (self.currentKey && [key compare:self.currentKey]==NSOrderedSame) {
                isMustReload = true;
            }
            [self.allSortArray removeObject:info];
            [[NSFileManager defaultManager]removeItemAtPath:[self getConfigPath:key] error:nil];
            break;
        }
    }
    return isMustReload;
}


-(NSArray*)getPrivateConfigList{
    return self.allSortArray;
}

-(void)pareseResult:(MKNetworkOperation *)completedOperation key:(NSString*)reqeustKey{
    if (completedOperation.HTTPStatusCode == 200) {
        NSString *strDesy =  [FTWCache decryptWithKey:completedOperation.responseData];
        arraySort *newSort  = [arraySort yy_modelWithDictionary:[strDesy JSONValue]];
        if (newSort.arraySort.count>0) {
            [completedOperation.responseData writeToFile:[self getConfigPath:reqeustKey] atomically:YES];
            self.currentKey = reqeustKey;
            self.arraySort = newSort;
            [self addNewSortItem:reqeustKey object:newSort];
            if ([self.delegate respondsToSelector:@selector(finish_down_private_config:)]) {
                [self.delegate finish_down_private_config:true];
            }
        }
        else{
            if ([self.delegate respondsToSelector:@selector(finish_down_private_config:)]) {
                [self.delegate finish_down_private_config:false];
            }
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(finish_down_private_config:)]) {
            [self.delegate finish_down_private_config:false];
        }
    }
}
//下载
- (void)downMarjorPrivateData:(NSString*)key{
    if (!key || [key length]<2) {
        return;
    }
    if (!_netWorkEngine) {
        _netWorkEngine = [[MKNetworkEngine alloc] init];
     
    }
    if ([self.delegate respondsToSelector:@selector(start_down_private_config)]) {
        [self.delegate start_down_private_config];
    }
    __block NSString* reqeustKey = key;
    MKNetworkOperation *operation =[_netWorkEngine operationWithURLString:[NSString stringWithFormat:@"http://%@%@%@-cn-shenzhen.aliyuncs.com/%@",@"max",@"share",@".oss",key] timeOut:3];
    [operation onCompletion:^(MKNetworkOperation *completedOperation) {
        [self pareseResult:completedOperation key:reqeustKey];
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        if ([self.delegate respondsToSelector:@selector(finish_down_private_config:)]) {
            [self.delegate finish_down_private_config:false];
        }
    }];
    [_netWorkEngine enqueueOperation:operation];
}

//上传
- (void)upLoadMarjorPrivateData{
    if (!self.currentKey) {
        return;
    }
    NSString *key = [self getDeviceUUID];
    if (self.arraySort.arraySort.count>0) {
        NSString *saveStr = [self.arraySort yy_modelToJSONString];
        NSData *enData=  [FTWCache encryptWithKeyNomarl:saveStr];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"marjor_private_configData"];
        if ([enData writeToFile:filePath atomically:YES]) {
            [self putTestDataWithKey:key withClient:_client withBucket:@"maxshare" filePath:filePath];
        }
    }
}

//加载end
-(void)clearAllSortData{
    [self loadBenDi];
}

-(void)updateLocalFormKey:(NSString*)key{
    NSData *data = [NSData dataWithContentsOfFile:[self getConfigPath:key]];
    NSString *strDesy =  [FTWCache decryptWithKey:data];
    BOOL isRet = false;
    arraySort *newData = nil;
    if ([strDesy length]>10) {
        newData  = [arraySort yy_modelWithDictionary:[strDesy JSONValue]];
        if (newData) {
            isRet = true;
        }
    }
    else{
      
    }
    if (isRet) {
        self.currentKey = key;
        self.arraySort = newData;
    }
    if (self.currentKey) {
        [self saveLastUUID:self.currentKey];
    }
    if ([self.delegate respondsToSelector:@selector(update_local_private:)]) {
        [self.delegate update_local_private:isRet];
    }
}


- (void) putTestDataWithKey: (NSString *)key withClient: (OSSClient *)client withBucket: (NSString *)bucket filePath:(NSString*)filePath
{
#if App_Use_OSS_Sycn
    NSString *objectKey = key;
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    if ([self.delegate respondsToSelector:@selector(start_upload_private_config)]) {
        [self.delegate start_upload_private_config];
    }
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucket;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    request.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
    OSSTask * task = [client putObject:request];
    // [task waitUntilFinished];
    [task continueWithExecutor:[OSSExecutor defaultExecutor] withBlock:^id _Nullable(OSSTask * _Nonnull task) {
        NSLog(@"同步数据到服务error = %@",[task.error description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(finish_upload_private_config:error:)]) {
                [self.delegate finish_upload_private_config:key error:task.error];
            }
        });
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return nil;
    }];
#endif
}

-(NSString *)getDeviceUUID{
#define MarjorPrivateDeivceUUID  @"MarjorPrivateDeivceUUID"
    NSUserDefaults *userdefaults  = [NSUserDefaults standardUserDefaults];
    NSString *value = [userdefaults objectForKey:MarjorPrivateDeivceUUID];
    if (!value) {
        value = [[UIDevice stringWithUUID]md5];
        [userdefaults setObject:value forKey:MarjorPrivateDeivceUUID];
        [userdefaults synchronize];
    }
    return value;
}

-(NSString *)getLocalUUID{
#define MarjorPrivateUUID  @"MarjorPrivateUUID"
    NSUserDefaults *userdefaults  = [NSUserDefaults standardUserDefaults];
    NSString *value = [userdefaults objectForKey:MarjorPrivateUUID];
    if (!value) {
        value = [[UIDevice stringWithUUID]md5];
        [userdefaults setObject:value forKey:MarjorPrivateUUID];
        [userdefaults synchronize];
    }
    return value;
}

-(NSString *)getLastUUID{
#define MarjorPrivateLastUUID  @"MarjorPrivateLastUUID"
    NSUserDefaults *userdefaults  = [NSUserDefaults standardUserDefaults];
    NSString *value = [userdefaults objectForKey:MarjorPrivateLastUUID];
    if (!value) {
        value = [[UIDevice stringWithUUID]md5];
        [userdefaults setObject:value forKey:MarjorPrivateLastUUID];
        [userdefaults synchronize];
    }
    return value;
}

-(void)saveLastUUID:(NSString*)key{
    if (key) {
        NSUserDefaults *userdefaults  = [NSUserDefaults standardUserDefaults];
        [userdefaults setObject:key forKey:MarjorPrivateLastUUID];
        [userdefaults synchronize];
    }
}

-(void)updatePrivateData
{
    if (!self.currentKey) {
        self.currentKey = [self getLastUUID];
    }
    NSData *data = [NSData dataWithContentsOfFile:[self getConfigPath:self.currentKey]];
    NSString *strDesy =  [FTWCache decryptWithKey:data];
    if ([strDesy length]>10) {
        self.arraySort = [arraySort yy_modelWithDictionary:[strDesy JSONValue]];
    }
    else{
        self.currentKey = [self getLocalUUID];
        [self loadBenDi];
    }
}

-(void)loadBenDi{
    self.arraySort = [[arraySort alloc] init];
    NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PrivateConfig" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    self.arraySort = [arraySort yy_modelWithDictionary:[str JSONValue]];
    [self updateCurrentConfig:self.arraySort.arraySort showName:self.arraySort.showName];
}

-(NSArray*)getCurrentConfigArray{
    return self.arraySort.arraySort;
}

-(NSString*)getCurrentConfigName{
    return self.arraySort.showName;
}

-(void)updateCurrentConfig:(NSArray*)array showName:(NSString*)showName{
    if (array.count>0 && [showName length]>0 && self.currentKey) {
        [self saveLastUUID:self.currentKey];
        self.arraySort.arraySort = array;
        self.arraySort.showName = showName;
        NSString *saveStr = [self.arraySort yy_modelToJSONString];
        NSData *enData=  [FTWCache encryptWithKeyNomarl:saveStr];
        [enData writeToFile:[self getConfigPath:self.currentKey] atomically:YES];
     }
    else if (array.count==0 && self.currentKey) {
        self.arraySort = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[self getConfigPath:self.currentKey] error:nil];
    }
}

-(NSString*)getConfigPath:(NSString*)key{
    NSString *pah = [NSString stringWithFormat:@"%@/%@",MarjorPrivateConfigInfoDir,key];
  return   pah;
}
@end
