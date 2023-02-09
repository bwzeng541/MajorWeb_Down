//
//  AdVertUrlConfig.m
//  AdSdk
//
//  Created by zengbiwang on 2018/4/8.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "AdVertUrlConfig.h"
#import "MKNetworkEngine.h"
#import "JSON.h"
#import "FTWCache.h"
#import "MajorSystemConfig.h"
#import <AdSupport/AdSupport.h>
#import "helpFuntion.h"
#define AppBundle @"bf3741f59f0c6da55816100eab7b5dee"

#define ApiRequestResponseKey @"AdSdK_ApiResponse"
//本机数据
#define AppBunldeKey @"app_bunlde"
#define AppDeviceUUID @"device_uuid"

//保存的值
#define Advert_app_id @"advert_app_id"
#define Advert_app_url @"advert_app_url"


#define UrlIndexNumber @"urlConfigIndex_key"
#define UrlIndexNumberState @"urlConfigIndexState_key"

@interface AdVertUrlConfig()
@property(retain)MKNetworkEngine *engine;
@property(copy)AdVertUrlConfigUrlBlock callBlock;
@property(copy)NSString *servicUrl;
@property(copy)NSArray *urlArray;
@end

@implementation AdVertUrlConfig
+(AdVertUrlConfig*)getInstance{
    static AdVertUrlConfig *g = NULL;
    if (!g) {
        g = [[AdVertUrlConfig alloc]init];
    }
    return g;
}

-(void)start:(AdVertUrlConfigUrlBlock)block serviceUrl:(NSString*)serviceUrl urlArray:(NSArray*)urlArray{
    self.callBlock = block;
    self.servicUrl = serviceUrl;
    self.urlArray = urlArray;
    if ([self isCheckQuest]) {
        self.engine = [[MKNetworkEngine alloc]init];
        [self reqeustNewIt];
    }
    else{
        [self callBackUI];
    }
}

-(void)callBackUI{
    if (self.urlArray.count>0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        int index = [[userDefaults objectForKey:UrlIndexNumber] intValue];
        [MajorSystemConfig getInstance].apiState = [[userDefaults objectForKey:UrlIndexNumberState] intValue];
        if (index<self.urlArray.count) {
            self.callBlock([self.urlArray objectAtIndex:index]);
        }
        [userDefaults setObject:[NSNumber numberWithInt:(index+1)%self.urlArray.count] forKey:UrlIndexNumber];
        [userDefaults synchronize];
    }
 
//    NSString *oldAppUrl = nil;
//    NSData *data =  [FTWCache objectForKey:Advert_app_url];
//    oldAppUrl = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    if (self.callBlock) {
//        self.callBlock(oldAppUrl);
//    }
}

//一天只请求一次数据
-(BOOL)isCheckQuest{
  BOOL ret =  [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:eveyrDayClickGDTAdertTimes(@"adVertUrlConfig_times") nCount:1 isUseYYCache:false time:nil];
    if (!ret) {
        //判断
//        NSData *idData = [FTWCache objectForKey:Advert_app_id];
//        NSData *urlData = [FTWCache objectForKey:Advert_app_url];
//        if (!idData || !urlData) {
//            ret = true;
//        }
        if(![[NSUserDefaults standardUserDefaults] objectForKey:UrlIndexNumberState]){
            ret = true;
        }
     }
    return ret;
}

-(void)reqeustNewIt{
    MKNetworkOperation *opertation = [_engine operationWithURLString:self.servicUrl params:nil httpMethod:@"GET" timeOut:5];
    [opertation onCompletion:^(MKNetworkOperation *completedOperation) {
        NSString *strMsg = completedOperation.responseString;
        if ([strMsg length]>2) {
            [[helpFuntion gethelpFuntion] isValideOneDay:eveyrDayClickGDTAdertTimes(@"adVertUrlConfig_times") nCount:1 isUseYYCache:false time:nil];
            [FTWCache setObject:[strMsg dataUsingEncoding:NSUTF8StringEncoding] forKey:ApiRequestResponseKey useKey:YES];
            [self parseNew:completedOperation.responseString];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        NSData *data = [FTWCache objectForKey:ApiRequestResponseKey useKey:YES];
        if (data) {
            NSString *strMsg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [self parseNew:strMsg];
        }
        else{
            [self performSelector:@selector(reqeustNewIt) withObject:nil afterDelay:3];
        }
    }];
    [_engine enqueueOperation:opertation];
}

-(void)reqeustIt{
   NSString *deviceUUID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:1];
    [info setObject:deviceUUID forKey:@"uuid"];
    [info setObject:AppBundle forKey:@"groupmark"];
    NSString *oldAppID = nil;
    NSData *data =  [FTWCache objectForKey:Advert_app_id useKey:YES];
    if (data) {
        oldAppID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [info setObject:oldAppID forKey:@"appmark"];
    }
    MKNetworkOperation *opertation = [_engine operationWithURLString:self.servicUrl params:info httpMethod:@"POST" timeOut:5];
    [opertation onCompletion:^(MKNetworkOperation *completedOperation) {
        //completedOperation.responseString
        NSString *strMsg = completedOperation.responseString;
        if ([strMsg length]>5) {
            [[helpFuntion gethelpFuntion] isValideOneDay:eveyrDayClickGDTAdertTimes(@"adVertUrlConfig_times") nCount:1 isUseYYCache:false time:nil];
            [FTWCache setObject:[strMsg dataUsingEncoding:NSUTF8StringEncoding] forKey:ApiRequestResponseKey useKey:YES];
            [self parse:completedOperation.responseString];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
         NSData *data = [FTWCache objectForKey:ApiRequestResponseKey useKey:YES];
        if (data) {
           NSString *strMsg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
           [self parse:strMsg];
        }
        else{
            [self performSelector:@selector(reqeustNewIt) withObject:nil afterDelay:3];
        }
    }];
    [_engine enqueueOperation:opertation];
}

//检查状态，确定apiState值,控制是否自动点击
-(void)parseNew:(NSString*)strMsg{
    id v = [strMsg JSONValue];
    NSInteger code = [[v objectForKey:@"code"] intValue];
    if (code==200) {
        [MajorSystemConfig getInstance].apiState = [[v objectForKey:@"state"] intValue];
        NSLog(@"GetAppDelegate.apiState %d",[MajorSystemConfig getInstance].apiState);
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:[MajorSystemConfig getInstance].apiState] forKey:UrlIndexNumberState];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self callBackUI];
    }
}//end

//逻辑数据判断，当前的appiid 是否和返回的一致，不一样需要删除gdt广告生成的目录
-(void)parse:(NSString*)strMsg{
    id v = [strMsg JSONValue];
    NSInteger code = [[v objectForKey:@"code"] intValue];
    NSInteger statuts = [[v objectForKey:@"status"] intValue];
    if (code!=200) {
        return;
    }
    id  retData = [v objectForKey:@"data"];
    
    NSString *retAppId = [retData objectForKey:@"appmark"];
    NSString *retAppUrl = [retData objectForKey:@"appurl"];
    
    NSString *oldAppUrl = nil;
    NSString *oldAppID = nil;
    NSData *data =  [FTWCache objectForKey:Advert_app_id useKey:YES];
    if (data) {
        oldAppID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    if (oldAppID && retAppId && [oldAppID compare:retAppId] != NSOrderedSame) {//删除目录
        [self delCachesDir];
        //end
        oldAppUrl = retAppUrl;
    }
    else{
        NSData *data =  [FTWCache objectForKey:Advert_app_url useKey:YES];
        NSString *saveUrl = nil;
        if (data) {
            saveUrl = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (data && !retAppUrl) {
            oldAppUrl = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }
        else if(retAppUrl){
            oldAppUrl = retAppUrl;
        }
        //url地址不一样，
        if(saveUrl && oldAppUrl &&  ([saveUrl compare:oldAppUrl]!=NSOrderedSame)){
            [self delCachesDir];
        }
    }
    if (retAppId) {//同步数据
        [FTWCache setObject:[retAppId dataUsingEncoding:NSUTF8StringEncoding] forKey:Advert_app_id useKey:YES];
    }
    if (retAppUrl ) {//同步数据
         [FTWCache setObject:[retAppUrl dataUsingEncoding:NSUTF8StringEncoding] forKey:Advert_app_url useKey:YES];
    }
    [self callBackUI];
}

-(void)delCachesDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"tencent_gdtmob"] error:NULL] ;
    //更具实际情况删除，每个app不一样
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];//删除gdt目录
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
