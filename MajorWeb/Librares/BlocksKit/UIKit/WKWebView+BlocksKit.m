//
//  UIWebView+BlocksKit.m
//  BlocksKit
//

#import "A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"
#import "WKWebView+BlocksKit.h"
#import "AppDelegate.h"
 #pragma mark Custom delegate

@interface A2DynamicWKWebViewDelegate : A2DynamicDelegate <WKNavigationDelegate>
@end

@implementation A2DynamicWKWebViewDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    printf("WKWebViewTest didStartProvisionalNavigation = %s\n",[[webView.URL absoluteString] UTF8String]);
    id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)])
		 [realDelegate webView:webView didStartProvisionalNavigation:navigation];

	void (^block)(WKWebView *,WKNavigation*) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(webView,navigation);

}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
	id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didCommitNavigation:)])
		[realDelegate webView:webView didCommitNavigation:navigation];

	void (^block)(WKWebView *,WKNavigation*) = [self blockImplementationForMethod:_cmd];
	if (block) block(webView,navigation);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
	id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didFinishNavigation:)])
		[realDelegate webView:webView didFinishNavigation:navigation];

	void (^block)(WKWebView *,WKNavigation*) = [self blockImplementationForMethod:_cmd];
	if (block) block(webView,navigation);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
	id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)])
		[realDelegate webView:webView didFailNavigation:navigation withError:error];

	void (^block)(WKWebView *,WKNavigation*, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block) block(webView,navigation,error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)])
        if (@available(iOS 9.0, *)) {
            [realDelegate webViewWebContentProcessDidTerminate:webView];
        } else {
            // Fallback on earlier versions
        }
    
    void (^block)(WKWebView *) = [self blockImplementationForMethod:_cmd];
    if (block) block(webView);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(WKWebViewDecisionHandler )decisionHandler
{
    printf("WKWebViewTest decidePolicyForNavigationAction = %s\n",[[navigationAction.request.URL absoluteString] UTF8String]);
    BOOL isExctDefualt = true;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]){
        [realDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        isExctDefualt = false;
    }
    void (^block)(WKWebView *,WKNavigationAction*,WKWebViewDecisionHandler) = [self blockImplementationForMethod:_cmd];
    if (block){
        isExctDefualt = false;
        block(webView,navigationAction,decisionHandler);
    }
    if (isExctDefualt) {
        decisionHandler(WKNavigationActionPolicyAllow+GetAppDelegate.appJumpValue);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(WKWebViewResponseHandler)decisionHandler{
    BOOL isExctDefualt = true;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]){
        [realDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        isExctDefualt = false;
    }
    void (^block)(WKWebView *,WKNavigationResponse*,WKWebViewResponseHandler) = [self blockImplementationForMethod:_cmd];
    if (block){
        isExctDefualt = false;
        block(webView,navigationResponse,decisionHandler);
    }
    if (isExctDefualt) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    id realDelegate = self.realDelegate;
     if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]){
        [realDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
     }
    void (^block)(WKWebView *,WKNavigation*) = [self blockImplementationForMethod:_cmd];
    if (block){
        block(webView,navigation);
     }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)])
        [realDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    
    void (^block)(WKWebView *,WKNavigation*,NSError*) = [self blockImplementationForMethod:_cmd];
    if (block){
        block(webView,navigation,error);
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(WKWebViewAuthChallengeHander)completionHandler{
    BOOL isExctDefualt = true;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]){
        [realDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        isExctDefualt = false;
    }
    void (^block)(WKWebView *,NSURLAuthenticationChallenge*,WKWebViewAuthChallengeHander) = [self blockImplementationForMethod:_cmd];
    if (block){
        block(webView,challenge,completionHandler);
        isExctDefualt = false;
    }
    if (isExctDefualt) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end

#pragma mark Category

@implementation WKWebView (BlocksKit)
//
@dynamic bk_shouldStartLoadBlock, bk_didStartLoadBlock, bk_didFinishLoadBlock, bk_didFinishWithErrorBlock,bk_didProcessDidTerminateBlock,bk_didDecidePolicyForNavigationAction,bk_decidePolicyForNavigationResponse,bk_didReceiveServerRedirectForProvisionalNavigation,bk_didFailProvisionalNavigation,bk_didReceiveAuthenticationChallenge;

+ (void)load
{
	@autoreleasepool {
        [self bk_registerDynamicDelegateUesrNamed:@"navigationDelegate" suffix:@"WKNavigation"];
        [self bk_linkDelegateUesrMethods:@{
@"bk_didDecidePolicyForNavigationAction":@"webView:decidePolicyForNavigationAction:decisionHandler:",
            @"bk_shouldStartLoadBlock": @"webView:didStartProvisionalNavigation:",
            @"bk_didStartLoadBlock": @"webView:didCommitNavigation:",
            @"bk_didFinishLoadBlock": @"webView:didFinishNavigation:",
            @"bk_didFinishWithErrorBlock": @"webView:didFailNavigation:withError:",
            @"bk_didProcessDidTerminateBlock":@"webViewWebContentProcessDidTerminate:",
            @"bk_decidePolicyForNavigationResponse":@"webView:decidePolicyForNavigationResponse:decisionHandler",
            @"bk_didReceiveServerRedirectForProvisionalNavigation":@"webView:didReceiveServerRedirectForProvisionalNavigation:",
            @"bk_didFailProvisionalNavigation":@"webView:didFailProvisionalNavigation:withError:",
            @"bk_didReceiveAuthenticationChallenge":@"webView:didReceiveAuthenticationChallenge:completionHandler:"
            } suffix:@"WKNavigation"];
    }
}

@end
