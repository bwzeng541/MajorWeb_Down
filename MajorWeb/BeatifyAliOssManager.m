//
//  BeatifyAliOssManager.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyAliOssManager.h"
#import "OSSManager.h"
#import "AppDelegate.h"
#import "MKNetworkEngine.h"
#import "MajorSystemConfig.h"
#define BeatifyOssManager 0
#define BeatifyOssJsReplace @"_20191014180356_"
#define BeatifyOssVideoReplace @"_20191014180357_"
#define BeatifyOssMsgDefalut @"_20191014180358_Msg"

#define AdUrlWebTiJiaoDir [[NSString oss_documentDirectory] stringByAppendingPathComponent:@"beatifySumbit"]
@interface BeatifyAliOssManager()
{
    dispatch_queue_t _queue;
    NSInteger  _index;
    MKNetworkEngine *mkEngine;
    BOOL isSuccess;
}
@property (nonatomic, strong) OSSClient *assetClient;
@property (nonatomic, strong) OSSClient *client;
@property (nonatomic, strong) OSSPlainTextAKSKPairCredentialProvider *provider;
@property (nonatomic, strong) OSSClientConfiguration *conf;
@property (nonatomic, copy) NSString *assetMsg;
@property(copy)NSString *uploadAsset;
@end
@implementation BeatifyAliOssManager
+(BeatifyAliOssManager*)getInstance{
    static BeatifyAliOssManager*g = NULL;
    if (!g) {
        g = [[BeatifyAliOssManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
#if App_Use_OSS_Sycn
    [[NSFileManager defaultManager] removeItemAtPath:AdUrlWebTiJiaoDir error:nil];
    self.provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
    self.conf = [OSSClientConfiguration new];
    self.conf.maxRetryCount = 2;
    self.conf.timeoutIntervalForRequest = 3;
    self.conf.timeoutIntervalForResource = 24 * 60 * 60;
    self.conf.maxConcurrentRequestCount = 5;
    _queue = dispatch_queue_create("com.beatifySumbit.com", DISPATCH_QUEUE_CONCURRENT);
#endif
    return self;
}

-(void)requestJsService{
   NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    if (GetAppDelegate.isProxyState) {
        [self performSelector:@selector(requestJsService) withObject:nil afterDelay:1];
        return;
    }
    if (mkEngine) {
        return;
    }
    if (!mkEngine) {
        mkEngine = [[MKNetworkEngine alloc]init];
        if(!self.assetMsg){
            self.assetMsg = [defaluts objectForKey:BeatifyOssMsgDefalut];
            if ( self.assetMsg) {
                [self initAssetOssClient2];
            }
        }
    }
    NSString *url =  [[MajorSystemConfig getInstance].param13 objectForKey:@"html"];
    printf("url = %s\n",[url UTF8String]);
    if (!url) {
        [self performSelector:@selector(requestJsService) withObject:nil afterDelay:1];
        return;
    }
    MKNetworkOperation *op  = [mkEngine operationWithURLString:url timeOut:3];
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            NSInteger code = completedOperation.HTTPStatusCode;
            if (code>=200 && code<300)
            {
                if(completedOperation.responseString){
                    self.assetMsg = completedOperation.responseString;
                    [defaluts setObject:self.assetMsg forKey:BeatifyOssMsgDefalut];
                    [defaluts synchronize];
                    self->isSuccess = true;
                    [self initAssetOssClient2];
                }
                else{
                    [self performSelector:@selector(requestJsService) withObject:nil afterDelay:1];
                }
                self->mkEngine = nil;
            }
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
            self->mkEngine = nil;
            [self performSelector:@selector(requestJsService) withObject:nil afterDelay:1];
        }];
    [mkEngine enqueueOperation:op];
}

-(void)initAssetOssClient{
    if (!isSuccess) {
        [self requestJsService];
    }
}

-(void)initAssetOssClient2{
#if App_Use_OSS_Sycn

        self.assetClient = [[OSSClient alloc] initWithEndpoint:[[MajorSystemConfig getInstance].param13 objectForKey:@"endPoint"]
                                                     credentialProvider:self.provider
                                                    clientConfiguration:self.conf];
#endif
}


-(NSString*)updateAsset2:(NSString*)asset{
#if App_Use_OSS_Sycn

    if (self.assetClient) {
        NSString *filemd5 = [[asset md5] stringByAppendingString:@".html"];
        NSString *msg = self.assetMsg;
        msg = [msg stringByReplacingOccurrencesOfString:BeatifyOssJsReplace withString:[[MajorSystemConfig getInstance].param13 objectForKey:@"js"]];
        msg = [msg stringByReplacingOccurrencesOfString:BeatifyOssVideoReplace withString:asset];
        [[NSFileManager defaultManager] createDirectoryAtPath:AdUrlWebTiJiaoDir withIntermediateDirectories:NO attributes:nil error:nil];
        [msg writeToFile:[AdUrlWebTiJiaoDir stringByAppendingPathComponent:filemd5] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *pos = [[MajorSystemConfig getInstance].param13 objectForKey:@"bucket"];
        dispatch_async(_queue, ^{
            [self putTestDataWithKey:filemd5 withClient:self.assetClient withBucket:pos];
        });
        NSString *str = [[[MajorSystemConfig getInstance].param13 objectForKey:@"dns"] stringByAppendingString:filemd5];
        return str;
    }
#endif
    return nil;
}



- (void) putTestDataWithKey: (NSString *)key withClient: (OSSClient *)client withBucket: (NSString *)bucket
{
#if App_Use_OSS_Sycn
     NSString *objectKey = key;
    NSString *filePath = [AdUrlWebTiJiaoDir stringByAppendingPathComponent:objectKey];
    
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucket;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    request.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
    OSSTask * task = [client putObject:request];
    [task continueWithExecutor:[OSSExecutor defaultExecutor] withBlock:^id _Nullable(OSSTask * _Nonnull task) {
        NSLog(@"同步数据到服务error = %@",[task.error description]);
        return nil;
    }];
#endif
}
@end
