//
//  Web47ViewNode.m
//  WatchApp
//
//  Created by zengbiwang on 2017/4/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "Web47ViewNode.h"
#import "ReactiveCocoa.h"
#import "AppDelegate.h"
#import "Url47ChangeNode.h"
#import "BlocksKit.h"
#import "WebUrlHandleNode.h"
#import "VideoUrlHandleNode.h"
@interface Web47ViewNode()<UIWebViewDelegate>{
    VideoUrlHandleNode *videoUrlNode;
}
@property(nonatomic,assign)BOOL isPostWeb47;
@property(nonatomic,strong) Url47ChangeNode *url47ChangeNode;
@property(nonatomic,copy)NSString *phoneHtmlUrl;
@property(nonatomic,copy)NSString *pareAPIHttp;
@property(nonatomic,copy)NSString *firstVideoUrl;
@property(nonatomic,assign)BOOL forceUrl47Node;
@property(nonatomic,assign)BOOL isBatch;
@property(nonatomic,strong)WebUrlHandleNode *webHandlNode;
@property(nonatomic,copy)NSString *htmlBody;
@end

@implementation Web47ViewNode
-(void)dealloc{
    self.realUrl = nil;self.htmlUrl = nil;
    self.htmlBody = nil;
    self.iosUserAnget = nil;self.firstVideoUrl = nil;
    self.phoneHtmlUrl = nil;self.pareAPIHttp = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);
}

-(id)initWithUrl:(NSString*)url firstVideo:(NSString*)firstVideo showName:(NSString*)showName pareApihttp:(NSString*)apiHttp htmlBody:(NSString*)htmlBody isShowFailMsg:(BOOL)f forceUrl47Node:(BOOL)_f isDirectApi:(BOOL)_isDirectApi isBatch:(BOOL)isBatch{
    [self initOtherParam];
    self.phoneHtmlUrl = url;
    self.isShowFailMsg = f;
    self.pareAPIHttp = apiHttp;
    self.firstVideoUrl = [firstVideo length]>10?firstVideo:nil;
    self.forceUrl47Node = _f;
    self.isDirectApi = _isDirectApi;
    self.htmlBody = htmlBody;
    self.isBatch = isBatch;
    self.isGoToBatchPip = false;
   // [AVPlayer initFution3:true];
    return self;
}

-(void)stop{
    [videoUrlNode clearJs];
    videoUrlNode = nil;
    [self.webHandlNode clearJs];
    self.webHandlNode = nil;
    [self cleanWebView];
    [super stop];
}
//先请求转换html数据
-(void)start{
#if DoUseWaitView
    [YSCHUDManager showHUDOnKeyWindowWithMesage:@"视频加载中..."];
#endif
    
    if(!self.isDirectApi)
    {
        [self setUserAgent:self.iosUserAnget];
        if (!self.isBatch) {
            [super initWithUrl:self.phoneHtmlUrl html:nil showName:@"ss" isShowFailMsg:true hidenParentView:nil];
            [super start];
        }
        else{
            self.isGoToBatchPip = true;
        }
        self.isAutoRemovePlayFution = false;
        return;
    }
    if (self.isNoPcWeb) {
        [self htmlUrlRealChuli:self.phoneHtmlUrl];
    }
    else
    {
        self.url47ChangeNode = [[Url47ChangeNode alloc]init];
        @weakify(self)
        [self.url47ChangeNode start:self.phoneHtmlUrl faildBlock:^{
            @strongify(self)
            self.url47ChangeNode = nil;
            [self chaoshichuli];
        } Success:^(id url) {
            @strongify(self)
            [self htmlUrlRealChuli:url];
        }];
    }
}

-(void)htmlUrlRealChuli:(NSString*)url{
    if ([url isEqualToString:@"about:blank"]) {
        url = self.phoneHtmlUrl;
    }
    if (!self.webHandlNode) {
        @weakify(self)
        self.webHandlNode = [[WebUrlHandleNode alloc]init];
        [self.webHandlNode startJs:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WebUrlHandleNode" ofType:@"js"] encoding:NSUTF8StringEncoding error:NULL] url:url parseApi:self.pareAPIHttp htmlBody:self.htmlBody finishBlock:^(id url) {
            @strongify(self)
            [self webHandlNodeFinish:url];
        }];
    }
}

//需要传递
-(void)webHandlNodeFinish:(NSString*)url{
    self.htmlUrl = url;
    self.url47ChangeNode = nil;
    [self setUserAgent:self.iosUserAnget];
    NSLog(@"UrlChangeOk = %@   %@",self.htmlUrl,self.phoneHtmlUrl);
    if (self.isBatch)
    {
        self.isGoToBatchPip = true;
        return;
    }
    if (self.forceUrl47Node ||
        (!self.firstVideoUrl || [self.htmlUrl compare:self.phoneHtmlUrl] != NSOrderedSame))
    {
        [super initWithUrl:[NSString stringWithFormat:@"%@%@",self.pareAPIHttp,url] html:nil showName:@"ss" isShowFailMsg:self.isShowFailMsg hidenParentView:nil];
        [super start];
    }
    else{
        [self bk_performBlock:^(id obj) {
            self.isShowFailMsg = true;
            self.realUrl = self.firstVideoUrl;
        } afterDelay:0.2];
    }
    self.isAutoRemovePlayFution = false;
}

-(void)setUserAgent:(NSString*)userAgent{
    return;
    NSString *newUagent = userAgent;
    NSDictionary *dictionary = [[NSDictionary alloc]
                                initWithObjectsAndKeys:newUagent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

-(NSString*)chaoshichuli{
    //return nil;

    if ([self.firstVideoUrl length]>10) {
        self.isShowFailMsg = true;
        self.realUrl = self.firstVideoUrl;
        return nil;
    }
    NSString *str  = [super chaoshichuli];
    if(!str ){
        if (self.isShowFailMsg)
        [KEY_WINDOW makeToast:@"视频原因无法播放" duration:1 position:@"center" ];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"VideoParseFail" object:nil];
    }
    else{
        self.isShowFailMsg = true;
        self.realUrl = str;
    }
    return nil;
}


//调用api必须每秒检查数据
-(void)checkVideoUrl:(UIWebView*)webView{
    [self webViewBaseDidFinishLoad:webView];
}

-(void)webViewBaseDidFinishLoad:(UIWebView*)webView{
#if (UserWKWebView!=1)
    NSString *lm3u8 = [webView stringByEvaluatingJavaScriptFromString:@"(document.getElementsByTagName('video')[0]).src"];
    if ([lm3u8 length] > 10) {
        [super webViewBaseDidFinishLoad:webView];
        self.isShowFailMsg = true;
        self.realUrl = lm3u8;
    }
    else{
       // [[NSNotificationCenter defaultCenter]postNotificationName:@"VideoParseFail" object:nil];
    }
#endif
}

#if (UserWKWebView==1)

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if (!self.isPostWeb47) {
        NSLog(@"message.body : %@ \nmessage.name:%@", message.body, message.name);
        self.isPostWeb47 = true;

        NSString *postUrl= nil;
        if(![[message.body objectForKey:@"originalURL"] isKindOfClass:[NSNull class]]){
            postUrl = [message.body objectForKey:@"originalURL"];
        }
        else{
            postUrl = [[[message.body objectForKey:@"source"] objectAtIndex:0] objectForKey:@"url"];
        }
        if ([postUrl length]<5) {
            return;
        }
        __weak typeof(self)weakSelf = self;
        [super chaoshichuli];
        videoUrlNode = [[VideoUrlHandleNode alloc]init];
        [videoUrlNode startJs:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VideoUrlHandleNode" ofType:@"js"] encoding:NSUTF8StringEncoding error:NULL] videoUrl:postUrl finishBlock:^(id url) {
            [weakSelf postNewUrl:url];
        }];
//        NSURL*url = [NSURL URLWithString:postUrl];
//        self.isShowFailMsg = true;
//        self.realUrl = [url absoluteString];
    }
   // [self cleanWebView];
}


-(void)postNewUrl:(NSString*)url
{
    
    if ([url length]>5)
    {
        self.isShowFailMsg = true;
        self.realUrl = url;
    }
    else{
         [super chaoshichuli];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"VideoParseFail" object:nil];
    }
    [videoUrlNode clearJs];
    videoUrlNode = nil;
    self.isPostWeb47 = false;
}
#endif
@end
