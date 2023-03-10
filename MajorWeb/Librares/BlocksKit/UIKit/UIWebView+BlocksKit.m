//
//  UIWebView+BlocksKit.m
//  BlocksKit
//

#import "A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"
#import "UIWebView+BlocksKit.h"
#import "GDTCpNativeManager.h"
#import "GDTCpBannerManager.h"
#import "GDTInterstitialManager.h"
#import "MajorSystemConfig.h"
#pragma mark Custom delegate

@interface A2DynamicUIWebViewDelegate : A2DynamicDelegate <UIWebViewDelegate>
@end

@implementation A2DynamicUIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	BOOL ret = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
		ret = [realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];

    if((_clickState != GDT_CLICK_unVaild && [[[request.URL absoluteString]lowercaseString] rangeOfString:@"itms-appss"].location != NSNotFound)||(_click_banner_State != GDT_CLICK_unVaild && [[[request.URL absoluteString]lowercaseString] rangeOfString:@"itms-appss"].location != NSNotFound) || (_click_Interstitial_State != GDT_CLICK_unVaild && [[[request.URL absoluteString]lowercaseString] rangeOfString:@"itms-appss"].location != NSNotFound))
    {
        ret = false;
    }
    //GDTWebView
    if(([MajorSystemConfig getInstance].isGotoUserModel == 2) && [NSStringFromClass([webView class]) compare:@"GDTAdWebView"]==NSOrderedSame){
        NSString *url  = [request.URL absoluteString];
        for (int i = 0; i < [MajorSystemConfig getInstance].gdtWebfilterArray.count; i++) {
            NSString *strFilt =  [[MajorSystemConfig getInstance].gdtWebfilterArray objectAtIndex:i];
            NSRange l1 = [[url lowercaseString] rangeOfString:strFilt];
            if (l1.location != NSNotFound) {
                ret = false;
                break;
            }
        }
    }
    
    NSLog(@"shouldStartLoadWithRequest = %s\n",[[[[request.URL absoluteString]lowercaseString] description]UTF8String]);
    BOOL (^block)(UIWebView *, NSURLRequest *, UIWebViewNavigationType) = [self blockImplementationForMethod:_cmd];
    if (block)
        ret &= block(webView, request, navigationType);
    
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
		[realDelegate webViewDidStartLoad:webView];

	void (^block)(UIWebView *) = [self blockImplementationForMethod:_cmd];
	if (block) block(webView);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
		[realDelegate webViewDidFinishLoad:webView];

	void (^block)(UIWebView *) = [self blockImplementationForMethod:_cmd];
	if (block) block(webView);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
		[realDelegate webView:webView didFailLoadWithError:error];

	void (^block)(UIWebView *, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block) block(webView, error);
}

@end

#pragma mark Category

@implementation UIWebView (BlocksKit)

@dynamic bk_shouldStartLoadBlock, bk_didStartLoadBlock, bk_didFinishLoadBlock, bk_didFinishWithErrorBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{
			@"bk_shouldStartLoadBlock": @"webView:shouldStartLoadWithRequest:navigationType:",
			@"bk_didStartLoadBlock": @"webViewDidStartLoad:",
			@"bk_didFinishLoadBlock": @"webViewDidFinishLoad:",
			@"bk_didFinishWithErrorBlock": @"webView:didFailLoadWithError:"
		}];
	}
}

@end
