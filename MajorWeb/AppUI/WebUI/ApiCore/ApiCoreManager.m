//
//  ApiCoreManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "ApiCoreManager.h"
#import "MainMorePanel.h"
#import "Web47ViewNode.h"
#import "MajorPipeView.h"
#import "AppDelegate.h"
#import "MajorModeDefine.h"
@interface ApiCoreManager(){
    Web47ViewNode *_web47Node;
}
@property(nonatomic,strong)MajorPipeView *pipePreView;
@property(nonatomic,strong)NSString *oldUserAgent;
@property(nonatomic,strong)WebConfigItem *webConfig;
@property(weak,nonatomic)WKWebView *apiWebView;
@property(copy,nonatomic)NSString *searchTitle;
@property(copy,nonatomic)NSString *medialUrl;
@property(copy,nonatomic)NSString *htmlUrl;
@property(copy,nonatomic)NSString *realUrl;
@property(copy,nonatomic)NSArray  *currentApiArray;
@end

@implementation ApiCoreManager
+(ApiCoreManager*)getInstace;{
    static ApiCoreManager *g = nil;
    if (!g) {
        g = [[ApiCoreManager alloc] init];
    }
    return g;
}

-(void)stopApiReqeust{
    [self.pipePreView stop];
    RemoveViewAndSetNil(self.pipePreView);
    [_web47Node stop];
    _web47Node = nil;
}

-(void)dispostNotifi:(BOOL)isSuccess url:(NSString*)url playerInterface:(id)playerInterface videoArray:(NSArray*)arrayVideoUrl{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopApiReqeust) object:nil];
    if (playerInterface) {
        self.pipePreView.center = CGPointMake(10000, 10000);//移到外面隐藏
        [self.pipePreView updateNotCreateThumbnail];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDesUrl" object:playerInterface];
        if (arrayVideoUrl) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateVideoArray" object:arrayVideoUrl];
        }//api需要保留30秒获取其它线路
        [self performSelector:@selector(stopApiReqeust) withObject:nil afterDelay:30];
        return;
    }
    else if ([url length]>10) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDesUrl" object:url];
    }
    [self performSelector:@selector(stopApiReqeust) withObject:nil afterDelay:0.016];
}

-(void)startApiReqeust:(WKWebView*)webView config:(WebConfigItem*)config searchTitle:(NSString*)title urlMedia:(NSString *)urlMedia{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopApiReqeust) object:nil];
    [self stopApiReqeust];
    if (GetAppDelegate.isProxyState) {
        return ;
    }
    self.apiWebView = webView;
    self.webConfig = config;
    self.searchTitle = title;
    self.medialUrl = urlMedia;
    @weakify(self)
    [self.apiWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        @strongify(self)
        self.oldUserAgent = ret;//
        NSString *vv = @"document.location.href;"; //@"function webUrlAndBody() \
        { \
        var v1 = document.location.href;\
        var v2 = document.documentElement.innerHTML;\
        var ret =new Array(v1,v2);\
        return ret;\
        }";
        [self.apiWebView evaluateJavaScript:vv completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            if (error) {
                if (self.completionBlock) {
                    self.completionBlock(false,@"" );
                }
                [self dispostNotifi:false url:@"" playerInterface:nil videoArray:nil];
            }
            else{
                [self.apiWebView evaluateJavaScript:@"webUrlAndBody()" completionHandler:^(id result, NSError *  error) {
                    self.currentApiArray = [[MainMorePanel getInstance] getApiArrayFromUrl:[result objectAtIndex:0]];
                    [self startParseSeconcd:result url:((searchWebInfo*)[self.currentApiArray objectAtIndex:0]).url showError:true];
                }];
            }
        }];
    }];
}

-(void)startParseSeconcd:(NSArray*)array url:(NSString*)url showError:(BOOL)showError{
    NSString *currentURL = [array objectAtIndex:0];
    NSString *scheme = [NSURL URLWithString:currentURL].scheme;
    if (!scheme) {
        scheme = @"http";
    }
    BOOL isforce47Node = true;
    //乐视特殊处理 http://m.le.com/vplay_28781046.html->http://www.le.com/ptv/vplay/28781046.html
    if (!self.webConfig.isCustom) {
        if ([self.webConfig.name compare:@"乐视"] == NSOrderedSame) {//乐视
            NSRange range = [currentURL rangeOfString:@"vplay_"];
            if (range.location != NSNotFound) {//替换
                isforce47Node = true;
                currentURL = [NSString stringWithFormat:@"%@://www.le.com/ptv/vplay/%@",scheme,[currentURL substringFromIndex:range.location+range.length]];
            }
        }
        else if ([self.webConfig.name compare:@"腾讯"] == NSOrderedSame){//腾讯
            NSRange range = [currentURL rangeOfString:@"m.v.qq.com"];
            if (range.location != NSNotFound) {//替换
                isforce47Node = true;
                currentURL = [NSString stringWithFormat:@"%@://%@",scheme,[currentURL substringFromIndex:range.location+2]];
            }
        }
    }
    else{
        if ([currentURL rangeOfString:@"le.com"].location != NSNotFound) {//乐视
            NSRange range = [currentURL rangeOfString:@"vplay_"];
            if (range.location != NSNotFound) {//替换
                isforce47Node = true;
                currentURL = [NSString stringWithFormat:@"%@://www.le.com/ptv/vplay/%@",scheme,[currentURL substringFromIndex:range.location+range.length]];
            }
        }
        else if ([currentURL rangeOfString:@"m.v.qq.com"].location != NSNotFound){//腾讯
            NSRange range = [currentURL rangeOfString:@"m.v.qq.com"];
            if (range.location != NSNotFound) {//替换
                isforce47Node = true;
                currentURL = [NSString stringWithFormat:@"%@://%@",scheme,[currentURL substringFromIndex:range.location+2]];
            }
        }
    }
    bool isUseApi = self.webConfig.isUseApi;
   
    _web47Node = [[Web47ViewNode alloc]initWithUrl:currentURL firstVideo:nil showName:@"测试" pareApihttp:url htmlBody: [array objectAtIndex:1] isShowFailMsg:showError forceUrl47Node:isforce47Node isDirectApi:isUseApi isBatch:isUseApi];

    _web47Node.isNoPcWeb = self.webConfig.isNoPcWeb;
    _web47Node.iosUserAnget = self.oldUserAgent;
    @weakify(self)
    [RACObserve(_web47Node, realUrl) subscribeNext:^(id x) {
        @strongify(self)
        if ([self->_web47Node.realUrl length]>10) {
            self.htmlUrl = self->_web47Node.htmlUrl;
            self.realUrl = self->_web47Node.realUrl;
            [self->_web47Node stop];
            self->_web47Node = nil;
            [self dispostNotifi:true url:self.realUrl playerInterface:nil videoArray:nil];
        }
    }];
    [RACObserve(_web47Node, isGoToBatchPip) subscribeNext:^(id x) {
        @strongify(self)
        if (self->_web47Node.isGoToBatchPip) {
            [self->_web47Node stop];
            [self showParesePipeView:self->_web47Node.htmlUrl];
            self->_web47Node = nil;
        }
    }];
    [_web47Node start];
}

-(void)showParesePipeView:(NSString*)url{
    if (!self.pipePreView) {
        NSArray *array = self.currentApiArray;
        self.pipePreView = [[MajorPipeView alloc] initWithFrame:CGRectMake(0, 0 , MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT) isFromSS:true arrayApi:array url:url webVideoUrl:self.medialUrl searchTitle:self.searchTitle];
        self.pipePreView.center = CGPointMake(MY_SCREEN_WIDTH/2, MY_SCREEN_HEIGHT/2);
        [GetAppDelegate.getRootCtrlView addSubview:self.pipePreView];
        [self.pipePreView start:nil];
        @weakify(self)
        self.pipePreView.closeBlock = ^{
            @strongify(self)
            [self playRromPipe:nil playerInterface:nil videoArray:nil];
        };
        self.pipePreView.selectBlock = ^(NSString *videoUrl,NSString*htmlUrl,int selectIndex, id playerInterface,NSArray *videoUrlArray) {
            @strongify(self)
            [self playRromPipe:videoUrl playerInterface:playerInterface videoArray:videoUrlArray];
        };
        self.pipePreView.closeReOpenBlock = ^(NSString *url) {
            @strongify(self)
            [self stopAndOpen:url];
        };
        
        self.pipePreView.contentView.frame  = self.pipePreView.bounds;
        //136X53
        UIButton *btnS = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnS setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
        [btnS setFrame:CGRectMake(GetAppDelegate.appStatusBarH+20, (GetAppDelegate.appStatusBarH+20), 30, 30)];
        [self.pipePreView addExtrentBtn:btnS];
        [btnS addTarget:self action:@selector(closePipe:) forControlEvents:UIControlEventTouchUpInside];
        self.pipePreView.collectionView.backgroundColor = [UIColor blackColor];
        //  addshoucang_t
        //self.pipePreView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    }
}

-(void)closePipe:(UIButton*)sender{
    [self.pipePreView stop];
    RemoveViewAndSetNil(self.pipePreView);
}

-(void)stopAndOpen:(NSString*)url{
    [self.pipePreView stop];
    RemoveViewAndSetNil(self.pipePreView);
    [self showParesePipeView:url];
}

-(void)playRromPipe:(NSString*)videoUrl playerInterface:(id)playerInterface videoArray:(NSArray*)arrayVideoUrl{
    if (playerInterface){
        [self dispostNotifi:true url:videoUrl playerInterface:playerInterface videoArray:arrayVideoUrl];
    }
    else if (videoUrl) {
        [self dispostNotifi:true url:videoUrl playerInterface:nil videoArray:nil];
    }
    else{
        [self dispostNotifi:false url:@"" playerInterface:nil videoArray:nil];
    }
}
@end
