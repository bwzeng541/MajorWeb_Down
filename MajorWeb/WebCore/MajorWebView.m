

#import "MajorWebView.h"
@interface MajorWebView()
@end
@implementation MajorWebView
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration{
    self = [super initWithFrame:frame configuration:configuration];
    return self;
}


-(void)removeFromSuperview{
    self.scrollView.delegate = nil;
    self.callBackDelegate = nil;
    [super removeFromSuperview];
}

@end
