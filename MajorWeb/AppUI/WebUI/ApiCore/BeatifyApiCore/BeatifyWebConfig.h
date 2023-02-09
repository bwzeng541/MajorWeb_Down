//
//  BeatifyWebConfig.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/4/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeatifyWebConfig : NSObject
+(BeatifyWebConfig*)getInstance;
+(void)addDefaultJs:(WKWebView*)webView jsContent:(NSString*)jsContent messageName:(NSArray*)messageNameArray;
-(WKProcessPool *)processPool ;
@property(readonly,nonatomic)BOOL isAdPlugInitSuucess;
@property(assign,nonatomic)BOOL isAllowsBackForwardGestures;
-(void)addWebObser:(WKWebView*)web;
-(void)remveWebObser:(WKWebView*)web;

-(void)removeRule:(WKWebView*)v;
-(void)remveAllJs:(WKWebView*)webView;
//添加js
-(void)updateWebMode:(WKWebView*)webView isSuspensionMode:(BOOL)isSuspensionMode;
-(void)updateRule:(WKWebView*)webView;

+(void)isUrlValid:(NSString*)urlString callBack:(void(^)(BOOL validValue, NSString *result))callBack;

@end

NS_ASSUME_NONNULL_END
