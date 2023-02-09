//
//  BeatifySearchView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifySearchView.h"
#import "BeatifySearchWebView.h"
#import "AppDelegate.h"
#import "NSObject+UISegment.h"
#import "UIView+BlocksKit.h"
#import "ZYInputAlertView.h"
#import "WKWebView+TagValue.h"
#import "MainMorePanel.h"
#define MixWebHeight 500
#define TopWebHeight (MY_SCREEN_HEIGHT*0.5)
@interface BeatifySearchView ()<BeatifyWebViewClickDelegate>{
    BeatifySearchWebView *lastWebView ;
    BeatifySearchWebView *firstWebView ;
    UIButton *btnMask;
    UIButton *btnClose;
    UILabel *titleLabel,*label;
}
@property (nonatomic ,strong) NSMutableArray *websArray;
@property (nonatomic ,strong) UIView *topView;
@property (nonatomic ,strong) UIView *secondView;
@property (nonatomic ,strong) UIImageView *bottomView;
@property (nonatomic, strong) UIScrollView *scrollViewParant;
@end
@implementation BeatifySearchView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)clickBackHome:(id)sender{
    if([self.delegate respondsToSelector:@selector(beatifySearchBack)]){
        [self.delegate beatifySearchBack];
    }
}

-(void)clickDh:(id)sender{
    if([self.delegate respondsToSelector:@selector(beatifySearchNavigation)]){
        [self.delegate beatifySearchNavigation];
    }
}

-(void)clickHome:(id)sender{
    if([self.delegate respondsToSelector:@selector(beatifySearchHome)]){
        [self.delegate beatifySearchHome];
    }
}

-(void)clickSet:(id)sender{
    if([self.delegate respondsToSelector:@selector(beatifySearchSet)]){
        [self.delegate beatifySearchSet];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (titleLabel) {
       CGRect rect =  titleLabel.frame ;
        rect.origin.x=0;
        rect.size.width = self.scrollViewParant.bounds.size.width;
        titleLabel.frame =rect;
    }
    if (label) {
        CGRect rect =  label.frame ;
        rect.origin.x=0;
        rect.size.width = self.scrollViewParant.bounds.size.width;
        label.frame =rect;
    }
}

-(void)startSearch:(NSString*)name{
    if ([name length]>=1) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        NSString *keywords = [name
                              stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray *tmpArray = [MainMorePanel getInstance].morePanel.fulld;
       tmpArray = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"searchApi" ofType:@"txt"]encoding:NSUTF8StringEncoding error:nil] JSONValue];
        for (int i = 0; i < tmpArray.count; i++) {//d
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[tmpArray objectAtIndex:i]];
            [info setObject:keywords forKey:@"word"];
           [array addObject:info] ;
        }
        [self unInitAsset];
        [self reLoadAsset:array];
    }
}

-(void)ssclick:(id)sender{
    @weakify(self)
    ZYInputAlertView *alertView = [ZYInputAlertView alertView];
    alertView.placeholder = @"输入查找的电影名字";
    alertView.inputTextView.text = @"";
    alertView.alertViewDesLabel.text = @"请输入电影名字";
    alertView.alertViewDesLabel.font = [UIFont boldSystemFontOfSize:20];
    [alertView confirmBtnClickBlock:^(NSString *inputString) {
        @strongify(self)
        [self startSearch:inputString];
    }];
    [alertView show];
}

-(void)tjclick:(id)sender{
    [self unInitAsset];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithArray:[MainMorePanel getInstance].morePanel.fullr];//r
    if (arrayTmp.count>=1) {
        [arrayTmp removeObjectAtIndex:0];
    }
    for (int i = 0; i< arrayTmp.count; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        [info setObject:[arrayTmp objectAtIndex:i] forKey:@"url"];
        [info setObject:@"get" forKey:@"type"];
        [array addObject:info];
    }
    [self reLoadAsset:array];
}

-(void)unInitAsset{
     while (self.websArray.count>0) {
        BeatifyWebView *v = self.websArray.firstObject;
        [v.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
        [v removeFromSuperview];
        [self.websArray removeObject:v];
    }
}

-(void)reLoadAsset:(NSArray*)array{
    self.websArray = [NSMutableArray arrayWithCapacity:3];
    [self.scrollViewParant setContentSize:CGSizeMake(self.frame.size.width, MixWebHeight*array.count+(lastWebView?(![MainMorePanel getInstance].morePanel.fulld?TopWebHeight*2:TopWebHeight):0))];//d
    for (int i = 0; i < array.count; i++) {
        BeatifyWebView*webView1 = [self createWebView:[array objectAtIndex:i]];
        webView1.frame = CGRectMake(0, MixWebHeight*i, self.frame.size.width, MixWebHeight);
        [self.websArray addObject:webView1];
        [webView1.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
}


-(UIButton*)createBtn:(NSString*)imageName action:(nonnull SEL)action parentView:(UIView*)view{
    UIButton *btnAddFa = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddFa setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
     [btnAddFa addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnAddFa];
    return btnAddFa;
}

-(void)initWebs:(BOOL)addTj{
    if (self.scrollViewParant) {
        return;
    }
    label = [[UILabel alloc] init];
    if (addTj) {
        label.text = @"最后一次访问的网站";
        label.font = [UIFont boldSystemFontOfSize:16];
    }
    else{
        label.text = @"视频搜索结果";
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
                       make.right.left.top.equalTo(self);
                       make.height.mas_equalTo(40);
                   }];
      
    }
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.scrollViewParant = [[UIScrollView alloc] initWithFrame:self.frame];
    [self addSubview:self.scrollViewParant];
    [self.scrollViewParant mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
        make.bottom.equalTo(self).mas_offset(20-GetAppDelegate.appStatusBarH);
            if (!addTj) {
                make.top.equalTo(self->label.mas_bottom);
            }
            else{
                make.top.equalTo(self);
            }
    }];
    self.backgroundColor = RGBCOLOR(0, 0, 0);
    [self tjclick:nil];
    
    btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setTitle:@"<返回" forState:UIControlStateNormal];
    [self addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self->label.mas_height);
        make.left.top.bottom.mas_equalTo(self->label);
    }];
    [btnClose addTarget:self action:@selector(pressBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self makeToast:@"视频搜索中..." duration:10 position:@"center"];
}

-(void)pressBack{
    [self.delegate beatifySearchHome];
}

-(void)removeFromSuperview{
    [self unInitAsset];
    [super removeFromSuperview];
}

- (BeatifyWebView*)createWebView:(NSDictionary*)info
{
    BeatifySearchWebView *webView = [[BeatifySearchWebView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MixWebHeight)];
    [webView loadWebView];
    [webView loadAllJs:true];
    webView.clickDelegate = self;
    [webView.webView setTagValue:webView];
    [webView loadUrlFromParam:info];
    webView.progressView.hidden = YES;
    [self.scrollViewParant addSubview:webView];
    NSLog(@"createWebView = %@",info);
    return webView;
}

-(bool)webViewClick:(NSString *)url
{
    NSLog(@"webViewClick = %@",url);
    if ([self.delegate respondsToSelector:@selector(beatifySearchClick:)]) {
        [self.delegate beatifySearchClick:url];
    }
    return true;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        // 方法一
        UIScrollView *scrollView = (UIScrollView *)object;
        NSString *msg = [NSString stringWithFormat:@"%@%@%@%@%@",@"_intern",@"alD",@"ele",@"ga",@"te"];
        Ivar iVar = class_getInstanceVariable([object class],[msg UTF8String] );
        WKWebView* objectWk = nil;
        if (iVar) {
            objectWk = object_getIvar(object, iVar);
        }
       // [objectWk setNeedsLayout];

        CGFloat height = scrollView.contentSize.height<MixWebHeight?MixWebHeight:scrollView.contentSize.height;
        BeatifyWebView *webView = [objectWk tagValue];
        NSInteger pos = [self.websArray indexOfObject:webView];
        float starY =0;
        if (lastWebView) {
            starY = TopWebHeight;
            lastWebView.frame = CGRectMake(0, 0, firstWebView?self.frame.size.width/2:self.frame.size.width, starY);
            CGRect rect = label.frame;
            label.frame = CGRectMake(0, rect.origin.y, lastWebView.frame.size.width, rect.size.height);
            if (titleLabel) {
                rect = titleLabel.frame;
                titleLabel.frame = CGRectMake(0, rect.origin.y, lastWebView.frame.size.width, rect.size.height);
            }
        }
        if (firstWebView) {
            starY = TopWebHeight;
            firstWebView.frame = CGRectMake(lastWebView?self.frame.size.width/2:0, 0, lastWebView?self.frame.size.width/2:self.frame.size.width, starY);
        }
        if (pos==0) {
            webView.frame = CGRectMake(0, starY, self.frame.size.width, height);
        }
        else {
            float starPos = 0;
                 CGRect rect =  ((UIView*)[self.websArray objectAtIndex:pos-1]).frame;
                starPos+=rect.origin.y+rect.size.height;
            webView.frame = CGRectMake(0, starPos, self.frame.size.width, height);
        }
       BeatifyWebView *web = self.websArray.lastObject;
        [self.scrollViewParant setContentSize:CGSizeMake(self.frame.size.width, web.frame.origin.y+web.frame.size.height)];

    }
}

@end
