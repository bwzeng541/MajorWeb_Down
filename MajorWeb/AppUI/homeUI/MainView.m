//
//  MainView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/26.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MainView.h"
#import "AddressToolbarView.h"
#import "MajorHomeContentView.h"
#import "NSObject+UISegment.h"
#import "WebBoardView.h"
#import "MainMorePanel.h"
#import "MarjorWebConfig.h"
#import "MajorSetView.h"
#import "helpFuntion.h"
#import "AppDelegate.h"
#import "JMButtons.h"
#import "WebPushManager.h"
#import "MajorHistoryAndFavoriteAllView.h"
#import "WebPushView.h"
#import "TmpSetView.h"
#import "ThrowUpLoadCtrl.h"
#import "ThrowToolsView.h"
#import "MajorPrivacyHome.h"
#import "MajorPermissions.h"
#import "WebCoreManager.h"
#import "MajorWebView.h"
#define MaxBcImageCount 9
@interface MainView()<AddressToolbarViewDelegate>
@property(strong,nonatomic)JMButton *btnMax;
@property(strong,nonatomic)JMButton *btnFirst;
@property(strong,nonatomic)MajorHistoryAndFavoriteAllView *showAllListView;
@property(strong,nonatomic)AddressToolbarView *addressToolsBar;
@property(strong,nonatomic)UIImageView *imagehome_bc;
@property(weak,nonatomic)WebBoardView *webBoardView;
@property(strong,nonatomic)MajorHomeContentView *majorHomeView;
@property(strong,nonatomic)MajorPrivacyHome *majorPrivacyHomeView;
@property(strong,nonatomic)UIView *bottomView;
@property(strong,nonatomic)UIImageView *bcImageView;
@property(strong,nonatomic)UIImageView *bcMaxImageView;
@property(strong,nonatomic)UIView *maskView;

@property(assign,nonatomic)int indexBc;

@end
@implementation MainView
 

-(void)initUI
{
    
    __weak typeof(self) weakSelf = self;
    self.backgroundColor = [UIColor whiteColor];
    [[MainMorePanel getInstance] initAndRequest];
   /* UIButton *imageView= [UIButton buttonWithType:UIButtonTypeCustom];
    [imageView setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/seach_home") forState:UIControlStateNormal];
    [imageView setAdjustsImageWhenHighlighted:NO];
    [self addSubview:imageView];
    float ss = 0.9;
    if (IF_IPAD) {
        ss = 0.8;
    }
    float searchHomeH  = MY_SCREEN_WIDTH*ss*(96.0/1190);
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).mas_offset(GetAppDelegate.appStatusBarH+6);
        make.width.mas_equalTo(MY_SCREEN_WIDTH*ss);
        make.height.mas_equalTo(searchHomeH);
    }];
    [imageView bk_addEventHandler:^(id sender) {
        [weakSelf showSearch];
    } forControlEvents:UIControlEventTouchUpInside];*/
    float searchHomeH = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewWeb:) name:@"addNewWeb" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBaiduWangPan:) name:@"OpenBaiduWangPan" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenTengXunYun:) name:@"OpenTengXunYun" object:nil];
    //底部按钮
    float bh = 90;
    NSInteger rank = 4;
    float W = (MY_SCREEN_WIDTH - 20) / rank;
    CGFloat H = 60;
    CGFloat rankMargin = (MY_SCREEN_WIDTH - rank * W) / (rank - 1);
    CGSize btnSize = CGSizeMake(100, 77);
    float fontSize = 18;
    if (IF_IPHONE) {
        bh /=2;
        H /=2;
        fontSize=12;
        btnSize = CGSizeMake(W, H);
    }
    else{
        bh = 60;
        fontSize = 14;
    }
    float offsetFixY = GetAppDelegate.appStatusBarH-20;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-bh-offsetFixY, MY_SCREEN_WIDTH, bh+offsetFixY)];
    [self addSubview:self.bottomView];
    self.bottomView.backgroundColor = RGBCOLOR(233, 233, 233);
  
    JMBaseButtonConfig *configBtn = nil;
    configBtn = [self createButtonConfig:@"下载管理" image:[UIImage imageNamed:@"AppMain.bundle/home_news_icon.png"] fontSize:fontSize];
    JMButton *btn3 = [[JMButton alloc] initWithFrame:CGRectMake(0, (bh-H)/2.0, btnSize.width,btnSize.height) ButtonConfig:configBtn];
    self.btnFirst = btn3;
    [self.bottomView addSubview:btn3];
    [btn3 addTarget:self action:@selector(llq:) forControlEvents:UIControlEventTouchUpInside];
    
    configBtn = [self createButtonConfig:@"Max" image:[UIImage imageNamed:@"AppMain.bundle/home_max_icon.png"] fontSize:fontSize];
    self.btnMax = [[JMButton alloc] initWithFrame:CGRectMake(W + rankMargin, (bh-H)/2.0, btnSize.width,btnSize.height) ButtonConfig:configBtn];
    [self.bottomView addSubview:self.btnMax];
    [self.btnMax addTarget:self action:@selector(maxEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    configBtn = [self createButtonConfig:@"视频大全" image:[UIImage imageNamed:@"AppMain.bundle/home_play_record_icon.png"] fontSize:fontSize];
    JMButton *btn2 = [[JMButton alloc] initWithFrame:CGRectMake(2*(W + rankMargin), (bh-H)/2.0, btnSize.width,btnSize.height) ButtonConfig:configBtn];
     [self.bottomView addSubview:btn2];
    [btn2 addTarget:self action:@selector(tansuo:) forControlEvents:UIControlEventTouchUpInside];
 
     configBtn = [self createButtonConfig:@"设置" image:[UIImage imageNamed:@"AppMain.bundle/home_setting_icon.png"] fontSize:fontSize];
    JMButton *btn4 = [[JMButton alloc] initWithFrame:CGRectMake((3*(W + rankMargin)), (bh-H)/2.0,btnSize.width,btnSize.height) ButtonConfig:configBtn];
    [self.bottomView addSubview:btn4];
    [btn4 addTarget:self action:@selector(shezhi:) forControlEvents:UIControlEventTouchUpInside];

    [NSObject initiiWithFrame:self.bottomView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn3 viSize:btnSize vi2:nil index:0 count:4];
    [NSObject initiiWithFrame:self.bottomView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:self.btnMax viSize:btnSize vi2:btn3 index:1 count:4];
    [NSObject initiiWithFrame:self.bottomView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn2 viSize:btnSize vi2:self.btnMax index:2 count:4];
    [NSObject initiiWithFrame:self.bottomView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn4 viSize:btnSize vi2:btn2 index:3 count:4];

    //
    //中间内容
    self.majorHomeView = [[MajorHomeContentView alloc] init];
    [self addSubview:self.majorHomeView];
    float homeViewH =  GetAppDelegate.appStatusBarH+searchHomeH;//MY_SCREEN_WIDTH*(362.0/640)
    float homeViewOffset = 0;
    if (IF_IPAD) {
        homeViewOffset = 100;
    }
    self.majorHomeView.frame = CGRectMake(homeViewOffset,homeViewH , MY_SCREEN_WIDTH-homeViewOffset*2, MY_SCREEN_HEIGHT-homeViewH-self.bottomView.frame.size.height);
    [self.majorHomeView initContentData];
    //end
    @weakify(self)
    [RACObserve([MainMorePanel getInstance],arraySort) subscribeNext:^(id x) {
        @strongify(self)
        [self updateBtnMaxTitle];
    }];
    
    self.majorHomeView.tansuoBlock = ^{
        @strongify(self)
        [self showHistory];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSpotLightUrl:) name:@"OpenSpotLightUrl" object:nil];
     
}

-(JMBaseButtonConfig*)createButtonConfig:(NSString*)title image:(UIImage*)image fontSize:(float)fontSize{
    JMBaseButtonConfig *buttonConfig = [JMBaseButtonConfig buttonConfig];
    buttonConfig.styleType = JMButtonStyleTypeTop;
    buttonConfig.backgroundColor = [UIColor clearColor];
    buttonConfig.titleFont = [UIFont systemFontOfSize:fontSize];
    buttonConfig.titleColor = [UIColor blackColor];
    buttonConfig.title = title;
    buttonConfig.padding= 2;
    buttonConfig.image = image;
    if(IF_IPAD){
        buttonConfig.imageSize = CGSizeMake(16*1.5, 16*1.5);
    }
    else {
        buttonConfig.imageSize = CGSizeMake(16, 16);
    }
    return buttonConfig;
}

-(void)shezhi:(UIButton*)sender{
    MajorSetView *v = [[MajorSetView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:v];
}

-(void)llq:(UIButton*)sender{//
    [TmpSetView showTmpSetView:nil];
    return;
    homeFristItem *fristItem = [MainMorePanel getInstance].morePanel.homeItem;
    if (fristItem.name && fristItem.url) {
        [self openWebFromUrl:fristItem.url];
    }
    else{
        [self openWebFromUrl:@"https://cpu.baidu.com/1022/ac797dc4/i?scid=15951"];
    }
}

-(void)showHistory{
        if (!self.showAllListView) {
            self.showAllListView = [[MajorHistoryAndFavoriteAllView alloc]initWithFrame:self.bounds array:[MarjorWebConfig getVideoHistoryAndUserTableData:KEY_TABEL_VIDEOHISTORY] type:Major_Video_Type];
            [self addSubview:self.showAllListView];
    
            @weakify(self)
            self.showAllListView.liveClickBlock = ^(NSString *url, NSString *name) {
                @strongify(self)
                [self.showAllListView removeFromSuperview];
                self.showAllListView = nil;
                WebConfigItem *item = [[WebConfigItem alloc] init];
                [MarjorWebConfig getInstance].webItemArray = nil;
                item.url = url;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
            };
            self.showAllListView.backBlock = ^{
                @strongify(self)
                [self.showAllListView removeFromSuperview];
                self.showAllListView = nil;
            };
        }
}

-(void)tansuo:(UIButton*)sender{
    ThrowToolsView *v = [[ThrowToolsView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    [v initConentUI];
    [self addSubview:v];
    
}

-(onePanel*)getMaxData{
    NSArray *array = [MainMorePanel getInstance].morePanel.morePanel;
    if (array.count>=2) {
        morePanelInfo *panelInfo = [array objectAtIndex:1];
        int i =  [panelInfo.type intValue];
        if (i <[MainMorePanel getInstance].arraySort.arraySort.count) {
            onePanel *onePanel = [[MainMorePanel getInstance].arraySort.arraySort objectAtIndex:[panelInfo.type intValue]];
            return onePanel;
        }
    }
    return nil;
}

-(BOOL)isAutoOpen{
    BOOL ret = false;
    NSString *ss = @"updateBtnMaxTitleOneDay";
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger nn = [[defaults objectForKey:ss] integerValue]+1;
    [defaults setObject:[NSNumber numberWithInteger:nn] forKey:ss];
    [defaults synchronize];
    if (nn%2==1) {
        ret = true;
    }
    return ret;
}

-(void)updateBtnMaxTitle{
    onePanel *onePanel = [self getMaxData];
    if (onePanel.headerName) {
        static BOOL isSet = false;
        if (!isSet) {
            isSet= true;
            //只有每天的第一次才
            if(!GetAppDelegate.penFromSpotLightUrl && [self isAutoOpen])
            {
                //打开最后一次网页
                NSString *lastUrl = [MarjorWebConfig getLastHistoryUrl];
                if ([lastUrl length]>4) {
                   // [self openWebFromUrl:lastUrl];
                }
                else {
                  //  [self maxEvent:nil];
                }
            }
            else if (GetAppDelegate.penFromSpotLightUrl){
                [self openWebFromUrl:GetAppDelegate.penFromSpotLightUrl];
            }
        }
        [_btnMax setTitle:onePanel.headerName forState:UIControlStateNormal];
    }
    /*//_btnFirst 直接d跳下载管理
    homeFristItem *homeItem = [MainMorePanel getInstance].morePanel.homeItem;
    if (homeItem.name&&homeItem.url) {
         [_btnFirst setTitle:homeItem.name forState:UIControlStateNormal];
    }*/
    if ([MainMorePanel getInstance].morePanel.huyaurl.count>0) {
        @weakify(self)
        [RACObserve([WebPushManager getInstance],isReqeustSuccess) subscribeNext:^(id x) {
            @strongify(self)
//            if ([WebPushManager getInstance].isReqeustSuccess) {
//                [self->_btnFirst setTitle:@"福利" forState:UIControlStateNormal];
//                [self->_btnFirst addTarget:self action:@selector(zbEvent:) forControlEvents:UIControlEventTouchUpInside];
//            }
        }];
        //，虎牙网页解析的时候，用户操作页面会很卡，应该点击后waitView状态，体验好点
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          //  huyaNodeInfo *node =  [[MainMorePanel getInstance].morePanel.huyaurl objectAtIndex:0];
          //  [[WebPushManager getInstance] startWithUrl:node.url updateBlock:NULL falidBlock:NULL];
        });
    }
}

-(WebPushView*)createWebPushAndView{
    WebPushView *v = [self viewWithTag:TmpTopViewTag];
    if (!v) {
        v = [[WebPushView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        [self addSubview:v];
        v.tag = TmpTopViewTag;
    }
    return v;
}

-(void)zbEvent:(UIButton*)sender{
//    [[WebPushManager getInstance] showDateBlock:^(NSArray * _Nonnull ret) {
//        [[self createWebPushAndView] addDataArray:ret isRemoveOldAll:YES];
//    } updateBlock:^(WebPushItem * _Nonnull item, BOOL isRemoveOldAll) {
//        [[self createWebPushAndView] addDataItem:item isRemoveOldAll:isRemoveOldAll];
//    } falidBlock:^{
//        
//    }];
}

-(void)maxEvent:(UIButton*)sender{
    onePanel *onePanel = [self getMaxData];
    if (onePanel) {
        [MarjorWebConfig getInstance].webItemArray = onePanel.array;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:[onePanel.array objectAtIndex:0]];
    }
    else{
        [self openWebFromUrl:@"https://cpu.baidu.com/1022/ac797dc4/i?scid=15951"];
    }
}

-(void)OpenSpotLightUrl:(NSNotification*)object
{
     [self openWebFromUrl:object.object];
}

-(void)openWebFromUrl:(NSString*)url{
    WebConfigItem *item = [[WebConfigItem alloc] init];
    [MarjorWebConfig getInstance].webItemArray = nil;
    item.url = url;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)updateHisotryAndFavorite{
    [self.majorHomeView updateHisotryAndFavorite];
}

-(void)updateWebBoardView:(UIView*)webBoardView{
    self.webBoardView = (WebBoardView*)webBoardView;
    [self.majorHomeView addWebBoradView:webBoardView];
}

-(void)loadSnycMarkFromLocal:(NSArray*)array{
    [self.webBoardView loadSnycMarkFromLocal:array];
}

-(void)addNewWeb:(NSNotification*)object
{
    if (self.searchBlock) {
        [self.majorPrivacyHomeView removeFromSuperview];self.majorPrivacyHomeView = nil;
        self.searchBlock([object object]);
    }
}


-(void)openBaiduWangPan:(id)sender{
    [MarjorWebConfig getInstance].webItemArray = nil;
    WebConfigItem *item = [[WebConfigItem alloc] init];
    item.userAgent = PCUserAgent;
    item.url = @"https://pan.baidu.com/s/1boOjO7P";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)OpenTengXunYun:(id)sender{
    [MarjorWebConfig getInstance].webItemArray = nil;
    WebConfigItem *item = [[WebConfigItem alloc] init];
    item.url = @"https://www.mp4pa.com/";
    item.isForceUseIjk = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)showSearch
{
    if (self.addressToolsBar) {
        return;
    }
    [self.maskView removeFromSuperview];
    self.addressToolsBar = [[AddressToolbarView alloc] initWithFrame:CGRectMake(0, 20, MY_SCREEN_WIDTH, 40) tabManager:nil];
    [self.addressToolsBar enlargeAddressBar:NO];
    self.addressToolsBar.relatedBrowserView = self;
    self.addressToolsBar.delegate = self;
    [self addSubview:self.addressToolsBar];
    self.maskView = [[UIView alloc] initWithFrame:self.bounds];
    self.maskView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:self.maskView belowSubview:self.addressToolsBar];
    [MarjorWebConfig getInstance].webItemArray = nil;
    [self.addressToolsBar showInput];
}

- (void)cancelToolsFun:(id)addressToolbar{
    [self.maskView removeFromSuperview];self.maskView = nil;
    [self.addressToolsBar removeFromSuperview];
    self.addressToolsBar  = nil;
}

- (void)loadReqeustFromUrl:(NSString*)url{
    [self cancelToolsFun:nil];
    if (self.searchBlock) {
        WebConfigItem *config =[[WebConfigItem alloc] init];
        config.url  = url;
        self.searchBlock(config);
    }
}

@end
