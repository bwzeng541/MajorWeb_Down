//
//  WebViewBase.m
//  WatchApp
//
//  Created by zengbiwang on 2017/4/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "WebViewBase.h"
#import "AppDelegate.h"
#import "MajorSchemeHelper.h"
#import "FTWCache.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"

@implementation UIWebViewTv
-(void)dealloc{
    GGLog(@"%s",__FUNCTION__);
}
@end
#if (UserWKWebView!=1)

@interface WebViewBase()<UIWebViewDelegate,NJKWebViewProgressDelegate>{
#else
@interface WebViewBase()<WebCoreManagerDelegate>{
#endif
    float progressValue;
    BOOL isFinished;
    
}
@property (nonatomic,copy)NSString *html;
@property (nonatomic,copy)NSString *url;
@property (nonatomic,strong)MajorWebView *webView;
@end

@implementation WebViewBase

-(void)initOtherParam{
        self.isCanShowWaitView = true;
}
    
    
-(void)getWebTitle:(void(^)(NSString *title))titleBlock{
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id re, NSError * _Nullable error) {
        titleBlock(re);
    }];
}
    
-(id)initWithUrl:(NSString*)url html:(NSString*)html showName:(NSString*)showName isShowFailMsg:(BOOL)f hidenParentView:(UIView*)view{
    [self initOtherParam];
    self.url = url;
    self.html = html;
    self.waitView = view;
    self.isShowFailMsg = f;
    GGLog(@"WebViewBase = %@",url);
    self.showName = showName;
    self.isAutoRemovePlayFution = true;
    return self;
}


-(void)updateUrl{
    [self.webViewLoadFinshTimer invalidate];
    _webViewLoadFinshTimer = nil;
    [self.checkVideoTimer invalidate];
    self.checkVideoTimer = nil;
    self.msgBlock = nil;
}


-(void)dealloc{
    if(self.isCanShowWaitView){
#if DoUseWaitView
        if (self.isShowFailMsg) {
            if (self.waitView)
            {
            HiddenHUDOnViewUsePng
            }
            else
            [YSCHUDManager hideHUDOnKeyWindow];
        }
#endif
    }
    GGLog(@"%s",__FUNCTION__);
    if (self.isAutoRemovePlayFution) {
       
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self cleanWebView];
    [self.webView removeFromSuperview];
    self.url = nil;
    self.showName = nil;
}

-(void)checkVideo{
    [self checkVideoUrl:self.webView];
}

-(NSString*)chaoshichuli{
    [self.webViewLoadFinshTimer invalidate];
    _webViewLoadFinshTimer = nil;
    [self.checkVideoTimer invalidate];
    self.checkVideoTimer = nil;
    if(self.msgBlock){
        self.msgBlock(nil);
    }
    self.msgBlock = nil;
    return nil;
}

-(void)stop{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self updateUrl];
}

-(void)cleanWebView{
#if (UserWKWebView==1)
    [self UnintExtendWebConfig];
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.webView];
    RemoveViewAndSetNil(self.webView)
    self.msgBlock = nil;
#endif
}
    
-(void)start{
    isFinished = false;
    progressValue = 0;
#if DoUseWaitView
    if(self.isCanShowWaitView)
    {
        if (self.waitView)
        {
            ShowHUDOnViewUsePng
        }
        else{
            [YSCHUDManager showHUDOnKeyWindowWithMesage:@"视频加载中..."];
        }
    }
#endif
     [self cleanWebView];
    _webViewLoadFinshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(chaoshichuli) userInfo:nil repeats:NO];
    _checkVideoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkVideo) userInfo:nil repeats:YES];
 #if (UserWKWebView!=1)
    RemoveViewAndSetNil(self.webView)
    self.webView = [[UIWebViewTv alloc]initWithFrame:CGRectMake(0, 10000, 200, 200)];
    webViewProgress = [[NJKWebViewProgress alloc] init]; // instance variable
    self.webView.delegate = webViewProgress;
    webViewProgress.webViewProxyDelegate = self;
    webViewProgress.progressDelegate = self;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.allowsInlineMediaPlayback = true;
#else
    self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
    self.webView.frame = CGRectMake(0, 20000, 320, 480);
    [self InitExtendWebConfig];
#endif
    if(self.url&&!self.html){
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [self.webView loadRequest:request];
    }
    else if (self.html&&self.url){
        if (@available(iOS 9.0, *)) {
            self.webView.customUserAgent = IosMicroMessagerUserAnent;
        } else {
            // Fallback on earlier versions
        }
        [self.webView loadHTMLString:self.html baseURL:[NSURL URLWithString:self.url]];
    }
    [GetAppDelegate.getRootCtrlView addSubview:self.webView];
}

-(void)InitExtendWebConfig{
        
}
    
-(void)UnintExtendWebConfig{
        
}
    
-(void)checkVideoUrl:(UIWebView*)webView{
    
}
    
-(void)webViewBaseDidFinishLoad:(UIWebView*)webView{
        [self.webViewLoadFinshTimer invalidate];
        _webViewLoadFinshTimer = nil;
        [self.checkVideoTimer invalidate];
        self.checkVideoTimer = nil;
    }

#if (UserWKWebView!=1)

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    progressValue = progress;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (/*progressValue>=0.5 && */!isFinished) {
        isFinished = true;
        [self webViewBaseDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    
}

    
#else
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    GGLog(@"webViewWebContentProcessDidTerminate WebViewBase");
    [self.webView reload];
}

    
- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
    {
        if (/*progressValue>=0.5 && */!isFinished && !self.msgBlock) {
            isFinished = true;
            [self webViewBaseDidFinishLoad:webView];
        }
    }
    
    
    - (void)webCore_userContentController:(WKUserContentController *)userContentController
didReceiveScriptMessage:(WKScriptMessage *)message;
{
        if([message.name compare:@"VideoHandler"]==NSOrderedSame)
        {
            if ([message.body isKindOfClass:[NSString class]]) {
                return;
            }
            if ([message.body isKindOfClass:[NSDictionary class]]) {
                NSDictionary *info = message.body;
                NSString *videoUrl   =  [info objectForKey:@"src"];
                if(self.msgBlock){
                    self.msgBlock(videoUrl);
                }
        }
    }
}
#endif
    
-(void)setWebDebugFrame:(CGRect)rect parentView:(UIView *)view
{
    [self.webView removeFromSuperview];
    [view addSubview:self.webView];
    self.webView.frame = rect;
}

@end
