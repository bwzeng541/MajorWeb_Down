//
//  BeatifyWebConfig.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/4/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyWebConfig.h"
#import "RegexKitLite.h"
#import "MKNetworkEngine.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "NSData+AES256.h"
@interface BeatifyWebConfig()
{
    WKProcessPool *_processPool;
    MKNetworkEngine *_engine;
}

@property(assign, nonatomic)BOOL isAdPlugInitSuucess;
@property(nonatomic,strong)NSMutableArray *obserArray;
@property(nonatomic,strong)NSMutableDictionary *wkWebViewConfig;
@property(nonatomic,strong)NSMutableArray *wkWebViewJsArrayConfig;
@property(nonatomic,strong)NSMutableDictionary *wkWebViewJsMessage;
@end
@implementation BeatifyWebConfig
+(BeatifyWebConfig*)getInstance
{
    static BeatifyWebConfig* g = NULL;
    if (!g) {
        g = [[BeatifyWebConfig alloc] init];
     }
    return g;
}

-(id)convertDicFromNSString:(NSString*)msg type:(NSInteger)type
{
    NSString*file = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"deltmp"];
    [msg writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if(type==0){
        NSArray *tmpe = [NSArray arrayWithContentsOfFile:file];
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        return tmpe;
    }
    if (type==1) {
/*#if DEBUG
        NSDictionary *tmpe = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ggtmpdel" ofType:@"plist"]];
        
        NSData *tmpSave = [[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ggtmpdel" ofType:@"plist"]] AES256EncryptWithKey:AppAESKey];
      bool t =  [tmpSave writeToFile:file atomically:YES];
        
        return tmpe;
#else*/
        NSDictionary *tmpe = [NSDictionary dictionaryWithContentsOfFile:file];
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        return tmpe;
//#endif
    }
    return nil;
}

+(void)addDefaultJs:(WKWebView*)webView jsContent:(NSString*)jsContent messageName:(NSArray*)messageNameArray{
    if (GetAppDelegate.isProxyState) {return;
    }
    if ([jsContent length]<5) {
        return;
    }
    int  injectionTime = WKUserScriptInjectionTimeAtDocumentStart;
    BOOL  forMainFrameOnly = false;
     WKUserScript * script = [[WKUserScript alloc]
                                  initWithSource:jsContent
                                  injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
    [webView.configuration.userContentController addUserScript:script];
    {//p屏蔽长按按钮
       
    }
    for (int i = 0; i<messageNameArray.count; i++) {
        [webView.configuration.userContentController addScriptMessageHandler:webView.superview name:[messageNameArray objectAtIndex:i]];
    }
}

-(id)init{
    self = [super init];
    self.obserArray = [NSMutableArray arrayWithCapacity:10];
    self.wkWebViewJsMessage = [NSMutableDictionary dictionaryWithCapacity:1];
    self.wkWebViewJsArrayConfig = [NSMutableArray arrayWithCapacity:10];
    self.wkWebViewConfig = [self convertDicFromNSString:[FTWCache decryptWithKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Brower.bundle/beatify_pic_config" ofType:@"plist_data"]]] type:1];
    return self;
}

-(void)updateWebGetPicJs{
    [self.wkWebViewJsArrayConfig removeAllObjects];
  
}
-(void)addWebObser:(WKWebView*)web{
    if (![self.obserArray containsObject:web]) {
        [self.obserArray addObject:web];
    }
}

-(void)remveWebObser:(WKWebView*)web{
    [self.obserArray removeObject:web];
}


- (WKProcessPool *)processPool {
    if (!_processPool) {
        _processPool = [[WKProcessPool alloc] init];
    }
    return _processPool;
}

-(void)remveAllJs:(WKWebView*)webView{
    [webView.configuration.userContentController removeAllUserScripts];
    NSArray *keyAll = [self.wkWebViewJsMessage allKeys];
    for (id v in keyAll) {
        [webView.configuration.userContentController removeScriptMessageHandlerForName:v];
    }
}

-(void)removeRule:(WKWebView*)v{
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=11) {
        if (@available(iOS 11.0, *)) {
            [v.configuration.userContentController removeAllContentRuleLists];
        } else {
            // Fallback on earlier versions
        }
    }
}

-(void)updateWebMode:(WKWebView*)webView isSuspensionMode:(BOOL)isSuspensionMode{
    [self remveAllJs:webView];
#ifdef DEBUG
    if(true){
#else
    if (!GetAppDelegate.isProxyState) {
#endif
        for (int i = 0; i < self.wkWebViewJsArrayConfig.count ; i++) {
            NSDictionary *info = [self.wkWebViewJsArrayConfig objectAtIndex:i];
            [self addWebInfo:info webView:webView];
        }
        NSString *key = @"DisSuspension";
        if (isSuspensionMode) {
            key = @"Suspension";
        }
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self.wkWebViewConfig objectForKey:key]];
        if(isSuspensionMode){
               [info setObject:[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorJs.bundle/webassetKey_new" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] forKey:@"js"];
           }
        [self addWebInfo:info webView:webView];
    }
}


-(void)addWebInfo:(NSDictionary *)info webView:(WKWebView*)webView{
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
        [webView.configuration.userContentController addScriptMessageHandler:webView.superview name:messageName];
        [self.wkWebViewJsMessage setObject:@"1" forKey:messageName];
    }
}





+(void)isUrlValid:(NSString*)urlString callBack:(void(^)(BOOL validValue, NSString *result))callBack
{
    NSString *tempUrl = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *regex = [NSString
                       stringWithFormat:
                       @"%@%@%@%@%@%@%@%@%@%@", @"^((https|http|ftp|rtsp|mms)?://)",
                       @"?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?",
                       @"(([0-9]{1,3}\\.){3}[0-9]{1,3}", @"|", @"([0-9a-zA-Z_!~*'()-]+\\.)*",
                       @"([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\.", @"[a-zA-Z]{2,6})",
                       @"(:[0-9]{1,4})?", @"((/?)|",
                       @"(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"];
    if ([tempUrl hasPrefix:@"http://"] || [tempUrl hasPrefix:@"https://"])
    {
        if ([tempUrl isMatchedByRegex:regex]) {
            callBack(YES,tempUrl);
        }
        else
        {
            callBack(NO,tempUrl);
        }
    }
    else
    {
        NSString *result = [NSString stringWithFormat:@"http://%@",tempUrl];
        if ([result isMatchedByRegex:regex]) {
            callBack(YES, result);
        }
        else
        {
            callBack(NO, tempUrl);
        }
    }
}
@end
