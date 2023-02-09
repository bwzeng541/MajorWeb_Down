//
//  QRWebBlockManager.m
//  QRTools
//
//  Created by bxing zeng on 2020/5/11.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRWebBlockManager.h"
#import  "AFNetworking.h"
#import "ZipArchive.h"
#import "JSON.h"
 
#define QRWebCacheDir [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"QRWebCacheDir"]
#define QRWebCacheDirTmp [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"QRWebCacheDirTmp"]
  

const NSString *qrJsWebKey = @"webKey";
const NSString *qrJsWebAssetKey = @"webassetKey";
 
@interface QRWebBlockManager()
@property(nonatomic,strong)AFURLSessionManager *manager;
@property(nonatomic,strong)NSMutableDictionary *qrJsMsgInfo;
@end

static QRWebBlockManager *__qrWebBlockConfig = nil;
@implementation QRWebBlockManager
+(QRWebBlockManager*)shareInstance
{
    static dispatch_once_t oneToken;
      dispatch_once(&oneToken, ^{
          __qrWebBlockConfig = [[QRWebBlockManager alloc]init];
      });
      return __qrWebBlockConfig;
}

-(id)init{
    self = [super init];
              if (![[NSFileManager defaultManager]fileExistsAtPath:QRWebCacheDir]) {
                     [[NSFileManager defaultManager] createDirectoryAtPath:QRWebCacheDir withIntermediateDirectories:NO attributes:nil error:nil];
                 }
    [self loadQrDefalut];
    [self startDownQRJsZip];
    return self;
}

 
 

-(void)loadQrDefalut{
    NSArray *array = @[qrJsWebKey,qrJsWebAssetKey];
    for (int i = 0;i<array.count; i++) {
       NSString *v = [QRWebCacheDir stringByAppendingPathComponent:array[i]];
       NSString *m =   [NSString stringWithContentsOfFile:v encoding:NSUTF8StringEncoding error:nil];
        if ([m length]>20) {
            [self.qrJsMsgInfo setObject:m forKey:array[i]];
        }
    }
}
 
-(void)updateQrBlockWithRuleList:(NSString*)identifier opWebView:(WKWebView*)opWebView ruleList:(WKContentRuleList*)ruleList complete:(void(^)(void))complete{
    if (@available(iOS 11.0, *)) {
        if (!ruleList) {
            complete();
            return;
        }
        WKUserContentController * v=opWebView.configuration.userContentController;
        [v addContentRuleList:ruleList];
        complete();
    } else {
        // Fallback on earlier versions
    }
}

 
#pragma mark --网络下载jz zip文件

-(void)startDownQRJsZip{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    configuration.URLCache = nil;
    self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"https://maxdownapp.oss-cn-hangzhou.aliyuncs.com/erwebf.zip"];
     NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            [self performSelector:@selector(startDownQRJsZip) withObject:nil afterDelay:2];
        }
        else {
           NSString *zip1 = [filePath path];
            BOOL ret = [SSZipArchive unzipFileAtPath:zip1 toDestination:QRWebCacheDirTmp overwrite:YES password:@"1" error:nil];
            if (ret) {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:QRWebCacheDir error:&error];
                [[NSFileManager defaultManager] moveItemAtPath:QRWebCacheDirTmp toPath:QRWebCacheDir error:&error];
                [self loadQrDefalut];
             }
            else{
                [self performSelector:@selector(startDownQRJsZip) withObject:nil afterDelay:2];
            }
            [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            #ifdef DEBUG
            NSLog(@"File downloaded to: %@", filePath);
#endif
        }
    }];
    [downloadTask resume];
}

-(NSString*)getQrJsStringFromKey:(NSString*)key{
    #ifdef DEBUG
    if ([key compare:@"webKey"]==NSOrderedSame) {
        NSString *msg = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"webKey(1)" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        return msg;
    }
#endif
    
     NSString *v = [self.qrJsMsgInfo objectForKey:key];
#ifdef DEBUG
    printf("getQrJsStringFromKey key :%s value = %s\n",[key UTF8String],[v UTF8String]);
#endif
    return v;
}
@end
