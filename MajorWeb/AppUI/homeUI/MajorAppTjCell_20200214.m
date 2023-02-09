//
//  MajorAppTjCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/12/24.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorAppTjCell.h"
#import "WebCoreManager.h"
#import "MajorWebView.h"
#import "MarjorWebConfig.h"
#import "ZYInputAlertView.h"
#import "AppVipBuyCtrl.h"
#import "AppDelegate.h"
#import "NewVipPay.h"
#import "GGWebSearchCtrl.h"
@protocol MajorAppTjViewDelegate
-(void)clickWebs:(NSString*)url;
@end
@interface MajorAppTjView : UIView
@property(weak)id<MajorAppTjViewDelegate> delegate;
@property(strong,nonatomic)MajorWebView *webView;
@property(assign,nonatomic)float offsetY;

@property(copy,nonatomic)NSString *url;
-(instancetype)initWithFrame:(CGRect)frame url:(NSString*)url title:(NSString*)title offsetY:(float)offsetY;
@end

@implementation MajorAppTjView
-(instancetype)initWithFrame:(CGRect)frame url:(NSString*)url title:(NSString*)title offsetY:(float)offsetY{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    self.url = url;
    self.offsetY = offsetY;
    self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager] createWKWebViewWithUrl:nil isAutoSelected:NO delegate:self];
    self.webView.scrollView.scrollEnabled  = NO;
    self.webView.frame =  CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
    [self addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

    float realW = self.bounds.size.width-20;
    self.webView.transform = CGAffineTransformMakeScale(realW/MY_SCREEN_WIDTH, realW/MY_SCREEN_WIDTH);
    self.clipsToBounds = YES;
    self.webView.center = CGPointMake(self.bounds.size.width/2, 5);
    self.webView.layer.anchorPoint = CGPointMake(0.5, 0);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-20, frame.size.width, 20)];
    label.text = title;
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    label.textAlignment = NSTextAlignmentCenter;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btn];
    btn.frame = self.bounds;
    [btn addTarget:self action:@selector(clickGo) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)webCore_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    float h = webView.scrollView.contentSize.height;
    if (h>self.offsetY) {
        [webView.scrollView setContentOffset:CGPointMake(0, self.offsetY)];
    }
}

-(void)clickGo{
    [self.delegate clickWebs:self.url];
}

-(void)dealloc{
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [[WebCoreManager getInstanceWebCoreManager] destoryWKWebView:self.webView];
    [self.webView removeFromSuperview];
    self.webView = nil;
}
@end

@interface MajorAppTjCell()<MajorAppTjViewDelegate,AppVipBuyCtrlDelegate,GGWebSearchCtrlDelegate>
@property(strong,nonatomic)GGWebSearchCtrl *searchCtrl;
@property(weak,nonatomic)MajorAppTjView *lastWebView;
@property(nonatomic,assign)float cellSizeH;
@property(strong)AppVipBuyCtrl *buyVipCtrl;
@property(strong,nonatomic)UILabel *vipLabel;
@end
@implementation MajorAppTjCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, 450)];
    self.cellSizeH =  1290;
    NSString *lastUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUrl20191226"];
    lastUrl = [lastUrl length]>0?lastUrl:@"http://www.baidu.com";
    NSArray *urls = @[lastUrl,@"https://m.mzitu.com",@"http://www.5tuu.com",@"http://v.sigu.me/list.php?type=2"];
    NSArray *titles = @[@"最后一次网页",@"91美女",@"",@""];
    int coum = 2;//seach 1187X180 //vipbtn 187X134
    float width = MY_SCREEN_WIDTH/coum;
    float height = 450.0/coum;
    int ii = 0;
    float offsetY = 0;
     for( ii = 0;ii<urls.count && ii<2;ii++){
        NSInteger row = ii/coum;
        NSInteger column = ii%coum;
        float x = column * (width);
        float y = row * (height);
        if (ii==1) {
            offsetY = 100;
        }
        else if(ii==2){
            offsetY = 200;
        }
        else if(ii==3){
            offsetY = 350;
        }
        MajorAppTjView *v = [[MajorAppTjView alloc] initWithFrame:CGRectMake(x, y, width, height) url:urls[ii] title:titles[ii] offsetY:offsetY];
        if (ii==0) {
            self.lastWebView = v;
        }
        [self addSubview:v];
        v.delegate = self;
     }
    //区
    offsetY = 400;
    float witdth3 = MY_SCREEN_WIDTH;
    float height3 = height+200;
    {
        MajorAppTjView *v = [[MajorAppTjView alloc] initWithFrame:CGRectMake(0, height, witdth3, height3) url:urls[ii] title:titles[ii] offsetY:offsetY];
        if (ii==0) {
            self.lastWebView = v;
        }
        [self addSubview:v];
        v.delegate = self;
        ii++;
     }
    {
        offsetY = 0;
        MajorAppTjView *v = [[MajorAppTjView alloc] initWithFrame:CGRectMake(0, height+height3, witdth3, height3+200) url:urls[ii] title:titles[ii] offsetY:offsetY];
              if (ii==0) {
                  self.lastWebView = v;
              }
              [self addSubview:v];
              v.delegate = self;
              ii++;
        height3+=200;
     }
    
    float startY = 1290;
    UIButton *btnhy = [UIButton buttonWithType:UIButtonTypeCustom];//vip按钮
    btnhy.frame = CGRectMake(5, startY, MY_SCREEN_WIDTH-10, (MY_SCREEN_WIDTH-10)*0.153);
    [self addSubview:btnhy];[btnhy setBackgroundImage:[UIImage imageNamed:@"AppMain.bundle/vipbtn.png"] forState:UIControlStateNormal];
    [btnhy addTarget:self action:@selector(clicHy) forControlEvents:UIControlEventTouchUpInside];
    self.vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, btnhy.frame.size.width-5, btnhy.frame.size.height)];
    self.vipLabel.textAlignment = NSTextAlignmentLeft;
    self.vipLabel.textColor = [UIColor whiteColor];
    self.vipLabel.font = [UIFont boldSystemFontOfSize:14];
    self.vipLabel.text = @"2020/09/09";
    [btnhy addSubview:self.vipLabel];
    @weakify(self)
    [self.vipLabel bk_whenTapped:^{
        @strongify(self)
        [self clicHy];
    }];
    startY+=btnhy.frame.size.height;
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];//全网搜索电影
    btnSearch.frame = CGRectMake(5, startY, MY_SCREEN_WIDTH-10, (MY_SCREEN_WIDTH-10)*0.1949);
    [self addSubview:btnSearch];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"AppMain.bundle/seach.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(clickSearchClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.cellSizeH+=btnhy.frame.size.height+btnSearch.frame.size.height;
    
    [RACObserve([NewVipPay getInstance], vipData) subscribeNext:^(NSString* x) {
        @strongify(self)
        self.vipLabel.text = [x length]<=0?@"未开通会员":[NSString stringWithFormat:@"会员结束:%@",[x substringToIndex:10]];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastWeb:) name:@"MajorAppTjCellRefresh" object:nil];
    //btnhy btnSearch tmpWebsArray的坐标
    return self;
}

-(void)refreshLastWeb:(NSNotification*)object{
    NSString *lastUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUrl20191226"];
    lastUrl = [lastUrl length]>0?lastUrl:@"http://www.baidu.com";
    [self.lastWebView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lastUrl]] ];
}

-(void)ggWebSearch:(NSArray*)urls titles:(NSArray*)titlesArray word:(NSString*)word isSearch:(BOOL)isSearch {
    if (isSearch) {
        self.clickSearch(word);
    }
    [self.searchCtrl.view removeFromSuperview];self.searchCtrl = nil;
}
-(void)clickSearchClick{
    if(!self.searchCtrl){
        self.searchCtrl = [[GGWebSearchCtrl alloc] initWithNibName:@"GGWebSearchCtrl" bundle:nil];
        [GetAppDelegate.getRootCtrlView addSubview:self.searchCtrl.view];
        float startY = STATUSBAR_HEIGHT;
        self.searchCtrl.view.frame = CGRectMake(0, startY, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(STATUSBAR_HEIGHT-20));
        self.searchCtrl.delegate = self;
    }
    else{
        
    }
}

-(void)willRemove{
    [self.buyVipCtrl.view removeFromSuperview];self.buyVipCtrl = nil;
}

-(void)clicHy{
    if (!self.buyVipCtrl) {
        self.buyVipCtrl = [[AppVipBuyCtrl alloc] initWithNibName:@"AppVipBuyCtrl" bundle:nil];
        self.buyVipCtrl.delegate = self;
        [[GetAppDelegate getRootCtrlView]addSubview:self.buyVipCtrl.view];
        [self.buyVipCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo([GetAppDelegate getRootCtrlView]);
        }];
    }
}

-(void)clickWebs:(NSString*)url{
    self.clickTjCellBlock(url, self);
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
