//
//  WebCallNode.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebCallNode.h"
#import "MajorSchemeHelper.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "AppDelegate.h"
typedef enum MiddleScrollViewState{
    Middle_Scroll_Finger_Begin,
    Middle_Scroll_Finger_End,
}_MiddleScrollViewState;

typedef enum MiddleScrollViewDirection{
    Middle_Scroll_Normal,
    Middle_Scroll_Up,
    Middle_Scroll_Down,
}_MiddleScrollViewDirection;
#define MiddleScrollDis 100

@interface WebCallNode()
{
    BOOL  isTouch;
    float offsetBeginY;
    _MiddleScrollViewState scrollState;
    _MiddleScrollViewDirection scrollDirection;
}
@end
@implementation WebCallNode

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)openOtherApp:(NSURL*)url decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webViewOpenOtherAction:url:)]) {
        [self.delegate webCallNode_webViewOpenOtherAction:self.webView url:url];
    }
    decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{ 
    if (isTouch) {
        float vv = scrollView.contentOffset.y;//(vv>10上面搜索消失，<10,上面搜索出现)
        float offsetY = offsetBeginY - vv;
        _MiddleScrollViewDirection tmpDirection = Middle_Scroll_Normal;
        
        if (offsetY>MiddleScrollDis||vv<10) {
            tmpDirection = Middle_Scroll_Up;
            offsetBeginY = vv;
            [self.delegate webCallNode_updateWebToolBar:self.webView state:false];
        }
        else if(offsetY<-MiddleScrollDis){
            tmpDirection = Middle_Scroll_Down;
            offsetBeginY = vv;
            [self.delegate webCallNode_updateWebToolBar:self.webView state:true];
        }
        if (tmpDirection !=Middle_Scroll_Normal && scrollDirection != tmpDirection && scrollState == Middle_Scroll_Finger_Begin) {
            scrollDirection = tmpDirection;
        }
    }
    if ([self.delegate respondsToSelector:@selector(webCallNode_scrollViewDidScroll:scrollView:)]) {
        [self.delegate webCallNode_scrollViewDidScroll:self.webView scrollView:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isTouch = true;
    if ([self.delegate respondsToSelector:@selector(webCallNode_scrollViewWillBeginDragging:scrollView:)]) {
        [self.delegate webCallNode_scrollViewWillBeginDragging:self.webView scrollView:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    isTouch = false;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(webCallNode_scrollViewDidEndDragging:scrollView:willDecelerate:)]) {
        [self.delegate webCallNode_scrollViewDidEndDragging:self.webView scrollView:scrollView willDecelerate:decelerate];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        if ([self.delegate respondsToSelector:@selector(webCallNode_webViewLoadProgress:progress:)]) {
            [self.delegate webCallNode_webViewLoadProgress :self.webView progress:progress];
            
        }
    }
    else if ([keyPath isEqualToString:@"title"]) {
        id v = change[NSKeyValueChangeNewKey];
        if (![v isKindOfClass:[NSNull class]]) {
             if ([self.delegate respondsToSelector:@selector(webCallNode_webViewTitleChange:title:)]) {
                [self.delegate webCallNode_webViewTitleChange:self.webView title:v];
            }
        }
    }
    else if ([keyPath isEqualToString:@"URL"]) {
        id v = change[NSKeyValueChangeNewKey];
        if (![v isKindOfClass:[NSNull class]]) {
            NSString* url = [v absoluteString];
            if ([self.delegate respondsToSelector:@selector(webCallNode_webViewUrlChange:url:)]) {
                [self.delegate webCallNode_webViewUrlChange:self.webView url:url];
            }
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    
    NSString *host = webView.URL.host;
    // Initialize alert view controller.
    NSString *v = [NSString stringWithFormat:@"%@%@%@%@%@",@"",@".",@"s",@"igu",@""];
      if(message && [message compare:@"fixBugWkIframe"]==NSOrderedSame){
          if ([host rangeOfString:v].location!=NSNotFound){
             completionHandler(YES);
          }
          else{
              completionHandler(false);
          }
          return;
      }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:host?:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    // Initialize cancel action.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        if (completionHandler != NULL) {
            completionHandler(NO);
        }
    }];
    // Initialize ok action.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        if (completionHandler != NULL) {
            completionHandler(YES);
        }
    }];
    // Add actions.
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:
(void (^)(NSString *))completionHandler {
    
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
        [self.delegate webCallNode_webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        if (completionHandler != NULL) {
            completionHandler(input?:defaultText);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSString *string = ((UITextField *)alertController.textFields.firstObject).text;
        if (completionHandler != NULL) {
            completionHandler(string?:defaultText);
        }
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{}];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.delegate webCallNode_webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    }
    else{
        completionHandler();
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)]) {
        return [self.delegate webCallNode_webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    }
    else{
        WKFrameInfo *frameInfo = navigationAction.targetFrame;
        if (![frameInfo isMainFrame]) {
            [webView loadRequest:navigationAction.request];
        }
        return nil;
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(webCallNode_webViewWebContentProcessDidTerminate:)]) {
        [self.delegate webCallNode_webViewWebContentProcessDidTerminate:webView];
    }
    else{
        [webView reload];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s %@",__FUNCTION__,[error description]);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:didStartProvisionalNavigation:)]) {
        [self.delegate webCallNode_webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:didFailNavigation:withError:)]) {
        [self.delegate webCallNode_webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:didFinishNavigation:)]) {
        [self.delegate webCallNode_webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [self.delegate webCallNode_webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:didCommitNavigation:)]) {
        [self.delegate webCallNode_webView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
//    - (void)webCallNode_webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
//
//    }
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.delegate webCallNode_webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        return;
    }
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
    
    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString isEqualToString:@"about:blank"] || ([url.absoluteString rangeOfString:@"app/register_business"].location!=NSNotFound)) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        if([self.delegate webCallNode_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler])
            return;
    }

//        if (navigationAction.navigationType==WKNavigationTypeLinkActivated && [[url absoluteString] rangeOfString:@"youku.com"].location!=NSNotFound){
//            decisionHandler(WKNavigationActionPolicyCancel);
//            [webView loadRequest:navigationAction.request];
//            return;
//        }
    if (url) {
        NSString *scheme = url.scheme;
        if (scheme) {
            if ([scheme isEqualToString:@"http"] ||
                [scheme isEqualToString:@"https"]) {
                NSString *schemUrl = [[[MajorSchemeHelper sharedHelper] findSchemeUrl:url] urlDecodedString];
                if (schemUrl) {
                    NSURL* newurl = [NSURL URLWithString:schemUrl];
                    if(newurl){
                        url = newurl;
                     goto OtherOpen;
                    }
                }
                if ([[MajorSchemeHelper sharedHelper] isAppStoreLink:url])
                {
                    if ([self.delegate respondsToSelector:@selector(webCallNode_webViewOpenInAppStore:url:)]) {
                        [self.delegate webCallNode_webViewOpenInAppStore:self.webView url:url];
                    }
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
                else {
                    if(!navigationAction.targetFrame)//在新标签里面打开
                    {
                        if ([self.delegate respondsToSelector:@selector(webCallNode_webViewIsOpenInNewWeb:url:)] && [self.delegate webCallNode_webViewIsOpenInNewWeb:self.webView url:url]) {
                            decisionHandler(WKNavigationActionPolicyCancel);
                        }
                        else{

                        }

                        decisionHandler(WKNavigationActionPolicyCancel);//20180605 WKNavigationActionPolicyCancel->WKNavigationActionPolicyAllow
                        [webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
                        return;
                    }
                  
                    decisionHandler(WKNavigationActionPolicyAllow+GetAppDelegate.appJumpValue);
                }
            }
            else if ([scheme isEqualToString:@"tel"]){
                if ([self.delegate respondsToSelector:@selector(webCallNode_webViewOpenInCall:url:)]) {
                    [self.delegate webCallNode_webViewOpenInCall:self.webView url:url];
                }
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else if ([scheme isEqualToString:AppTeShuPre]) {
                if ([self.delegate respondsToSelector:@selector(webCallNode_webViewOpenInAppStore:url:)]) {
                    [self.delegate webCallNode_webViewOpenInAppStore:self.webView url:url];
                }
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else{
            OtherOpen:
                [self openOtherApp:url decisionHandler:decisionHandler];
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


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))
decisionHandler {
    if ([self.delegate respondsToSelector:@selector(webCallNode_webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.delegate webCallNode_webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }
    else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(webCallNode_userContentController:userContentController:didReceiveScriptMessage:)]) {
        [self.delegate webCallNode_userContentController:self.webView userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end
