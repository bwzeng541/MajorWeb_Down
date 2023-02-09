//
//  SearchWebView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/18.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "SearchWebView.h"
#import "WebCoreManager.h"
#import "MajorWebView.h"
#import "AppDelegate.h"
@interface SearchWebView()<WebCoreManagerDelegate>
@property(strong,nonatomic)MajorWebView *webView;
@property(strong,nonatomic)UIProgressView *webProgressView;
@end

@implementation SearchWebView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame url:(NSString*)url{
    self = [super initWithFrame:frame];
    self.webProgressView = [[UIProgressView alloc]
                            initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH,
                                                     self.frame.size.width, 2)];
    self.webProgressView.progressTintColor =RGBCOLOR(255, 0, 0); // ProgressTintColor;
    self.webProgressView.trackTintColor = [UIColor blackColor];
    self.webProgressView.alpha = 1;

    self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
    self.webView.frame = self.bounds;
    [self addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self addSubview:self.webProgressView];
    UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:maskView];
    maskView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
    return self;
}

-(void)removeFromSuperview{
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.webView];
    RemoveViewAndSetNil(self.webView);
    [super removeFromSuperview];
}

- (void)webCore_webViewLoadProgress:(float)progress{
     [self updateProcessbar:progress animated:YES];
}

- (void)updateProcessbar:(float)progress animated:(BOOL)animated {
    if (progress == 1.0) {
        [self.webProgressView setProgress:progress animated:animated];
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.webProgressView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [self.webProgressView setProgress:0.0 animated:NO];
                             }
                         }];
    } else {
        if (self.webProgressView.alpha < 1.0) {
            self.webProgressView.alpha = 1.0;
        }
        [self.webProgressView setProgress:progress
                                 animated:(progress > self.webProgressView.progress) && animated];
    }
}
@end
