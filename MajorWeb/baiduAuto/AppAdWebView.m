//
//  AppAdWebView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/10.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "AppAdWebView.h"
#import <WebKit/WebKit.h>
#import "AppAdSchemeHelper.h"
#import "NSString+MKNetworkKitAdditions.h"
@interface AppAdWebView()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property(strong,nonatomic)WKWebView *webView;
@property(assign)NSInteger finishCount;
@property(assign)NSInteger totalCount;
@property(assign)BOOL isNewMode;
@property(nonatomic,strong)NSMutableDictionary *keyInfo;
@end
@implementation AppAdWebView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)readUlrKey{
    self.keyInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath   = [cachesPath stringByAppendingPathComponent:@"webviewclickinfo"];
    NSDictionary *tmpInfo = [NSDictionary dictionaryWithContentsOfFile:dbPath];
    if (tmpInfo.allKeys.count>0) {
        [self.keyInfo setDictionary:tmpInfo];
    }
}

-(void)saveUrlKey{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dbPath   = [cachesPath stringByAppendingPathComponent:@"webviewclickinfo"];
        [self.keyInfo writeToFile:dbPath atomically:YES];
    });
}

-(instancetype)initWithFrame:(CGRect)frame js:(NSString*)js{
    self = [super initWithFrame:frame];
    [self readUlrKey];
    WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController =
    [[WKUserContentController alloc] init];
    
    NSString *jsstr  =js;
    WKUserScript * videoScript = [[WKUserScript alloc]
                                  initWithSource:jsstr
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:videoScript];
    [configuration.userContentController addScriptMessageHandler:self name:@"CloseWebView"];
    [configuration.userContentController addScriptMessageHandler:self name:@"InitTotalCount"];
    [configuration.userContentController addScriptMessageHandler:self name:@"ClickDelayTime"];
    [configuration.userContentController addScriptMessageHandler:self name:@"ClickWebUrl"];

//    for (int i=0; i<9; i++) {
//        [configuration.userContentController
//         addScriptMessageHandler:self
//         name:[NSString stringWithFormat:@"Debug%d",i]];
//    }
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.allowsInlineMediaPlayback = YES;
    configuration.processPool = [[WKProcessPool alloc] init];
    self.webView = [[WKWebView alloc]initWithFrame:self.bounds configuration:configuration];
    self.webView.allowsBackForwardNavigationGestures = true;
    if (@available(iOS 9.0, *)) {
        self.webView.allowsLinkPreview = false;
    } else {
        // Fallback on earlier versions
    }
     [self.webView addObserver:self
              forKeyPath:@"estimatedProgress"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self addSubview:self.webView];
    return self;
}

-(void)loadUrl:(NSString*)url isNewMode:(BOOL)isNewMode{
    self.isNewMode = isNewMode;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)removeFromSuperview{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"CloseWebView"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"InitTotalCount"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"ClickDelayTime"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"ClickWebUrl"];
    
//    for (int i=0; i<9; i++) {
//        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:[NSString stringWithFormat:@"Debug%d",i]];
//    }
    
    [super removeFromSuperview];
}

-(void)notiJsFinsihLoad{
    self.finishCount++;
    NSLog(@"finishCount %d totalCount %d",self.finishCount,self.totalCount);
    NSArray *array = self.keyInfo.allKeys;
    NSMutableString *ret = [NSMutableString string];
//    for (int i = 0; i < array.count; i++) {
//        [ret appendFormat:@"%@,",[array objectAtIndex:i]];
//    }
    [ret appendString:@""];
    NSString *js = [NSString stringWithFormat:@"triggerFingerWebLoadFinish(%ld,%ld,%d,'%@');",(long)self.finishCount,(long)self.totalCount,self.isNewMode,[ret urlEncodedString]];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable v, NSError * _Nullable error) {
        
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{}];
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
        if(completionHandler!=NULL)
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (completionHandler!=NULL) {
            completionHandler(@"");
        }
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{}];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
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
    NSLog(@"%s",__FUNCTION__);
    [webView reload];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self.webView evaluateJavaScript:@"triggerFingerWebLoadFaild()" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
        
    }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    [self.webView evaluateJavaScript:@"triggerFingerWebLoadStart();" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
        
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self notiJsFinsihLoad];
    
    NSString *jsContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"adwebview" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    [webView evaluateJavaScript:jsContent completionHandler:^(id _Nullable t, NSError * _Nullable error) {
        [webView evaluateJavaScript:@"addAdTest()" completionHandler:^(id _Nullable t, NSError * _Nullable error) {
            NSLog(@"addAdTest");
        }];
    }];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
   
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
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

    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    NSLog(@"decidePolicyForNavigationAction = %@",[url absoluteString]);
    if (url) {
        NSString *scheme = url.scheme;
        if (scheme) {
            if ([scheme isEqualToString:@"http"] ||
                [scheme isEqualToString:@"https"]) {
                NSString *schemUrl = [[[AppAdSchemeHelper sharedHelper] findSchemeUrl:url] urlDecodedString];
                if (schemUrl) {
                    NSURL* newurl = [NSURL URLWithString:schemUrl];
                    if(newurl){
                        url = newurl;
                        decisionHandler(WKNavigationActionPolicyCancel);
                       //不打开第三方app
                    }
                }
                if ([[AppAdSchemeHelper sharedHelper] isAppStoreLink:url])
                {//不打开AppStore
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
                else {
                    if(!navigationAction.targetFrame)//在新标签里面打开
                    {
                        decisionHandler(WKNavigationActionPolicyCancel);
                        [webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
                        return;
                    }
                    decisionHandler(WKNavigationActionPolicyAllow);
                }
            }
            else if ([scheme isEqualToString:@"tel"]){
                //不打电话
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else if ([scheme isEqualToString:AppTeShuPre]) {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else{
                decisionHandler(WKNavigationActionPolicyCancel);
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
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSLog(@"message.name = %@",message.name);
    if ([message.name compare:@"CloseWebView"]==NSOrderedSame) {
        NSLog(@"CloseWebView message");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate willRemoveFromSuperView:self.isNewMode];
        });
    }
    else if ([message.name compare:@"InitTotalCount"]==NSOrderedSame){
        if (self.totalCount==0) {
            self.totalCount = [message.body integerValue];
        }
    }
    else if([message.name compare:@"ClickDelayTime"]==NSOrderedSame){
        [self performSelector:@selector(notiJsFinsihLoad) withObject:nil afterDelay:0.5];
    }
    else if ([message.name compare:@"ClickWebUrl"]==NSOrderedSame){
        if ([message.body isKindOfClass:[NSString class]]) {
            [self.keyInfo setObject:@"0" forKey:message.body];
            [self saveUrlKey];
        }
    }
   NSLog(@"message.body = %@",[message.body description]);
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"triggerFingerWebLoadProgress(%f)",progress*100] completionHandler:^(id _Nullable v, NSError * _Nullable error) {
            
        }];
    }
}
@end
