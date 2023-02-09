//
//  MajorZyListView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/9.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZyListView.h"
#import "MajorWebView.h"
#import "WebCoreManager.h"
#import "JMDefine.h"
#import "MajorZyCookie.h"
#import "MajorWebView+WebCookie.h"
#import "MajorZyPlug.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "Toast+UIView.h"
#import "VipPayPlus.h"
#import "ShareSdkManager.h"
#import "MajorZyBridgeNode.h"
#import "FMTagsView.h"
#import "AppDelegate.h"
static BOOL MajorZyShowHelp = true;
@interface MajorZyListView()<WebCoreManagerDelegate,FMTagsViewDelegate>
{
    float _picW;
}
@property(strong,nonatomic)MajorZyBridgeNode *birdgeNode;//正序排列的数组
@property(strong,nonatomic)NSArray *positiveArray;//正序排列的数组
@property(strong,nonatomic)NSArray *listArray;//传递过来的是逆序数组
@property(strong,nonatomic)UIButton *closeBtn;
@property(strong,nonatomic)UIButton *listBtn;
@property(strong,nonatomic)UIButton *jiangxuBtn;
@property(strong,nonatomic)UIButton *positiveBtn;
@property(copy,nonatomic)NSString* showName;
@property(copy,nonatomic)NSString* dataSource;
@property(strong,nonatomic)UILabel *titleLable;
@property(copy,nonatomic)NSString *currentUrl;
@property(strong,nonatomic)MajorWebView *majorWebView;
@property(strong,nonatomic)UIProgressView *webProgressView;
@property(strong,nonatomic)FMTagsView *collectionView;
@property(strong,nonatomic)UIView *bottomView;
@property(assign,nonatomic)BOOL isPositive;
@property(assign,nonatomic)BOOL isBridgeMode;
@property(assign,nonatomic)BOOL isExitRead;
@property(assign,nonatomic)NSInteger selectedIndex;
@property(assign,nonatomic)NSInteger positiveIndex;
@property(assign,nonatomic)BOOL isCanAddWebTouch;
@property(assign,nonatomic)BOOL isAddWebTouchSuccess;
@property(copy,nonatomic)void(^closeBlock)(void);

@end
@implementation MajorZyListView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (BOOL)isValidGesture:(CGPoint)point{
    if (point.x<self.bounds.size.width/2) {
        return true;
    }
    return false;
}

-(instancetype)initWithFrame:(CGRect)frame showName:(NSString*)showName array:(NSArray*)listArray dataSource:(NSString*)dataSource isPage:(BOOL)isPage closeBlcok:(void(^)(void))closeBlock{
    self = [super initWithFrame:frame];
    UIView *topW = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, GetAppDelegate.appStatusBarH)];
    [self addSubview:topW];
    self.isBridgeMode = !isPage;
    self.isPositive = false;
    topW.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    self.closeBlock = closeBlock;
    self.showName = showName;
    self.isUsePopGesture = true;
    self.listArray = listArray;
    self.dataSource = dataSource;
    self.positiveArray = [listArray reverseObjectEnumerator].allObjects;
    [self loadList:showName];
    syncCartoonList(listArray, showName,self.dataSource);
    return self;
}

-(void)removeFromSuperview
{
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self.birdgeNode stop];
    self.birdgeNode = nil;
    [self.majorWebView.configuration.userContentController removeScriptMessageHandlerForName:sendWebJsNodeLeftMessageInfo];
    [self.majorWebView.configuration.userContentController removeScriptMessageHandlerForName:sendWebJsNodeRightMessageInfo];
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.majorWebView];
    self.majorWebView = nil;
    [super removeFromSuperview];
}

-(void)loadHistroyUrl:(NSString*)url
{
    self.currentUrl = url;
    [self findCurrentUrlAndScorll];
    [self loadWebUrl:url];
}

-(void)loadList:(NSString*)title
{
    self.isExitRead = true;
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn addTarget:self action:@selector(closeZyList) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[UIImage imageNamed:@"AppMain.bundle/close_ad.png"] forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self.closeBtn setFrame:CGRectMake(5, GetAppDelegate.appStatusBarH, 35, 35)];
    [self addSubview:self.closeBtn];
    
    self.listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listBtn setFrame:CGRectMake(MY_SCREEN_WIDTH-55, GetAppDelegate.appStatusBarH, 50, 35)];
    [self addSubview:self.listBtn];
    [self.listBtn setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self.listBtn setTitle:@"选集" forState:UIControlStateNormal];
    self.listBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.listBtn addTarget:self action:@selector(showlist) forControlEvents:UIControlEventTouchUpInside];

    float startY = self.closeBtn.frame.origin.y+self.closeBtn.frame.size.height;
    
    
    self.positiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.positiveBtn setFrame:CGRectMake(5, startY+20, 50, 35)];
    [self addSubview:self.positiveBtn];
    [self.positiveBtn setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self.positiveBtn setTitle:@"升序" forState:UIControlStateNormal];
    self.positiveBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [self.positiveBtn addTarget:self action:@selector(positiveEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.jiangxuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.jiangxuBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [self.jiangxuBtn setFrame:CGRectMake(_positiveBtn.frame.origin.x+_positiveBtn.frame.size.width*1.5, self.positiveBtn.frame.origin.y, 50, 35)];
    [self addSubview:self.jiangxuBtn];
    [self.jiangxuBtn setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self.jiangxuBtn setTitle:@"降序" forState:UIControlStateNormal];
    [self.jiangxuBtn addTarget:self action:@selector(jiangxuEvent:) forControlEvents:UIControlEventTouchUpInside];
    
   self.majorWebView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager]createWKWebViewWithUrl:nil isAutoSelected:false delegate:self];
    [self addSubview:self.majorWebView];
    
    [self.majorWebView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)self.majorWebView).callBackDelegate name:sendWebJsNodeLeftMessageInfo];
    [self.majorWebView.configuration.userContentController addScriptMessageHandler:((MajorWebView*)self.majorWebView).callBackDelegate name:sendWebJsNodeRightMessageInfo];

    if (@available(iOS 11.0, *)) {
    }
    else{
        NSString*  cookie = @"document.cookie = 'readmode=3';\n";
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.majorWebView.configuration.userContentController addUserScript:cookieScript];
    }
    
    self.webProgressView = [[UIProgressView alloc]
                            initWithFrame:CGRectMake(0, startY,
                                                     self.frame.size.width, 2)];
    self.webProgressView.progressTintColor =RGBCOLOR(255, 0, 0); // ProgressTintColor;
    self.webProgressView.trackTintColor = [UIColor blackColor];
    self.webProgressView.alpha = 1;
    [self addSubview:self.webProgressView];
    float webH = MY_SCREEN_WIDTH;
    float toolsH = 46;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-toolsH-(GetAppDelegate.appStatusBarH-20), MY_SCREEN_WIDTH, toolsH)];
    [self addSubview:self.bottomView];self.bottomView.backgroundColor = [UIColor blackColor];
    [self initBottomView];
    startY = self.closeBtn.frame.origin.y+self.closeBtn.frame.size.height;
    self.majorWebView.frame = CGRectMake(0, startY, webH, self.bottomView.frame.origin.y-startY);
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,MY_SCREEN_WIDTH, 30)];
    self.titleLable.center = CGPointMake(_titleLable.center.x, self.closeBtn.center.y);
    self.titleLable.text = title;
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.font  = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    self.titleLable.textColor = [UIColor blackColor];
    [self insertSubview:_titleLable belowSubview:_closeBtn];
    startY = self.positiveBtn.frame.origin.y+self.positiveBtn.frame.size.height;
    self.collectionView = [[FMTagsView alloc] initWithFrame:CGRectMake(30, startY, MY_SCREEN_WIDTH-60, MY_SCREEN_HEIGHT-startY-(GetAppDelegate.appStatusBarH-20))];
    [self addSubview:self.collectionView];
    if (IF_IPHONE) {
        _picW = (self.collectionView.bounds.size.width-80)/4;
    }
    else{
        _picW = (self.collectionView.bounds.size.width-60)/6;
    }
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.tagHeight = 30;
    self.collectionView.interitemSpacing = 10;
    self.collectionView.mininumTagWidth = _picW;
    self.collectionView.allowEmptySelection = NO;
    self.collectionView.tagSelectedTextColor = [UIColor redColor];
    self.collectionView.tagSelectedFont =  [UIFont fontWithName:@"Helvetica-Bold" size:12];
    self.collectionView.tagFont =  [UIFont systemFontOfSize:12];
    self.collectionView.tagSelectedBackgroundColor = self.collectionView.tagBackgroundColor;
    [self updateTitleArray];

    self.bottomView.hidden = self.listBtn.hidden = self.majorWebView.hidden = self.webProgressView.hidden = YES;
    self.selectedIndex = 0;
    self.currentUrl = getCartoonHistory([self.showName md5]);
    if (self.currentUrl) {
        [self findCurrentUrlAndScorll];
    }
}

-(void)updateTitleArray{
    NSMutableArray *arraty = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < self.listArray.count; i++) {
      [arraty addObject:[[_listArray objectAtIndex:i] objectForKey:@"title"]]  ;
    }
    self.collectionView.tagsArray = arraty;
}

-(void)positiveEvent:(UIButton*)sender{
    if (self.isPositive!=true) {
        self.listArray = self.positiveArray;
        [self updateTitleArray];
        if (self.currentUrl) {
            [self findCurrentUrlAndScorll];
        }
    }
    self.isPositive = true;
}

-(void)jiangxuEvent:(UIButton*)sender{
    if (self.isPositive!=false) {
        self.listArray  = [self.positiveArray reverseObjectEnumerator].allObjects;
        [self updateTitleArray];
        if (self.currentUrl) {
            [self findCurrentUrlAndScorll];
        }
    }
    self.isPositive = false;
}

- (UIButton*)createEventBtn:(SEL)action rect:(CGRect)rect title:(NSString*)title{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = rect;
    return btn;
}

-(void)initBottomView{
    UIButton *nextBtn = [self createEventBtn:@selector(prePic:) rect:CGRectMake(0, 0, 0, 0) title:@"<上一页 "];
    [self.bottomView addSubview:nextBtn];
    UIButton *preBtn = [self createEventBtn:@selector(nextPic:) rect:CGRectMake(0, 0, 0, 0) title:@" 下一页>"];
    [self.bottomView addSubview:preBtn];

    UIButton *choucang = [self createEventBtn:@selector(choucang:) rect:CGRectMake(0, 0, 0, 0) title:@"收藏"];
    [self.bottomView addSubview:choucang];
    choucang.frame = CGRectMake(5, 0, 40, self.bottomView.bounds.size.height);

    UIButton *share = [self createEventBtn:@selector(share:) rect:CGRectMake(0, 0, 0, 0) title:@"分享"];
    [self.bottomView addSubview:share];
    share.frame = CGRectMake(MY_SCREEN_WIDTH- choucang.frame.size.width-10, 0, 40, self.bottomView.bounds.size.height);
    
    UIButton *quxiao = [self createEventBtn:@selector(quxiao:) rect:CGRectMake(0, 0, 0, 0) title:@"取消广告"];
    [self.bottomView addSubview:quxiao];
    float s = 0;
    if(IF_IPHONE)
    {
        quxiao.frame = CGRectMake(MY_SCREEN_WIDTH-60, 0, 60, self.bottomView.bounds.size.height);
    }
    else{
        s  =1;
         quxiao.frame = CGRectMake(MY_SCREEN_WIDTH/2+240, 0, 60, self.bottomView.bounds.size.height);
    }
    nextBtn.frame = CGRectMake(MY_SCREEN_WIDTH/2-s*40-75, 0, 60, self.bottomView.bounds.size.height);
     preBtn.frame = CGRectMake(MY_SCREEN_WIDTH/2+75-s*40, 0, 60, self.bottomView.bounds.size.height);
    quxiao.alpha = 0;
}

//通过cell点击
-(void)loadFromIndex:(NSInteger)index{
    self.selectedIndex = index;
    NSString *url =  [[self.listArray objectAtIndex:index] objectForKey:@"url"];
    self.currentUrl = url;
    [self loadWebUrl:url];
    [self findCurrentUrlAndScorll];
}


-(void)findCurrentUrlAndScorll{
    __weak MajorZyListView *weakSelf = self;
   __block   NSInteger index = 0;
    [self.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (weakSelf.currentUrl && [[obj objectForKey:@"url"] isEqualToString:weakSelf.currentUrl]) {
            index = idx;
            *stop = true;
        }
    }];
    
    self.positiveIndex = 0;
    [self.positiveArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (weakSelf.currentUrl && [[obj objectForKey:@"url"] isEqualToString:weakSelf.currentUrl]) {
            weakSelf.positiveIndex = idx;
            *stop = true;
        }
    }];
    self.titleLable.text = [NSString stringWithFormat:@"%@:%@",self.showName,[[self.listArray objectAtIndex:index] objectForKey:@"title"]] ;
    self.selectedIndex = index;
    [self.collectionView updateSelectState:YES index:self.selectedIndex];
}

-(void)quxiao:(UIButton*)sender{
    [[VipPayPlus getInstance] isVaildOperation:false plugKey:MajorPlugKey];
}

-(void)share:(UIButton*)sender{
    [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
        return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
    } value:^NSString *{
        return nil;
    } titleBlock:^NSString *{
        return nil;
    } imageBlock:^UIImage *{
        return nil;
    }urlBlock:^NSString  *{
        return nil;
    }shareViewTileBlock:^NSString *{
        return @"分享app";
    }];
}

-(void)choucang:(UIButton*)sender{
    syncCartoonFavourite(self.showName,self.dataSource);
}

-(void)prePic:(UIButton*)sender{
    if (self.positiveIndex-1>0 && self.positiveArray.count>0) {
        [self loadHistroyUrl:[[self.positiveArray objectAtIndex:self.positiveIndex-1]objectForKey:@"url"]];
    }
    else{
        [self makeToast:@"已到第一章" duration:1 position:@"center"];
    }
}

-(void)nextPic:(UIButton*)sender{
    if (self.positiveIndex+1<self.positiveArray.count) {
        [self loadHistroyUrl:[[self.positiveArray objectAtIndex:self.positiveIndex+1]objectForKey:@"url"]];
    }
    else{
        [self makeToast:@"已到最后一章" duration:1 position:@"center"];
    }
}

-(void)showlist{
    self.titleLable.text = self.showName;
   self.bottomView.hidden = self.listBtn.hidden = self.majorWebView.hidden = self.webProgressView.hidden = YES;
    self.collectionView.hidden = NO;
    self.isExitRead = false;
}

-(void)loadWebUrl:(NSString*)url{
    self.isExitRead = true;
    syncCartoonHistory(url, self.showName,self.dataSource);
    self.bottomView.hidden = self.listBtn.hidden = self.majorWebView.hidden = self.webProgressView.hidden = NO;
    self.collectionView.hidden = YES;
    [self.birdgeNode stop];
    self.birdgeNode = nil;
    if (self.isBridgeMode) {
        NSString *basePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/zymywww"];
        NSURL *baseUrl =  [NSURL fileURLWithPath:basePath isDirectory:YES];
        NSString *path = [NSString stringWithFormat:@"%@/index.html",basePath];
        NSString *urt= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
         [self.majorWebView loadHTMLString:urt baseURL:baseUrl];
        __weak MajorZyListView *weakSelf = self;
        self.birdgeNode = [[MajorZyBridgeNode alloc] init];
        [self.birdgeNode startWithUrl:url totalBlock:^(NSInteger totalNo) {
    
        } imageBlock:^(NSString * _Nonnull imageDom, NSInteger index,NSInteger total) {
            [weakSelf.majorWebView evaluateJavaScript:[NSString stringWithFormat:@"__webjsNodePlug__.addPicIntoWeb('%@',%ld,%ld)",imageDom,index,total] completionHandler:^(id ret , NSError * _Nullable error) {
                
            }];
        }];
     }
    else{
        [self loadRequestURL:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    if (MajorZyShowHelp) {
        //640X1138
        //
        UIImage*image = UIImageFromNSBundlePngPath(@"AppMain.bundle/read_help");
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_WIDTH*(1138.0/640));
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        [imageView bk_whenTapped:^{
            [imageView removeFromSuperview];
        }];
        MajorZyShowHelp = false;
        
    }
}

- (void)loadRequestURL:(NSMutableURLRequest *)request
{
    self.isCanAddWebTouch = false;
    self.majorWebView.allowsBackForwardNavigationGestures = false;
    [self.majorWebView insertCookie:[MajorZyCookie getReadModeCookie]];
    [self.majorWebView loadRequest:request];
}

- (void)webCore_webViewLoadProgress:(float)progress{
    [self updateProcessbar:progress animated:YES];
}

#pragma mark--label数据
- (void)tagsView:(FMTagsView *)tagsView didSelectAlreadyTagAtIndex:(NSUInteger)index{
    self.isExitRead = true;
    self.bottomView.hidden = self.listBtn.hidden = self.majorWebView.hidden = self.webProgressView.hidden = NO;
    self.collectionView.hidden = YES;
}

- (BOOL)tagsView:(FMTagsView *)tagsView shouldSelectTagAtIndex:(NSUInteger)index{
    return true;
}

- (void)tagsView:(FMTagsView *)tagsView didSelectTagAtIndex:(NSUInteger)index{
    [self loadFromIndex:index];
}

- (void)webCore_userContentController:(WKUserContentController *)userContentController
              didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name compare:sendWebJsNodeLeftMessageInfo]==NSOrderedSame)
    {
        NSLog(@"%s",__FUNCTION__);
        [self prePic:nil];
    }
    else if([message.name compare:sendWebJsNodeRightMessageInfo]==NSOrderedSame){
        NSLog(@"%s",__FUNCTION__);
        [self nextPic:nil];
    }
}

- (void)webCore_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    self.isCanAddWebTouch = true;
    self.isAddWebTouchSuccess = false;
}

- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
   
}


- (BOOL)webCore_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
   
    decisionHandler(WKNavigationActionPolicyAllow);
    return true;
}


- (void)updateProcessbar:(float)progress animated:(BOOL)animated {
    if (self.isCanAddWebTouch && !self.isAddWebTouchSuccess) {
        [self.majorWebView evaluateJavaScript:@"__webjsNodePlug__.hookBodyTouch();" completionHandler:^(id ret, NSError * _Nullable error) {
            if (!error) {
                self->_isAddWebTouchSuccess = true;
            }
         }];
        //self.isCanAddWebTouch = false;
    }

    if (progress == 1.0) {
        [self.webProgressView setProgress:progress animated:animated];
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.webProgressView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [self.webProgressView setProgress:0.0 animated:NO];
                             }
                         }];
    } else {
        if (self.webProgressView.alpha < 1.0) {
            self.webProgressView.alpha = 1.0;
        }
        [self.webProgressView setProgress:progress
                                 animated:(progress > self.webProgressView.progress) && animated];
    }
}

-(void)closeZyList{
    if (self.isExitRead) {
        [self removeFromSuperview];
    }
    else{
        [self tagsView:nil didSelectAlreadyTagAtIndex:0];
    }
}
@end
