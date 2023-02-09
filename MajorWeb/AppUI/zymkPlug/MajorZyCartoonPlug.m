//
//  MajorZyCartoonView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/9.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZyCartoonPlug.h"
#import "WebCoreManager.h"
#import "MajorWebView.h"
#import "MajorWebView+WebCookie.h"
#import "MajorZyListView.h"
#import "NSObject+UISegment.h"
#import "NSDate+DateTools.h"
#import "MajorZyCookie.h"
#import "MajorZyContentList.h"
#import "VipPayPlus.h"
#import "MajorZyPlug.h"
#import "MajorZyParseNode.h"
#import "Toast+UIView.h"
#import "WebTopChannel.h"
#import "MainMorePanel.h"
#import "VideoPlayerManager.h"
#import "AppDelegate.h"
static NSArray *majorZtSortArray = NULL;
static NSInteger cartoonPlugIndex = -1;
@interface MajorZyCartoonPlug()<WebCoreManagerDelegate,MajorZyParseNodeDelegate>
@property(strong,nonatomic)UIProgressView *webProgressView;
@property(strong,nonatomic)MajorWebView *majorWebView;
@property(strong,nonatomic)UIView *bottomTools;
@property(strong,nonatomic)UIButton *btnSort;
@property(strong,nonatomic)WebTopChannel *webTopcChannel;
@property(strong,nonatomic)MajorZyListView *zylistView;
@property(strong,nonatomic)MajorZyContentList *zylistContentView;
@property(assign,nonatomic)NSInteger fireTime;
@property(strong,nonatomic)NSTimer *recordTimer;
@property(strong,nonatomic)NSDate *fireData;
@property(strong,nonatomic)MajorZyParseNode *parseNode;
@property(strong,nonatomic)ZyMkInfo *zyMkInfo;
@property(strong,nonatomic)ZyMkInfo *oldZyMkInfo;
@property(strong,nonatomic)NSArray *zyMkInfoArray;
@end
@implementation MajorZyCartoonPlug

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.parseNode stop];
    [[VipPayPlus getInstance] stopVideoAd];
    [self.recordTimer invalidate];self.recordTimer = nil;
    [MajorZyCookie delCookie];
    [self.majorWebView.configuration.userContentController removeScriptMessageHandlerForName:sendWebJsNodeMessageZySort];
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.majorWebView];
    self.majorWebView = nil;
    [super removeFromSuperview];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    //[MobClick event:@"manhua_btn"];
    initYYCache(@"majorZyCaches");
    [MajorZyCookie delCookie];
    UIView *topW = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, GetAppDelegate.appStatusBarH)];
    [self addSubview:topW];
    topW.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor blackColor];
    float toolsH = 46;
    self.bottomTools = [[UIView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-toolsH-(GetAppDelegate.appStatusBarH-20), MY_SCREEN_WIDTH, toolsH)];
    self.bottomTools.backgroundColor = [UIColor blackColor];
    [self addSubview:self.bottomTools];
    
    self.majorWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
    [self addSubview:self.majorWebView];
    [self.majorWebView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)self.majorWebView).callBackDelegate name:sendWebJsNodeMessageZySort];

    if (@available(iOS 11.0, *)) {
    }
    else{
        NSString*  cookie = @"document.cookie = 'readmode=3';\n";
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.majorWebView.configuration.userContentController addUserScript:cookieScript];
    }
 
    self.zyMkInfoArray = [MainMorePanel getInstance].morePanel.zyMkArray;
    if (self.zyMkInfoArray.count==0) {
        // self.homeUrl = @"http://m.zymk.cn";
        self.zyMkInfo = [[ZyMkInfo alloc] init];
        self.zyMkInfo.url = @"http://m.zymk.cn";
        self.zyMkInfo.isPage = @"1";
        self.zyMkInfo.name = @"默认漫画";
    }
    else{
        float hh = 25;
        if (IF_IPAD) {
            hh = 40;
        }
        self.webTopcChannel = [[WebTopChannel alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH,
                                                                              self.frame.size.width, hh)];
        [self addSubview:self.webTopcChannel];
       // self.webTopcChannel.delegate = self;
        [self.webTopcChannel updateTopArray:self.zyMkInfoArray];
        __weak __typeof(self)weakSelf = self;
        self.webTopcChannel.clickBlock = ^(ZyMkInfo *item) {
            weakSelf.zyMkInfo = item;
            weakSelf.oldZyMkInfo = item;
            [weakSelf loadHome];
        };
        self.webTopcChannel.backgroundColor = [UIColor blackColor];
        self.webTopcChannel.collectionView.backgroundColor = [UIColor blackColor];
        [self.webTopcChannel hiddenMore];
        if (cartoonPlugIndex==-1) {
            cartoonPlugIndex = arc4random() % self.zyMkInfoArray.count;
        }
        [self.webTopcChannel updateSelect:cartoonPlugIndex];
        self.zyMkInfo = [self.zyMkInfoArray objectAtIndex:cartoonPlugIndex];
     }
    self.oldZyMkInfo = self.zyMkInfo;
    self.webProgressView = [[UIProgressView alloc]
                            initWithFrame:CGRectMake(0, !self.webTopcChannel?GetAppDelegate.appStatusBarH:self.webTopcChannel.frame.origin.y+self.webTopcChannel.frame.size.height,
                                                     self.frame.size.width, 2)];
    self.webProgressView.progressTintColor =RGBCOLOR(255, 0, 0); // ProgressTintColor;
    self.webProgressView.trackTintColor = [UIColor blackColor];
    self.webProgressView.alpha = 1;
    [self addSubview:self.webProgressView];
    
    
    float webH = MY_SCREEN_WIDTH;
    self.majorWebView.frame = CGRectMake(0, self.webProgressView.frame.origin.y, webH, self.bottomTools.frame.origin.y-( self.webProgressView.frame.origin.y));
    
    [self initBtnsEvent];
    [self loadHome];
    self.fireData = [NSDate date];
    self.fireTime = 480;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkShowAd) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkVipStatus:) name:@"checkVipStatus" object:nil];
    return self;
}

-(void)checkVipStatus:(NSNotification*)object{
    [self addZyCartAlter];
}


-(void)addZyCartAlter{
    if ([VipPayPlus getInstance].systemConfig.vip == General_User) {
        TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否关闭提示框" message:nil];
        alertView.buttonFont = [UIFont systemFontOfSize:14];
        __weak __typeof(self)weakSelf = self;
        TYAlertAction *v  = [TYAlertAction actionWithTitle:@"退出"
                                                      style:TYAlertActionStyleCancel
                                                    handler:^(TYAlertAction *action) {
                                                        [weakSelf BackHome];
                                                    }];
        [alertView addAction:v];
        
        TYAlertAction *v0  = [TYAlertAction actionWithTitle:@"加入会员"
                                                     style:TYAlertActionStyleDefault
                                                   handler:^(TYAlertAction *action) {
                                                       [[VipPayPlus getInstance] show:false];
                                                   }];
        [alertView addAction:v0];

        
        TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"看完广告获得功能" style:TYAlertActionStyleDefault handler:^(TYAlertAction *action) {
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
            [[VipPayPlus getInstance] isVaildOperation:YES isShowAlter:NO plugKey:MajorPlugKey stopVideoAdBlock:^(BOOL isSuccess) {
                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                self.fireTime = arc4random()%400 + 600;
                self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkShowAd) userInfo:nil repeats:YES];
                self.fireData = [NSDate date];
            }];
        }];
        [alertView addAction:v1];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
    }
}

-(void)checkShowAd{
  //  if ([VipPayPlus getInstance].systemConfig.vip == General_User) {
  //      if (self.fireData && [[NSDate date] timeIntervalSinceDate:self.fireData]>self.fireTime) {
  //          self.fireData = nil;
   //         [self addZyCartAlter];
            [self.recordTimer invalidate];self.recordTimer = nil;
    //    }
   // }
}

- (BOOL)isValidGesture:(CGPoint)point{
    if (point.x<self.bounds.size.width/2) {
        return true;
    }
    return false;
}

- (UIButton*)createEventBtn:(SEL)action rect:(CGRect)rect title:(NSString*)title{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.backgroundColor = [UIColor clearColor];
    [self.bottomTools addSubview:btn];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = rect;
    return btn;
}

-(void)updateSortBtn{
    if (majorZtSortArray) {
        [self.btnSort setTitle:@"分类" forState:UIControlStateNormal];
    }
    else{
        [self.btnSort setTitle:@"loading" forState:UIControlStateNormal];
    }
}

-(void)BackHome{
    [self removeFromSuperview];
}

-(void)initBtnsEvent{
     UIButton *btnHome =  [self createEventBtn:@selector(BackHome) rect:CGRectZero title:@"返回"];
    UIButton *btnSort =  [self createEventBtn:@selector(loadSort) rect:CGRectZero title:@"loading"];
    self.btnSort = btnSort;
    [self updateSortBtn];
    UIButton *btnFavirot =  [self createEventBtn:@selector(showFavirot) rect:CGRectZero title:@"收藏"];
    UIButton *btnhistory =  [self createEventBtn:@selector(showHistory) rect:CGRectZero title:@"历史"];
    CGSize btnSize = CGSizeMake(60, _bottomTools.bounds.size.height);
    [NSObject initii:_bottomTools contenSize:_bottomTools.bounds.size vi:btnHome  viSize:btnSize vi2:nil index:0 count:4];
    [NSObject initii:_bottomTools contenSize:_bottomTools.bounds.size vi:btnSort  viSize:btnSize vi2:btnHome index:1 count:4];
    [NSObject initii:_bottomTools contenSize:_bottomTools.bounds.size vi:btnFavirot  viSize:btnSize vi2:btnSort index:2 count:4];
    [NSObject initii:_bottomTools contenSize:_bottomTools.bounds.size vi:btnhistory  viSize:btnSize vi2:btnFavirot index:3 count:4];

}

-(void)updateZyInfo:(NSString*)url{
    for (int i = 0; i < self.zyMkInfoArray.count; i++) {
       ZyMkInfo *info =  [self.zyMkInfoArray objectAtIndex:i];
        NSString *v1 = [[NSURL URLWithString:url] host];
        NSString *v2 = [[NSURL URLWithString:info.url] host];
        if (v1 && [v2 containsString:v1]) {
            self.oldZyMkInfo = self.zyMkInfo;
            self.zyMkInfo = info;
            break;
        }
    }
    
}

-(void)showConentlist:(NSString*)key{
    if (!self.zylistContentView) {
        [MajorZyCookie delCookie];
        __weak __typeof(self)weakSelf = self;
        self.zylistContentView = [[MajorZyContentList alloc]initWithFrame:self.bounds typeDes:key selectBlock:^(NSArray * _Nonnull array, NSString * _Nonnull showName, NSString * _Nonnull historUrl) {
            [weakSelf updateZyInfo:historUrl];
            [weakSelf showListView:array showName:showName historyUrl:historUrl];
            weakSelf.zylistContentView = nil;
        } closeBlcok:^{
            weakSelf.zylistContentView = nil;
        }];
        [self addSubview:self.zylistContentView];
    }
}

-(void)showHistory{
    [self showConentlist:@"历史记录"];
}


-(void)showFavirot{
    [self showConentlist:@"收藏"];
}

-(void)loadWebUrl:(NSString*)url{
    
    [self loadRequestURL:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)loadRequestURL:(NSMutableURLRequest *)request
{
    self.majorWebView.allowsBackForwardNavigationGestures = false;
    [self.majorWebView insertCookie:[MajorZyCookie getReadModeCookie]];
    [self.majorWebView loadRequest:request];
}

-(void)loadSort{
    if (majorZtSortArray) {
        [MajorZyCookie delCookie];
        __weak __typeof(self)weakSelf = self;
        self.zylistContentView = [[MajorZyContentList alloc] initWithFrame:self.bounds array:majorZtSortArray selectBlock:^(NSString * _Nonnull sortUrl) {
            weakSelf.zylistContentView = nil;
            [weakSelf loadWebUrl:sortUrl];
        } closeBlcok:^{
              weakSelf.zylistContentView = nil;
        }];
        [self addSubview:self.zylistContentView];
    }
}

-(void)loadHome{
    if (!self.zyMkInfo) {
        return;
    }
    self.zylistView = nil;
    [self loadWebUrl:self.zyMkInfo.url];
}

-(void)showListView:(NSArray*)array showName:(NSString*)showName historyUrl:(NSString*)historyUrl{
    if (!self.zylistView) {
        __weak __typeof(self)weakSelf = self;
        self.zylistView = [[MajorZyListView alloc] initWithFrame:self.bounds showName:showName  array:array dataSource:self.zyMkInfo.url isPage:[self.zyMkInfo.isPage intValue] closeBlcok:^{
            weakSelf.zylistView = nil;
            weakSelf.zyMkInfo = weakSelf.oldZyMkInfo;
        }];
        [self addSubview:self.zylistView];
        if (historyUrl) {
            [self.zylistView loadHistroyUrl:historyUrl];
        }
    }
}

-(void)updateWebDesList:(NSDictionary*)info
{
    NSArray *array = [info objectForKey:@"listArray"];
    NSString*showName = [info objectForKey:@"ShowName"];
    if (array.count>0) {
        [self showListView:array showName:showName historyUrl:nil];
        [self.majorWebView evaluateJavaScript:@"__webjsNodePlug__.stopCheckList();" completionHandler:nil];
        [self loadWebUrl:self.zyMkInfo.url];
    }
    if (self.zylistView) {
        [self.majorWebView evaluateJavaScript:@"__webjsNodePlug__.stopCheckList();" completionHandler:nil];
    }
}

-(void)praseResultSuccess:(NSDictionary*)info{
    [self updateWebDesList:info];
    [self.parseNode stop];
    self.parseNode = nil;
}

-(void)praseResultFalid:(NSDictionary*)info{
    [self.parseNode stop];
    self.parseNode = nil;
    [self makeToast:@"请求失败，请重试" duration:1 position:@"center"];
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


- (void)webCore_webViewLoadProgress:(float)progress{
    [self updateProcessbar:progress animated:YES];
    if (progress>0.2 && progress<=1) {//
        [self.majorWebView evaluateJavaScript:@"__webjsNodePlug__.startCheckList();" completionHandler:^(id ret , NSError * _Nullable error) {
            NSLog(@"error = %@",[error description]);
        }];
        if (!majorZtSortArray) {
            [self.majorWebView evaluateJavaScript:@"__webjsNodePlug__.updateZySort();" completionHandler:^(id ret , NSError * _Nullable error) {
                NSLog(@"error = %@",[error description]);
            }];
        }
#ifdef DEBUG
       NSString * strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_new_max" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        [self.majorWebView evaluateJavaScript:strJs completionHandler:^(id ret , NSError * _Nullable error) {
            NSLog(@"error = %@",[error description]);
        }];
#endif
    }
}

- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name compare:sendWebJsNodeMessageInfo]==NSOrderedSame)
    {
        [self updateWebDesList:message.body];
    }
    else if([message.name compare:sendWebJsNodeMessageZySort]==NSOrderedSame){
        if ([message.body count]>0 && !majorZtSortArray){
            majorZtSortArray = [[NSMutableArray alloc]initWithArray:message.body];
            [self updateSortBtn];
        }
    }
}

- (void)webCore_webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler{
}

- (BOOL)webCore_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *path  = [navigationAction.request.URL path];
    if ([path length]>2) {
//        path = [path substringFromIndex:1];
//            NSScanner* scan = [NSScanner scannerWithString:path];
//            int val;
//             BOOL ret= [scan scanInt:&val] && [scan isAtEnd];
//        if (ret) {
//            decisionHandler(WKNavigationActionPolicyCancel);
//            if (!self.parseNode) {
//                self.parseNode = [[MajorZyParseNode alloc] init];
//                self.parseNode.delegate = self;
//                [self.parseNode start:[navigationAction.request.URL absoluteString]];
//            }
//            return true;
//        }
    }
    return false;
}

- (void)webCore_webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
     NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    if (@available(iOS 11.0, *)) {
        //浏览器自动存储cookie
    }else
    {
        //存储cookies
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            
            @try{
                //存储cookies
                for (NSHTTPCookie *cookie in cookies) {
                    [self.majorWebView insertCookie:cookie];
                }
            }@catch (NSException *e) {
                NSLog(@"failed: %@", e);
            } @finally {
                
            }
        });
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
@end
