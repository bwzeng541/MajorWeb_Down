//
//  MajorPreview.m
//  WatchApp
//
//  Created by zengbiwang on 2017/12/22.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "MajorPreview.h"
#import "WebViewBase.h"
#import "VideoUrlHandleNode.h"
#import "MajorThumbnail.h"
#import "AppDelegate.h"
#define PipRStryTimes 2
@interface MajorPreview()<MajorThumbnailDelegate>
@property(assign)int indexPos;
@property(assign)BOOL isPostWeb47;
@property(assign)BOOL isShowWeb;
@property(assign)BOOL isVideoFind;
@property(strong)WebViewBase *webParse;
@property(strong)MajorThumbnail *majorThumbnail;
@property(strong)VideoUrlHandleNode *videoUrlNode;
@property(copy)NSString *url;
@property(copy)NSString *html;
@property(assign)int restryTime;
@property(assign)BOOL isAutoPlayer;
@property(assign)BOOL isAddWebVideo;
@property(assign)BOOL isMedia;
@property(copy)NSString* testVideoUrl;
@property(copy)NSString* title;

@end
@implementation MajorPreview

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithUrl:(NSString*)url html:(NSString*)html  frame:(CGRect)frame isShowWeb:(BOOL)isShowWeb index:(int)index isAddWebVideo:(BOOL)isAddWebVideo isAutoPlayer:(BOOL)isAutoPlayer isMedia:(BOOL)isMedia showTitle:(NSString*)title {
    self = [super initWithFrame:frame];
    NSLog(@"MajorPreview url = %@",url);
    self.isAddWebVideo = isAddWebVideo;
    self.indexPos = index;
    self.isMedia = isMedia;
    self.title = title;
    self.url = url;
    self.html = html;
    self.isShowWeb = isShowWeb;
    self.isCanTestVideoPlay = true;
    [self initWebParse];
    self.backgroundColor = [UIColor blackColor];
    return self;
}

-(void)initWebParse{
    if (!self.isAddWebVideo)
    {
        if (!self.webParse)
        {
            self.webParse = [[WebViewBase alloc]initWithUrl:self.url html:self.html showName:@"" isShowFailMsg:false hidenParentView:nil];
            self.webParse.isCanShowWaitView = false;
        }
    }
}

-(int)getIndexPos{
    return self.indexPos;
}

-(void)pipePreFail
{
    NSLog(@"MajorPreview faild = %@",_url);
    if ([self.delegate respondsToSelector:@selector(pipePreFail:)]) {
        [self.delegate pipePreFail:self];
    }
    else
    {
    }
}

-(void)pipePreShortSuccess{
    if ([self.delegate respondsToSelector:@selector(pipePreShortSuccess:)]) {
        [self.delegate pipePreShortSuccess:self];
    }
}

-(void)pipePreSuccess:(BOOL)isFroaceAuto
{
    [YSCHUDManager hideHUDOnView:self animated:NO];
    if ([self.delegate respondsToSelector:@selector(pipePreSuccess:)]) {
        [self.delegate pipePreSuccess:self];
    }
    if ((isFroaceAuto || self.isAutoPlayer) && [self.delegate respondsToSelector:@selector(pipeAutoPlayer:)]) {//需要自动播放
        [self.delegate pipeAutoPlayer:self];
    }
}

-(void)pipePlayFromWebSuccess:(id)object{
    if ([self.delegate respondsToSelector:@selector(pipePlayFromWebSuccess:)]) {
        [self.delegate pipePlayFromWebSuccess:self];
    }
}

-(BOOL)pipeIsMute{
    if (!self.isCanTestVideoPlay) {//
        return true;
    }
    if ([self.delegate respondsToSelector:@selector(pipeIsMute:)])
        return [self.delegate pipeIsMute:self];
    return true;
}

-(void)pipeClickPlay{
    if ([self.delegate respondsToSelector:@selector(pipeClickPlay:)])
         [self.delegate pipeClickPlay:self];
}

-(NSString*)getRealVideoUrl{
    return self.majorThumbnail.videoUrl?self.majorThumbnail.videoUrl:self.testVideoUrl;
}

-(void)setIsCanTestVideoPlay:(BOOL)isCanTestVideoPlay{
    _isCanTestVideoPlay = isCanTestVideoPlay;
    if (!isCanTestVideoPlay) {
        [self.majorThumbnail updateMuteState];
    }
}

-(id<ZFPlayerMediaPlayback>)getZFAVPlayerInterface{
   id<ZFPlayerMediaPlayback> outRet = [self.majorThumbnail getZFAVPlayerInterface];
    [self.majorThumbnail setZFAVPlayerInterfaceNil];
    return outRet;
}

-(id<IJKMediaPlayback>)getPlayInterface
{
     id<IJKMediaPlayback> outRet = [self.majorThumbnail getPlayInterface];
    [self.majorThumbnail setPlayInterfaceNil];
    return outRet;
}

-(void)delayStart:(NSInteger)pos delay:(NSInteger)delay{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
    [self performSelector:@selector(start) withObject:nil afterDelay:pos*delay];
}

-(void)start{
    if (!self.isMedia) {
        if (!self.isAddWebVideo){
            [self initWebParse];
            [YSCHUDManager showHUDOnView:self message:self.title];
            __weak typeof(self) weakSelf = self;
            [self.webParse start];
             self.webParse.msgBlock = ^(NSString *videoUrl) {
                [weakSelf parse:videoUrl];
            };
        }
        else{
            [self postNewUrl:@"majorWebFixBug"];
        }
    }
    else{
        [self postNewUrl:self.url];
    }
    self.restryTime++;
}

-(void)parse:(NSString*)videoUrl
{
    if(self.isPostWeb47)return;
    self.isPostWeb47 = true;
    NSString *postUrl= videoUrl;
    if ([postUrl length]<5) {
        if (self.restryTime < PipRStryTimes) {
            [self stop];
            [self start];
            NSLog(@"self.restryTime = %d",self.restryTime);
        }
        else {
            [self cleanAllWeb];
            [self pipePreFail];
            NSLog(@"pipePreFail = %d",self.restryTime);
        }
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self.webParse chaoshichuli];
    self.videoUrlNode = [[VideoUrlHandleNode alloc]init];
    [self.videoUrlNode startJs:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VideoUrlHandleNode" ofType:@"js"] encoding:NSUTF8StringEncoding error:NULL] videoUrl:postUrl finishBlock:^(id url) {
        [weakSelf postNewUrl:url];
    }];
}



-(void)postNewUrl:(NSString*)url
{
    [self cleanAllWeb];
    if (url.length < 5) {
        return;
    }
    if (!self.isCanTestVideoPlay) {//
        self.testVideoUrl = url;
        if ([self.delegate respondsToSelector:@selector(pipeRevicePlayUrl:)]) {
            [self.delegate pipeRevicePlayUrl:self];
        }
        NSLog(@"create self.isCanTestVideoPlay");
        return;
    }
    if (!self.majorThumbnail) {
        NSLog(@"create self.majorThumbnail");
        CGSize size = self.bounds.size;
        NSComparisonResult ret = [url compare:@"majorWebFixBug"];
        self.majorThumbnail = [[MajorThumbnail alloc]initWith:self.url videoUrl:url title:self.title frame:CGRectMake(2, 2, size.width-4, size.height-4) isAddWebVideo:ret==NSOrderedSame?true:false delegate:self];
        self.majorThumbnail.isShowWeb = self.isShowWeb;
        [self addSubview:self.majorThumbnail];
    }
}

-(void)cleanAllWeb{
    [self.videoUrlNode clearJs];
    self.videoUrlNode = nil;
    [self.webParse cleanWebView];
    [self.webParse stop];
    self.webParse = nil;
}

-(void)stop{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
    [YSCHUDManager hideHUDOnView:self animated:NO];
    [self.majorThumbnail stop];
    [self cleanAllWeb];
    RemoveViewAndSetNil(self.majorThumbnail);
 }

@end
