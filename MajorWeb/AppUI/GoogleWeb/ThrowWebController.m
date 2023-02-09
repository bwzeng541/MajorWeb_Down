//
//  ThrowWebController.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ThrowWebController.h"
#import "JsServiceManager.h"
#import "ReactiveCocoa.h"
#import "FTWCache.h"
#import "VideoPlayerManager.h"
#import "MajorSystemConfig.h"
#import "MarjorWebConfig.h"
@interface ThrowWebController ()<WKScriptMessageHandler>
@property (nonatomic,assign)BOOL isSuspensionMode;
@property (nonatomic,strong) NSMutableArray<WKWebView*>* wkWebViewArray;
@property (nonatomic,strong) NSMutableDictionary* wkWebViewJsMessage;
@property (nonatomic,strong)WKProcessPool*processPool;
@property (nonatomic,strong) NSDictionary* wkWebViewVideoJsArrayConfig;
@property (nonatomic,strong) NSMutableArray* wkWebViewJsArrayConfig;

@property (copy,nonatomic)NSString *mediaUrl ;
@property (copy,nonatomic)NSString *mediaTitle ;
@property (copy,nonatomic)NSString *mediaReferer ;

@end

@implementation ThrowWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)dealloc{
    self.wkWebViewArray = nil;
    [self remveAlljsAndMessage:self.webView];
    NSLog(@"%s",__FUNCTION__);
}

- (WKProcessPool *)processPool {
    if (!_processPool) {
        _processPool = [[WKProcessPool alloc] init];
    }
    return _processPool;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (IF_IPHONE) {
       // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)];
    }
}

-(void)updateToolbarItems{
    [super updateToolbarItems];
    if (!IF_IPHONE) {
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fixedSpace.width = 35.0f;
            UIBarButtonItem *bottonItem = nil;// [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)];
            UIBarButtonItem *refreshStopBarButtonItem = self.self.webView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;

               NSArray *items = [NSArray arrayWithObjects:fixedSpace, refreshStopBarButtonItem, fixedSpace, self.backBarButtonItem, fixedSpace, self.forwardBarButtonItem, fixedSpace, self.actionBarButtonItem,fixedSpace,bottonItem, nil];
            self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
        }
    }
}

-(void)goSearch:(NSString*)text{
    NSString *tempUrl = [text
                         stringByTrimmingCharactersInSet:[NSCharacterSet
                                                          whitespaceAndNewlineCharacterSet]];
    NSString *regex = [NSString
                       stringWithFormat:
                       @"%@%@%@%@%@%@%@%@%@%@", @"^((https|http|ftp|rtsp|mms)?://)",
                       @"?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?",
                       @"(([0-9]{1,3}\\.){3}[0-9]{1,3}", @"|", @"([0-9a-zA-Z_!~*'()-]+\\.)*",
                       @"([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\.", @"[a-zA-Z]{2,6})",
                       @"(:[0-9]{1,4})?", @"((/?)|",
                       @"(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"];
    if (tempUrl.length > 0) {
        if ([tempUrl isMatchedByRegex:regex] || [tempUrl hasPrefix:@"http://"] ||
            [tempUrl hasPrefix:@"https://"]) {
            if (![tempUrl hasPrefix:@"http://"] && ![tempUrl hasPrefix:@"https://"]) {
                tempUrl = [@"http://" stringByAppendingString:tempUrl];
            }
            
            tempUrl =
            (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  kCFAllocatorDefault, (CFStringRef)tempUrl,
                                                                                  (CFStringRef) @"!$&'()*+,-./:;=?@_~%#[]", NULL,
                                                                                  kCFStringEncodingUTF8));
            
            //回调出去
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempUrl]]];
         } else {
            NSString *keywords = [tempUrl
                                  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString * kBaiduHomeSearchIPadURL = @"https://www.baidu.com/s?word=%@";
            NSString *urlStr = [NSString stringWithFormat:kBaiduHomeSearchIPadURL,keywords];
             [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
            //回调出去
             //
        }
    }
}

-(void)searchButtonClicked:(UIBarButtonItem*)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入网址或搜索内容" preferredStyle:UIAlertControllerStyleAlert];
    NSString *url =  [self.webView.URL absoluteString];
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.placeholder = url;
    }];
    
    //添加一个确定按钮 并获取AlertView中的第一个输入框 将其文本赋值给BUTTON的title
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        [wself goSearch:envirnmentNameTextField.text];
    }]];
    
     [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}


- (instancetype)initWithAddress:(NSString*)urlString{
    
    NSMutableArray *tmpAray = [NSMutableArray arrayWithArray:[MarjorWebConfig convertIdFromNSString:[FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/js_config" ofType:@"plist_data"]]] type:0]];
    NSMutableDictionary *listJs = [NSMutableDictionary dictionaryWithCapacity:1];
    [listJs setObject:[NSNumber numberWithInt:0] forKey:@"injectionTime"];
    [listJs setObject:[NSNumber numberWithBool:false] forKey:@"forMainFrameOnly"];
    [listJs setObject:@[sendWebJsNodeMessageInfo] forKey:@"message"];
#if 1
    NSString *strJs = [FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/WebJsNode" ofType:@"txt_data"]]];
    if ([[JsServiceManager getInstance]getJsContent:@"WebJsNode_new_max"]) {
        strJs = [[JsServiceManager getInstance]getJsContent:@"WebJsNode_new_max"];
    }
    [listJs setObject:strJs forKey:@"js"];
#endif
    [tmpAray addObject:listJs];
    
#if (UseBeatifyAppJs==1)
    {//and
#if 1
        NSString *strJs = [FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/WebJsNode_beatify" ofType:@"txt_data"]]];
        if ([[JsServiceManager getInstance]getJsContent:@"WebJsNode_beatify"]) {
            strJs = [[JsServiceManager getInstance]getJsContent:@"WebJsNode_beatify"];
        }
#ifdef DEBUG
        strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_beatify" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
        NSMutableDictionary *listJs = [NSMutableDictionary dictionaryWithCapacity:1];
        [listJs setObject:[NSNumber numberWithInt:0] forKey:@"injectionTime"];
        [listJs setObject:[NSNumber numberWithBool:false] forKey:@"forMainFrameOnly"];
        [listJs setObject:@[PostMoreInfoMessageInfo,GetInfoTimeMessageInfo,DeviceFullMessageInfo,PostListInfoMessageInfo,PostAssetInfoMessageInfo] forKey:@"message"];
        [listJs setObject:strJs forKey:@"js"];
        [tmpAray addObject:listJs];
#endif
    }
#endif
    
    self.wkWebViewJsArrayConfig = tmpAray;

    self.wkWebViewVideoJsArrayConfig = [MarjorWebConfig convertIdFromNSString:[FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/js_video_config" ofType:@"plist_data"]]] type:1];
    
    WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController =
    [[WKUserContentController alloc] init];
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.processPool = self.processPool;
    
    self = [super initWithURL:[NSURL URLWithString:urlString ] configuration:configuration];
    self.wkWebViewArray = [NSMutableArray arrayWithCapacity:1];
    [self.wkWebViewArray addObject:self.webView];
    self.webView.scrollView.bounces = NO;
    self.wkWebViewJsMessage = [NSMutableDictionary dictionaryWithCapacity:1];
    @weakify(self)
    [RACObserve([JsServiceManager getInstance], isWebJsSuccess) subscribeNext:^(id x) {
        @strongify(self)
        if ([JsServiceManager getInstance].isWebJsSuccess) {
            [self updateSendWebJsNodeMessageInfo];
         }
    }];
    self.isSuspensionMode = true;
    [self updateVideoPlayMode:self.webView isSuspensionMode:false];
    [RACObserve([MarjorWebConfig getInstance], isSuspensionMode) subscribeNext:^(id x) {
        @strongify(self)
        [self updateVideoPlayMode:self.webView isSuspensionMode:[x boolValue]];
    }];
    return self;
}

-(void)updateSendWebJsNodeMessageInfo{
    for (int i = 0; i < self.wkWebViewJsArrayConfig.count; i++) {
        NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:[self.wkWebViewJsArrayConfig objectAtIndex:i]];
        NSArray *ms  = [newInfo objectForKey:@"message"];
        if ([ms count]>0 ) {
            if ([[ms objectAtIndex:0] isEqualToString:sendWebJsNodeMessageInfo]) {
                NSString * strJs = [[JsServiceManager getInstance]getJsContent:@"WebJsNode_new_max"];
#ifdef DEBUG
                strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_new_max" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
                if ([strJs length]>10) {
                    [newInfo setObject:strJs forKey:@"js"];
                }
                [self.wkWebViewJsArrayConfig replaceObjectAtIndex:i withObject:newInfo];
            }
            else if([[ms objectAtIndex:0] isEqualToString:PostMoreInfoMessageInfo]){
#if (UseBeatifyAppJs==1)
                NSString * strJs = [[JsServiceManager getInstance]getJsContent:@"WebJsNode_beatify"];
#ifdef DEBUG
                strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_beatify" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
                if ([strJs length]>10) {
                    [newInfo setObject:strJs forKey:@"js"];
                }
                [self.wkWebViewJsArrayConfig replaceObjectAtIndex:i withObject:newInfo];
#endif
            }
        }
    }
}


//所有js重新加载
-(void)updateVideoPlayMode:(WKWebView*)webView isSuspensionMode:(BOOL)isSuspensionMode{
    // DisSuspension
    if (self.isSuspensionMode==isSuspensionMode) {
        return;
    }
    self.isSuspensionMode = isSuspensionMode;
    [self remveAlljsAndMessage:webView];
    for (int i = 0; i < self.wkWebViewJsArrayConfig.count ; i++) {
        NSDictionary *info = [self.wkWebViewJsArrayConfig objectAtIndex:i];
        [self addJsFromInfo:info webView:webView];
    }
    NSString *key = @"DisSuspension";
    if (isSuspensionMode) {
        key = @"Suspension";
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self.wkWebViewVideoJsArrayConfig objectForKey:key]];
    //#ifdef DEBUG
    //    [info setObject:[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"testjsddd" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] forKey:@"js"];
    //    [info setObject:@[@"ClickOverButttonVideo",@"VideoHandler"] forKey:@"message"];
    //#endif
    [self addJsFromInfo:info webView:webView];
    [self.webView reload];
}

-(void)addJsFromInfo:(NSDictionary *)info webView:(WKWebView*)webView{
    NSString *jsContent = [info objectForKey:@"js"];
    int  injectionTime = [[info objectForKey:@"injectionTime"] intValue];
    BOOL  forMainFrameOnly = [[info objectForKey:@"forMainFrameOnly"] boolValue];
    NSArray *arrayMessage = [info objectForKey:@"message"];
    if (jsContent) {
        WKUserScript * videoScript = [[WKUserScript alloc]
                                      initWithSource:jsContent
                                      injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
        [webView.configuration.userContentController addUserScript:videoScript];
    }
    for (int i =0; i < arrayMessage.count; i++) {
        NSString *messageName = [arrayMessage objectAtIndex:i];
        [webView.configuration.userContentController addScriptMessageHandler:self name:messageName];
        [self.wkWebViewJsMessage setObject:@"1" forKey:messageName];
    }
    
    NSMutableString *javascript = [NSMutableString string];
    [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
    WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [webView.configuration.userContentController addUserScript:noneSelectScript];
}

-(void)remveAlljsAndMessage:(WKWebView*)webView{
    [webView.configuration.userContentController removeAllUserScripts];
    NSArray *keyAll = [self.wkWebViewJsMessage allKeys];
    for (id v in keyAll) {
        [webView.configuration.userContentController removeScriptMessageHandlerForName:v];
    }
}

-(void)hiddeVideoMode{
     if (![MarjorWebConfig getInstance].isSuspensionMode) {
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.setMainFrameVideoEnable(false,'',false)"] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
    else{
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.setMainFrameVideoEnable(true,'',false)"] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (progress>0.15){
#if (UseBeatifyAppJs==0)
            [self.webView evaluateJavaScript:@"__webjsNodePlug__.startCheckAdBlock();" completionHandler:^(id ret , NSError * _Nullable error) {

            }];
#endif
        }
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [self hiddeVideoMode];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ( [self.wkWebViewArray indexOfObject:self.webView] !=NSNotFound ) {
        {
            if ([message.body isKindOfClass:[NSString class]]) {
                return;
            }
            if ([message.body isKindOfClass:[NSDictionary class]]) {
                NSDictionary *info = message.body;
                self.mediaUrl  =  [info objectForKey:@"src"];
                self.mediaTitle = self.webView.title;
                self.mediaReferer = [info objectForKey:@"referer"];
                 NSString *msgID = [info objectForKey:@"msgId"];
                if ([msgID isEqualToString:@"play"]) {
                    [self playMedia:false rect:CGRectZero];
                }
                else if([msgID isEqualToString:@"get"]){
                    
                }
            }
        }
    }
}

- (void)navigationIemHandleClose:(UIBarButtonItem *)sender {
    [self remveAlljsAndMessage:self.webView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonClicked:(id)sender {
    [self remveAlljsAndMessage:self.webView];
    if (self.willRemoveBlock) {
        self.willRemoveBlock();
    }
    [super dismissViewControllerAnimated:YES completion:NULL];
}

-(void)playMedia:(BOOL)isAuto rect:(CGRect)rect
{
    
    NSDictionary *saveInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.webView.URL.absoluteString,@"requestUrl",self.mediaTitle,@"theTitle", nil];
    [[VideoPlayerManager getVideoPlayInstance] playWithUrl:self.mediaUrl title:self.mediaTitle referer:self.mediaReferer saveInfo:saveInfo replayMode:false rect:DefalutVideoRect throwUrl:self.mediaUrl isUseIjkPlayer:false];

}
@end
