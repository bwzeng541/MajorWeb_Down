//
//  BeatifyWebView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/4/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyWebView.h"
#import <WebKit/WebKit.h>
#import "BeatifyWebConfig.h"
#import "Masonry.h"
#import <StoreKit/StoreKit.h>
#import "AXPracticalHUD.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "JSON.h"
#import "JsServiceManager.h"
//#import "NSObject+TestFuntion.h"
//#import "BeatifyJsManager.h"
//#import "MoreBeatfiyWebsView.h"
#import "AppDelegate.h"
#define AppTeShuPre [NSString stringWithFormat:@"%@%@%@",@"itm",@"s-serv",@"ices"]

#ifndef kAX404NotFoundHTMLPath
#define kAX404NotFoundHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"BeatifyWebView")] pathForResource:@"BeatifyWebView.bundle/html.bundle/404" ofType:@"html"]
#endif
#ifndef kAXNetworkErrorHTMLPath
#define kAXNetworkErrorHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"BeatifyWebView")] pathForResource:@"BeatifyWebView.bundle/html.bundle/neterror" ofType:@"html"]
#endif



#define AppTeShuPre [NSString stringWithFormat:@"%@%@%@",@"itm",@"s-serv",@"ices"]


/// URL key for 404 not found page.
static NSString *const kAX404NotFoundURLKey = @"ax_404_not_found";
/// URL key for network error page.
static NSString *const kAXNetworkErrorURLKey = @"ax_network_error";
@interface BeatifyWebView()<WKUIDelegate,WKNavigationDelegate,SKStoreProductViewControllerDelegate>{
    BOOL _loading;
    WKWebViewConfiguration *_configuration;
    NSMutableArray *_localPrefixes;
    NSArray* _schemes;
    NSArray* _prefixes;
    NSTimer* _cancelTimer;
    
}
@property(copy,nonatomic)NSString* defaultJSON;
@property(assign, nonatomic) BOOL isAddUI;
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;
@property(assign, nonatomic) NSTimeInterval timeoutInternal;
@property(assign,nonatomic)BOOL reviewsAppInAppStore;
@property(copy,nonatomic)NSString*currentUrl;
@property(strong,nonatomic)NSTimer *delayLoadTimer;
@property(copy,nonatomic)NSString*webTitle;
@property(strong, nonatomic)UIProgressView *progressView;
@property(nonatomic,strong)WKWebView *webView;
@property(assign, nonatomic)BOOL isOperation;
@property(copy, nonatomic) NSString *uuid;
@end

@implementation BeatifyWebView

-(void)dealloc{
    self.webView = nil;
    printf("BeatifyWebView dealloc \n");
    NSLog(@"%s",__FUNCTION__);
}

- (void)isOperationError:(BOOL)isOperation{
    self.isOperation = isOperation;
}

- (void)enableWebSrollview:(BOOL)f{
    self.webView.scrollView.scrollEnabled = f;
}

-(void)removeFromSuperview{
    [self.delayLoadTimer invalidate];self.delayLoadTimer=nil;
    [self.webView stopLoading];
    [_cancelTimer invalidate];_cancelTimer = nil;
    [self destoryWKWebView];
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame isShowOpUI:(BOOL)isShowOpUI{
    self = [super initWithFrame:frame];
    self.uuid = [NSString uniqueString];
    self.timeoutInternal = 10;
    self.webViewType = webView_Naroml;
    _cachePolicy = NSURLRequestReturnCacheDataElseLoad ;
    self.isAddUI = isShowOpUI;
    self.isOperation = true;
    self.defaultJSON = [NSString stringWithFormat:@"{ \"schemes\": [ \"itms\", \"itmss\", \"itms-apps\", \"itms-apps\",\"%@\" ],\"prefixes\": [ \"http://itunes.apple.com\", \"https://itunes.apple.com\" ] }",AppTeShuPre];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[self.defaultJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    _schemes = [jsonDict objectForKey:@"schemes"];
    _prefixes = [jsonDict objectForKey:@"prefixes"];
    return self;
}

- (void)loadWebView{
    [self createWebView];
}

- (BOOL)isAppStoreLink:(NSURL*)url
{
    __block BOOL schemeFound = NO;
    
    [_schemes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ([url.scheme isEqualToString:obj]) {
            schemeFound = YES;
            *stop = YES;
        }
    }];
    
    if (schemeFound == YES) {
        return YES;
    }
    
    __block BOOL hasPrefix = NO;
    
    [_prefixes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ([url.absoluteString hasPrefix:obj]) {
            hasPrefix = YES;
            *stop = YES;
        }
    }];
    if (hasPrefix == YES) {
        return YES;
    }
    
    return NO;
}

-(void)addUI{//返回，前进，stop
    
}

-(void)destoryWKWebView
{
    if (self.webView) {
        [self.delayLoadTimer invalidate];self.delayLoadTimer=nil;
        [_cancelTimer invalidate];_cancelTimer = nil;
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"PostListInfo"];
         [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"PostMoreInfo"];
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"GetInfoTime"];
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"DeviceFull"];
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"PostAssetInfo"];
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendMessageGetPicFromPagWeb"];
        [[BeatifyWebConfig getInstance] remveWebObser:self.webView];
        [self.webView stopLoading];
        self.webView.navigationDelegate=nil;_webView.UIDelegate = nil;
        [[BeatifyWebConfig getInstance] remveAllJs:self.webView];
        [self.webView removeObserver:self  forKeyPath:@"estimatedProgress" context:nil];
        [self.webView removeObserver:self  forKeyPath:@"title" context:nil];
        [self.webView removeObserver:self  forKeyPath:@"URL" context:nil];
        [[BeatifyWebConfig getInstance] removeRule:self.webView];
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
}

- (void)goBack{
    if (self.webView.canGoBack) {
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        }
        [self.webView goBack];
    }
}

- (void)goForward{
    if (self.webView.canGoForward) {
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        }
        [self.webView goForward];
    }
}

- (void)stopLoading{
    [self.webView stopLoading];
}

-(void)reloadWeb{
    [self.webView reload];
}

- (void)tryPlayOperation
{
    if (self.webViewType==webView_Naroml) {
        
    }
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)loadAllJs:(BOOL)f
{
    [[BeatifyWebConfig getInstance]updateWebMode:self.webView isSuspensionMode:f];
    [BeatifyWebConfig addDefaultJs:self.webView jsContent:[[JsServiceManager getInstance]getJsContent:@"WebJsNode_beatify"] messageName:@[@"PostMoreInfo",@"GetInfoTime",@"DeviceFull",@"PostListInfo",@"PostAssetInfo",@"contextMenuMessageHandler",@"sendMessageSetWordSuccess",@"sendMessageGetPicFromPagWeb",@"sendMessageClickSuccess",@"sendNodeLeftMessageInfo",@"sendNodeRightMessageInfo",@"errorReport",@"pureMode",@"clickWebsImage"]];
 }

- (void)loadAllRule
{
    
}
    
-(void)createWebView{
    if (!self.webView) {
        WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController =
        [[WKUserContentController alloc] init];
        configuration.preferences = [[WKPreferences alloc] init];
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        
        //zbw 20190729
        configuration.allowsInlineMediaPlayback = true;
        //configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        //end
        configuration.processPool = [[WKProcessPool alloc] init];
        
        self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, 5, 5) configuration:configuration];
        [self addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.webView.allowsBackForwardNavigationGestures =  false;
        if (@available(iOS 9.0, *)) {
            self.webView.allowsLinkPreview = false;
        } else {
            // Fallback on earlier versions
        }
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        [self.webView addObserver:self
                  forKeyPath:@"estimatedProgress"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        [self.webView addObserver:self
                  forKeyPath:@"title"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(2);
        }];
   
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

#pragma mark - Public
- (void)loadURL:(NSURL *)pageURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
    request.timeoutInterval = _timeoutInternal;
    request.cachePolicy = _cachePolicy;
    [_webView loadRequest:request];
    NSLog(@"loadURL = %@",[pageURL absoluteString]);
}

- (void)openWithBlank{
    if ([self.externDelegate respondsToSelector:@selector(webViewExternCallBack:uuid:assetKey:)]) {
        [self.externDelegate webViewExternCallBack:false uuid:self.uuid assetKey:nil];
     }
}

- (void)delayLoadURL:(NSURL*)URL time:(float)time isDefault:(BOOL)isDefault{
    [self.delayLoadTimer invalidate];self.delayLoadTimer=nil;
    [_cancelTimer invalidate];_cancelTimer = nil;
    if (isDefault) {
        self.externParam = [URL absoluteString];
        if ([self.externDelegate respondsToSelector:@selector(webViewExternCallBack:uuid:assetKey:)]) {
            [self.externDelegate webViewExternCallBack:true uuid:self.uuid assetKey:self.externParam];
        }
        return;
    }
     _cancelTimer = [NSTimer scheduledTimerWithTimeInterval:time+10 target:self selector:@selector(openWithBlank) userInfo:nil repeats:YES];
    self.delayLoadTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(delayTimer:) userInfo:URL repeats:YES];
 }

-(void)delayTimer:(NSTimer*)timer{
    [self loadURL:timer.userInfo];
    [self.delayLoadTimer invalidate];self.delayLoadTimer=nil;
}

- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL {
      [_webView loadHTMLString:HTMLString baseURL:baseURL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        // Add progress view to navigation bar.
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        [self _updateProcess:progress animated:YES];
    }
    else if ([keyPath isEqualToString:@"title"]) {
        [self _updateTitle];
    }
    else if ([keyPath isEqualToString:@"URL"]) {
        id v = change[NSKeyValueChangeNewKey];
        if (![v isKindOfClass:[NSNull class]]) {
            NSString* url = [v absoluteString];
            [self _updateUrl:url host:((NSURL*)v).host];
        }
    }
    else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)_updateUrl:(NSString*)url host:(NSString*)host{
    if (self.webViewType == webView_Naroml){
        
    }
    self.currentUrl = url;
    if([self.delegate respondsToSelector:@selector(webViewUrl:)])
    [self.delegate webViewUrl:url];
}

-(void)_updateTitle{
    self.webTitle = self.webView.title;
    if([self.delegate respondsToSelector:@selector(webViewTitle:)])
    [self.delegate webViewTitle:self.webTitle];
}

- (void)_updateProcess:(float)progress animated:(BOOL)animated {
    if (self.webViewType == webView_Naroml){
      
    }
    if (progress>0.5) {
        [_cancelTimer invalidate];_cancelTimer = nil;
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
    if ([self.delegate respondsToSelector:@selector(webViewLoadingPogress:)]) {
        [self.delegate webViewLoadingPogress:progress];
    }
}

- (NSString*)getWebUrl{
    return self.currentUrl;
}

- (void)fireDealy{
    if (self.webViewType==webView_Test0)  {
        [self  evaluateJavaScript:@"checkDealy();" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
            if (error) {
                NSLog(@"webView_Test0 = checkDealy %@",[error description]);
            }
        }];
        if (![self viewWithTag:10]) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 10;btn.backgroundColor = RGBCOLOR(0, 0, 0);
#if DEBUG
            btn.alpha = 0.5;
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitleColor:RGBCOLOR(255, 0, 0) forState:UIControlStateNormal];
            [btn setTitle:[self.webView.URL absoluteString] forState:UIControlStateNormal];
#else
            [btn setTitle:@"视频正在搜索中,请选择时间较长的播放" forState:UIControlStateNormal];
#endif
            [self addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
}

- (void)webViewOpenInAppStore:(NSURL*)url{
    
}

- (void )webViewOpenInCall:(NSURL*)url{
    
}

-(void)openOtherApp:(NSURL*)url decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)didFailLoadWithError:(NSError *)error{
    if (!self.isOperation) {
        [self fireDealy];
        return;
    }
    // #if !AX_WEB_VIEW_CONTROLLER_USING_WEBKIT
    if (error.code == NSURLErrorCannotFindHost) {// 404
        [self loadURL:[NSURL fileURLWithPath:kAX404NotFoundHTMLPath]];
    } else {
        [self loadURL:[NSURL fileURLWithPath:kAXNetworkErrorHTMLPath]];
    }
    // #endif
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(webViewWithError:didFailLoadWithError:)]) {
        [_delegate webViewWithError:self didFailLoadWithError:error];
    }
    [_progressView setProgress:0.9 animated:YES];
}
#pragma mark--webCallback

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if (navigationAction.request) {
            [webView loadRequest:navigationAction.request];
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
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:NULL];
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
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{}];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{

    
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    if (self.webViewType==webView_Naroml && [self.delegate respondsToSelector:@selector(webViewUpDataAsset:)]) {
     }
        
    NSDictionary *dictNU = [[NSDictionary alloc] initWithObjectsAndKeys:IosIphoneOldUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictNU];
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_delegate webViewDidStartLoad:self];
    }
    [self fireDealy];
}

- (void)webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error{
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'" completionHandler:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_delegate webViewDidFinishLoad:self];
    }
    [self _updateUrl:webView.URL.absoluteString host:webView.URL.host];
     if (self.webViewType == webView_Test) {
    }
    [self fireDealy];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webCallNode_webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
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
    NSString *scheme = url.scheme;
//    for (int i = 0; i < GetAppDelegate.param9.count; i++) {
//        if ([[url absoluteString] rangeOfString:[GetAppDelegate.param9 objectAtIndex:i]].location!=NSNotFound) {
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//    }
    if ([scheme isEqualToString:@"http"] ||
        [scheme isEqualToString:@"https"]) {
        if([self isAppStoreLink:url]){
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    else{
        WKNavigationActionPolicy v = WKNavigationActionPolicyCancel;
               if ([[url absoluteString] rangeOfString:@"MajorWeb.app/zymywww/"].location!=NSNotFound) {
                   v = WKNavigationActionPolicyAllow;
               }
        decisionHandler(v);
        return;
    }
    if (!navigationAction.targetFrame.isMainFrame) {
        [self evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    if (navigationAction.navigationType==WKNavigationTypeLinkActivated) {//点击事件
        if([self.clickDelegate respondsToSelector:@selector(webViewClick:)]&&[self.clickDelegate webViewClick:[url absoluteString]]){
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    if (([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/' OR SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString])) {
        if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/'"] evaluateWithObject:components.URL.absoluteString] && !_reviewsAppInAppStore) {
            /*
            [[AXPracticalHUD sharedHUD] showNormalInView:self text:nil detail:nil configuration:^(AXPracticalHUD *HUD) {
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
                        [[AXPracticalHUD sharedHUD] showErrorInView:self text:error.localizedDescription detail:nil configuration:^(AXPracticalHUD *HUD) {
                            HUD.removeFromSuperViewOnHide = YES;
                        }];
                        [[AXPracticalHUD sharedHUD] hide:YES afterDelay:1.5 completion:NULL];
                    } else {
                        [[AXPracticalHUD sharedHUD] hide:YES afterDelay:0.5 completion:NULL];
                    }
                }];
                [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:productVC animated:YES completion:NULL];
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
            }*/
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
    }
    } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {// For any other schema but not `https`、`http` and `file`.
       // if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
       //     [[UIApplication sharedApplication] openURL:components.URL];
       // }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([[NSPredicate predicateWithFormat:@"SELF ENDSWITH[cd] %@ OR SELF ENDSWITH[cd] %@", kAX404NotFoundURLKey, kAXNetworkErrorURLKey] evaluateWithObject:components.URL.absoluteString]) {
        // Reload the original URL.
        [self loadURL:[NSURL URLWithString:@"http://image.so.com/i?q=%E6%BD%AE%E6%B5%81%E5%A3%81%E7%BA%B8&src=srp#/"]];
    }
    if(!navigationAction.targetFrame)//在新标签里面打开
    {
        
        decisionHandler(WKNavigationActionPolicyCancel);//20180605 WKNavigationActionPolicyCancel->WKNavigationActionPolicyAllow
        [webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
        return;
    }
    [self fireDealy];
    decisionHandler(WKNavigationActionPolicyAllow+2);
}


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))
decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
     if([message.name compare:@"VideoHandler"]==NSOrderedSame)
    {
       
        if([message.body isKindOfClass:[NSDictionary class]] && self.webViewType!=webView_Test) {
            self.externParam = [message.body objectForKey:@"src"];
            self.webViewType = webView_Test;
            if (@available(iOS 10.0, *)) {
                self.webView.configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
            } else {
                // Fallback on earlier versions
            }
            if ([self.externDelegate respondsToSelector:@selector(webViewExternCallBack:uuid:assetKey:)]) {
                [self.externDelegate webViewExternCallBack:true uuid:self.uuid assetKey:self.externParam];
            }
            //不走网页判断时间
            //[self loadURL:[NSURL URLWithString:@"https://softhome.oss-cn-hangzhou.aliyuncs.com/max/help/test/sample/h5.html"]];
        }
    }
    else if ([message.name compare:@"PostAssetInfo"]==NSOrderedSame){
        if([self.postMoreInfoDelegate respondsToSelector:@selector(webViewPostAssetInfoCallBack:)])
            [self.postMoreInfoDelegate webViewPostAssetInfoCallBack:(NSDictionary*)message.body];
    }
    else if([message.name compare:@"sendMessageGetPicFromPagWeb"]==NSOrderedSame){
        if ([self.externDelegate respondsToSelector:@selector(webViewGetPicsFromPagWebCallBack:uuid:ret:)]) {
            [self.externDelegate webViewGetPicsFromPagWebCallBack:true uuid:self.uuid ret:message.body];
        }
    }
    else if([message.name compare:@"sendMessageSetWordSuccess"]==NSOrderedSame){
        if ([self.externDelegate respondsToSelector:@selector(webViewSetWordSuucessCallBack:uuid:)]) {
            [self.externDelegate webViewSetWordSuucessCallBack:true uuid:self.uuid];
        }
    }
    else if ([message.name compare:@"sendMessageClickSuccess"]==NSOrderedSame){
        if ([self.externDelegate respondsToSelector:@selector(webViewSetClickSuccessCallBack:uuid:)]) {
            [self.externDelegate webViewSetClickSuccessCallBack:true uuid:self.uuid];
        }
    }
    else if ([message.name compare:@"clickWebsImage"]==NSOrderedSame){
        if ([self.delegate respondsToSelector:@selector(webViewClickWebsFromImage:)]) {
            [self.delegate webViewClickWebsFromImage:message.body];
        }
    }
}

@end
