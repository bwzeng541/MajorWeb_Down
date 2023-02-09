//
//  DebugModeCommond.m
//  WatchApp
//
//  Created by zengbiwang on 2018/1/9.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "DebugModeCommond.h"
#import "MajorSystemConfig.h"
#import "MKNetworkEngine.h"
#import "AppDelegate.h"
#import "JSON.h"
#define DebugModeConfigkey @"sfdsDebugkkheCommond"
@interface  DebugModeCommond(){
    MKNetworkEngine *engine;
}
@end
@implementation DebugModeCommond
@synthesize extb,extn;
+(DebugModeCommond*)getInstance{
    static DebugModeCommond *g  = NULL;
    if (!g) {
        g = [[DebugModeCommond alloc] init];
        [g initLocal];
        [g startReqeustService];
    }
    return g;
}

-(void)startReqeustService{
    if (!engine) {
        engine = [[MKNetworkEngine alloc]init];
    }
    if(GetAppDelegate.isProxyState){
        [self performSelector:@selector(startReqeustService) withObject:nil afterDelay:5];
        return;
    }
    MKNetworkOperation *op = [engine operationWithURLString:@"http://mjg.oss-cn-qingdao.aliyuncs.com/action.txt" params:nil httpMethod:@"GET" timeOut:5];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSString *response = [FTWCache decryptWithKey:completedOperation.responseData];
        [FTWCache setObject:[response dataUsingEncoding:NSUTF8StringEncoding] forKey:DebugModeConfigkey useKey:YES];
        NSDictionary *dicInfo = [response JSONValue];
        [self parseDebugInfo:dicInfo];
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        NSData *state = [FTWCache objectForKey:DebugModeConfigkey useKey:YES];
        if (state) {
            NSString *stateEncoding = [[NSString alloc]initWithData:state encoding:NSUTF8StringEncoding];
            NSDictionary *dicInfo = [stateEncoding JSONValue];
            [self parseDebugInfo:dicInfo];
        }
        else{
            [self performSelector:@selector(startReqeustService) withObject:nil afterDelay:5];
        }
    }];
    [engine enqueueOperation:op];
}

-(void)initLocal{
    NSData *state = [FTWCache objectForKey:DebugModeConfigkey useKey:YES];
    if (state) {
        NSString *stateEncoding = [[NSString alloc]initWithData:state encoding:NSUTF8StringEncoding];
        NSDictionary *dicInfo = [stateEncoding JSONValue];
        [self parseDebugInfo:dicInfo];
    }
}

-(void)parseDebugInfo:(NSDictionary*)info{
    NSString *strisDebugMode = [info objectForKey:@"isDebugMode"];
    if([strisDebugMode isEqualToString:@"0"]){
        [MajorSystemConfig getInstance].isDebugMode = true;
    }
    id tmpGdtInfo = [info objectForKey:@"extb"];
    //gdtAdInfo是数组，需要计算gdtAdInfo值
    if ([tmpGdtInfo isKindOfClass:[NSArray class]])
    {
        extb = [[NSArray alloc]initWithArray:tmpGdtInfo];
    }
    tmpGdtInfo = [info objectForKey:@"extn"];
    //gdtAdInfo是数组，需要计算gdtAdInfo值
    if ([tmpGdtInfo isKindOfClass:[NSArray class]])
    {
        extn = [[NSArray alloc]initWithArray :tmpGdtInfo];
    }
}
@end
