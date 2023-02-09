//
//  TJLiancePlug.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "TJLiancePlug.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"
#import "MarjorWebConfig.h"
#import "MainMorePanel.h"

#define TJLiancePlugKey @"sfdusuuuTh-_duud"
static TJLiancePlug *g = nil;
@interface TJLiancePlug()<WebCoreManagerDelegate>
@property(strong,nonatomic)MajorWebView *webView;
@end
@implementation TJLiancePlug
+(TJLiancePlug*)autoInitPlug{
    if (!g) {
        g = [[TJLiancePlug alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    return self;
}

-(void)autoInit{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayInit:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRemove:) object:nil];
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.webView];
    self.webView = nil;
    NSString *vv = [[NSUserDefaults standardUserDefaults] objectForKey:TJLiancePlugKey];
    TjLiance *v =  [MainMorePanel getInstance].morePanel.tjLiance;
    
    if (!vv || ([vv compare:v.vesion]!=NSOrderedSame)) {
        if(v.url && [MarjorWebConfig isValid:v.beginTime a2:v.endTime]){
            [self performSelector:@selector(delayInit:) withObject:nil afterDelay:[v.fireTime floatValue]];
        }
    }
}

-(void)delayInit:(NSNumber*)object{
    self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager] createWKWebViewWithUrl:nil isAutoSelected:NO delegate:self];
    self.webView.frame = CGRectMake(0, 10000, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[MainMorePanel getInstance].morePanel.tjLiance.url]]];

}

- (BOOL)webCore_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return true;
    }
    
    if (url) {
        NSString *scheme = url.scheme;
        if (scheme) {
            if ([scheme isEqualToString:@"http"] ||
                [scheme isEqualToString:@"https"])
            {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
            else if ([scheme isEqualToString:@"tel"]){
                
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else if ([scheme isEqualToString:AppTeShuPre]) {
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
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
    return true;
}

- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self performSelector:@selector(delayRemove:) withObject:[NSNumber numberWithBool:true] afterDelay:10];
}

- (void)webCore_webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self performSelector:@selector(delayRemove:) withObject:[NSNumber numberWithBool:false] afterDelay:10];
}

-(void)delayRemove:(NSNumber*)isSave{
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.webView];
    self.webView = nil;
    if ([isSave boolValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:[MainMorePanel getInstance].morePanel.tjLiance.vesion forKey:TJLiancePlugKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
