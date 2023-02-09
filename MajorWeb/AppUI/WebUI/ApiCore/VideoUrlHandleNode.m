//
//  WebUrlHandleNode.m
//  WatchApp
//
//  Created by zengbiwang on 2017/11/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "VideoUrlHandleNode.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "JsServiceManager.h"
#import "NSString+MKNetworkKitAdditions.h"
@interface VideoUrlHandleNode()<WKScriptMessageHandler,WKNavigationDelegate>
@property(nonatomic,strong)WKWebView *webView;
 @property(nonatomic,copy)VideoUrlHandleNodeFinish finishBlock;
@property(nonatomic,copy)NSString *htmlBody;
@end
@implementation VideoUrlHandleNode

-(void)dealloc{
      self.htmlBody = nil;
}

-(void)startJs:(NSString*)strJs videoUrl:(NSString*)videoUrl finishBlock:(VideoUrlHandleNodeFinish)block{
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0 )return;
    self.finishBlock = block;
    self.htmlBody = videoUrl;
    if ([[JsServiceManager getInstance]getJsContent:NSStringFromClass([self class])]) {
        strJs = [[JsServiceManager getInstance]getJsContent:NSStringFromClass([self class])];
    }
    WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController =
    [[WKUserContentController alloc] init];
    configuration.requiresUserActionForMediaPlayback = NO;
    WKUserScript * videoScript = [[WKUserScript alloc]
                                  initWithSource:strJs
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:videoScript];
    [configuration.userContentController
     addScriptMessageHandler:self
     name:@"sendWebJsHandelMessageInfo"];
    self.webView  = [[WKWebView alloc]initWithFrame:CGRectMake(0,20000,320,200) configuration:configuration];
    self.webView.navigationDelegate = self;
    [GetAppDelegate.getRootCtrlView addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/test" ofType:@"html"]]]];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSString *str = [NSString stringWithFormat:@"videoUrlHandle(\"%@\")",[self.htmlBody urlEncodedString]];
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        NSLog(@"ret = %@ error= %@",ret,[error debugDescription]);
        [weakSelf finishUrl:ret];
    }];
}

-(void)finishUrl:(NSString*)url{
    if (self.finishBlock) {
        self.finishBlock(url);
    }
}

-(void)clearJs{
    self.finishBlock = nil;
     [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendWebJsHandelMessageInfo"];
    [self.webView.configuration.userContentController removeAllUserScripts];
    RemoveViewAndSetNil(self.webView)
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"message.body : %@ \nmessage.name:%@", message.body, message.name);
}
@end
