//
//  ZyBrigdgenode.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/23.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ZyBrigdgeNode.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"

@interface ZyBrigdgeNode()<WebCoreManagerDelegate>
@property(assign,nonatomic)BOOL isExctjJs;
@property(copy,nonatomic)NSString *webUrl;
@property(assign,nonatomic)NSInteger type;
@property(strong,nonatomic)MajorWebView *pareseWebView;
@end

@implementation ZyBrigdgeNode
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)startUrl:(NSString*)url type:(NSInteger)type{
    if (!self.pareseWebView) {
        self.pareseWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager] createWKWebViewWithUrl:nil isAutoSelected:NO delegate:self];
        [[UIApplication sharedApplication].keyWindow addSubview:self.pareseWebView];
        self.pareseWebView.frame = CGRectMake(0,MY_SCREEN_HEIGHT*10,MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT);
    }
    self.type = type;
    self.webUrl = url;
    NSLog(@"self.index  url = %@",url);
    [self.pareseWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)stopLoading{
    [self.pareseWebView stopLoading];
}

-(void)stop
{
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.pareseWebView];
    self.pareseWebView = nil;
}

-(void)tryTopGetInfo{
    __weak __typeof__(self) weakSelf = self;
    [self.pareseWebView evaluateJavaScript:[NSString stringWithFormat:@"__webjsNodePlug__.getWebLists(\'%@\')",self.webUrl] completionHandler:^(id ret, NSError * _Nullable error) {
        weakSelf.isExctjJs = false;
        if (weakSelf.type==0) {
            [weakSelf.delegate updateListArray:[ret objectForKey:@"retArray"]];
            [weakSelf.delegate updateDomContent:[ret objectForKey:@"dom"] url:self.webUrl];
        }
        else if(weakSelf.type==1){
            [weakSelf.delegate updateDomContent:[ret objectForKey:@"dom"] url:self.webUrl];
        }
    }];
}

- (void)webCore_webViewLoadProgress:(float)progress{
    if (!self.isExctjJs && progress>=0.6) {
             self.isExctjJs = true;
        [self tryTopGetInfo];
        }
}


-(void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self tryTopGetInfo];
}
@end
