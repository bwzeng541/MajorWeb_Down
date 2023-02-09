//
//  WebUrlHandleNode.m
//  WatchApp
//
//  Created by zengbiwang on 2017/11/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "WebUrlHandleNode.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "MainMorePanel.h"
#import "JsServiceManager.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "MajorModeDefine.h"
@interface WebUrlHandleNode()<WKScriptMessageHandler,WKNavigationDelegate>
@property(nonatomic,strong)WKWebView *webView;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *parseApi;
@property(nonatomic,copy)WebUrlHandleNodeFinish finishBlock;
@property(nonatomic,copy)NSString *htmlBody;
@property(nonatomic,copy)NSString *sourceUrl;
@end
@implementation WebUrlHandleNode

-(void)dealloc{
    self.url = nil;
    self.parseApi = nil;
    self.htmlBody = nil;
    self.sourceUrl = nil;
}
-(void)startJs:(NSString*)strJs url:(NSString*)url parseApi:(NSString*)paresApi htmlBody:(NSString*)htmlBody finishBlock:(WebUrlHandleNodeFinish)block{
    self.url =url;
    self.parseApi = paresApi;
    self.finishBlock = block;
    htmlBody = [htmlBody stringByReplacingOccurrencesOfString:@" " withString:@""];
    htmlBody = [htmlBody stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    htmlBody = [htmlBody stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    self.htmlBody = htmlBody;
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
    NSArray *array = [MainMorePanel getInstance].morePanel.apiUrlArray;
    NSMutableString *apiStr = [NSMutableString string];
    for (int i = 0; i < array.count; i++) {
        [apiStr appendString:((searchWebInfo*)[array objectAtIndex:i]).url];
        [apiStr appendString:@","];
    }
    NSString *str = [NSString stringWithFormat:@"webUrlHandle(\"%@\",\"%@\",\"%@\",\"%@\")",self.url,[self.parseApi urlEncodedString],[self.htmlBody urlEncodedString],apiStr];
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
