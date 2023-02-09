//
//  WebCallNode.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebCallNodeDelegate<NSObject>
- (void)webCallNode_webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;
- (void)webCallNode_webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;
- (void)webCallNode_webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
- (void)webCallNode_webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler;
- (void)webCallNode_webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
- (WKWebView *)webCallNode_webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
- (void)webCallNode_webViewWebContentProcessDidTerminate:(WKWebView *)webView;
- (void)webCallNode_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
-(void)webCallNode_webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error;
- (void)webCallNode_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (BOOL)webCallNode_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)webCallNode_webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
- (void)webCallNode_webViewLoadProgress:(WKWebView *)webView progress:(float)progress;
- (void)webCallNode_webViewUrlChange:(WKWebView *)webView url:(NSString*)url;
- (void)webCallNode_webViewTitleChange:(WKWebView *)webView title:(NSString*)title;
//web pos消息给ui
- (void)webCallNode_userContentController:(WKWebView *)webView userContentController:(WKUserContentController *)userContentController
didReceiveScriptMessage:(WKScriptMessage *)message ;

////通过 openURL 打开，appstore ，或者第三方app

- (void)webCallNode_webViewOpenOtherAction:(WKWebView *)webView url:(NSURL*)url;
- (void)webCallNode_webViewOpenInAppStore:(WKWebView *)webView url:(NSURL*)url;
- (void)webCallNode_webViewOpenInCall:(WKWebView *)webView url:(NSURL*)url;

- (BOOL)webCallNode_webViewIsOpenInNewWeb:(WKWebView *)webView url:(NSURL*)url;


- (void)webCallNode_scrollViewDidScroll:(WKWebView *)webView scrollView:(UIScrollView *)scrollView;
- (void)webCallNode_scrollViewWillBeginDragging:(WKWebView *)webView scrollView:(UIScrollView *)scrollView;
- (void)webCallNode_scrollViewDidEndDragging:(WKWebView *)webView scrollView:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
-(void)webCallNode_updateWebToolBar:(WKWebView*)webView state:(BOOL)state;
@end

@interface WebCallNode : NSObject<UIScrollViewDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property(nonatomic,weak)id<WebCallNodeDelegate> delegate;
@property(nonatomic,weak)WKWebView *webView;



@end
