//
//  AloneOenItem.m
//  WatchApp
//
//  Created by zengbiwang on 2017/6/23.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "AloneOenItem.h"
#import "FileArInfo.h"
#import "ASIHTTPRequest.h"
#import "AppNodeTask.h"
#import "RecordUrlToUUID.h"
#if DoNotKMPLayerCanShareVideo
@interface AloneOenItem ()
#else
@interface AloneOenItem ()<PlayVideoTaskDelegate>
#endif
{
    BOOL isStart;

    ASIHTTPRequest *asiRequest;

    BOOL  isCanPlay;
}
@property(strong)NSDate *createTime;
@property(strong)FileArInfo *requestApi;
#if DoNotKMPLayerCanShareVideo
#else
@property(strong)    AppNodeTask *AppNodeTask;
#endif
@end

@implementation AloneOenItem

-(id)init{
    self = [super init];
#if DoNotKMPLayerCanShareVideo
#else
    self.AppNodeTask = [[AppNodeTask alloc]init];
    self.AppNodeTask.delegate = self;
#endif
    self.createTime = [NSDate date];
    return self;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [self stop];
#if DoNotKMPLayerCanShareVideo
#else
    self.AppNodeTask = nil;
#endif
    [super dealloc];
}

-(void)start{
    if(!isStart)
    {
        isStart = true;
#if DoNotKMPLayerCanShareVideo
#else
        self.AppNodeTask.uuid = self.uuid;
#endif
        asiRequest = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:self.fileUrl]];
        [asiRequest setTimeOutSeconds:10];
        [asiRequest setDownloadDestinationPath:self.saveRootPath];
        [asiRequest setTemporaryFileDownloadPath:self.tmpRootPath];
        asiRequest.isAuToRemoveTmp = true;
        [asiRequest setAllowResumeForFileDownloads:YES];
        [asiRequest setDelegate:self];
        [asiRequest setDownloadProgressDelegate:self];
        [asiRequest setDidDownProgressSelector:@selector(setProgressMy:)];
        [asiRequest setIsShowProgress:true];
        [asiRequest setUserAgent:IosIphoneOldUserAgent];
        NSString *referer = [[RecordUrlToUUID getInstance] urlFromKey:self.uuid];
        if (referer) {
            [asiRequest addRequestHeader:@"Referer" value:referer];
        }
        [asiRequest startAsynchronous];
        if([self.delegate respondsToSelector:@selector(app_state_change_1:)]){
            [self.delegate app_state_change_1:self.uuid];
        }
        NSLog(@"start uuid = %@",self.uuid);
    }
}

-(void)stop
{
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask stopCheckToSlow];
#endif
    NSLog(@"stop uuid = %@",self.uuid);
     [self.requestApi clearCompletionBlock];
    [self.requestApi setResumableDownloadProgressBlock:nil];
    [asiRequest setDownloadProgressDelegate:nil];
    [asiRequest setDidDownProgressSelector:nil];
    [asiRequest setDelegate:nil];
    [self.requestApi stop];
    self.requestApi =nil;
    [asiRequest cancel];
    [asiRequest release];
    asiRequest = nil;
    if (isStart && [self.delegate respondsToSelector:@selector(app_state_change_2:)]) {
        [self.delegate app_state_change_2:self.uuid];
    }
    isStart = FALSE;
}

-(void)speedSlow:(NSString *)uuid{
    [self stop];
    [self reqeustFail:nil];
}

-(void)updateProgress:(float)porgress{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(app_state_change_4:parma0:)]){
            [self.delegate app_state_change_4:self.uuid parma0:porgress];
        }
        if (!isCanPlay && porgress>0.02 && [self.delegate respondsToSelector:@selector(app_state_change_3:)]) {
            isCanPlay = true;
            [self.delegate app_state_change_3:self.uuid];
        }
    });
}

-(void)updateRequestOK:(NSInteger)code{
    if (isStart) {
#if DoNotKMPLayerCanShareVideo
#else
        [self.AppNodeTask stopCheckToSlow];
#endif
        if (code>=200 && code<300) {
            if([self.delegate respondsToSelector:@selector(app_state_change_5:)]){
                [self.delegate app_state_change_5:self.uuid];
            }
        }
        else{
            if([self.delegate respondsToSelector:@selector(app_state_change_6:)]){
                [self.delegate app_state_change_6:self.uuid];
            }
        }
    }
}
#pragma mark-- ASIHttpDelagte
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    NSProgress *tmp = [[NSProgress alloc]init];
    tmp.completedUnitCount = bytes;
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask jisuan2:tmp];
#endif
}

- (void)setProgressMy:(NSDictionary*)info {
    float newProgress = [[info objectForKey:@"Progress"] floatValue];
    [self updateProgress:newProgress];
}

-(void)requestOK:(ASIHTTPRequest *)request{
    [self updateRequestOK:request.responseStatusCode];
}

-(void)reqeustFail:(id )reqeust{//?需要p
    NSLog(@"uuid %@ requestFailed ",self.uuid);
    if([self.delegate respondsToSelector:@selector(app_state_change_6:)]){
        [self.delegate app_state_change_6:self.uuid];
    }
}

-(void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"%s",__FUNCTION__);
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask startCheckToSlow];
#endif
}


-(void)requestFinished:(ASIHTTPRequest *)request{
    if (isStart) {
        //判断responseStatusCode
        if (request.responseStatusCode>=200 && request.responseStatusCode<300) {
            [self requestOK:request];
        }
        else {
            //删除文件
            [[NSFileManager defaultManager]removeItemAtPath:self.saveRootPath error:nil];
            [self reqeustFail:request];
        }
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    
}

-(void)requestFailed:(ASIHTTPRequest *)request{
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask stopCheckToSlow];
#endif
    [self reqeustFail:request];
}
@end
