//
//  UIWebView+BlocksKit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
/** Block callbacks for UIWebView.

 @warning UIWebView is only available on a platform with UIKit.
*/

typedef void (^WKWebViewDecisionHandler)(WKNavigationActionPolicy actionType);
typedef void (^WKWebViewResponseHandler)(WKNavigationResponsePolicy actionType);
typedef void (^WKWebViewAuthChallengeHander)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential);
@interface WKWebView (BlocksKit)

/** The block to be decide whether a URL will be loaded. 
 
 @warning If the delegate implements webView:shouldStartLoadWithRequest:navigationType:,
 the return values of both the delegate method and the block will be considered.
*/
@property (nonatomic, copy, setter = bk_setShouldStartLoadBlock:) BOOL (^bk_shouldStartLoadBlock)(WKWebView *webView,  WKNavigation *navigation);

/** The block that is fired when the web view starts loading. */
@property (nonatomic, copy, setter = bk_setDidStartLoadBlock:) void (^bk_didStartLoadBlock)(WKWebView *webView,  WKNavigation *navigation);

/** The block that is fired when the web view finishes loading. */
@property (nonatomic, copy, setter = bk_setDidFinishLoadBlock:) void (^bk_didFinishLoadBlock)(WKWebView *webView,  WKNavigation *navigation);


/** The block that is fired when the web view stops loading due to an error. */
@property (nonatomic, copy, setter = bk_setDidFinishWithErrorBlock:) void (^bk_didFinishWithErrorBlock)(WKWebView *webView,  WKNavigation *navigation, NSError *error);

@property (nonatomic, copy, setter = bk_setDidProcessDidTerminateBlock:) void (^bk_didProcessDidTerminateBlock)(WKWebView *webView);

@property (nonatomic, copy, setter = bk_setDidDecidePolicyForNavigationAction:) void (^bk_didDecidePolicyForNavigationAction)(WKWebView *webView,WKNavigationAction*navigationAction, WKWebViewDecisionHandler decisionHandler);

@property (nonatomic, copy, setter = bk_setDecidePolicyForNavigationResponse:) void (^bk_decidePolicyForNavigationResponse)(WKWebView *webView,WKNavigationResponse*navigationResponse, WKWebViewResponseHandler decisionHandler);

@property (nonatomic, copy, setter = bk_setDidReceiveServerRedirectForProvisionalNavigation:) void (^bk_didReceiveServerRedirectForProvisionalNavigation)(WKWebView *webView ,WKNavigation*navigation);

@property (nonatomic, copy, setter = bk_setDidFailProvisionalNavigation:) void (^bk_didFailProvisionalNavigation)(WKWebView *webView ,WKNavigation*navigation,NSError*error);

@property (nonatomic, copy, setter = bk_setDidReceiveAuthenticationChallenge:) void (^bk_didReceiveAuthenticationChallenge)(WKWebView *webView ,NSURLAuthenticationChallenge*challenge,WKWebViewAuthChallengeHander autoChallengeHander);

@end
