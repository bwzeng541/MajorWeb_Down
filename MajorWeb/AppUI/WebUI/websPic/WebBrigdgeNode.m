

#import "WebBrigdgeNode.h"
#import "BeatifyWebView.h"

@interface WebBrigdgeNode()<BeatifyWebViewDelegate>
@property(assign,nonatomic)BOOL isExctjJs;
@property(copy,nonatomic)NSString *webUrl;
@property(assign,nonatomic)NSInteger type;
@property(strong,nonatomic)BeatifyWebView *pareseWebView;
@property(copy,nonatomic)NSString *picName;
@end

@implementation WebBrigdgeNode
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}


-(void)startUrl:(NSString*)url type:(NSInteger)type{
    if (!self.pareseWebView) {
        self.pareseWebView = [[BeatifyWebView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        self.pareseWebView.delegate = self;
        [self.pareseWebView loadWebView];
        [self.pareseWebView loadAllJs:true];
        [[UIApplication sharedApplication].keyWindow addSubview:self.pareseWebView];
        self.pareseWebView.frame = CGRectMake(0,MY_SCREEN_HEIGHT*10,MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT);
    }
    self.type = type;
    self.webUrl = url;
    self.picName = [url md5];
    
    NSLog(@"self.index  url = %@",url);
    NSString *filePath = [WebBrigdgeNode isPicFileExit:self.picName];
    if (filePath) {
        [self.delegate revicePic:filePath];
        NSString *msg = @"<img id=\"manga\" src=\"20191101pic_key\"style=\"max-width: 100%;\">";
        NSString *file = [[NSURL fileURLWithPath:filePath] absoluteString];
        NSString *name = [file substringFromIndex:[file rangeOfString:@"/pics/"].location+6];
        file = [@"http://localhost:10086" stringByAppendingFormat:@"%@%@",@"/pics/",name];
        msg = [msg stringByReplacingOccurrencesOfString:@"20191101pic_key" withString:file];
        [self.delegate updateDomContent:msg url:self.webUrl imageUrl:nil isLocal:YES picName:self.picName];
    }
    else{
        [self.pareseWebView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

+(NSString*)isPicFileExit:(NSString*)name{
    NSString *file =[[BeatifyWebPicsViewWebRoot stringByAppendingPathComponent:BeatifyWebPicsViewPicDirName] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return file;
    }
    return nil;
}

+(NSString*)getPicFileFromUrl:(NSString*)url{
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *name = [url substringFromIndex:range.location+1];
    NSString *file  = [[BeatifyWebPicsViewWebRoot stringByAppendingPathComponent:BeatifyWebPicsViewPicDirName] stringByAppendingPathComponent:name];
    return file;
}

-(void)stopLoading{
    [self.pareseWebView stopLoading];
}

-(void)stop
{
    [self.pareseWebView removeFromSuperview];
    self.pareseWebView = nil;
}

-(void)tryTopGetInfo{
    __weak __typeof__(self) weakSelf = self;
    [self.pareseWebView evaluateJavaScript:[NSString stringWithFormat:@"getWebLists(\'%@\')",self.webUrl] completionHandler:^(id ret, NSError * _Nullable error) {
        weakSelf.isExctjJs = false;
        if (weakSelf.type==0) {
            [weakSelf.delegate updateListArray:[ret objectForKey:@"retArray"]];
            [weakSelf.delegate updateDomContent:[ret objectForKey:@"dom"] url:self.webUrl imageUrl:[ret objectForKey:@"imageUrl"]isLocal:false picName:self.picName];
        }
        else if(weakSelf.type==1){
            [weakSelf.delegate updateDomContent:[ret objectForKey:@"dom"] url:self.webUrl imageUrl:[ret objectForKey:@"imageUrl"]isLocal:false picName:self.picName];
        }
    }];
}

- (void)webViewLoadingPogress:(float)progress uuid:(NSString *)uuid {
    if (!self.isExctjJs && progress>=0.6) {
             self.isExctjJs = true;
        [self tryTopGetInfo];
        }
}


-(void)webViewDidFinishLoad:(BeatifyWebView *)webView {
    [self tryTopGetInfo];
}
@end
