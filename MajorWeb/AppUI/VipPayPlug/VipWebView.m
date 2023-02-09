
//
//  VipWebView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/4.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VipWebView.h"
#import <WebKit/WebKit.h>
#import "JMDefine.h"
#import "AppDelegate.h"
@interface VipWebView()<WKNavigationDelegate,WKScriptMessageHandler>
@property(strong,nonatomic)UIProgressView *webProgressView;
@property(strong,nonatomic)WKWebView *webView;
@property(strong,nonatomic)UIButton *closeBtn;
@property(copy,nonatomic)void(^closeBlock)(void);
@property(copy,nonatomic)void(^buyBlock)(NSString *res);
@property(copy,nonatomic)void(^loginBlock)(NSString* resp);

@end
@implementation VipWebView

-(void)dealloc{
    
}

-(id)initWithFrame:(CGRect)frame url:(NSString*)url  buyBlock:(void(^)(NSString *res))buyBlock loginBlock:(void(^)(NSString* resp))loginBlock closeBlock:(void(^)(void))closeBlock{
    self = [super initWithFrame:frame];
    self.closeBlock = closeBlock;
    self.buyBlock = buyBlock;
    self.loginBlock = loginBlock;
    if(!self.webView){
        WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [[WKUserContentController alloc] init];
        [configuration.userContentController addScriptMessageHandler:self name:@"sendLoginNodeMessageInfo"];
        [configuration.userContentController addScriptMessageHandler:self name:@"sendPayNodeMessageInfo"];
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) configuration:configuration];
        self.webView.navigationDelegate = self;
        [self addSubview:self.webView];
        [self.webView addObserver:self
                       forKeyPath:@"estimatedProgress"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeBtn addTarget:self action:@selector(closeWeb:) forControlEvents:UIControlEventTouchUpInside];
        [self.closeBtn setImage:[UIImage imageNamed:@"AppMain.bundle/close_ad.png"] forState:UIControlStateNormal];
        [self.closeBtn setFrame:CGRectMake(GetAppDelegate.appStatusBarH, kStatusBarHeight, 35, 35)];
        [self addSubview:self.closeBtn];
        self.webProgressView = [[UIProgressView alloc]
                                initWithFrame:CGRectMake(0, kStatusBarHeight,
                                                         self.frame.size.width, 2)];
        self.webProgressView.progressTintColor =RGBCOLOR(255, 0, 0); // ProgressTintColor;
        self.webProgressView.trackTintColor = [UIColor blackColor];
        self.webProgressView.alpha = 1;
        [self addSubview:self.webProgressView];

    }
    return self;
}

-(void)removeFromSuperview{
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendLoginNodeMessageInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendPayNodeMessageInfo"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [super removeFromSuperview];
}

- (void)closeWeb:(UIButton*)sender{
    if(self.closeBlock){
        [self removeFromSuperview];
        self.closeBlock();
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }else {
            // 验证失败，取消本次验证
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:
(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"navigationAction url = %@",[navigationAction request]);
     NSURL *url =  navigationAction.request.URL;
    if ([[url scheme] isEqualToString:@"alipay"]) {
        [[UIApplication sharedApplication]openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{

}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"sendLoginNodeMessageInfo"]) {
        NSString *ret  = [message.body objectForKey:@"respone"];
        if (self.loginBlock) {
            self.loginBlock([ret stringByReplacingOccurrencesOfString:@"'" withString:@""]);
        }
     }
    else if ([message.name isEqualToString:@"sendPayNodeMessageInfo"]) {
        if (self.buyBlock) {
            NSString *ret  = [message.body objectForKey:@"respone"];
            self.buyBlock([ret stringByReplacingOccurrencesOfString:@"'" withString:@""]);
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        [self updateProcessbar:progress animated:YES];
    }
}

- (void)updateProcessbar:(float)progress animated:(BOOL)animated {
    if (progress == 1.0) {
        [self.webProgressView setProgress:progress animated:animated];
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.webProgressView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [self.webProgressView setProgress:0.0 animated:NO];
                             }
                         }];
    } else {
        if (self.webProgressView.alpha < 1.0) {
            self.webProgressView.alpha = 1.0;
        }
        [self.webProgressView setProgress:progress
                                 animated:(progress > self.webProgressView.progress) && animated];
    }
}
@end
