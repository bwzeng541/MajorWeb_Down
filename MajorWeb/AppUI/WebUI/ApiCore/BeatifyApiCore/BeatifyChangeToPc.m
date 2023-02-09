//
//  BeatifyChangeToPc.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/29.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyChangeToPc.h"
#import "BeatifyWebView.h"
#import "AppDelegate.h"
@interface BeatifyChangeToPc()<BeatifyWebViewDelegate>
{
    float progressValue;
}
@property(assign,nonatomic)BOOL  isevaluateJs;
@property(copy,nonatomic)NSString *asset;
@property(copy,nonatomic)NSString *assetNew;
@property(strong,nonatomic)NSTimer *delayTimer;
@property(copy,nonatomic)void(^callBack)(NSString *realAsset);
@property (nonatomic,strong)BeatifyWebView *beatifyWebView;
@end

@implementation BeatifyChangeToPc

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)startWithAsset:(NSString*)url callBack:(void(^)(NSString *realAsset))CallBack{
     self.beatifyWebView = [[BeatifyWebView alloc] initWithFrame:CGRectMake(0, 100000, 320,  480)isShowOpUI:false];
    [self.beatifyWebView setWebViewType:webView_TestChange];
    [self.beatifyWebView loadWebView];
    self.callBack = CallBack;
    self.beatifyWebView.delegate = self;
    self.asset = url;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.beatifyWebView];
    [self.beatifyWebView enableWebSrollview:false];
    [self.beatifyWebView isOperationError:false];
    self.beatifyWebView.webView.customUserAgent = PCUserAgent;
    [self.beatifyWebView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(delayFaild:) userInfo:nil repeats:YES];
}

-(void)delayFaild:(NSTimer*)timer{
    if (self.assetNew) {
        if (self.callBack) {
            self.callBack(self.assetNew);
        }
    }
    else{
        if (self.callBack) {
            self.callBack(self.asset);
        }
    }
    [self.delayTimer invalidate];self.delayTimer = nil;
}

-(void)isAssetFinish:(WKWebView*)webView{
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSLog(@"userAgent :%@", result);
    }];
    __weak __typeof(self)weakSelf = self;
    if (progressValue >= 0.8 && !self.isevaluateJs ) {
        [webView evaluateJavaScript:@"document.location.href" completionHandler:^(NSString* reulst, NSError *  error) {
            if ([reulst rangeOfString:@"http"].location!=NSNotFound && [reulst compare:self.asset]!=NSOrderedSame) {
                NSLog(@"userAgent http:%@", reulst);
                    weakSelf.isevaluateJs = true;
                if (!weakSelf.assetNew) {
                    weakSelf.assetNew = reulst;
                }
                    if (weakSelf.callBack) {
                        weakSelf.callBack(weakSelf.assetNew);
                    }
            }
        }];
    }
}

- (void)webViewDidFinishLoad:(BeatifyWebView *)webView{
    [self isAssetFinish:self.beatifyWebView.webView];
}

- (void)webViewLoadingPogress:(float)progress{
    progressValue = progress;
    [self isAssetFinish:self.beatifyWebView.webView];
}

- (void)webViewUrl:(NSString*)url{
    if ([url rangeOfString:@"http"].location!=NSNotFound && [url compare:self.asset]!=NSOrderedSame) {
        self.assetNew = url;
        if (!self.isevaluateJs) {
            self.isevaluateJs = true;
            if (self.callBack) {
                self.callBack(self.assetNew);
            }
        }
    }
}


-(void)unInitAsset{
    [self.delayTimer invalidate];self.delayTimer = nil;
    self.callBack = nil;
    self.beatifyWebView.delegate = nil;
    [self.beatifyWebView removeFromSuperview];
}
@end
