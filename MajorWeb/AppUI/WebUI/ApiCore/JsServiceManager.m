//
//  JsServiceManager.m
//  WatchApp
//
//  Created by zengbiwang on 2017/11/27.
//  Copyright © 2017年 cxh. All rights reserved.
//



#import "JsServiceManager.h"
#import "MKNetworkEngine.h"
#import "JSON.h"
#import "WebCoreManager.h"
#import "ZFAutoListParseManager.h"
#import "MajorSystemConfig.h"
#define GdtAdOperatJsKey @"sfsGtAddfOpessratJsKeydfjjj"
#define JsServiceSaveKey @"20191009184746_jj"

#define JsServiceUrlHttp @"https://maxdownapp.oss-cn-hangzhou.aliyuncs.com/"
@interface JsServiceManager(){
    MKNetworkEngine *mkEngine;
    NSMutableArray *arrayjskey;
    int requestIndex;
    
    
    MKNetworkEngine *adEngine;
}
@property(copy)NSString *reqeustKey;
@property(retain)NSMutableDictionary*dicInfo;
@end

@implementation JsServiceManager
+(JsServiceManager*)getInstance{
    static JsServiceManager *g = nil;
    if (!g) {
        g = [[JsServiceManager alloc] init];
        [g requestJsService];
        [g reqeustAdJsService];
    }
    return g;
}

-(id)init{
    self = [super init];
    self.dicInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:JsServiceSaveKey]) {
        [self.dicInfo setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:JsServiceSaveKey]];
    }
    return self;
}
-(NSString*)getJsContent:(NSString*)key{
    NSString *msg = [self.dicInfo objectForKey:key];
   // printf("key  = %s msg = %s\n",[key UTF8String],[msg UTF8String]);
    return msg;
}

-(void)reqeustAdJsService{
    if (!adEngine) {
        adEngine = [[MKNetworkEngine alloc]init];
    }
    NSString *adJsUrl=@"http://softhome.oss-cn-hangzhou.aliyuncs.com/pingjia_open/tx_ad_all.js";
    MKNetworkOperation *op  = [adEngine operationWithURLString:adJsUrl timeOut:3];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSInteger code = completedOperation.HTTPStatusCode;
        if (code>=200 && code<300 && [completedOperation.responseString length]>20)
        {
            [self.dicInfo setObject:completedOperation.responseString forKey:GdtAdOperatJsKey];
        }
        else{
            [self performSelector:@selector(reqeustAdJsService) withObject:nil afterDelay:1];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self performSelector:@selector(reqeustAdJsService) withObject:nil afterDelay:1];
    }];
    [adEngine enqueueOperation:op];
}
//下载所有js
//DelAdsB.js DelAdsA.js VideoUrlHandleNode.js VideoWebView.js VideoWebView2.js WebJsNode.js WebUrlHandleNode.js
-(void)requestJsService{
    if (!mkEngine) {
        mkEngine = [[MKNetworkEngine alloc]init];
        arrayjskey = [[NSMutableArray alloc]initWithCapacity:1];
        [arrayjskey addObject:@"VideoUrlHandleNode"];
        [arrayjskey addObject:@"RemoveMark_new"];
        [arrayjskey addObject:@"WebJsNode_beatify"];
        [arrayjskey addObject:@"WebJsNode_new_max"];
        requestIndex = 0;
    }
    if (arrayjskey.count>0) {
        self.reqeustKey = [arrayjskey objectAtIndex:requestIndex];
        NSString *url = [NSString stringWithFormat:@"%@%@",JsServiceUrlHttp,self.reqeustKey];
        MKNetworkOperation *op  = [mkEngine operationWithURLString:url timeOut:3];
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
           NSInteger code = completedOperation.HTTPStatusCode;
            if (code>=200 && code<300)
            {
                [self.dicInfo setObject:completedOperation.responseString forKey:self.reqeustKey];
                if ([self.reqeustKey isEqualToString:@"WebJsNode_new_max"]) {
                    [[WebCoreManager getInstanceWebCoreManager]updateSendWebJsNodeMessageInfo];
                    self.isWebJsSuccess = true;
                    [[NSUserDefaults standardUserDefaults] setObject:self.dicInfo forKey:JsServiceSaveKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[ZFAutoListParseManager getInstance] initAssetArray:[MajorSystemConfig getInstance].param8];
                }
                [self->arrayjskey removeObject:self.reqeustKey];
                if (self->arrayjskey.count>0) {
                    self->requestIndex =  (self->requestIndex+1)%self->arrayjskey.count;
                }
                [self performSelector:@selector(requestJsService) withObject:nil afterDelay:1];
            }
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
           [self performSelector:@selector(requestJsService) withObject:nil afterDelay:1];
        }];
       [mkEngine enqueueOperation:op];
    }
    else{
        
    }
}
@end
