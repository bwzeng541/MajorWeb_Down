//
//  BeatifyWebView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/4/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
@class BeatifyWebView;

typedef enum BeatifyWebViewType{
    webView_Naroml,
    webView_Test0,
    webView_Test,
    webView_TestChange,
}_BeatifyWebViewType;

@protocol BeatifyWebViewExternDelegate <NSObject>
@optional
-(void)webViewExternCallBack:(BOOL)isSuccess uuid:(NSString*)uuid assetKey:(NSString*)assetKey;
-(void)webViewSetWordSuucessCallBack:(BOOL)isSuccess uuid:(NSString*)uuid;
-(void)webViewSetClickSuccessCallBack:(BOOL)isSuccess uuid:(NSString*)uuid;
-(void)webViewGetPicsFromPagWebCallBack:(BOOL)isSuccess uuid:(NSString*)uuid ret:(NSDictionary *)retInfo;
@end

@protocol BeatifyWebViewPostMoreInfoDelegate <NSObject>
@optional
-(void)webViewPostMoreInfoCallBack:(NSArray*)array isSeek:(BOOL)seek;
-(void)webViewPostListInfoCallBack:(NSDictionary*)info;
-(void)webViewPostAssetInfoCallBack:(NSDictionary*)array;
@end

@protocol BeatifyWebViewClickDelegate <NSObject>
@optional
- (bool)webViewClick:(NSString*)url;
@end

@protocol BeatifyWebViewDelegate <NSObject>
@optional

- (void)webViewGetAsset:(NSString*)url referer:(NSString*)referer title:(NSString*)title isAsset:(BOOL)isAsset;
- (void)webViewUpDataAsset:(NSString*)url ;
- (void)webViewWillGoBack:(BeatifyWebView *)webView;

- (void)webViewWillGoForward:(BeatifyWebView *)webView;

- (void)webViewWillReload:(BeatifyWebView *)webView;

- (void)webViewWillStop:(BeatifyWebView *)webView;

- (void)webViewDidStartLoad:(BeatifyWebView *)webView;

- (void)webViewDidFinishLoad:(BeatifyWebView *)webView;

- (void)webViewWithError:(BeatifyWebView *)webView didFailLoadWithError:(NSError *)error;

- (void)webViewLoadingPogress:(float)progress;
//更新按钮
- (void)webViewUpdateForward:(BOOL)btnState;
//更新按钮
- (void)webViewUpdateGoBack:(BOOL)btnState;
//更新按钮
- (void)webViewUpdateStop:(BOOL)btnState;
- (void)webViewTitle:(NSString*)title;
- (void)webViewUrl:(NSString*)url;
- (void)webViewPressAsset;
- (void)webViewClickWebsFromImage:(NSString*)url;
@end

@interface BeatifyWebView : UIView
@property(weak,nonatomic)id<BeatifyWebViewPostMoreInfoDelegate>postMoreInfoDelegate;
@property(weak,nonatomic)id<BeatifyWebViewExternDelegate>externDelegate;
@property(weak,nonatomic)id<BeatifyWebViewDelegate>delegate;
@property(weak,nonatomic)id<BeatifyWebViewClickDelegate>clickDelegate;
@property(assign, nonatomic) _BeatifyWebViewType webViewType;
@property(copy, nonatomic) NSString *externParam;
@property(readonly, nonatomic) WKWebView *webView;
@property(readonly, nonatomic) NSString *uuid;
@property(readonly, nonatomic)UIProgressView *progressView;

- (NSString*)getWebUrl;
- (void)enableWebSrollview:(BOOL)f;
- (void)isOperationError:(BOOL)isOperation;
- (id)initWithFrame:(CGRect)frame isShowOpUI:(BOOL)isShowOpUI;
- (void)loadURL:(NSURL*)URL;
- (void)delayLoadURL:(NSURL*)URL time:(float)time isDefault:(BOOL)isDefault;
- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL;
- (void)loadAllJs:(BOOL)f;
- (void)loadAllRule;
- (void)goBack;
- (void)goForward;
- (void)stopLoading;
- (void)reloadWeb;
- (void)tryPlayOperation;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;
- (void)loadWebView;
@end

NS_ASSUME_NONNULL_END
