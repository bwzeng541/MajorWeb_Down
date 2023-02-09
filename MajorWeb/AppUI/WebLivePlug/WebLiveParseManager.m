//
//  WebLiveParseManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebLiveParseManager.h"
#import "MKNetworkKit.h"
#import "WebLivePlug.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"
#import "WebLiveVaildUrlParse.h"
@interface WebLiveParseManager()<WebCoreManagerDelegate>{
    dispatch_queue_t _dateFormatterQueue ;
}
@property(nonatomic,weak)UIView *webParentView;
@property(nonatomic,strong)NSDictionary *faildInfo;
@property(nonatomic,strong)MKNetworkOperation *netWorkOperation;
@property(nonatomic,strong)MKNetworkEngine *netWorkKit;
@property(nonatomic,strong)NSMutableArray *arrayWebs;
@property(nonatomic,strong)MajorWebView *parseWebView;
@end
@implementation WebLiveParseManager
+(WebLiveParseManager*)getInstance{
    static WebLiveParseManager*g = NULL;
    if (!g) {
        g = [[WebLiveParseManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    self.arrayWebs = [NSMutableArray arrayWithCapacity:10];
    [[WebLiveVaildUrlParse getInstance] initVaildPlug];
    [self getFilterJson];
    return self;
}

-(void)getFilterJson{
    if (_dateFormatterQueue == NULL) {
        _dateFormatterQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    }
    dispatch_sync(_dateFormatterQueue, ^{
        NSString *info = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://softhome.oss-cn-hangzhou.aliyuncs.com/max/WebFilterFaild.plist"] encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!info) {
                [self performSelector:@selector(getFilterJson) withObject:nil afterDelay:2];
            }
            else{
                self.faildInfo = [info JSONValue];
            }
        });
    });
}

-(void)startParse:(UIView *)webParentView
{
    if (!self.parseWebView) {
         self.webParentView = webParentView;
        self.parseWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager] createWKWebViewWithUrl:nil isAutoSelected:NO delegate:self];
        self.parseWebView.frame = CGRectMake(0, 100000, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
        [self.webParentView addSubview:self.parseWebView];
        NSString *commond = @"window.onload=function(){var jq=document.createElement(\"script\");jq.setAttribute(\"src\",\"https://code.jquery.com/jquery-3.1.1.min.js\");document.getElementsByTagName(\"head\")[0].appendChild(jq); };function exec(){document.write($(\"body\").get(0))};";
        WKUserScript * commondJS = [[WKUserScript alloc]
                                      initWithSource:commond
                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
        
        [self.parseWebView.configuration.userContentController addUserScript:commondJS];
        [self.parseWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://softhome.oss-cn-hangzhou.aliyuncs.com/max/help/360.html"]]];
        self.netWorkKit = [[MKNetworkEngine alloc] init];
    }
}

-(void)stopParse{
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.parseWebView];
    self.parseWebView = nil;
    [self.netWorkOperation cancel];
    self.netWorkOperation = nil;
    self.netWorkKit = nil;
}

-(void)addParseWeb:(NSArray*)webArray key:(NSString*)key
{
    __weak __typeof(self)weakSelf = self;
    [webArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.arrayWebs addObject:@{@"webUrl":obj,@"key":key,@"index":[NSNumber numberWithInteger:idx]}];
    }];
    [self tryToHttpReqeust];
}

-(void)deleteWeb:(NSString*)key{
    
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
    [self.arrayWebs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([[obj objectForKey:@"key"] isEqualToString:key]){
            [set addIndex:idx];
        }
    }];
    [self.arrayWebs removeObjectsAtIndexes:set];
}

-(void)stopCurrentParse{
    [self.netWorkOperation cancel];
    self.netWorkOperation = nil;
}

-(void)tryToHttpReqeust{
    if (self.arrayWebs.count>0 && !self.netWorkOperation) {
        NSDictionary *info =  [self.arrayWebs objectAtIndex:0];
        __weak __typeof(self)weakSelf = self;
        self.netWorkOperation = [self.netWorkKit operationWithURLString:[info objectForKey:@"webUrl"] timeOut:3];
        self.netWorkOperation.userInfo = @{@"key":[info objectForKey:@"key"],@"object":info};
        [self.netWorkOperation addHeaders:@{@"User-Agent":IosIphoneOldUserAgent}];
        [self.netWorkOperation onCompletion:^(MKNetworkOperation *completedOperation) {
            [weakSelf pareseResopne:completedOperation];
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
            [weakSelf pareseResopne:completedOperation];
        }];
        [self.netWorkKit enqueueOperation:self.netWorkOperation];
    }
}

-(void)filterArray:(NSArray*)array number:(NSNumber*)indexNumber key:(NSString*)key object:(id)object{
    NSMutableArray *newTmpArray = [NSMutableArray arrayWithCapacity:100];
    [array enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![self.faildInfo objectForKey:[obj objectForKey:@"name"]]){
            [newTmpArray addObject:obj];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:WebLiveNofitiSuccessMsg(key) object:@{@"retKey":newTmpArray,@"index":indexNumber}];
    [self.arrayWebs removeObject:object];
    self.netWorkOperation = nil;
    [self tryToHttpReqeust];
}

-(void)pareseResopne:(MKNetworkOperation*)completedOperation{
    NSInteger code = completedOperation.HTTPStatusCode;
    NSString *key = [completedOperation.userInfo objectForKey:@"key"];
    NSDictionary *object = [completedOperation.userInfo objectForKey:@"object"];
    NSNumber *indexNumber = [object objectForKey:@"index"];
    if (code>=200 && code<=300) {
        __weak __typeof(self)weakSelf = self;
        NSString *str = [NSString stringWithFormat:@"__webjsNodePlug__.getWebNoInFoJs(\"%@\")",[completedOperation.responseString urlEncodedString]];
        [self.parseWebView evaluateJavaScript:str completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            [weakSelf filterArray:ret number:indexNumber key:key object:object];
        }];
    }
    else{
        [self.arrayWebs removeObject:object];
        [[NSNotificationCenter defaultCenter]postNotificationName:WebLiveNofitifaildMsg(key) object:indexNumber];
        self.netWorkOperation = nil;
        [self tryToHttpReqeust];
    }
}

-(void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
 
}
@end
