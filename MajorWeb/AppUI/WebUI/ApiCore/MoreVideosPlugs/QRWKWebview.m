//
//  QRWKWebview.m
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/17.
//  Copyright © 2020 cxh. All rights reserved.
//

#import "QRWKWebview.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"
#import "AXPracticalHUD.h"
#import "QRWebBlockManager.h"

static WKProcessPool *wkProcessPool = nil;
@interface QRWKWebview()<WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate,SKStoreProductViewControllerDelegate>
@property(strong,nonatomic)WKWebView *webView;
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;
@property(assign, nonatomic) NSTimeInterval timeoutInternal;
@property(strong, nonatomic)UIProgressView *progressView;
@property(copy)NSString *currentUrl;
@property(copy,nonatomic)NSString *webUUID;
@property(assign)BOOL isExcutJs;
@property(copy)NSString *loadUrl;
@property(copy,nonatomic)NSString *userAgent;
@end
@implementation QRWKWebview

-(id)initWithFrame:(CGRect)frame uuid:(NSString*)uuid userAgent:(NSString*)userAgent isExcutJs:(BOOL)isExcutJs{
    self = [super initWithFrame:frame];
    _cachePolicy = NSURLRequestReturnCacheDataElseLoad ;
    if (!uuid) {
        CFUUIDRef    uuidObj = CFUUIDCreate(nil);
        NSString    *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
        self.webUUID = uuidString;
        CFRelease(uuidObj);
    }
    else{
        self.webUUID = uuid;
    }
    self.isUseChallenge = true;
    self.isExcutJs = isExcutJs;
    self.userAgent = userAgent;
     [self creaetWeb];
    return self;
}

-(void)dealloc{
    #ifdef DEBUG
    NSLog(@"%s",__FUNCTION__);
#endif
}

-(void)loadUrl:(NSString*)url{        
    if ([_qrWkdelegate respondsToSelector:@selector(qrUpdateTitle:)]) {
        [_qrWkdelegate qrUpdateTitle:@""];
    }
    self.loadUrl= url;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
     request.timeoutInterval = _timeoutInternal;
     request.cachePolicy = _cachePolicy;
    [self.webView stopLoading];
    [self.webView loadRequest:request];
}

-(void)removeWebMsg{
    if (self.isExcutJs) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"contextMenuMessageHandler"];
          [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"VideoHandler"];
          [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"GetAssetSuccess"];
          [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"PostMoreInfo"];
          [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"GetInfoTime"];
          [self.webView.configuration.userContentController removeAllUserScripts];
    }
}

-(void)addWebMsg{
    if (self.isExcutJs) {
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"GetAssetSuccess"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"GetInfoTime"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"PostMoreInfo"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"contextMenuMessageHandler"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"VideoHandler"];
    }
}
 

- (void)tryPlayOperation
{
    if (self.isExcutJs) {
    if (self.webViewType==webView_Naroml) {
        [self.webView evaluateJavaScript:@"qrTryDoIt();" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            if (![ret boolValue]) {
                if ([self.qrWkdelegate respondsToSelector:@selector(qrWebPressAsset)]) {
                    [self.qrWkdelegate qrWebPressAsset];
                }
            }
        }];
    }
    }
}

-(void)creaetWeb{
    if (!self.webView) {
           WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
           configuration.userContentController =
           [[WKUserContentController alloc] init];
           configuration.preferences = [[WKPreferences alloc] init];
           configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        if (@available(iOS 13.0, *)) {
            configuration.preferences.fraudulentWebsiteWarningEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
            //zbw 20190729
           configuration.allowsInlineMediaPlayback = true;
           //configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
           //end
        if (wkProcessPool==nil) {
            wkProcessPool = [[WKProcessPool alloc] init];
        }
           configuration.processPool = wkProcessPool;
           
        self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) configuration:configuration];
           [self addSubview:self.webView];
          [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.edges.equalTo(self);
          }];
           self.webView.allowsBackForwardNavigationGestures = NO;
           if (@available(iOS 9.0, *)) {
               self.webView.allowsLinkPreview = false;
           } else {
               // Fallback on earlier versions
           }
           self.webView.UIDelegate = self;
           self.webView.navigationDelegate = self;
        if (self.isExcutJs) {
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
        }
        [self addSubview:self.progressView];
        self.progressView.frame = CGRectMake(0, 0, self.bounds.size.width, 2);
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.left.top.right.equalTo(self);
                   make.height.mas_equalTo(2);
               }];
        if (self.isExcutJs) {
        NSString *js = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"js" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        if (js) {
            WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                   [self.webView.configuration.userContentController addUserScript:noneSelectScript];
        }
        //video hook
        {
         NSString *v =   [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/webassetKey_new" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
            if ([v length]>20) {
                WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:v injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                             [self.webView.configuration.userContentController addUserScript:noneSelectScript];
            }
        }
        {
           NSString *v = [[QRWebBlockManager shareInstance] getQrJsStringFromKey:qrJsWebKey];
            if ([v length]>20) {
                WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:v injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                                     [self.webView.configuration.userContentController addUserScript:noneSelectScript];
            }
        }
        } 
        //end
        if (self.userAgent) {
                  self.webView.customUserAgent = self.userAgent;
        }else{
            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad){
                           self.webView.customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 13_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari/15E148";
            }
        }
        [self addWebMsg];
       }
}

- (void)updateProcess:(float)progress animated:(BOOL)animated {
    if (!self.isExcutJs) {
        return;
    }
    if (self.webViewType == webView_Naroml){
           if (progress>0.4) {
               NSURL *_url = self.webView.URL;
               if (_url) {
                   NSString *js = [NSString stringWithFormat:@"qrHanderUrl(\"%@\",\"%@\")",_url.absoluteString,_url.host];
                   [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable v, NSError * _Nullable error) {
                       if (error) {
                           #ifdef DEBUG
                           NSLog(@"qrHanderUrl externParam = %@",[error description]);
#endif
                       }
                   }];
               }
           }
    }
    if (progress == 1.0) {
        [self.progressView setProgress:progress animated:animated];
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.progressView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [self.progressView setProgress:0.0 animated:NO];
                             }
                         }];
    } else {
        if (self.progressView.alpha < 1.0) {
            self.progressView.alpha = 1.0;
        }
        [self.progressView setProgress:progress
                                 animated:(progress > self.progressView.progress) && animated];
    }
    if ([self.qrWkdelegate respondsToSelector:@selector(qrUpdateProgress:)]) {
        [self.qrWkdelegate qrUpdateProgress:progress];
    }
}

-(void)_updateUrl:(NSString*)url host:(NSString*)host{
    if (!self.isExcutJs) {
        return;
    }
    if (self.webViewType == webView_Naroml){
        NSString *js = [NSString stringWithFormat:@"qrHanderUrl(\"%@\",\"%@\")",url,host];
        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable v, NSError * _Nullable error) {
                   if (error) {
                       #ifdef DEBUG
                       NSLog(@"qrHanderUrl externParam = %@",[error description]);
#endif
                   }
               }];
    }
    if ([_qrWkdelegate respondsToSelector:@selector(qrUpdateUrl:host:)]) {
                   self.currentUrl = url;
                   [_qrWkdelegate qrUpdateUrl:url host:host];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (!self.isExcutJs) {
         return;
     }
#ifdef DEBUG
  //  printf("keyPath%s object=  %s\n",[keyPath UTF8String],[[[change objectForKey:NSKeyValueChangeNewKey] description]UTF8String]);
#endif
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        // Add progress view to navigation bar.
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        [self updateProcess:progress animated:YES];
     }
    else if ([keyPath isEqualToString:@"title"]) {
        id v = change[NSKeyValueChangeNewKey];
        if (![v isKindOfClass:[NSNull class]]) {
        if ([_qrWkdelegate respondsToSelector:@selector(qrUpdateTitle:)]) {
                        [_qrWkdelegate qrUpdateTitle:v];
                    }
        }
    }
    else if ([keyPath isEqualToString:@"URL"]) {
        id v = change[NSKeyValueChangeNewKey];
        if (![v isKindOfClass:[NSNull class]]) {
            NSString* url = [v absoluteString];
            [self _updateUrl:url host:[v host]];
        }
        else if([v isKindOfClass:[NSNull class]]){
            [self addWKWebBlankAlter];
        }
    }
    else if([keyPath isEqualToString:@"canGoForward"]){
       if ([_qrWkdelegate respondsToSelector:@selector(qrUpdateGoForwardState:)]) {
           id v = change[NSKeyValueChangeNewKey];
                  [_qrWkdelegate qrUpdateGoForwardState:[v boolValue]];
            }
    }
    else if([keyPath isEqualToString:@"canGoBack"]){
        if ([_qrWkdelegate respondsToSelector:@selector(qrUpdateGoBackState:)]) {
            id v = change[NSKeyValueChangeNewKey];
                   [_qrWkdelegate qrUpdateGoBackState:[v boolValue]];
               }
    }
    else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIProgressView *)progressView {
    if (_progressView) return _progressView;
    CGFloat progressBarHeight = 2.0f;
     CGRect barFrame =  CGRectMake(0, 0, 0, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.progressTintColor =[UIColor redColor]; // ProgressTintColor;
    _progressView.trackTintColor = [UIColor blackColor];
    _progressView.progress = 0;
    return _progressView;
}

-(void)removeFromSuperview{
    [self removeWebMsg];
    if (self.isExcutJs) {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"URL"];
    }
    [self.webView stopLoading];
    [super removeFromSuperview];
}

- (void)checkTimeOut{
    if (!self.isExcutJs) {
        return;
    }
if (self.webViewType==webView_Simple) {
        [self.webView  evaluateJavaScript:@"qrCheckTimeOut();" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
        if (error) {
            #ifdef DEBUG
            NSLog(@"webView_Test0 = qrCheckTimeOut %@",[error description]);
#endif
        }
    }];
    if ([self.qrWkdelegate respondsToSelector:@selector(qrWebCheckTimeOut)]) {
        [self.qrWkdelegate qrWebCheckTimeOut];
    }
  }
}

- (void)didFailLoadWithError:(NSError *)error{
    
//    if (error.code == NSURLErrorCannotFindHost) {// 404
//        [self loadURL:[NSURL fileURLWithPath:kAX404NotFoundHTMLPath]];
//    } else {
//        [self loadURL:[NSURL fileURLWithPath:kAXNetworkErrorHTMLPath]];
//    }
//    // #endif
  
    [_progressView setProgress:0.9 animated:YES];
}

-(void)addWKWebBlankAlter{
    if (!self.isExcutJs) {
         return;
     }
    if ([self.qrWkdelegate respondsToSelector:@selector(qrUpdateWhiteScreen)]) {
        [self.qrWkdelegate qrUpdateWhiteScreen];
    }
}

#pragma mark --WKWebViewDelte
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if (navigationAction.request) {
           // [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSString *host = webView.URL.host;
    
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
    // Initialize alert view controller.
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
    [GetAppDelegate.window.rootViewController presentViewController:alert animated:YES completion:NULL];
}


- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:
(void (^)(NSString *))completionHandler {
    
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
    [GetAppDelegate.window.rootViewController presentViewController:alertController animated:YES completion:^{}];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSString *host = webView.URL.host;
    // Init the alert view controller.
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:host?:@"提示" message:message preferredStyle: UIAlertControllerStyleAlert];
    // Init the cancel action.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completionHandler != NULL) {
            completionHandler();
        }
    }];
    // Init the ok action.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        if (completionHandler != NULL) {
            completionHandler();
        }
    }];
    
    // Add actions.
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [GetAppDelegate.window.rootViewController presentViewController:alert animated:YES completion:NULL];
}
 
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self addWKWebBlankAlter];
#ifdef DEBUG
    printf("webViewWebContentProcessDidTerminate %s\n",[self.loadUrl UTF8String]);
#endif
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    if ([self.qrWkdelegate respondsToSelector:@selector(qrStartProvisionalNavigation)]) {
        [self.qrWkdelegate qrStartProvisionalNavigation];
    }
    [self checkTimeOut];
}

- (void)webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error{
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([self.qrWkdelegate respondsToSelector:@selector(qrDidFinishNavigation:title:)]) {
        [self.qrWkdelegate qrDidFinishNavigation:nil title:nil];
    }
    [self checkTimeOut];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}


/**
 https 请求会进这个方法，在里面进行https证书校验、白名单域名判断等操作
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
#ifdef DEBUG
    printf("didReceiveAuthenticationChallenge = %s\n",[[webView.URL absoluteString] UTF8String]);
#endif
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if (challenge.previousFailureCount == 0) {
                if (!self.isUseChallenge) {
                    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                }
                else{
                    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                                       completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                }
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

    if ([self.qrWkdelegate respondsToSelector:@selector(qrDecidePolicyForNavigationAction:decisionHandler:)]&&
        [self.qrWkdelegate qrDecidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler]) {
        return;
    }
NSURL *url = navigationAction.request.URL;
   if ([url.absoluteString isEqualToString:@"about:blank"] || ([url.absoluteString rangeOfString:@"app/register_business"].location!=NSNotFound) ) {
       decisionHandler(WKNavigationActionPolicyCancel);
       return;
   }
   
    NSString *scheme = url.scheme;
   
    if ([scheme isEqualToString:@"http"] ||
        [scheme isEqualToString:@"https"]   ) {
        if(false){
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    else{
        WKNavigationActionPolicy v = WKNavigationActionPolicyCancel;
        decisionHandler(v);
        return;
    }
     if (!navigationAction.targetFrame.isMainFrame) {//为什么要加这个？
       //  [self.webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
     }
   
   if (navigationAction.navigationType==WKNavigationTypeLinkActivated || navigationAction.navigationType==WKNavigationTypeOther) {//点击事件
       if ([self.qrWkdelegate respondsToSelector:@selector(qrLinkActivatedHandle:object:)]) {
           if([self.qrWkdelegate qrLinkActivatedHandle:[url absoluteString] object:self]){
               decisionHandler(WKNavigationActionPolicyCancel);
               return;
           }
       }
    }
     NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
      if (([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/' OR SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString])) {
          if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/'"] evaluateWithObject:components.URL.absoluteString] ) {
              [[AXPracticalHUD sharedHUD] showNormalInView:self.webView text:nil detail:nil configuration:^(AXPracticalHUD *HUD) {
                  HUD.removeFromSuperViewOnHide = YES;
              }];
              SKStoreProductViewController *productVC = [[SKStoreProductViewController alloc] init];
              productVC.delegate = self;
              NSError *error;
              NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"id[1-9]\\d*" options:NSRegularExpressionCaseInsensitive error:&error];
              NSTextCheckingResult *result = [regex firstMatchInString:components.URL.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, components.URL.absoluteString.length)];
              
              if (!error && result) {
                  NSRange range = NSMakeRange(result.range.location+2, result.range.length-2);
                  [productVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: @([[components.URL.absoluteString substringWithRange:range] integerValue])} completionBlock:^(BOOL result, NSError * _Nullable error) {
                      if (!result || error) {
                          [[AXPracticalHUD sharedHUD] showErrorInView:self.webView text:error.localizedDescription detail:nil configuration:^(AXPracticalHUD *HUD) {
                              HUD.removeFromSuperViewOnHide = YES;
                          }];
                          [[AXPracticalHUD sharedHUD] hide:YES afterDelay:1.5 completion:NULL];
                      } else {
                          [[AXPracticalHUD sharedHUD] hide:YES afterDelay:0.5 completion:NULL];
                      }
                  }];
                  [GetAppDelegate.window.rootViewController presentViewController:productVC animated:YES completion:NULL];
                  decisionHandler(WKNavigationActionPolicyCancel);
                  return;
              } else {
                  [[AXPracticalHUD sharedHUD] hide:YES afterDelay:0.5 completion:NULL];
              }
              if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
                  if (@available(iOS 10.0, *)) {
                      //  [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
                  } else {
                      //  [[UIApplication sharedApplication] openURL:components.URL];
                  }
              }
              decisionHandler(WKNavigationActionPolicyCancel);
              return;
          }
      } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {// For any other schema but not `https`、`http` and `file`.
          if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
              [[UIApplication sharedApplication] openURL:components.URL];
          }
          decisionHandler(WKNavigationActionPolicyCancel);
          return;
      }
      if(!navigationAction.targetFrame)//在新标签里面打开
      {
#ifdef DEBUG
          printf("%s\n","!navigationAction.targetFrame");
#endif
         
          decisionHandler(WKNavigationActionPolicyCancel);//20180605 WKNavigationActionPolicyCancel->WKNavigationActionPolicyAllow
          [webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
          return;
      }
       [self checkTimeOut];
      decisionHandler(WKNavigationActionPolicyAllow+2);
}


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))
decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

 - (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
     if (!self.isExcutJs) {
          return;
      }
    __weak __typeof(self)weakSelf = self;
     #ifdef DEBUG
                        printf("[message.body message = %s\n",[[message.body description] UTF8String]);
            #endif
      if([message.name compare:@"PostMoreInfo"]==NSOrderedSame){
            if([self.qrWkdelegate respondsToSelector:@selector(qrGetMoreInfoCallBack:isSeek:)])
               [self.qrWkdelegate qrGetMoreInfoCallBack:[message.body objectForKey:@"array"]isSeek:[[message.body objectForKey:@"seek"]boolValue]];
          #ifdef DEBUG
            NSLog(@"[message.body PostMoreInfo = %@",[message.body description]);
#endif
        }
   else if([message.name compare:@"GetInfoTime"]==NSOrderedSame){//api的网页的时候用
//          NSLog(@"[message.body = %@",[message.body description]);
//          if ([self.qrWkdelegate respondsToSelector:@selector(webViewExternCallBack:uuid:assetKey:)]) {
//              [self.qrWkdelegate webViewExternCallBack:[message.body intValue]!=0?false:true uuid:self.uuid assetKey:self.externParam];
//          }
      }
   else if ([message.name compare:@"GetAssetSuccess"]==NSOrderedSame){
       if ([self.qrWkdelegate respondsToSelector:@selector(qrGetAssetSuccess:isSeek:)]) {
           if ([message.body isKindOfClass:[NSString class]]) {
              return;
           }
           [self.qrWkdelegate qrGetAssetSuccess:[message.body objectForKey:@"array"]isSeek:[[message.body objectForKey:@"seek"]boolValue]];

       }
   }
     else if ([message.name compare:@"VideoHandler"]==NSOrderedSame) {
         id v = message.body;
           
         if ([message.body isKindOfClass:[NSString class]]) {
                    return;
        }
         if ([message.body isKindOfClass:[NSDictionary class]] && self.webViewType==webView_Naroml){
             if ([self.qrWkdelegate respondsToSelector:@selector(qrUpDataAsset:)]) {
                 [self.qrWkdelegate qrUpDataAsset:[v objectForKey:@"src"]];
             }
             if ([self.qrWkdelegate respondsToSelector:@selector(qrGetAsset:referer:title:isAsset:rect:)]) {
                 NSString *msgID = [v objectForKey:@"msgId"];
                 id rectDic = [message.body objectForKey:@"rect"];
                 CGRect rect = CGRectMake([[rectDic objectForKey:@"left"] floatValue], [[rectDic objectForKey:@"top"] floatValue], [[rectDic objectForKey:@"width"] floatValue], [[rectDic objectForKey:@"height"] floatValue]);
                 if ([msgID isEqualToString:@"play"]) {
                     [weakSelf.webView evaluateJavaScript:@"qrTryDoIt();" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                         [weakSelf.qrWkdelegate qrGetAsset:[message.body objectForKey:@"src"] referer:[message.body objectForKey:@"referer"] title:[message.body objectForKey:@"title"] isAsset:[ret boolValue]rect:rect];
                     }];
                 }
                 else if([msgID isEqualToString:@"get"]){
                    NSString *js = [NSString stringWithFormat:@"qrHanderUrl(\"%@\",\"%@\")",self.currentUrl,[NSURL URLWithString:self.currentUrl].host];
                    if ([self.qrWkdelegate respondsToSelector:@selector(qrInsertView:)]) {
                                [self.qrWkdelegate qrInsertView:rect];
                        }
                 [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                     [weakSelf.webView evaluateJavaScript:@"qrCheckVaild();" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                                        if ([ret boolValue]) {
                                             [weakSelf.qrWkdelegate qrGetAsset:[message.body objectForKey:@"src"] referer:[message.body objectForKey:@"referer"] title:[message.body objectForKey:@"title"]isAsset:[ret boolValue]rect:rect];
                                        }
                                    }];
                                }];
                            }
                }
         }
         else if ([message.body isKindOfClass:[NSDictionary class]] && self.webViewType!=webView_Simple_Finish)
         {
             self.webViewType = webView_Simple_Finish;
             if (@available(iOS 10.0, *)) {
                          // self.webView.configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
                       } else {
                           // Fallback on earlier versions
                       }
             if ([self.qrWkdelegate respondsToSelector:@selector(qrExternCallBack:uuid:assetKey:title:)]) {
                 [self.qrWkdelegate qrExternCallBack:true uuid:self.webUUID assetKey:[message.body objectForKey:@"src"] title:self.webView.title];
                        }
         }
     }
    else if ([message.name compare:@"contextMenuMessageHandler"]==NSOrderedSame) {
            id v = message.body;
            if([v isKindOfClass:[NSDictionary class]] && ![v objectForKey:@"action"] && [v allKeys].count>2){
                #ifdef DEBUG
                NSLog(@"WKScriptMessage = %@",[v description]);
                #endif
                NSString *imageUrl =  [v objectForKey:@"image"];
                NSString *linkUrl = [v objectForKey:@"link"];
                NSString *title = [v objectForKey:@"title"];
                NSString *webUrl = [self.webView.URL absoluteString];
                if (imageUrl || linkUrl) {
                    if ([_qrWkdelegate respondsToSelector:@selector(qrGetAssetUrl:title:weblink:)]) {
                        NSString *url = imageUrl?imageUrl:linkUrl;
                        url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        [_qrWkdelegate qrGetAssetUrl:url title:title weblink:webUrl];
                    }
                }
            }
        }
 }

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [GetAppDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
