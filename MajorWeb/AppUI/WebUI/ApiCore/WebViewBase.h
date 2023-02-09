//
//  WebViewBase.h
//  WatchApp
//
//  Created by zengbiwang on 2017/4/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSCHUDManager.h"
#import "YSCKitMacro.h"
#import <WebKit/WebKit.h>

#define DoUseWaitView 0

#if (UserWKWebView==1)
#define UIWebView WKWebView
#endif


#define ShowHUDOnViewUsePng  \
if(![self.waitView viewWithTag:10000]){ \
UIImageView *imageView =  [[UIImageView alloc]initWithFrame:self.waitView.bounds]; \
imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight; \
imageView.image = UIImageFromNSBundlePngPath(@"Default_wwww"); \
imageView.tag = 10000; \
[self.waitView addSubview:imageView]; } \
[YSCHUDManager showHUDOnView:self.waitView message:@"视频加载中..." edgeInsets:UIEdgeInsetsZero backgroundColor:[UIColor clearColor]];
#define HiddenHUDOnViewUsePng \
[[self.waitView viewWithTag:10000] removeFromSuperview]; \
[YSCHUDManager hideHUDOnView:self.waitView animated:NO];

@class MajorWebView;
@interface UIWebViewTv : UIWebView
@end


typedef void (^WebViewBaseMsgBlock)(NSString *videoUrl);
@interface WebViewBase : NSObject
@property (nonatomic,strong)NSTimer *checkVideoTimer;
@property (nonatomic,strong)NSTimer *webViewLoadFinshTimer;

@property (nonatomic,strong,readonly)MajorWebView *webView;
@property(nonatomic,weak)UIView *waitView;
@property(nonatomic,assign)BOOL isShowFailMsg;
@property(nonatomic,copy)NSString *showName;
@property(nonatomic,assign)BOOL isAutoRemovePlayFution;
@property(nonatomic,copy)WebViewBaseMsgBlock msgBlock;
@property(nonatomic,assign)BOOL isCanShowWaitView;
//YuGuWebViewNode//使用
@property(nonatomic,assign)BOOL isDirectApi;
//end
#if (UserWKWebView!=1)
-(void)webViewBaseDidFinishLoad:(UIWebView*)webView;
-(void)checkVideoUrl:(UIWebView*)webView;
#endif
-(void)getWebTitle:(void(^)(NSString *title))titleBlock;
-(id)initWithUrl:(NSString*)url html:(NSString*)html showName:(NSString*)showName isShowFailMsg:(BOOL)f hidenParentView:(UIView*)view;
-(void)start;
-(void)stop;
-(void)initOtherParam;
-(NSString*)chaoshichuli;
-(void)cleanWebView;
#pragma mark--debug
-(void)setWebDebugFrame:(CGRect)rect parentView:(UIView*)view;

-(void)InitExtendWebConfig;
-(void)UnintExtendWebConfig;
@end
