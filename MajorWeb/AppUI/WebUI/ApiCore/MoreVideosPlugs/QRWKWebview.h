//
//  QRWKWebview.h
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/17.
//  Copyright © 2020 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef enum QRWKWebviewType{
    webView_Naroml,
    webView_Simple,
    webView_Simple_Finish,
    webView_Short,
}_QRWKWebviewType;

@protocol QRWKWebviewDelegate <NSObject>
@optional
-(void)qrUpdateGoForwardState:(BOOL)isEnable;
-(void)qrUpdateGoBackState:(BOOL)isEnable;
-(void)qrUpdateWhiteScreen;

-(BOOL)qrLinkActivatedHandle:(NSString*)url object:(id)object;

-(BOOL)qrDecidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                         decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
-(void)qrUpdateUrl:(NSString*)url host:(NSString*)host;
-(void)qrUpdateProgress:(float)progress;
-(void)qrUpdateTitle:(NSString*)title;
-(void)qrGetAssetUrl:(NSString*)fileUrl title:(NSString*)title weblink:(NSString*)weblink;
-(void)qrDidFinishNavigation:(NSString*)url title:(NSString*)title;
-(void)qrStartProvisionalNavigation;
-(void)qrVideoHandler:(NSDictionary*)info;

-(void)qrWebCheckTimeOut;
-(void)qrWebPressAsset;
-(void)qrGetMoreInfoCallBack:(NSArray*)array isSeek:(BOOL)seek;
-(void)qrInsertView:(CGRect)rect;
-(void)qrGetAssetSuccess:(NSArray*)array isSeek:(BOOL)seek;
-(void)qrUpDataAsset:(NSString*)url ;
-(void)qrGetAsset:(NSString*)url referer:(NSString*)referer title:(NSString*)title isAsset:(BOOL)isAsset rect:(CGRect)rect;
-(void)qrExternCallBack:(BOOL)isSuccess uuid:(NSString*)uuid assetKey:(NSString*)assetKey title:(NSString*)title;
@end
@interface QRWKWebview : UIView
@property(readonly,nonatomic)NSString *webUUID;
@property(assign, nonatomic) _QRWKWebviewType webViewType;
@property(readonly,nonatomic)WKWebView *webView;
@property(weak)id<QRWKWebviewDelegate>qrWkdelegate;
@property(assign)BOOL isUseChallenge;
- (void)tryPlayOperation;
-(id)initWithFrame:(CGRect)frame uuid:(NSString*)uuid userAgent:(NSString*)userAgent isExcutJs:(BOOL)isExcutJs;
-(void)loadUrl:(NSString*)url;
@end

NS_ASSUME_NONNULL_END
