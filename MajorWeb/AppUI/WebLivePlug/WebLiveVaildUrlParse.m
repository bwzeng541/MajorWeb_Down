//
//  WebLiveVaildUrlParse.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebLiveVaildUrlParse.h"
#import "MajorPipeView.h"//修改这个类接口为通用类型
#import "AppDelegate.h"
#import "WebCoreManager.h"
#import "MajorWebView.h"
#import "MKNetworkKit.h"
#import "YSCHUDManager.h"
#import "MajorZyPlug.h"
#import "WebLivePlug.h"
@interface WebLiveVaildUrlParse ()<WebCoreManagerDelegate>
@property(nonatomic,strong)NSArray *htmlArray;
@property(nonatomic,strong)NSArray *titleArray;
@property(nonatomic,strong)MajorPipeView *pipePreView;
@property(nonatomic,strong)MajorWebView *parseWebView;
@property(nonatomic,strong)MKNetworkEngine *netWorkKit;
@property(nonatomic,strong)MKNetworkOperation* netWorkOperation;
@property(nonatomic,copy)NSString *jsHtml;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *title;
@end
@implementation WebLiveVaildUrlParse
+(WebLiveVaildUrlParse*)getInstance{
    static WebLiveVaildUrlParse *g = NULL;
    if (!g) {
        g = [[WebLiveVaildUrlParse alloc] init];
    }
    return g;
}

-(void)initVaildPlug{
    if (!self.parseWebView) {
        self.parseWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager] createWKWebViewWithUrl:nil isAutoSelected:NO delegate:self];
        self.parseWebView.frame = CGRectMake(0, 100000, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
        [GetAppDelegate.getRootCtrlView addSubview:self.parseWebView];
        NSString *commond = @"window.onload=function(){var jq=document.createElement(\"script\");jq.setAttribute(\"src\",\"https://code.jquery.com/jquery-3.1.1.min.js\");document.getElementsByTagName(\"head\")[0].appendChild(jq); };function exec(){document.write($(\"body\").get(0))};";
        WKUserScript * commondJS = [[WKUserScript alloc]
                                    initWithSource:commond
                                    injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
        
        [self.parseWebView.configuration.userContentController addUserScript:commondJS];
        [self.parseWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://softhome.oss-cn-hangzhou.aliyuncs.com/max/help/360.html"]]];
    }
}

-(void)startVaildParse:(NSArray*)htmlArray titleArray:(NSArray*)titleArray{
    self.htmlArray = htmlArray;
    self.titleArray = titleArray;
    [self showParesePipeView];
}

-(void)stopVaildParse{
    [self.pipePreView stop];
    RemoveViewAndSetNil(self.pipePreView);
    self.netWorkOperation = nil;
    self.netWorkKit = nil;
    self.jsHtml = nil;
    [YSCHUDManager hideHUDOnKeyWindow];
}

-(void)showParesePipeView{
    if (!self.pipePreView) {
        self.pipePreView = [[MajorPipeView alloc] initWithLiveFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) webaArray:self.htmlArray url:self.url titleArray:self.titleArray searchTitle:self.title];
        self.pipePreView.center = CGPointMake(MY_SCREEN_WIDTH/2, MY_SCREEN_HEIGHT/2);
        [GetAppDelegate.getRootCtrlView addSubview:self.pipePreView];
        [self.pipePreView start:nil];
        @weakify(self)
        self.pipePreView.closeBlock = ^{
            @strongify(self)
            [self playRromPipe:nil playerInterface:nil];
        };
        self.pipePreView.selectBlock = ^(NSString *videoUrl,NSString*htmlUrl,int selectIndex, id playerInterface,NSArray *videoUrlArray) {
            @strongify(self)
            [self playRromPipe:videoUrl playerInterface:playerInterface];
        };
        self.pipePreView.closeReOpenBlock = ^(NSString *url) {
            @strongify(self)
            [self stopAndOpen];
        };
        self.pipePreView.contentView.frame  = self.pipePreView.bounds;
        //136X53
        UIButton *btnS = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnS setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/addshoucang_t") forState:UIControlStateNormal];
        [btnS setFrame:CGRectMake(0, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-27, 68, 27)];
        [self.pipePreView addExtrentBtn:btnS];
        [btnS addTarget:self action:@selector(shouCan:) forControlEvents:UIControlEventTouchUpInside];

        btnS = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnS setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
        [btnS setFrame:CGRectMake(20, (GetAppDelegate.appStatusBarH+20), 20, 20)];
        [self.pipePreView addExtrentBtn:btnS];
        [btnS addTarget:self action:@selector(closePipe:) forControlEvents:UIControlEventTouchUpInside];
        self.pipePreView.collectionView.backgroundColor = [UIColor blackColor];
      //  addshoucang_t
    }
}

-(void)closePipe:(UIButton*)sender{
    [self.pipePreView stop];
    RemoveViewAndSetNil(self.pipePreView);
}

-(void)shouCan:(UIButton*)sender{
    if (self.url && self.title) {
        NSArray *array = @[@{@"url":self.url,@"name":self.title}];
        syncCartoonList(array, self.title,MajorDataSource);
        syncCartoonFavourite(self.title,MajorDataSource);
    }
}

-(void)stopAndOpen{
    [self.pipePreView stop];
    RemoveViewAndSetNil(self.pipePreView);
    [self showParesePipeView];
}

-(void)playRromPipe:(NSString*)videoUrl playerInterface:(id)playerInterface{
    if (playerInterface){
        [self dispostNotifi:true url:videoUrl playerInterface:playerInterface];
    }
    else if (videoUrl) {
        [self dispostNotifi:true url:videoUrl playerInterface:nil];
    }
    else{
        [self dispostNotifi:false url:@"" playerInterface:nil];
    }
}

-(void)dispostNotifi:(BOOL)isSuccess url:(NSString*)url playerInterface:(id)playerInterface{
    if (playerInterface) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateWebLiveVaildDesUrl" object:playerInterface];
    }
    else if ([url length]>10) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateWebLiveVaildDesUrl" object:url];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopVaildParse) object:nil];
    [self performSelector:@selector(stopVaildParse) withObject:nil afterDelay:0.016];
}

//解析播放通道
-(void)startWebChannel:(NSString*)webUrl title:(NSString*)title{
    if (!self.netWorkKit) {
        self.url = webUrl;
        self.title = title;
        [YSCHUDManager showHUDOnKeyWindow];
        self.netWorkKit = [[MKNetworkEngine alloc] init];
        __weak __typeof(self)weakSelf = self;
        self.netWorkOperation = [self.netWorkKit operationWithURLString:webUrl timeOut:3];
        [self.netWorkOperation addHeaders:@{@"User-Agent":IosMicroMessagerUserAnent}];
        [self.netWorkOperation onCompletion:^(MKNetworkOperation *completedOperation) {
            [weakSelf pareseResopne:completedOperation];
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
            [weakSelf pareseResopne:completedOperation];
        }];
        [self.netWorkKit enqueueOperation:self.netWorkOperation];
    }
}

-(void)pareseResopne:(MKNetworkOperation*)completedOperation{
    NSInteger code = completedOperation.HTTPStatusCode;
     if (code>=200 && code<=300) {
         self.jsHtml = completedOperation.responseString;
         self.netWorkOperation = nil;
         self.netWorkKit = nil;
         [self putHtmlIntoWeb:self.jsHtml];
    }
    else{
        [YSCHUDManager hideHUDOnKeyWindow];
        self.netWorkOperation = nil;
        self.netWorkKit = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"WebLiveFilterManagerFaild" object:self.title];
        [YSCHUDManager showHUDThenHideOnView:[UIApplication sharedApplication].keyWindow message:@"暂无此节目" afterDelay:1];
    }
}

-(void)putHtmlIntoWeb:(NSString*)html{
        if (html) {
            NSString *js = [NSString stringWithFormat:@"__webjsNodePlug__.getWebChanneInFoJs(\"%@\")",[self.jsHtml urlEncodedString]];
            __weak __typeof(self)weakSelf = self;
            [self.parseWebView evaluateJavaScript:js completionHandler:^(NSArray* ret, NSError * _Nullable error) {
                [YSCHUDManager hideHUDOnKeyWindow];
                if (ret.count>0) {
                    NSMutableArray *arrayHtml = [NSMutableArray arrayWithCapacity:1];
                    NSMutableArray *arrayTitle = [NSMutableArray arrayWithCapacity:1];
                    for (int i = 0; i < ret.count; i++) {
                        [arrayHtml addObject:[[ret objectAtIndex:i]objectForKey:@"html"]];
                        [arrayTitle addObject:[[ret objectAtIndex:i]objectForKey:@"name"]];
                    }
                    [weakSelf startVaildParse:arrayHtml titleArray:arrayTitle];
                }
                else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"WebLiveFilterManagerFaild" object:self.title];
                    [YSCHUDManager showHUDThenHideOnView:[UIApplication sharedApplication].keyWindow message:@"暂无此节目" afterDelay:2];
                }
            }];
        }
}
@end
