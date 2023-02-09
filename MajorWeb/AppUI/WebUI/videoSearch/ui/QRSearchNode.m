//
//  QRSearchNode.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRSearchNode.h"
#import "QRWKWebview.h"
#import "AppDevice.h"
#import "QRWebBlockManager.h"
@interface QRSearchNode()<QRWKWebviewDelegate>
@property(strong)NSDictionary *info;
@property(assign)BOOL isGet;
@property(strong)QRWKWebview *wbWebView;
@end

//        addTabLoadTask("http://4kdy.net/index.php/search/index?wd="+filmName, 1);

@implementation QRSearchNode

-(void)dealloc{
#ifdef DEBUG
    printf("%s\n",__FUNCTION__);
#endif
}
-(id)initWithParam:(NSDictionary*)info parentView:(UIView*)parentView{
    self = [super init];
    self.wbWebView = [[QRWKWebview alloc] initWithFrame:CGRectMake(0, -1000, 375, 878) uuid:nil userAgent:nil isExcutJs:true];
    self.info = info;
    self.wbWebView.qrWkdelegate = self;
    [parentView addSubview:self.wbWebView];
    //[[QRSystemConfig shareInstance].qrRootCtrl.view addSubview:self.wbWebView];
    return self;
}

-(void)start{
    NSString *type = [self.info objectForKey:QRSearch_Type_Key];
    self.isGet = ([type compare:@"GET"]==NSOrderedSame)?true:false;
    if (self.isGet) {
        NSString *word = [self.info objectForKey:QRSearch_Word_Key];
        word = [word stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [NSString stringWithFormat:@"%@%@",[self.info objectForKey:QRSearch_Url_Key],word];
        [self.wbWebView loadUrl:url];

    }
}

-(void)stop{
    //[[QRWebBlockManager shareInstance] remveQrWebObser:self.wbWebView.webView];
    [self.wbWebView removeFromSuperview];
    self.wbWebView = nil;
}

-(void)qrDidFinishNavigation:(NSString *)url title:(NSString *)title {
    __weak __typeof(self)weakSelf = self;
    [self.wbWebView.webView evaluateJavaScript:@"getSearchResult()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
               if (!error) {
                   [self.delegate qrSearchRevice:ret object:weakSelf];
               }
    }];
}
@end
