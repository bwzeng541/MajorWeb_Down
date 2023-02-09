//
//  Url47ChangeNode.m
//  WatchApp
//
//  Created by zengbiwang on 2017/4/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "Url47ChangeNode.h"
#import "ReactiveCocoa.h"
#import "AppDelegate.h"
#include "NSTimer+BlocksKit.h"
#import <WebKit/WebKit.h>
#import "MajorSchemeHelper.h"
#import "BeatifyChangeToPc.h"
#if (UserWKWebView==1)
#define UIWebView WKWebView
#endif

#define ClearPCWebView     [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];[self.webView stopLoading];  RemoveViewAndSetNil(self.webView); \
;

@interface Url47ChangeNode()<WKNavigationDelegate>{
    float progressValue;
    BOOL  isevaluateJs;
}
@property (nonatomic, strong) Url47ChangeNodeSuccess successblock;
@property (nonatomic, strong) Url47ChangeNodeFaild failblock;
@property(nonatomic,strong)NSTimer *pcRequestTimer;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,copy)NSString *changeUrl;
@property(nonatomic,strong)BeatifyChangeToPc *beatifyChangeNode;
@end
@implementation Url47ChangeNode


#pragma mark -- 进度
-(void)dealloc{
    ClearPCWebView
    NSLog(@"%s",__FUNCTION__);
    [self.beatifyChangeNode unInitAsset];
    self.beatifyChangeNode = nil;
    
}

-(void)start:(NSString*)url faildBlock:(Url47ChangeNodeFaild)fail Success:(Url47ChangeNodeSuccess)success{
    __weak __typeof(self)weakSelf = self;
    self.beatifyChangeNode = [[BeatifyChangeToPc alloc]init];
    self.successblock = success;
    [self.beatifyChangeNode startWithAsset:url callBack:^(NSString * _Nonnull realAsset) {
        weakSelf.successblock(realAsset);
    }];
    return;
    isevaluateJs = false;
    progressValue = 0;
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20000, 320, 400)];
    self.webView.navigationDelegate = self;
    if (@available(iOS 9.0, *)) {
        self.webView.customUserAgent = PCUserAgent;
    } else {
        // Fallback on earlier versions
    }
    [GetAppDelegate.getRootCtrlView addSubview:self.webView];
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    self.failblock = fail;self.successblock = success;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    return;
    @weakify(self)
    self.pcRequestTimer = [NSTimer bk_scheduledTimerWithTimeInterval:10 block:^(NSTimer *timer) {
        @strongify(self)
        self.pcRequestTimer = nil;
        if (self.changeUrl&&self.successblock) {
            self.successblock(self.changeUrl);
        }
        else{
            self.failblock();
        }
        self.failblock = nil;
        self.successblock = nil;
    } repeats:NO];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self isOver:webView];
}


-(void)isOver:(UIWebView*)webView{
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSLog(@"userAgent :%@", result);
    }];
    if (progressValue>=1 && !isevaluateJs) {
        self->isevaluateJs = true;
     //   NSString *currentURL = [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
        [self.webView evaluateJavaScript:@"document.location.href" completionHandler:^(id reulst, NSError *  error) {
                [self.pcRequestTimer invalidate];self.pcRequestTimer = nil;
                self.successblock(self.changeUrl?self.changeUrl:reulst);
                self.failblock = nil;
                self.successblock = nil;
                ClearPCWebView
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        progressValue = progress;
        [self isOver:self.webView];
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"webViewWebContentProcessDidTerminate WebViewBase");
    [self.webView reload];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
}



- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:
(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = url.scheme;
    if ([scheme isEqualToString:@"http"] ||
        [scheme isEqualToString:@"https"]) {
        if([[MajorSchemeHelper sharedHelper] isAppStoreLink:url]){
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    else{
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if (!navigationAction.targetFrame.isMainFrame) {
        [self.webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    if (([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/' OR SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString])) {
    } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {// For any other schema but not `https`、`http` and `file`.
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            [[UIApplication sharedApplication] openURL:components.URL];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if(!navigationAction.targetFrame)//在新标签里面打开
    {
        
        decisionHandler(WKNavigationActionPolicyCancel);//20180605 WKNavigationActionPolicyCancel->WKNavigationActionPolicyAllow
        [webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
        return;
    }
     decisionHandler(WKNavigationActionPolicyAllow+2);
}


/*- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:
(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString isEqualToString:@"about:blank"] || ([url.absoluteString rangeOfString:@"app/register_business"].location!=NSNotFound)) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    NSLog(@"url47ChangeNode Url = %@",url);
    if (url) {
        NSString *scheme = url.scheme;
        if (scheme) {
            if ([scheme isEqualToString:@"http"] ||
                [scheme isEqualToString:@"https"]) {
                if ([[MajorSchemeHelper sharedHelper] isAppStoreLink:url])
                {
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
                else {
                    if(!navigationAction.targetFrame)
                    {
                        [webView loadRequest:[NSURLRequest requestWithURL:url]];
                        decisionHandler(WKNavigationActionPolicyCancel);
                        return;
                    }
                    self.changeUrl = url.absoluteString;
                    decisionHandler(WKNavigationActionPolicyAllow+GetAppDelegate.appJumpValue);
                }
            }
            else if ([scheme isEqualToString:@"tel"]){
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else if ([scheme isEqualToString:AppTeShuPre]) {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else{
                [self openURL:url
                      success:^{
                          decisionHandler(WKNavigationActionPolicyCancel);
                      }
                      failure:^{
                          decisionHandler(WKNavigationActionPolicyCancel);
                      }];
            }
        }
        else{
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
*/
- (void)openURL:(NSURL *)url
        success:(void (^)())success
        failure:(void (^)())failure {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        success();
    } else {
        failure();
    }
}

@end
