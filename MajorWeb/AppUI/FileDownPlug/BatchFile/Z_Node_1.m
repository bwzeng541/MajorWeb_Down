//
//  Z_Node_1.m
//  WatchApp
//
//  Created by zengbiwang on 2018/5/3.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "Z_Node_1.h"
#import "RecordUrlToUUID.h"
NSString* const ForceExitDownZ_Node_Flag = @"ForceExitDownZ_Node_Flag";

@interface Z_Node_1()
@property(copy)NSString *parma0;
@property(copy)NSString *parma1;
@property(strong)WebViewBase *webBase;
@property(strong)NSTimer *delayTimer;//
@property(assign)BOOL isGetInfo;
@property(copy)NSString *_UUIDPp;
@property(copy)NSString *_UUID;
@property(copy)NSString *_title;
@property(copy)NSString *exitCode;
@end
@implementation Z_Node_1

-(void)dealloc{
    self._UUID = nil;self._UUIDPp = nil;
    self.parma1 = nil;self.parma0 = nil;
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithParam0:(NSString*)pamar0  pamar1:(NSString*)pamar1 pamar2:(NSString*)pamar{
    self = [super init];
    if(!pamar0){
       pamar0 =  [[RecordUrlToUUID getInstance] urlFromKey:pamar];
      pamar1 =  [[RecordUrlToUUID getInstance] titleFromKey:pamar];
    }
    self.parma0 = pamar0;
    self.parma1 = pamar1;
    self._UUID =  pamar;
    return self;
}

-(void)start{
    if (self._UUIDPp) {
        [self excte];
        return;
    }
    if (!self.webBase ) {
        self.isGetInfo = false;
        self.webBase = [[WebViewBase alloc]initWithUrl:self.parma0 html:nil showName:@"" isShowFailMsg:NO hidenParentView:nil];
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkChaoshi:) userInfo:nil repeats:NO];
        self.webBase.isCanShowWaitView = false;
        [self.webBase start];
        __weak typeof(self)weakSelf = self;
        self.webBase.msgBlock = ^(NSString *videoUrl) {
            [weakSelf parse:videoUrl];
        };
    }
}

-(void)parse:(NSString*)videoUrl
{
    if (self.isGetInfo) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self.webBase getWebTitle:^(NSString *title) {
        [weakSelf postVideoAndTitle:videoUrl title:title];
    }];
}

-(void)postVideoAndTitle:(NSString*)videoUrl title:(NSString*)title{
    NSString *postUrl= videoUrl;
    if ([postUrl length]>5) {
        self._title = title;
        self.isGetInfo = true;
        self._UUIDPp = postUrl;
        [self excte];
    }
}

-(void)checkChaoshi:(NSTimer *)timer{
    if (self.delayTimer) {
        self._UUIDPp = nil;
        [self excte];
    }

}

-(void)stopInMainthread{
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    [self.webBase cleanWebView];
    self.webBase = nil;
}

-(void)stop{
    if ([NSThread isMainThread]) {
        self.exitCode = nil;
        [self stopInMainthread];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.exitCode = ForceExitDownZ_Node_Flag;
            [self stopInMainthread];
        });
    }
}

-(void)z_node_1_clearAndKill{
    self.block = nil;
    [self stop];
}

-(void)excte{
    [self stop];
    if (self.block) {
        if (!self.exitCode) {
            self.block(self._UUIDPp,self._UUID,self.parma1,self._title);
        }
        else{
            self.block(self._UUIDPp,self.exitCode,self.parma1,self._title);
        }
    }
}
@end
