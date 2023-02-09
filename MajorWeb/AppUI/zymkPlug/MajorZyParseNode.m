//
//  MajorZyParseNode.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/10.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZyParseNode.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"
#import "AppDelegate.h"
#import "YSCHUDManager.h"
@interface MajorZyParseNode()<WebCoreManagerDelegate>
@property(strong,nonatomic)MajorWebView *webView;
@property(strong,nonatomic)NSTimer*delayTimer;
@end

@implementation MajorZyParseNode

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)start:(NSString*)url{
    self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
    self.webView.frame = CGRectMake(0, 20000, 100, 100);
    [GetAppDelegate.getRootCtrlView addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(faild) userInfo:nil repeats:YES];
    [YSCHUDManager showHUDOnKeyWindowWithMesage:@"loading..."];
}

-(void)faild{
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    [self stop];
    [self.delegate praseResultFalid:nil];
}

-(void)stop{
    [YSCHUDManager hideHUDOnKeyWindow];
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.webView];
    RemoveViewAndSetNil(self.webView);
    
}

- (void)webCore_webViewLoadProgress:(float)progress{
     if (progress>0.5 && progress<=1) {//
        [self.webView evaluateJavaScript:@"__webjsNodePlug__.startCheckList();" completionHandler:nil];
    }
}

- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name compare:sendWebJsNodeMessageInfo]==NSOrderedSame)
    {
        [self.delegate praseResultSuccess:message.body];
    }
}

@end
