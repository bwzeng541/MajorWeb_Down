//
//  ReadModeWeb.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/29.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "ReadModeWeb.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"
#import "MarjorWebConfig.h"
#import "NSString+MKNetworkKitAdditions.h"
@interface ReadModeWeb()<WebCoreManagerDelegate>
@property(nonatomic,strong)MajorWebView *majorWebView;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *iconUrl;
@property(nonatomic,copy)NSString *currentUrl;

@property(nonatomic,strong)NSDictionary *contentInfo;
@property(nonatomic,strong)NSDictionary *nextInfo;

@end
@implementation ReadModeWeb

-(void)dealloc{
    
    NSLog(@"%s",__FUNCTION__);
}
-(void)removeFromSuperview{
    [[WebCoreManager getInstanceWebCoreManager]destoryWKWebView:self.majorWebView];
    self.majorWebView = nil;
    [super removeFromSuperview];
}

-(void)callContentBack{
    if ([self.contentDelegate respondsToSelector:@selector(readMoreWebContent:title:nextUrl:)]) {
        NSString *title = [self.contentInfo objectForKey:@"title"];
        NSString *content = [[self.contentInfo objectForKey:@"content"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *header = [NSString stringWithFormat:@"<div><h3>%@</h3></div>",title];
        content  = [NSString stringWithFormat:@"%@%@",header,content];
        [self.contentDelegate readMoreWebContent:content title:title nextUrl:[self.nextInfo objectForKey:@"next"]];
    }
}

-(void)getContentNovle{
    __weak typeof(self) weakSelf = self;
    [self.majorWebView evaluateJavaScript:@"window.__firefox__.reader.readerize()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        if ([ret isKindOfClass:[NSDictionary class]]) {
            weakSelf.contentInfo = ret;
            [weakSelf.majorWebView evaluateJavaScript:@"window.__firefox__.getNextPageAndIndexURL()" completionHandler:^(id _Nullable ret2, NSError * _Nullable error) {
                weakSelf.nextInfo = ret2;
                [weakSelf callContentBack];
            }];
        }else{
            NSLog(@"getContentNovle error=%@",ret);
        }
    }];
}
-(void)initReqestWeb{
    if (!self.majorWebView) {
        self.majorWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
        [self addSubview:self.majorWebView];
        [[WebCoreManager getInstanceWebCoreManager] updateVideoPlayMode:self.majorWebView isSuspensionMode:true];
        [[WebCoreManager getInstanceWebCoreManager] updateRuleListState:YES webView:self.majorWebView url:nil];
        [self.majorWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

-(void)stopNextPageLoad{
    [self.majorWebView evaluateJavaScript:@"window.__firefox__.nextPageStopLoading()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}

-(void)webSetVideoFloatingPageScrollOffset{
    [self.majorWebView evaluateJavaScript:@"window.__firefox__.setVideoFloatingPageScrollOffset(0)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}

-(void)hideAdsByLoadingPercent{
    [self.majorWebView evaluateJavaScript:@" window.__firefox__.hideAdsByLoadingPercent()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}
//隐藏广告
-(void)hiddenTopAd{
         [self.majorWebView evaluateJavaScript:@"window.__firefox__.setElementHidingArray(null,true,70,0,20,[\"cmt\", \"comment\", \"nav\", \"tab\", \"login\", \"signup\", \"regist\", \"toast\", \"share\", \"tip\", \"pop\", \"bar\", \"box\", \"user\", \"pass\", \"pwd\", \"search\", \"menu\", \"main\", \"side\", \"card\", \"content\", \"drop\", \"panel\", \"modal\", \"info\", \"dialog\", \"blur\", \"head\", \"footer\", \"input\", \"tool\", \"page\", \"map\", \"post\", \"album\", \"item\", \"refresh\", \"load\"],[\"baidu.com\", \"weibo.cn\", \"google.com\", \"translate.google\", \"qq.com\", \"neets.cc\", \"avgle.com\"],'')" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
}

-(void)fireScoll{
    [self.majorWebView evaluateJavaScript:@"window.__firefox__.setTouchToScrollEnable(true,100)" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}

-(void)webGetFavicon{
    [self.majorWebView evaluateJavaScript:@"__firefox__.favicon.getFavicon()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}

- (void)webCore_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    self.currentUrl = webView.URL.absoluteString;
    [self fireScoll];
}


-(void)loadUrl:(NSString*)url{
    [self initReqestWeb];
    [self stopNextPageLoad];
    [self.majorWebView stopLoading];
    [self.majorWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)webCore_webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    [self hiddenTopAd];
    [self.majorWebView evaluateJavaScript:@"window.__firefox__.forceReaderMode = true" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    [self fireScoll];
    [self webSetVideoFloatingPageScrollOffset];
    [self stopNextPageLoad];
}

- (void)webCore_webViewLoadProgress:(float)progress{
    [self hideAdsByLoadingPercent];
}

- (void)webCore_webViewUrlChange:(NSString*)url{
    
}

-(void)webCore_webViewTitleChange:(NSString*)url{
    
}

- (BOOL)webCore_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    [self webGetFavicon];
    [self fireScoll];
    self.currentUrl = webView.URL.absoluteString;
    return false;
}

- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
   
    [self webGetFavicon];
    [self.majorWebView evaluateJavaScript:@" window.__firefox__.reader.checkReadability()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    [self getContentNovle];
    [MarjorWebConfig updateDB:self.title withFavicon:self.iconUrl withUrl:webView.URL.absoluteString];
}


- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name compare:@"faviconMessageHandler"]==NSOrderedSame) {
        NSArray *array = [message.body componentsSeparatedByString:@":#:"];
        if (array.count>0) {
            self.currentUrl = [array objectAtIndex:0];
             if (array.count>1) {
                self.iconUrl = [array objectAtIndex:1];
            }
        }
    }
    else if([message.name compare:@"spotlightMessageHandler"]==NSOrderedSame){
        NSDictionary *info = message.body;
        self.title = [info objectForKey:@"title"];
        
    }
    else if ([message.name compare:@"readerModeMessageHandler"]==NSOrderedSame){
        NSString *type = [message.body objectForKey:@"Type"];
        if([type compare:@"ReaderModeStateChange"] ==NSOrderedSame)
        {
           
        }
        else if ([type compare:@"LoadingNextPage"]==NSOrderedSame){
            NSString *value = [message.body objectForKey:@"Value"];//单独创建一个web请求数据
            if (value) {
                
            }
        }
    }
}

@end
