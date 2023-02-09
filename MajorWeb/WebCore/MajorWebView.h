
#import <WebKit/WebKit.h>

@interface MajorWebView : WKWebView
//-(void)delFiterDom;
@property(nonatomic,strong)id callBackDelegate;
@property(nonatomic,weak)id callBackUIdelegate;
@end
