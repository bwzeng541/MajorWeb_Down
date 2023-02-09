//
//  RemoveMarkWeb.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/25.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "RemoveMarkWeb.h"
#import "MajorWebView.h"
#import "JsServiceManager.h"
//操作类型
typedef enum RemoveMarkOptionType{
    Remove_Mark_Loading,//加载网页
    Remove_Mark_StartClick,//检查网页是否有对应的项，然后点击click事件
    Remove_Mark_Result//检查超时结果
}_RemoveMarkOptionType;
@interface RemoveMarkWeb()
@property(copy,nonatomic)NSString* searchUrl;
@property(assign,nonatomic)_RemoveMarkOptionType actionType;
@end
@implementation RemoveMarkWeb

-(id)initWithUrl:(NSString*)url searchUrl:(NSString*)searchUrl waitView:(UIView*)waitView{
    self = [super initWithUrl:url html:nil showName:@"" isShowFailMsg:false hidenParentView:waitView];
    self.searchUrl = searchUrl;
    return self;
}

-(void)startDelay:(float)delayTime{
    [self performSelector:@selector(start) withObject:nil afterDelay:delayTime];
}

-(void)stop{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
    [super stop];
}

-(void)InitExtendWebConfig{
    [self.checkVideoTimer invalidate];
    [self.webViewLoadFinshTimer invalidate];
    self.checkVideoTimer = nil;
    self.webViewLoadFinshTimer = nil;
    
    self.actionType = Remove_Mark_Loading;
    NSString *commond =  nil;
    if ([[JsServiceManager getInstance]getJsContent:@"RemoveMark_new"]) {
        commond = [[JsServiceManager getInstance]getJsContent:@"RemoveMark_new"];
    }
    if (commond) {
        WKUserScript * commondJS = [[WKUserScript alloc]
                                    initWithSource:commond
                                    injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
        
        [self.webView.configuration.userContentController addUserScript:commondJS];
    }
//    NSString *commond1 = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"百度网盘直接user" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
//    WKUserScript * commondJS1 = [[WKUserScript alloc]
//                                initWithSource:commond1
//                                injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];
//    [self.webView.configuration.userContentController addUserScript:commondJS1];

    [self.webView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)self.webView).callBackDelegate name:@"sendMessageSetUrlSuccess"];
    [self.webView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)self.webView).callBackDelegate name:@"sendMessageClickSuccess"];
    [self.webView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)self.webView).callBackDelegate name:@"sendMessageLog"];
    [self.webView setCustomUserAgent:PCUserAgent];
    self.webView.frame = CGRectMake(0, 100000, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
}

-(void)UnintExtendWebConfig{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayClick) object:nil];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendMessageSetUrlSuccess"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendMessageClickSuccess"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendMessageLog"];

    
}

- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
}

- (void)webCore_webViewLoadProgress:(float)progress
{
    if(progress>0.5){
        if (self.actionType == Remove_Mark_Loading) {
            NSString *js = [NSString stringWithFormat:@"window.__removeMarkPlug__.startCheckInput('%@')",self.searchUrl];
            [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                NSLog(@"errrpr = %@",[error description]);
            }];
        }
        else if (self.actionType==Remove_Mark_StartClick){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayClick)  object:nil];
            [self performSelector:@selector(delayClick) withObject:nil afterDelay:0.2];
        }
    }
    if (progress>=1) {
    }
}

- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message;
{
    if([message.name compare:@"sendMessageSetUrlSuccess"]==NSOrderedSame)
    {
        if (self.actionType != Remove_Mark_StartClick) {
            self.actionType = Remove_Mark_StartClick;
            [self performSelector:@selector(delayClick) withObject:nil afterDelay:0.5];
        }
    }
    if([message.name compare:@"sendMessageClickSuccess"]==NSOrderedSame){
        if (self.actionType != Remove_Mark_Result) {//referrer videoUrl;
            self.actionType = Remove_Mark_Result;
           NSString *referrer = [message.body objectForKey:@"referrer"];
           NSString *videoUrl = [message.body objectForKey:@"videoUrl"];
            NSLog(@"sendMessageClickSuccess %@  %@",referrer,videoUrl);
            if (self.removeMarkMsgBlock) {
                self.removeMarkMsgBlock(videoUrl, referrer);
            }
        }
    }
    if([message.name compare:@"sendMessageLog"]==NSOrderedSame){
        NSLog(@"sendMessageLog  %@",message.body);
    }
    
}


-(void)delayClick
{
    NSString *js = [NSString stringWithFormat:@"window.__removeMarkPlug__.startClick()"];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        NSLog(@"delayClick error = %@",[error description]);
    }];
}
@end
