//
//  WebCoreManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebCoreManager.h"
#import "MajorWebView.h"
#import "WebCallNode.h"
#import "MarjorWebConfig.h"
#import "FTWCache.h"
#import "JsServiceManager.h"
#import "AppDelegate.h"
#import "MKNetworkEngine.h"
#import "MajorAdBlockNode.h"
#define adBlockNetVersionKey @"adBlockNetVersionKey"
#define adBlockNetContentKey @"adBlockNetContentKey"
#define adBlockNetAdIdentifier @"adBlockNetAdIdentifier"

#define adBlockExternKeyIndentifier(X) [NSString stringWithFormat:@"Major_%@",X]
#define adBlockExternFilePath(X) [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"AdBlockPlug.bundle/%@",X] ofType:@"json"]
@interface WebCoreManager()<WebCallNodeDelegate,MajorAdBlockNodeDelegate>{
    MKNetworkEngine *engine ;
    BOOL isAdPlugInitSuucess;
}
@property (strong, nonatomic) MajorAdBlockNode* majorAdNode;
@property (strong, nonatomic) NSMutableDictionary *adblockInfo;
@property (strong, nonatomic) NSMutableDictionary *adPlugInfo;
@property (strong, nonatomic) NSMutableDictionary *adPlugRestultInfo;
@property (strong, nonatomic) NSMutableArray<WKWebView*>* wkWebViewArray;
@property (strong, nonatomic) NSMutableDictionary* wkWebViewJsMessage;
@property (strong, nonatomic) NSMutableArray* wkWebViewJsArrayConfig;
@property (strong, nonatomic) NSDictionary* wkWebViewVideoJsArrayConfig;
@property (nonatomic,weak)WKWebView *currentWeb;
@property (strong,nonatomic)WKProcessPool *processPool;
@end

@implementation WebCoreManager
+(WebCoreManager*)getInstanceWebCoreManager{
     static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (WKProcessPool *)processPool {
    if (!_processPool) {
        _processPool = [[WKProcessPool alloc] init];
    }
    return _processPool;
}

-(NSString*)getBlockAdPath{
    if (![[NSFileManager defaultManager]fileExistsAtPath:AdBlockEasylistDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:AdBlockEasylistDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *localFile = [NSString stringWithFormat:@"%@/zh201900321111.json",AdBlockEasylistDir];
    if ([[NSFileManager defaultManager]fileExistsAtPath:localFile]) {
        return localFile;
    }
    return [[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/zh201900321111" ofType:@"json"];
}

-(void)reInitAdblock{
    if (@available(iOS 11.0, *)) {
        __weak typeof(self)weakSelf = self;
        [WKContentRuleListStore.defaultStore removeContentRuleListForIdentifier:@"zh201900321111" completionHandler:^(NSError *error) {
            [weakSelf initRuleList:^(BOOL succeeded) {
                if (succeeded) {
                    [weakSelf reSetWebAdBlock];
                }
            }];
        }];
        NSArray *allKey = [self.adPlugInfo allKeys];
        for (int i = 0; i < allKey.count; i++) {
            [WKContentRuleListStore.defaultStore removeContentRuleListForIdentifier:[allKey objectAtIndex:i] completionHandler:^(NSError *error) {
               
            }];
        }
    } else {
    }
}

-(void)reSetWebAdBlock{
    for (int i = 0;i < self.wkWebViewArray.count;i++) {
       MajorWebView *webView = (MajorWebView*)[self.wkWebViewArray objectAtIndex:i];
        [self updateRuleListState:[MarjorWebConfig getInstance].isRemoveAd webView:webView url:nil];
    }
}

-(void)reSetWebBlockWithIdentifierifSuccess:(NSString*)identifier{
    //;
    [self.adblockInfo removeObjectForKey:identifier];
    for (int i = 0;i < self.wkWebViewArray.count;i++) {
        MajorWebView *webView = (MajorWebView*)[self.wkWebViewArray objectAtIndex:i];
        [self removeRulelist:webView];
        if ([MarjorWebConfig getInstance].isRemoveAd) {
            if (@available(iOS 11.0, *)) {
                [WKContentRuleListStore.defaultStore lookUpContentRuleListForIdentifier:identifier completionHandler:^(WKContentRuleList *ret, NSError *error) {
                    if (ret) {
                        [webView.configuration.userContentController addContentRuleList:ret];
                    }
                }];
            } else {
                // Fallback on earlier versions
            }
        }
     }
}

-(void)initRuleList:(void (^_Nullable)( BOOL succeeded))completionHandler{
    if (@available(iOS 11.0, *)) {
        NSString *ind = @"zh201900321111";
        [WKContentRuleListStore.defaultStore lookUpContentRuleListForIdentifier:ind completionHandler:^(WKContentRuleList *ret, NSError *error) {
            if (!ret) {
                [self.adblockInfo setObject:@"1" forKey:ind];
                NSString *strch = [NSString stringWithContentsOfFile:[self getBlockAdPath] encoding:NSUTF8StringEncoding error:NULL];
                [WKContentRuleListStore.defaultStore compileContentRuleListForIdentifier:ind encodedContentRuleList:strch completionHandler:^(WKContentRuleList *ret, NSError *error) {
                    [self.adblockInfo removeObjectForKey:ind];
                    if (ret) {
                        completionHandler(true);
                    }
                    else{
                        completionHandler(false);
                    }
                }];
            }
            else{
                completionHandler(true);
            }
        }];
    } else {
        completionHandler(false);
    }
}

- (instancetype)init {
    self = [super init];
    self.adblockInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    self.adPlugRestultInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    self.adPlugInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                   adBlockExternKeyIndentifier(@"en"):adBlockExternFilePath(@"en"),
                    adBlockExternKeyIndentifier(@"zh"):adBlockExternFilePath(@"zh")}] ;
    
     __weak typeof(self)weakSelf = self;
#if (is_Web_Core_Debug_==1)
    [self reInitAdblock];
#endif
    [self initRuleList:^(BOOL succeeded) {
        [weakSelf reSetWebAdBlock];
    }];
    [self startCompileAdPlug];
    [self updateAdBlock];
    self.wkWebViewArray = [NSMutableArray arrayWithCapacity:10];
    self.wkWebViewJsMessage = [NSMutableDictionary dictionaryWithCapacity:10];
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
#if (is_Web_Core_Debug_==1)
    strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_new_max" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
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
#if (is_Web_Core_Debug_==1)
        strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_beatify" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif

        NSMutableDictionary *listJs = [NSMutableDictionary dictionaryWithCapacity:1];
        [listJs setObject:[NSNumber numberWithInt:0] forKey:@"injectionTime"];
        [listJs setObject:[NSNumber numberWithBool:false] forKey:@"forMainFrameOnly"];
        [listJs setObject:@[PostMoreInfoMessageInfo,GetInfoTimeMessageInfo,DeviceFullMessageInfo,PostListInfoMessageInfo,PostAssetInfoMessageInfo,sendMessageGetPicFromPagWeb] forKey:@"message"];
        if (strJs) {
            [listJs setObject:strJs forKey:@"js"];
        }
        [tmpAray addObject:listJs];
        {
            //添加tmp_addDiv
               //在body 添加div
            NSString *tjs =  [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmp_addDiv" ofType:@"js"]encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *listJs = [NSMutableDictionary dictionaryWithCapacity:1];
            [listJs setObject:[NSNumber numberWithInt:0] forKey:@"injectionTime"];
            [listJs setObject:[NSNumber numberWithBool:YES] forKey:@"forMainFrameOnly"];
            [listJs setObject:@[@"appAddAdMaskLayerMessage",@"updateMaskLayerPosMessage"] forKey:@"message"];
            if (tjs) {
                [listJs setObject:tjs forKey:@"js"];
            }
            [tmpAray addObject:listJs];
        }
#endif
    }
#endif
    
    self.wkWebViewJsArrayConfig = tmpAray;
    self.wkWebViewVideoJsArrayConfig = [MarjorWebConfig convertIdFromNSString:[FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/js_video_config" ofType:@"plist_data"]]] type:1];//[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/js_video_config" ofType:@"plist"]];
      return  self;
}

-(void)updateSendWebJsNodeMessageInfo{
    BOOL isUpdateJs = false;
    for (int i = 0; i < self.wkWebViewJsArrayConfig.count; i++) {
       NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:[self.wkWebViewJsArrayConfig objectAtIndex:i]];
        NSArray *ms  = [newInfo objectForKey:@"message"];
        if ([ms count]>0 ) {
            if ([[ms objectAtIndex:0] isEqualToString:sendWebJsNodeMessageInfo]) {
                NSString * strJs = [[JsServiceManager getInstance]getJsContent:@"WebJsNode_new_max"];
#if (is_Web_Core_Debug_==1)
                strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_new_max" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
                if ([strJs length]>10) {
                    [newInfo setObject:strJs forKey:@"js"];
                }
                [self.wkWebViewJsArrayConfig replaceObjectAtIndex:i withObject:newInfo];
                isUpdateJs = true;
            }
            else if([[ms objectAtIndex:0] isEqualToString:PostMoreInfoMessageInfo]){
#if (UseBeatifyAppJs==1)

                NSString * strJs = [[JsServiceManager getInstance]getJsContent:@"WebJsNode_beatify"];
#if (is_Web_Core_Debug_==1)
                strJs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"WebJsNode_beatify" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
#endif
                if ([strJs length]>10) {
                    [newInfo setObject:strJs forKey:@"js"];
                }
                [self.wkWebViewJsArrayConfig replaceObjectAtIndex:i withObject:newInfo];
                isUpdateJs = true;
#endif
            }
        }
    }
    if (isUpdateJs) {
        GetAppDelegate.isUpateJsChange = !GetAppDelegate.isUpateJsChange;
    }
}

-(void)updateRuleListState:(BOOL)isUse webView:(WKWebView*)webView url:(NSString *)url{
        if ( [[[UIDevice currentDevice]systemVersion]floatValue]>=11) {
            __block WKWebView *opWebView = nil;;
            if (webView) {
                opWebView = webView;
            }
            else{
                opWebView = self.currentWeb;
            }
            [self removeRulelist:opWebView];
            if (isUse){
                NSString *strch = [NSString stringWithContentsOfFile:[self getBlockAdPath] encoding:NSUTF8StringEncoding error:NULL];
                __weak typeof(self)weakSelf = self;
                [self addAllBlock:@"zh201900321111" opWebView:opWebView jsonContent:strch complete:^{
                    NSString *jscontent = [[NSString alloc]initWithData:[FTWCache objectForKey:adBlockNetContentKey useKey:YES] encoding:NSUTF8StringEncoding];
                    [weakSelf addAllBlock:adBlockNetAdIdentifier opWebView:opWebView jsonContent:jscontent complete:^{
                        [weakSelf addAdBlockCallBack:opWebView url:url];
                    }];
                }];
                NSArray *array = [self.adPlugRestultInfo allKeys];
                for (int i = 0;i<array.count;i++) {
                    NSString *key = [array objectAtIndex:i];
                    [self addAllBlockWithRuleList:key opWebView:opWebView ruleList:[self.adPlugRestultInfo objectForKey:key] complete:^{
                        
                    }];
                }
            }
            else{
            }
        }
}

-(void)addAdBlockCallBack:(WKWebView*)webview url:(NSString*)url{
    if (!url) {
       // [webview reload];
    }
}

-(void)addAllBlockWithRuleList:(NSString*)identifier opWebView:(WKWebView*)opWebView ruleList:(WKContentRuleList*)ruleList complete:(void(^)(void))complete{
    if (@available(iOS 11.0, *)) {
        if (!ruleList) {
            complete();
            return;
        }
        [opWebView.configuration.userContentController addContentRuleList:ruleList];
        complete();
    } else {
        // Fallback on earlier versions
    }
}

-(void)addAllBlock:(NSString*)identifier opWebView:(WKWebView*)opWebView jsonContent:(NSString*)jsonContent complete:(void(^)(void))complete{
    if (@available(iOS 11.0, *)) {
        if ([jsonContent length]<=10) {
            complete();
            return;
        }
        [WKContentRuleListStore.defaultStore lookUpContentRuleListForIdentifier:identifier completionHandler:^(WKContentRuleList *ret, NSError *error) {
            NSLog(@"..");
            if (!ret) {
                if ([self.adblockInfo objectForKey:identifier]) {
                    complete();
                 }
                else {
                    [self.adblockInfo setObject:@"1" forKey:identifier];
                    NSString *strch = jsonContent;
                    [WKContentRuleListStore.defaultStore compileContentRuleListForIdentifier:identifier encodedContentRuleList:strch completionHandler:^(WKContentRuleList *ruleList, NSError *error) {
                        //[opWebView.configuration.userContentController addContentRuleList:ruleList];
                        [self reSetWebBlockWithIdentifierifSuccess:identifier];
                    }];
                    complete();
              }
            }
            else{
                [opWebView.configuration.userContentController addContentRuleList:ret];//
           
                complete();
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}
                    

-(WKWebView*)createWKWebViewWithUrl:(NSString*)ur11l isAutoSelected:(BOOL)isAutoSelected delegate:(id<WebCoreManagerDelegate>)uiCallBackDelegate{
    MajorWebView *webView = nil;
    WebCallNode *callNode = [[WebCallNode alloc] init];
    callNode.delegate = self;
    
    WKWebViewConfiguration*configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController =
    [[WKUserContentController alloc] init];
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.allowsInlineMediaPlayback = YES;
   /* if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeVideo;
    } else {
        configuration.mediaPlaybackRequiresUserAction = YES;
        // Fallback on earlier versions
    }//把手动播放设置NO ios(8.0, 9.0)*/
    configuration.processPool = self.processPool;
  //  configuration.requiresUserActionForMediaPlayback = NO;
   // configuration.mediaTypesRequiringUserActionForPlayback=NO;
    webView = [[MajorWebView alloc]initWithFrame:CGRectMake(0, 0, 5, 5) configuration:configuration];
    webView.allowsBackForwardNavigationGestures = [MarjorWebConfig getInstance].isAllowsBackForwardNavigationGestures;
    webView.callBackDelegate = callNode;
    webView.callBackUIdelegate = uiCallBackDelegate;
    //[webView setCustomUserAgent:PCUserAgent];
    if (@available(iOS 9.0, *)) {
        webView.allowsLinkPreview = false;
    } else {
        // Fallback on earlier versions
    }
    callNode.webView = webView;
    
    webView.scrollView.delegate = webView.callBackDelegate;
    [self.wkWebViewArray addObject:webView];
    if (isAutoSelected) {
        [self updateUseWKWebview:webView];
    }
    [self updateVideoPlayMode:webView isSuspensionMode:[MarjorWebConfig getInstance].isSuspensionMode];
    [webView addObserver:webView.callBackDelegate
          forKeyPath:@"estimatedProgress"
             options:NSKeyValueObservingOptionNew
             context:nil];
    [webView addObserver:webView.callBackDelegate
              forKeyPath:@"title"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    [webView addObserver:webView.callBackDelegate forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    
    webView.UIDelegate = webView.callBackDelegate;
    webView.navigationDelegate = webView.callBackDelegate;
    [self updateRuleListState:[MarjorWebConfig getInstance].isRemoveAd webView:webView url:nil];
    return webView;
}

//所有js重新加载
-(void)updateVideoPlayMode:(WKWebView*)webView isSuspensionMode:(BOOL)isSuspensionMode{
   // DisSuspension
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
#ifdef DEBUG
    //[info setObject:[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"testjsddd" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] forKey:@"js"];
    //[info setObject:@[@"ClickOverButttonVideo",@"VideoHandler"] forKey:@"message"];
#endif
    if(isSuspensionMode){
        [info setObject:[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/webassetKey_new" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] forKey:@"js"];
       //NSMutableArray *array = [NSMutableArray arrayWithArray: [info  objectForKey:@"message"]];
       // [array addObject:@"GetAssetSuccess"];
        //[info setObject:array forKey:@"message"];
    }
    [self addJsFromInfo:info webView:webView];
}

-(void)addJsFromInfo:(NSDictionary *)info webView:(WKWebView*)webView{
    NSString *jsContent = [info objectForKey:@"js"];
    NSArray *arrayMessage = [info objectForKey:@"message"];
    if (jsContent) {
        int  injectionTime = [[info objectForKey:@"injectionTime"] intValue];
        BOOL  forMainFrameOnly = [[info objectForKey:@"forMainFrameOnly"] boolValue];
        WKUserScript * videoScript = [[WKUserScript alloc]
                                      initWithSource:jsContent
                                      injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
        [webView.configuration.userContentController addUserScript:videoScript];
    }
    NSMutableArray *arrayNew = [NSMutableArray arrayWithArray:arrayMessage];
    for (int i =0; i < arrayNew.count; i++) {
        NSString *messageName = [arrayNew objectAtIndex:i];
        [webView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)webView).callBackDelegate name:messageName];
        [self.wkWebViewJsMessage setObject:@"1" forKey:messageName];
    }
}

-(void)remveAlljsAndMessage:(WKWebView*)webView{
    [webView.configuration.userContentController removeAllUserScripts];
    NSArray *keyAll = [self.wkWebViewJsMessage allKeys];
    for (id v in keyAll) {
        [webView.configuration.userContentController removeScriptMessageHandlerForName:v];
    }
}

-(void)removeRulelist:(WKWebView*)v{
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=11) {
        if (@available(iOS 11.0, *)) {
            [v.configuration.userContentController removeAllContentRuleLists];
        } else {
            // Fallback on earlier versions
        }
    }
}


-(void)destoryWKWebView:(WKWebView *)webView
{
    if (webView) {
        [webView stopLoading];
        webView.navigationDelegate=nil;webView.UIDelegate = nil;
        [self remveAlljsAndMessage:webView];
        [webView removeObserver:((MajorWebView*)webView).callBackDelegate forKeyPath:@"estimatedProgress" context:nil];
        [webView removeObserver:((MajorWebView*)webView).callBackDelegate forKeyPath:@"title" context:nil];
        [webView removeObserver:((MajorWebView*)webView).callBackDelegate forKeyPath:@"URL" context:nil];
        ((MajorWebView*)webView).callBackDelegate = nil;
        [self removeRulelist:webView];
        [self.wkWebViewArray removeObject:webView];
        [webView removeFromSuperview];
    }
}

-(void)updateUseWKWebview:(WKWebView*)webView
{
    self.currentWeb = webView;
}

//js部分
- (void)evaluateJavaScript:(WKWebView*)webView jsContent:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler
{
    if (webView) {
        [webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
    else{
        [self.currentWeb evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

-(void)updateWebToolBar:(WKWebView*)webView state:(BOOL)state{
    if ( [self.wkWebViewArray indexOfObject:webView] !=NSNotFound ) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_toolBarState:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_toolBarState:state];
        }
    }
}
#pragma DelegateCallBack

- (void)webCallNode_scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)webCallNode_scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)webCallNode_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   
}

- (void)webCallNode_webViewLoadProgress:(WKWebView *)webView progress:(float)progress{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if ([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewLoadProgress:)]) {
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewLoadProgress:progress];
        }
        else{
         }
    }
}

- (void)webCallNode_webViewUrlChange:(WKWebView *)webView url:(NSString*)url{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if ([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewUrlChange:)]) {
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewUrlChange:url];
        }
        else{
        }
    }
}

- (void)webCallNode_webViewTitleChange:(WKWebView *)webView title:(NSString*)title{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if ([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewTitleChange:)]) {
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewTitleChange:title];
        }
        else{
        }
    }
}

- (void)webCallNode_webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    
}

- (void)webCallNode_webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if ([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        }
        else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = defaultText;
            }];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
                completionHandler(input);
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                completionHandler(nil);
            }]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{}];
        }
    }
}

- (void)webCallNode_webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if ([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        }
        else{
            completionHandler();
        }
    }
}

- (WKWebView *)webCallNode_webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if ([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)]) {
            return [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
        }
        else{
            WKFrameInfo *frameInfo = navigationAction.targetFrame;
            if (![frameInfo isMainFrame]) {
                [webView loadRequest:navigationAction.request];
            }
            return nil;
        }
    }
    return nil;
}

- (void)webCallNode_webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewWebContentProcessDidTerminate:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewWebContentProcessDidTerminate:webView];
        }
        else{
          //  [webView reload];
        }
    }
}

- (void)webCallNode_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:didStartProvisionalNavigation:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView didStartProvisionalNavigation:navigation];
        }
    }
}

-(void)webCallNode_webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:didFailNavigation:withError:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView didFailNavigation:navigation withError:error];
        }
    }
}

- (void)webCallNode_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:didFinishNavigation:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView didFinishNavigation:navigation];
        }
    }
}

- (void)webCallNode_webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
 
}

- (void)webCallNode_webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:didCommitNavigation:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView didCommitNavigation:navigation];
        }
    }
}

- (void)webCallNode_webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
              if (challenge.previousFailureCount == 0) {
                  if (true  ) {
                      completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                  }
                  else{
                      NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                                         completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                  }
              }else {
                  // 验证失败，取消本次验证
                  completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
              }
          }else {
              completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
          }
   // completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
}

- (BOOL)webCallNode_webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:
(void (^)(WKNavigationActionPolicy))decisionHandler
{
#if !(DEBUG)//设置代理的话，无法走api数据
    MajorWebView *jorWebView = (MajorWebView*)webView;
    NSString *name = NSStringFromClass([jorWebView.callBackUIdelegate class]);
    if ([name isEqualToString:@"WebViewBase"] && GetAppDelegate.isProxyState) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return true;
    }
#endif
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:decidePolicyForNavigationAction:decisionHandler:)]){
           return  [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        }
    }
    return false;
}


- (void)webCallNode_webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))
decisionHandler {
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webView:decidePolicyForNavigationResponse:decisionHandler:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        }
        else{
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
    }
}

- (void)webCallNode_scrollViewDidEndDragging:(WKWebView *)webView scrollView:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%s",__FUNCTION__);
}


- (void)webCallNode_scrollViewWillBeginDragging:(WKWebView *)webView scrollView:(UIScrollView *)scrollView {
    NSLog(@"%s",__FUNCTION__);
}

-(void)webCallNode_updateWebToolBar:(WKWebView*)webView state:(BOOL)state
{
    [self updateWebToolBar:webView state:state];
}

- (void)webCallNode_scrollViewDidScroll:(WKWebView *)webView scrollView:(UIScrollView *)scrollView {
   
}

- (void)webCallNode_userContentController:(WKWebView *)webView userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ( [self.wkWebViewArray indexOfObject:webView] !=NSNotFound ) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_userContentController:didReceiveScriptMessage:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_userContentController:userContentController didReceiveScriptMessage:message];
        }
      //  NSLog(@"webCallNode_userContentController...%@ %@",message.name,message.body);
    }
}


- (BOOL)webCallNode_webViewIsOpenInNewWeb:(WKWebView *)webView url:(NSURL *)url {
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewIsOpenInNewWeb:)]){
          return   [((MajorWebView*)webView).callBackUIdelegate webCore_webViewIsOpenInNewWeb:url];
        }
    }
    return NO;
}


- (void)webCallNode_webViewOpenInAppStore:(WKWebView *)webView url:(NSURL *)url {
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewOpenInAppStore:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewOpenInAppStore:url];
        }
    }
}


- (void)webCallNode_webViewOpenInCall:(WKWebView *)webView url:(NSURL *)url {
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewOpenInCall:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewOpenInCall:url];
        }
    }
}


- (void)webCallNode_webViewOpenOtherAction:(WKWebView *)webView url:(NSURL *)url {
    if ([self.wkWebViewArray indexOfObject:webView]!=NSNotFound) {
        if([((MajorWebView*)webView).callBackUIdelegate respondsToSelector:@selector(webCore_webViewOpenOtherAction:)]){
            [((MajorWebView*)webView).callBackUIdelegate webCore_webViewOpenOtherAction:url];
        }
    }
}

//3dTouch

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo  API_AVAILABLE(ios(10.0)){
   
    return YES;
}

- (UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id<WKPreviewActionItem>> *)previewActions  API_AVAILABLE(ios(10.0)){
    
    return nil;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    
}

//更新广告配置文件
-(void)updateAdBlock{
    if (!engine) {
       engine = [[MKNetworkEngine alloc]initWithHostName:@"maxdownapp.oss-cn-hangzhou.aliyuncs.com/"];
    }    
    MKNetworkOperation *op = [engine operationWithPath:MAXADBLOCKCONFIG params:nil httpMethod:@"GET" ssl:true timeOut:5];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSInteger code = completedOperation.HTTPStatusCode;
        if (code>=200 && code<300)
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self parseAdBlockNet:completedOperation.responseString];
            });
        }
        else{
            [self performSelector:@selector(updateAdBlock) withObject:nil afterDelay:10];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self performSelector:@selector(updateAdBlock) withObject:nil afterDelay:10];
    }];
    [engine enqueueOperation:op];
 }

-(void)parseAdBlockNet:(NSString*)msg{
    id v = [msg JSONValue];
    if ([v isKindOfClass:[NSDictionary class]]) {
        NSString *vesion =  [v objectForKey:@"version"];
        id value = [v objectForKey:@"adBlock"];
        if ([value isKindOfClass:[NSArray class]]){
            NSString *versionOld = [[NSString alloc]initWithData:[FTWCache objectForKey:adBlockNetVersionKey useKey:YES] encoding:NSUTF8StringEncoding];
            [FTWCache setObject:[vesion dataUsingEncoding:NSUTF8StringEncoding] forKey:adBlockNetVersionKey useKey:YES];
            NSString *adContent= [value JSONString];
            [FTWCache setObject:[adContent dataUsingEncoding:NSUTF8StringEncoding] forKey:adBlockNetContentKey useKey:YES];
            if (![versionOld isEqualToString:vesion]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateNetAdBlock];
                });
            }
          
        }
    }
}


-(void)updateNetAdBlock{
    if (@available(iOS 11.0, *)) {
        __weak typeof(self)weakSelf = self;
        [WKContentRuleListStore.defaultStore removeContentRuleListForIdentifier:adBlockNetAdIdentifier completionHandler:^(NSError *error) {
            [weakSelf reSetWebAdBlock];
        }];
    } else {
        // Fallback on earlier versions
    };
}
@end

@implementation  WebCoreManager(AdBlockPlug)
-(void)startCompileAdPlug{
    if (@available(iOS 11.0, *)) {
        NSArray *allKey = self.adPlugInfo.allKeys;
        if (allKey.count>0) {
            NSLog(@"startCompileAdPlug start");
            NSString *key = [allKey objectAtIndex:0];
            NSString *jsonContent = [NSString stringWithContentsOfFile:[self.adPlugInfo objectForKey:key] encoding:NSUTF8StringEncoding error:nil];
            self.majorAdNode = [[MajorAdBlockNode alloc]init];
            [self.majorAdNode startCheckAndCompileAdPlug:key jsonContent:jsonContent delegate:self];
        }
        else{
            NSLog(@"startCompileAdPlug finish");
            isAdPlugInitSuucess = true;
        }
    } else {
        // Fallback on earlier versions
    
    }
}

-(void)major_adBlock_result:(NSString*)indentifier ruleList:(WKContentRuleList*)ruleList{
    if (ruleList) {
        [self.adPlugRestultInfo setObject:ruleList forKey:indentifier];
    }
    [self.adPlugInfo removeObjectForKey:indentifier];
    [self startCompileAdPlug];
}
@end
