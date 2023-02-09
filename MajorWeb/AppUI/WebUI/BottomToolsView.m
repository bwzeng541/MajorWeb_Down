//
//  BottomToolsView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "BottomToolsView.h"
#import "NSObject+UISegment.h"
#import "AppDelegate.h"
#import "MarjorWebConfig.h"
#import "MajorHistoryAndFavoriteAllView.h"
#import "MajorSetView.h"
#import "TYAlertAction+TagValue.h"
#import "TmpSetView.h"
@interface BottomToolsView()
@property(nonatomic,strong)MajorHistoryAndFavoriteAllView *showAllListView;
@property(nonatomic,strong)UIView *popView;
@property(nonatomic,strong)UILabel *totalDel;
@end
@implementation BottomToolsView
@synthesize webTitleLable;
@synthesize btnGoBack;

-(void)dealloc{
    self.popView = nil;
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    [self.popView removeFromSuperview];
    self.popView = nil;
    [super removeFromSuperview];
}

-(void)initUI{
    [self initBottomBtn];
}

-(void)initBottomBtn{
    if (btnGoBack) {
        return;
    }
    CGSize viewSize = self.frame.size;
    CGSize btnSize = CGSizeMake(70, 60);
    CGSize btnHomeSize = CGSizeMake(99, 50);
    CGSize desSize = CGSizeMake(24, 24);
    float sizeFont = 20;
    if(IF_IPHONE){
        sizeFont/=2;
        desSize = CGSizeMake(desSize.width*0.4,desSize.height*0.4);
        btnSize = CGSizeMake(btnSize.width*0.4,btnSize.height*0.4);
        btnHomeSize = CGSizeMake(btnHomeSize.width*0.4,btnHomeSize.height*0.4);
    }
    else{
        btnSize = CGSizeMake(40, 34);
        desSize = CGSizeMake(12, 12);
        btnHomeSize = CGSizeMake(68,34);
        sizeFont = 10;
    }
    btnHomeSize = CGSizeMake((viewSize.height)*2, viewSize.height);

    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(viewSize.width/2+10, 0, viewSize.width/2-10, viewSize.height)];
    [self addSubview:rightView];
    
    btnGoBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnGoBack setImage:[UIImage imageNamed:@"Menu.bundle/b_back"] forState:UIControlStateNormal];
    [rightView addSubview:btnGoBack];
    [btnGoBack addTarget:self action:@selector(clickGoBack:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMore setImage:[UIImage imageNamed:@"Menu.bundle/b_setting"] forState:UIControlStateNormal];
    [rightView addSubview:btnMore];
    [btnMore addTarget:self action:@selector(clickMore:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnBq = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBq setImage:[UIImage imageNamed:@"Menu.bundle/b_biqian"] forState:UIControlStateNormal];
    [rightView addSubview:btnBq];
    [btnBq addTarget:self action:@selector(clickBq:) forControlEvents:UIControlEventTouchUpInside];
    
    self.totalDel = [[UILabel alloc]initWithFrame:CGRectMake(btnSize.width-desSize.width-5, btnSize.height-desSize.height-5, desSize.width, desSize.height)];
    self.totalDel.center = CGPointMake(btnSize.width/2, btnSize.height/2);
    self.totalDel.textColor = [UIColor blackColor];
    self.totalDel.font = [UIFont systemFontOfSize:sizeFont];
    self.totalDel.textAlignment = NSTextAlignmentCenter;
    self.totalDel.adjustsFontSizeToFitWidth = YES;
    [btnBq addSubview:self.totalDel];
    @weakify(self)
    [RACObserve(GetAppDelegate,totalWebOpen) subscribeNext:^(id x) {
        @strongify(self)
        self.totalDel.text = [NSString stringWithFormat:@"%ld",GetAppDelegate.totalWebOpen];
    }];
    
    
    UIButton *btnHome= [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHome setImage:[UIImage imageNamed:@"Menu.bundle/b_home"] forState:UIControlStateNormal];
    [self addSubview:btnHome];
    [btnHome addTarget:self action:@selector(clickHome:) forControlEvents:UIControlEventTouchUpInside];
    btnHome.frame = CGRectMake((viewSize.width-btnHomeSize.width)/2, (viewSize.height-btnHomeSize.height)/2, btnHomeSize.width, btnHomeSize.height);
    rightView.frame = CGRectMake(btnHome.frame.size.width+btnHome.frame.origin.x, 0, viewSize.width-(btnHome.frame.size.width+btnHome.frame.origin.x)-20, viewSize.height);
    
    CGSize rightViewSize = rightView.frame.size;
    [NSObject initii:rightView contenSize:rightViewSize vi:btnGoBack viSize:btnSize vi2:NULL index:0 count:2];
    [NSObject initii:rightView contenSize:rightViewSize vi:btnMore viSize:btnSize vi2:btnGoBack index:1 count:2];
  //  btnHomeSize = CGSizeMake(rightView.bounds.size.height*1.8, rightView.bounds.size.height);
  //  btnHome.frame = CGRectMake(rightView.bounds.size.width-btnHomeSize.width, (rightView.bounds.size.height-btnHomeSize.height)/2, btnHomeSize.width, btnHomeSize.height);
   // [btnHome removeFromSuperview];
   // [rightView addSubview:btnHome];
   // [NSObject initii:rightView contenSize:rightViewSize vi:btnHome viSize:btnSize vi2:btnMore index:2 count:3];
    btnBq.hidden = YES;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width/2-btnHome.frame.size.width/2, viewSize.height)];
    [self addSubview:leftView];
    UIImageView *imageLeftView = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(@"Menu.bundle/url_input")];
    [leftView addSubview:imageLeftView];imageLeftView.frame = leftView.bounds;
    
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRefresh.frame = CGRectMake(leftView.bounds.size.width-btnSize.width-10, (leftView.bounds.size.height-btnSize.height)/2, btnSize.width, btnSize.height);
    [btnRefresh setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/NavRefresh_2_2")
                forState:UIControlStateNormal];
    [btnRefresh setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/NavRefresh_2_1")
                forState:UIControlStateHighlighted];
    [btnRefresh addTarget:self
                   action:@selector(refresh)
         forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:btnRefresh];
    
    UIView *topSearchView = [[UIView alloc] initWithFrame:CGRectMake(6, 2,btnRefresh.frame.origin.x-12, viewSize.height-1)];
   // topSearchView.backgroundColor = RGBCOLOR(235, 235, 235);
   // topSearchView.layer.cornerRadius = 4;
   // topSearchView.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
   // topSearchView.layer.borderWidth = 0;
    topSearchView.layer.masksToBounds = YES;
    [leftView addSubview:topSearchView];
    
    NSString *imageName = @"Brower.bundle/topsstb_B";
    UIImageView *searchLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [topSearchView addSubview:searchLeft];
    searchLeft.frame = CGRectMake(2, 8, topSearchView.frame.size.height-16, topSearchView.frame.size.height-16);
    float starXX = searchLeft.frame.origin.x+searchLeft.frame.size.width+3;
    webTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(starXX, 0,btnRefresh.frame.origin.x-starXX,  topSearchView.bounds.size.height)];
    [topSearchView addSubview:webTitleLable];
    webTitleLable.userInteractionEnabled = YES;
    webTitleLable.font = [UIFont systemFontOfSize:12];
    webTitleLable.textColor = [UIColor blackColor];
    __weak __typeof(self)weakSelf = self;
    [webTitleLable bk_whenTapped:^{
        if (weakSelf.clickSearch) {
            weakSelf.clickSearch();
        }
    }];
//    UIView *viewTop = [[UIView alloc] init];
//    [self addSubview:viewTop];
//    viewTop.backgroundColor = RGBCOLOR(220, 220, 220);
//    [viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(0.5);
//        make.left.right.top.equalTo(self);
//    }];
}

-(void)refresh{
    if (self.clickRefresh) {
        self.clickRefresh();
    }
}

-(void)initPopView{
    float w = MY_SCREEN_WIDTH/8;
    UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, 50)];
    [btnFavorite setTitle:@"favvorite" forState:UIControlStateNormal];
    [self addSubview:btnFavorite];
    [btnFavorite addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnShowFavorite = [[UIButton alloc] initWithFrame:CGRectMake(0, w, 50, 50)];
    [btnShowFavorite setTitle:@"favvorite" forState:UIControlStateNormal];
    [self addSubview:btnShowFavorite];
    [btnShowFavorite addTarget:self action:@selector(showFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnHosirty = [[UIButton alloc] initWithFrame:CGRectMake(0, w*2, 50, 50)];
    [btnHosirty setTitle:@"hosirty" forState:UIControlStateNormal];
    [self addSubview:btnHosirty];
    [btnHosirty addTarget:self action:@selector(showHosirty:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnCaptuer = [[UIButton alloc] initWithFrame:CGRectMake(0,  w*3, 50, 50)];
    [btnCaptuer setTitle:@"capture" forState:UIControlStateNormal];
    [self addSubview:btnCaptuer];
    [btnCaptuer addTarget:self action:@selector(captureWeb:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnAutoPlay = [[UIButton alloc] initWithFrame:CGRectMake(0,  w*5, 50, 50)];
    [btnAutoPlay setTitle:@"autoPlay" forState:UIControlStateNormal];
    [self addSubview:btnAutoPlay];
    [btnAutoPlay addTarget:self action:@selector(autoPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnPic = [[UIButton alloc] initWithFrame:CGRectMake(0,  w*6, 50, 50)];
    [btnPic setTitle:@"btnPic" forState:UIControlStateNormal];
    [self addSubview:btnPic];
    [btnPic addTarget:self action:@selector(showPics:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnNight = [[UIButton alloc] initWithFrame:CGRectMake(0,  w*7, 50, 50)];
    [btnNight setTitle:@"Night" forState:UIControlStateNormal];
    [self addSubview:btnNight];
    [btnNight addTarget:self action:@selector(showNight:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)clickHome:(UIButton*)sender{
    [GetAppDelegate showAppHomeView];
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncMarkWebNotifi object:nil];
    GetAppDelegate.isClickWebEvent = true;
}

-(void)clickBq:(UIButton*)sender{
    [GetAppDelegate showWebBoardView];
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncMarkWebNotifi object:nil];
    GetAppDelegate.isClickWebEvent = true;
}

-(void)clickMore:(UIButton*)sender{
    if (!self.popView) {
        if(self.popViewShow){
            self.popViewShow(true);
        }
        //613X302 //80X90
        float offsetFixY = GetAppDelegate.appStatusBarH-20;
        self.popView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-offsetFixY)];
        if (IF_IPAD) {
            [self.superview.superview addSubview:self.popView];
        }
        else {
            [self.superview addSubview:self.popView];
        }
        __weak __typeof(self)weakSelf = self;
        [self.popView bk_whenTapped:^{
            [weakSelf clickSh:nil];
        }];
        self.popView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        UIImageView *uiimageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Menu.bundle/b_pop_back"]];
        [self.popView addSubview:uiimageView];
        uiimageView.userInteractionEnabled = YES;
        float popBackW = MY_SCREEN_WIDTH;
        float popBackH = 378/640.0*popBackW;//多了18像素  1-60 2->110 3->160 4->46
        float scale = popBackW/640;
        float btnw = 80,btnh= 90;
        float btnsw = 85,btnsh = 59;
        if (IF_IPHONE) {
            btnh/=2.3;btnw/=2.3;
            btnsw/=2;btnsh/=2;
        }
        else{
            btnh/=1.5;btnw/=1.5;
        }
        uiimageView.frame = CGRectMake((MY_SCREEN_WIDTH-popBackW)/2, MY_SCREEN_HEIGHT-popBackH-offsetFixY, popBackW, popBackH);
        
        //添加首页----分享软件
        
        UIView *shareParetenView = [[UIView alloc]initWithFrame:CGRectMake(0, popBackH-46*scale, popBackW, 46*scale)];
        [uiimageView addSubview:shareParetenView];
        {
            float btnsViewh = MY_SCREEN_WIDTH*0.078;//640*50
            float btnh = btnsViewh*1.44/2;
            if (IF_IPAD) {
                btnh *= 0.8;
            }
            float btnw = btnh*4;
            CGSize btnSize = CGSizeMake( btnw,btnh);
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1 setImage:[UIImage imageNamed:@"Brower.bundle/list_tianjia_home"] forState:UIControlStateNormal];
            [shareParetenView addSubview:btn1];
            [btn1 addTarget:self action:@selector(addWebHome:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn2 setImage:[UIImage imageNamed:@"Brower.bundle/list_fankui"] forState:UIControlStateNormal];
            [shareParetenView addSubview:btn2];
            [btn2 addTarget:self action:@selector(fanguiyijian:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn3 setImage:[UIImage imageNamed:@"Brower.bundle/list_share_haoyou"] forState:UIControlStateNormal];
            [shareParetenView addSubview:btn3];
            [btn3 addTarget:self action:@selector(shareWeb:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn4 setImage:[UIImage imageNamed:@"Brower.bundle/list_share_pyq"] forState:UIControlStateNormal];
            [shareParetenView addSubview:btn4];
            [btn4 addTarget:self action:@selector(shareapp:) forControlEvents:UIControlEventTouchUpInside];
            [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn1 viSize:btnSize vi2:nil index:0 count:4];
            [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn2 viSize:btnSize vi2:btn1 index:1 count:4];
            [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn3 viSize:btnSize vi2:btn2 index:2 count:4];
            [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)vi:btn4 viSize:btnSize vi2:btn3 index:3 count:4];
        }
        //播放记录----晚上模式
        int    nCountBtn = 4;
        CGSize btnSize = CGSizeMake( btnw,btnh);
        UIView *btnsView2 = [[UIView alloc] initWithFrame:CGRectMake(0,shareParetenView.frame.origin.y-scale*160,popBackW,scale*160)];
        [uiimageView addSubview:btnsView2];
        
        UIButton *btnVideoHi = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView2 addSubview:btnVideoHi];
        [btnVideoHi setImage:[UIImage imageNamed:@"Menu.bundle/b_bofangjilu"] forState:UIControlStateNormal];
        [btnVideoHi addTarget:self action:@selector(showVideoHistory:) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:btnsView2 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnVideoHi viSize:btnSize vi2:nil index:0 count:nCountBtn];
        
        
        UIButton *btnAuto = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView2 addSubview:btnAuto];
        [btnAuto setImage:[UIImage imageNamed:@"Menu.bundle/b_auto_play"] forState:UIControlStateNormal];
        [btnAuto addTarget:self action:@selector(autoPlay:) forControlEvents:UIControlEventTouchUpInside];
        [self updateAutpBtn:btnAuto];
        [NSObject initii:btnsView2 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnAuto  viSize:btnSize vi2:btnVideoHi index:1 count:nCountBtn];
        
        
        UIButton *btnPics = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView2 addSubview:btnPics];
        [btnPics setImage:[UIImage imageNamed:@"Menu.bundle/b_web_pics"] forState:UIControlStateNormal];
        [btnPics addTarget:self action:@selector(showPics:) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:btnsView2 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnPics   viSize:btnSize vi2:btnAuto index:2 count:nCountBtn];
        
        UIButton *btnNight = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView2 addSubview:btnNight];
        [btnNight setImage:[UIImage imageNamed:@"Menu.bundle/b_down_mode"] forState:UIControlStateNormal];
        [btnNight addTarget:self action:@selector(showNight:) forControlEvents:UIControlEventTouchUpInside];
        [self updateNigthBtn:btnNight];
        [NSObject initii:btnsView2 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnNight    viSize:btnSize vi2:btnPics index:3 count:nCountBtn];
        
        
        //添加收藏---字体大小
        UIView *btnsView1 = [[UIView alloc] initWithFrame:CGRectMake(0, btnsView2.frame.origin.y-110*scale, popBackW, 110*scale)];
        [uiimageView addSubview:btnsView1];
        UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView1 addSubview:btnFavorite];
        [btnFavorite setImage:[UIImage imageNamed:@"Menu.bundle/b_web_add_favr"] forState:UIControlStateNormal];
        [btnFavorite addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:btnsView1 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnFavorite viSize:btnSize vi2:NULL index:0 count:nCountBtn];
        
        UIButton *btnShowFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView1 addSubview:btnShowFavorite];
        [btnShowFavorite setImage:[UIImage imageNamed:@"Menu.bundle/b_web_favr"] forState:UIControlStateNormal];
        [btnShowFavorite addTarget:self action:@selector(showFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:btnsView1 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnShowFavorite  viSize:btnSize vi2:btnFavorite index:1 count:nCountBtn];
        
        UIButton *btnHistory = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView1 addSubview:btnHistory];
        [btnHistory setImage:[UIImage imageNamed:@"Menu.bundle/b_web_history"] forState:UIControlStateNormal];
        [btnHistory addTarget:self action:@selector(showHosirty:) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:btnsView1 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnHistory  viSize:btnSize vi2:btnShowFavorite index:2 count:nCountBtn];
        
        UIButton *btnCloseAd = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnsView1 addSubview:btnCloseAd];
        [btnCloseAd setImage:[UIImage imageNamed:@"Menu.bundle/b_web_font"] forState:UIControlStateNormal];
        [btnCloseAd addTarget:self action:@selector(addJustWebFont:) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:btnsView1 contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btnCloseAd viSize:btnSize vi2:btnHistory index:3 count:nCountBtn];
        //end
        
        //设置系统----X
        UIView *settingView = [[UIView alloc] initWithFrame:CGRectMake(0, btnsView1.frame.origin.y-60*scale, popBackW, 60*scale)];
        
        UIButton *btnhidden = [UIButton buttonWithType:UIButtonTypeCustom];
        btnhidden.frame = CGRectMake((popBackW-btnsw*1.4*0.7), 10, btnsw*1.4*0.7, btnsh*0.72*0.7);
        [btnhidden setImage:[UIImage imageNamed:@"Menu.bundle/b_sh"] forState:UIControlStateNormal];
        [uiimageView addSubview:settingView];
        [settingView addSubview:btnhidden];
        
        [btnhidden addTarget:self action:@selector(clickSh:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnGoSet = [UIButton buttonWithType:UIButtonTypeCustom];
        btnGoSet.frame = CGRectMake(btnhidden.frame.origin.x-20-btnsw*2.3*0.7, 10, btnsw*2.3*0.7, btnsh*0.72*0.7);
        [btnGoSet setImage:[UIImage imageNamed:@"Menu.bundle/set_icon"] forState:UIControlStateNormal];
        btnGoSet.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnGoSet setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
        [settingView addSubview:btnGoSet];
        [btnGoSet addTarget:self action:@selector(clickSet:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)addWebHome:(UIButton*)sender{
    if (self.addWebHome) {
        self.addWebHome();
    }
}

-(void)fanguiyijian:(UIButton*)sender{
    if (self.feeBack) {
        self.feeBack();
    }
}

-(void)shareWeb:(UIButton*)sender{
    if (self.shareWeb) {
        self.shareWeb();
    }
}

-(void)shareapp:(UIButton*)sender{
    if (self.shareApp) {
        self.shareApp();
    }
}

-(void)clickSh:(UIButton*)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.popView.center = CGPointMake(self.popView.center.x, MY_SCREEN_HEIGHT+self.popView.frame.size.height/2);
    } completion:^(BOOL finished) {
        [self.popView removeFromSuperview];
        self.popView = nil;
        if(self.popViewShow){
            self.popViewShow(false);
        }
    }];
}

-(void)clickGoBack:(UIButton*)sender{
    if (self.clickBack) {
        GetAppDelegate.isClickWebEvent = true;
        self.clickBack();
    }
}

-(void)clickGoNext:(UIButton*)sender{
    if (self.clickNext) {
        GetAppDelegate.isClickWebEvent = true;
        self.clickNext();
    }
}

-(void)updateNigthBtn:(UIButton*)sender{
    return;
    if([MarjorWebConfig getInstance].isNightMode){
        [sender setImage:[UIImage imageNamed:@"Menu.bundle/b_disnight_mode"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"Menu.bundle/b_night_mode"] forState:UIControlStateNormal];
    }
}

-(void)clickSet:(UIButton*)sender{
    MajorSetView *v = [[MajorSetView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:v];
}

-(void)showNight:(UIButton*)sender{
    [TmpSetView showTmpSetView:nil];
    return;
    [MarjorWebConfig getInstance].isNightMode = ![MarjorWebConfig getInstance].isNightMode;
    [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
    [self updateNigthBtn:sender];
}

-(void)updateAutpBtn:(UIButton*)sender{
    if([MarjorWebConfig getInstance].isAutoPlay){
        [sender setImage:[UIImage imageNamed:@"Menu.bundle/b_disauto_play"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"Menu.bundle/b_auto_play"] forState:UIControlStateNormal];
    }
}

-(void)autoPlay:(UIButton*)sender{
    BOOL ret = ![MarjorWebConfig getInstance].isAutoPlay;
    [MarjorWebConfig getInstance].isSuspensionMode = ret;
    [MarjorWebConfig getInstance].isAutoPlay = ret;
    [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
    [self updateAutpBtn:sender];
}

-(void)showPics:(UIButton*)sender{
    if (self.showPicBlock) {
        self.showPicBlock();
    }
}

-(void)showVideoHistory:(UIButton*)sender{
    [self showAllView:[MarjorWebConfig getVideoHistoryAndUserTableData:KEY_TABEL_VIDEOHISTORY] contentType:(Major_Video_Type)];
}

-(void)captureWeb:(UIButton*)sender{
}

-(void)addFavorite:(UIButton*)sender{
    if (self.addFavorite) {
        self.addFavorite();
        [GetAppDelegate updateHisotryAndFavorite];
    }
}

-(void)showHosirty:(UIButton*)sender{
    [self showAllView:[MarjorWebConfig getFavoriteOrHistroyData:true] contentType:(Major_History_Type)];
}

-(void)showFavorite:(UIButton*)sender{
    [self showAllView:[MarjorWebConfig getFavoriteOrHistroyData:false] contentType:Major_Favortite_Type];
}


-(void)addJustWebFont:(UIButton*)sender{
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"设置网页字体大小" message:nil];
    alertView.clickedAutoHide = false;
    NSArray *array=@[@(70),@(80),@(90),@"正常大小",@(110),@(120),@(125),@(150)];
    for (int i =0; i < array.count; i++) {
        NSInteger type = [[array objectAtIndex:i] integerValue];
        NSString *title = [NSString stringWithFormat:@"%@%%",[array objectAtIndex:i]];
        if(i==3){
            title = @"正常大小";
        }
        TYAlertAction *v  = [TYAlertAction actionWithTitle:title
                                                     style:TYAlertActionStyleDefault
                                                   handler:^(TYAlertAction *action) {
                                                       NSInteger vv = action.tagValue;
                                                       [MarjorWebConfig getInstance].webFontSize = vv;
                                                       [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
                                                   }];
        if(i==3){
            v.tagValue =100;
        }
        else {
            v.tagValue =type;
        }
        [alertView addAction:v];
    }
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"取消"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                                   [alertView hideView];
                                               }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
}

-(void)showAllView:(NSArray*)list contentType:(MajorShowAllContentType)contentType{
    if (!self.showAllListView) {
        if (self.popViewShow) {
            self.popViewShow(true);
        }
        self.showAllListView = [[MajorHistoryAndFavoriteAllView alloc]initWithFrame:self.superview.bounds array:list type:contentType];
        [self.superview addSubview:self.showAllListView];
        @weakify(self)
        self.showAllListView.liveClickBlock = ^(NSString *url, NSString *name) {
            @strongify(self)
            [self.showAllListView removeFromSuperview];
            self.showAllListView = nil;
            self.reloadUrl(url);
            [GetAppDelegate updateHisotryAndFavorite];
            [self checkIsPopShow];
        };
        self.showAllListView.backBlock = ^{
            @strongify(self)
            [self.showAllListView removeFromSuperview];
            self.showAllListView = nil;
            [GetAppDelegate updateHisotryAndFavorite];
            [self checkIsPopShow];
        };
    }
}

-(void)checkIsPopShow{
    if (!self.popView && self.popViewShow) {
        self.popViewShow(false);
    }
}
@end
