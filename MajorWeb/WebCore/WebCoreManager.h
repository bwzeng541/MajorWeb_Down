//
//  WebCoreManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
//创建wkwebview，js,等 ,以及处理wkwebview回调,操作js等
//ctrl->createWKWebViewWithUrl创建多个url，当前操作的webView通过updateUseWKWebview更新
@protocol WebCoreManagerDelegate<NSObject>
@optional
- (void)webCore_webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;
- (void)webCore_webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler;
- (void)webCore_webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
- (WKWebView *)webCore_webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
- (void)webCore_webViewWebContentProcessDidTerminate:(WKWebView *)webView;
- (void)webCore_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
-(void)webCore_webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error;
- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (BOOL)webCore_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)webCore_webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
- (void)webCore_webViewLoadProgress:(float)progress;
- (void)webCore_webViewUrlChange:(NSString*)url;
- (void)webCore_webViewTitleChange:(NSString*)title;
//web pos消息给ui
- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message;

//通过 openURL 打开，appstore ，或者第三方app
- (void)webCore_webViewOpenOtherAction:(NSURL*)url;
- (void)webCore_webViewOpenInAppStore:(NSURL*)url;
- (void)webCore_webViewOpenInCall:(NSURL*)url;

- (BOOL)webCore_webViewIsOpenInNewWeb:(NSURL*)url;

#pragma mark 滚动菜单
- (void)webCore_toolBarState:(BOOL)isHidden;
@end

@interface WebCoreManager : NSObject
@property(nonatomic,assign)BOOL isUpateJsChange;
+(WebCoreManager*)getInstanceWebCoreManager;
@property(nonatomic,weak)id<WebCoreManagerDelegate>delegate;
-(WKWebView*)createWKWebViewWithUrl:(NSString*)url isAutoSelected:(BOOL)isAutoSelected delegate:(id<WebCoreManagerDelegate>)uiCallBackDelegate;
-(void)destoryWKWebView:(WKWebView*)webView;
-(void)updateUseWKWebview:(WKWebView*)webView;
-(void)updateRuleListState:(BOOL)isUse webView:(WKWebView*)webView url:(NSString*)url;
-(void)updateVideoPlayMode:(WKWebView*)webView isSuspensionMode:(BOOL)isSuspensionMode;
//js部分
- (void)evaluateJavaScript:(WKWebView*)webView jsContent:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

-(void)initRuleList:(void (^_Nullable)( BOOL succeeded))completionHandler;

-(void)updateSendWebJsNodeMessageInfo;
-(void)updateAdBlock;
-(void)reInitAdblock;
@end


@interface WebCoreManager(AdBlockPlug)
-(void)startCompileAdPlug;
@end
