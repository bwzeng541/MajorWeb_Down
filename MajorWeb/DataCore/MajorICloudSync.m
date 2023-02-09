//
//  MajorICloudSync.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/17.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorICloudSync.h"
#import "MarjorWebConfig.h"
#import "FileDonwPlus.h"
#import "OSSManager.h"
#import "OSSWrapper.h"
#import <AdSupport/AdSupport.h>
#define SyncFromOssKey  @"marjor_SyncFromOssKey"
#define SyncOssBucket @"maxuserbf"
#define SyncFilePre  @"marjor_bk_"
#define SynciCloudName @"guangchangwu"
#define SyncPassWord @"app_uc_browe_20180821"
#define SyncUpdateTime  NSDate *date = [NSDate date]; \
[[NSUserDefaults standardUserDefaults] setObject:date forKey:MajorICloudSyncLastUpdatedTimeKey]; \
[[NSUserDefaults standardUserDefaults] synchronize];
//修改成oss数据同步
@interface MajorICloudSync ()<SSZipCreateArchiveDelegate>{
    OSSClient *_client;
     dispatch_queue_t _queue ;
}
@property(assign,nonatomic)BOOL majorCloudIsAvailable;
@property(strong,nonatomic)NSString* iclondSyncDes;
@property(assign,nonatomic)BOOL isSyncIng;
@property(assign,nonatomic)BOOL isUpdateZip;
@property(assign,nonatomic)BOOL isSyncToFinish;
@end
@implementation MajorICloudSync

+(MajorICloudSync*)getInstance{
    static MajorICloudSync*g = nil;
    if (!g) {
        g = [[MajorICloudSync alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    self.iclondSyncDes = nil;
    self.isSyncIng = false;
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    _queue = dispatch_queue_create("com.MajorICloud.com", DISPATCH_QUEUE_CONCURRENT);

    return self;
}

-(void)applicationDidEnterBackground{
    [self syncLoaclToICloud];
}

-(BOOL)cloudIsAvailable
{
    return  true;
}

-(BOOL)zipCanArchive:(NSString*)filePath{
    if ([filePath rangeOfString:@"Web/"].location==NSNotFound && [filePath rangeOfString:@"alone/"].location==NSNotFound) {
        return true;
    }
    return false;
}
//同步数据到服务器
- (void)syncLoaclToICloud{
    if (![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return;
    }
    NSString *key = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSString *zip = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"SynchronizationDir.zip"];
    BOOL ret = [SSZipArchive createZipFileAtPath:zip withContentsOfDirectory:AppSynchronizationDir withPassword:SyncPassWord delegate:self];
   NSString *zip1 = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"VideoDownCaches.zip"];
    ret =  [SSZipArchive createZipFileAtPath:zip1 withContentsOfDirectory:VIDEOCACHESROOTPATH withPassword:SyncPassWord delegate:self];
    NSString *upZip = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"app_marjor_sync.zip"];
    ret = [SSZipArchive  createZipFileAtPath:upZip withFilesAtPaths:@[zip,zip1] delegate:nil];
    if (ret) {
         key = [SyncFilePre  stringByAppendingFormat:@"_%@",key] ;
        dispatch_async(_queue, ^{
            [self putTestDataWithKey:key withClient:self->_client withBucket:SyncOssBucket filePath:upZip];
        });
    }
}


- (void) putTestDataWithKey: (NSString *)key withClient: (OSSClient *)client withBucket: (NSString *)bucket filePath:(NSString*)filePath
{
    
#if App_Use_OSS_Sycn
    NSString *objectKey = key;
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
 
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucket;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    request.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
    OSSTask * task = [client putObject:request];
   // [task waitUntilFinished];
     [task continueWithExecutor:[OSSExecutor defaultExecutor] withBlock:^id _Nullable(OSSTask * _Nonnull task) {
         NSLog(@"同步数据到服务error = %@",[task.error description]);
         return nil;
    }];
#endif
 }


-(BOOL)syncNetToLoalInMainThread:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure{
    if (![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return false;
    }
    if(![self getSyncMarjorFlag])return false;
 
    [self foceUpdateAsset:success failure:failure];
    return true;
}

-(void)foceUpdateAsset:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure{
#if App_Use_OSS_Sycn
    NSString *downloadFilePath = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"down_app_marjor_sync.zip"];
    NSString*objectKey = [SyncFilePre  stringByAppendingFormat:@"_%@",[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    OSSGetObjectRequest* _normalDloadRequest = [OSSGetObjectRequest new];
    _normalDloadRequest.bucketName = SyncOssBucket;
    _normalDloadRequest.objectKey = objectKey;
    _normalDloadRequest.downloadToFileURL = [NSURL URLWithString:downloadFilePath];
    _normalDloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float progress = 1.f * totalBytesWritten / totalBytesExpectedToWrite;
        NSLog(@"下载文件进度: %f", progress);
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSTask * task = [self->_client  getObject:_normalDloadRequest];
        [task continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.error) {
                    NSString *des = [task.error description];
                    if ([des rangeOfString:@"Code=-404"].location!=NSNotFound) {//新用户或者没有该功能的用户
                        [self updateSyncMarjorFlag:true];
                    }
                    else{
                        [self updateSyncMarjorFlag:false];
                    }
                    if (failure) {
                        failure(task.error);
                    }
                } else {
                    [self updateSyncMarjorFlag:true];
                    dispatch_async(self->_queue, ^{
                        [self unZipSyncFile:downloadFilePath];
                    });
                    if (success) {
                        success(downloadFilePath);
                    }
                }
            });
            return nil;
        }];
    });
#endif
}

-(void)unZipSyncFile:(NSString*)filePath{
    NSString *file = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"down_app_marjor_sync_dir"];
    BOOL ret = [SSZipArchive unzipFileAtPath:filePath toDestination:file overwrite:YES password:SyncPassWord error:nil];
    if (ret) {
         NSString *zip1 = [file stringByAppendingPathComponent:@"SynchronizationDir.zip"];
        NSString *zip2 = [file stringByAppendingPathComponent:@"VideoDownCaches.zip"];
        BOOL ret = [SSZipArchive unzipFileAtPath:zip1 toDestination:AppSynchronizationDir overwrite:YES password:SyncPassWord error:nil];
        
         ret = [SSZipArchive unzipFileAtPath:zip2 toDestination:VIDEOCACHESROOTPATH overwrite:YES password:SyncPassWord error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSyncToFinish = true;
        });
    }
    
    [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:file error:nil];
}

-(BOOL)getSyncMarjorFlag{
   NSUserDefaults *dd = [NSUserDefaults standardUserDefaults];
    NSNumber *nn = [dd objectForKey:SyncFromOssKey];
    if (nn && [nn boolValue]) {
        return false;
    }
    else if(nn && ![nn boolValue]){
        return true;
    }
    return true;
}

-(void)updateSyncMarjorFlag:(BOOL)isSyncFromOss{
    NSUserDefaults *dd = [NSUserDefaults standardUserDefaults];
    [dd setObject:[NSNumber numberWithBool:isSyncFromOss] forKey:SyncFromOssKey];
    [dd synchronize];
}



-(void)updateIclondSyncDes{
    SyncUpdateTime
    date = [[NSUserDefaults standardUserDefaults] objectForKey:MajorICloudSyncLastUpdatedTimeKey];
    if (date) {
        NSInteger hour =  [date hour];
        NSInteger minute =  [date minute];
        if([date isToday]){
            self.iclondSyncDes = [NSString stringWithFormat:@"上次同步时间 今天%02ld:%02ld",hour,minute];
        }
        else{
            self.iclondSyncDes = [NSString stringWithFormat:@"上次同步时间 %02ld-%02ld %02ld:%02ld",[date month],[date day],hour,minute];
        }
    }
}
@end
