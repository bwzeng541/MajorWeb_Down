//
//  WebPushManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "WebPushManager.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"
#import "AppDelegate.h"
@interface WebPushManager ()<WebCoreManagerDelegate,WebPushItemDelegate>
@property (nonatomic,strong)MajorWebView *webView;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSMutableArray *arrayData;
@property (nonatomic,strong)NSMutableArray *parseData;
@property (nonatomic,assign)NSInteger retryTime;
@property (nonatomic,assign)BOOL isDelData;
@property (nonatomic,assign)BOOL isReqeustSuccess;
@property (nonatomic, copy) void(^webPushFaild)(void);
@property (nonatomic, copy) void(^startRequetHomeBlock)(void);
@property (nonatomic, copy) void(^showBlock)(NSArray *array);
@property (nonatomic, copy) void(^webPushItemUpdate)(WebPushItem *item,BOOL isRemoveOldAll);
@end

@implementation WebPushManager

+(WebPushManager*)getInstance
{
    static WebPushManager *g = NULL;
    if (!g) {
        g = [[WebPushManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    self.arrayData = [NSMutableArray arrayWithCapacity:20];
    self.parseData = [NSMutableArray arrayWithCapacity:20];
    self.isReqeustSuccess = false;
    return self;
}

-(void)loadWeb{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

-(void)stop{
    self.webPushItemUpdate = nil;
    self.webPushFaild = nil;
    self.showBlock = nil;
    self.startRequetHomeBlock = nil;
    [[WebCoreManager getInstanceWebCoreManager]destoryWKWebView:self.webView];
    RemoveViewAndSetNil(self.webView);
    [self clearAllItem];
}

-(void)clearAllItem{
    [self.arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj stop];
    }];
    [self.arrayData removeAllObjects];
}

-(void)startWithUrlUsrOldBlock:(NSString*)url{
    [self clearAllItem];
    [self startWithUrl:url updateBlock:self.webPushItemUpdate falidBlock:self.webPushFaild];
}


-(void)showDateBlock:(void(^)(NSArray*))showBlock updateBlock:(void(^)(WebPushItem*item,BOOL isRemoveOldAll))updateBlock startHomeBlock:(void(^)(void))startHomeBlock falidBlock:(void(^)(void))falidBlock{
    self.showBlock = showBlock;
    self.webPushItemUpdate = updateBlock;
    self.startRequetHomeBlock = startHomeBlock;
    self.webPushFaild = falidBlock;
    if (self.parseData.count>0 && self.showBlock) {
        self.showBlock(self.parseData);
    }
    if (self.parseData.count==0) {
        self.retryTime = 0;
        if (self.startRequetHomeBlock) {
            self.startRequetHomeBlock();
        }
    }
}

-(void)startWithUrl:(NSString*)url updateBlock:(void(^)(WebPushItem*item,BOOL isRemoveOldAll))updateBlock falidBlock:(void(^)(void))falidBlock{
    self.webPushItemUpdate = updateBlock;
    self.webPushFaild = falidBlock;
    self.isDelData = true;
    if (!self.webView) {
        self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
        [GetAppDelegate.getRootCtrlView addSubview:self.webView];
        self.webView.frame = CGRectMake(0,20000, 320, 480);
        self.url = url;
        self.retryTime = 0;
        @weakify(self)
        [RACObserve(GetAppDelegate,isUpateJsChange) subscribeNext:^(id x) {
            @strongify(self)
            [self updateJsWeb];
        }];
        [self loadWeb];
    }
}

- (NSMutableArray *) randomizedArrayWithArray:(NSArray *)array {
    NSMutableArray *results = [[NSMutableArray alloc]initWithArray:array];
//    NSInteger i = [results count];
//    while(--i > 0) {
//        int j = rand() % (i+1);
//        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
//    }
    return results;
}

-(void)updateItem:(NSArray*)array{
    if (array.count>0) {
        array = [NSArray arrayWithArray:[self randomizedArrayWithArray:array]];
        [self.arrayData removeAllObjects];
        [[WebCoreManager getInstanceWebCoreManager]destoryWKWebView:self.webView];
        RemoveViewAndSetNil(self.webView);
        //创建
        for (int i =0; i < array.count; i++) {
            NSDictionary *info = [array objectAtIndex:i];
            WebPushItem *item = [[WebPushItem alloc] initWithUrl:[info objectForKey:@"url"] iconUrl:[info objectForKey:@"imgUrl"] referer:[info objectForKey:@"referer"] title:[info objectForKey:@"title"]];
            item.delegate = self;
            [self.arrayData addObject: item];
            [item delayStart:0];
        }
    }
}

-(void)updateWebPushSuccess:(id)object{
    if (self.webPushItemUpdate) {
        self.webPushItemUpdate(object,self.isDelData);
    }
    if (self.isDelData) {
        [self.parseData removeAllObjects];
    }
    [self.parseData addObject:object];
    self.isDelData = false;
    if (!self.isReqeustSuccess) {
        static BOOL flag =true;
        if (flag) {
            self.isReqeustSuccess = true;
        }
        _isReqeustSuccess = false;
        flag = false;
    }
}

-(void)updateJsWeb{
    if (self.webView) {
        [[WebCoreManager getInstanceWebCoreManager] updateVideoPlayMode:self.webView isSuspensionMode:false];
        [self loadWeb];
    }
}

- (void)webCore_webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if (self.webView && self.retryTime++<4) {
        [self performSelector:@selector(loadWeb) withObject:nil afterDelay:4];
    }
    else{
        [[WebCoreManager getInstanceWebCoreManager]destoryWKWebView:self.webView];
        RemoveViewAndSetNil(self.webView);
    }
}

//解析
- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    __weak __typeof(self)weakSelf = self;
//    [webView evaluateJavaScript:@"__webjsNodePlug__.gotoParseWeb()" completionHandler:^(NSArray* ret, NSError * _Nullable error) {
//        NSLog(@"error = %@",[error description]);
//        [weakSelf updateItem:ret];
//    }];
}

@end
