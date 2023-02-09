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
#import "MajorSystemConfig.h"
#import "MajorPermissions.h"
#import "MainMorePanel.h"
#import "MajorCartoonCtrl.h"
#import "MajorZyCartoonPlug.h"
#import "WebViewLivePlug.h"
#import "ZFAutoPlayerViewController.h"
#import "ShareSdkManager.h"
#import "MajorAppTiCellChild1.h"
#define MajorLifeCell_LivePlug @"MajorLifeCell_LivePlug"
#define MajorNovel_ZyCartoonPlug @"MajorNovel_ZyCartoonPlug"
#define MajorNovel_ZyNeiHanPlug @"MajorNovel_Neihan_Btn"
#define MajorHotCell_key @"majorHotCell_meinv"
#define MajorZhiboCell_key @"majorHotCell_zhibo"
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
    self.backgroundColor = [UIColor whiteColor];
    self.url = url;
    self.offsetY = offsetY;
    self.webView = (MajorWebView*)[[WebCoreManager getInstanceWebCoreManager] createWKWebViewWithUrl:nil isAutoSelected:NO delegate:self];
    self.webView.scrollView.scrollEnabled  = NO;
    self.webView.frame =  CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
    [self addSubview:self.webView];
  //  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

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
    @weakify(self)
    [RACObserve([MajorSystemConfig getInstance], isReqestFinish) subscribeNext:^(id x) {
        @strongify(self)
        if ([x boolValue]) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        }
    }];
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

@interface MajorAppTjCell()<MajorAppTjViewDelegate,AppVipBuyCtrlDelegate,GGWebSearchCtrlDelegate,UICollectionViewDelegate,UICollectionViewDataSource,ZFAutoPlayerViewControllerDelegate>{
    float itemSpacing;
    float cellW,cellH;
}
@property(strong,nonatomic)GGWebSearchCtrl *searchCtrl;
@property(weak,nonatomic)MajorAppTjView *lastWebView;
@property(nonatomic,assign)float cellSizeH;
@property(strong)AppVipBuyCtrl *buyVipCtrl;
@property(strong,nonatomic)UILabel *vipLabel;
@property(strong,nonatomic)NSArray *arrayPic;
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)ZFAutoPlayerViewController *autoPlayerCtrl;
@end
@implementation MajorAppTjCell

-(UILabel*)addLabel:(NSString*)text color:(UIColor*)color{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-10, 20)];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = color;
    label.minimumScaleFactor = 0.5;
    label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:label];
    return label;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, 450)];
    @weakify(self)
    self.cellSizeH =  225+(IF_IPAD?90:0);
    NSString *lastUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUrl20191226"];
    lastUrl = [lastUrl length]>0?lastUrl:@"http://www.baidu.com";
    NSArray *urls = @[lastUrl,@"https://m.mzitu.com"/*,@"http://www.5tuu.com",@"http://v.sigu.me/list.php?type=2&cat=all"*/];
    NSArray *titles = @[@"最后一次网页",@"91美女"/*,@"",@""*/];
    int coum = 2;//seach 1187X180 //vipbtn 187X134
    float width = frame.size.width/coum;
    float height = (450.0+(IF_IPAD?90:0))/coum;
    int ii = 0;

    float startY = 0;//1290
    
   UILabel *label1 = [self addLabel:@"感谢您的支持，请多多分享软件给好友" color:[UIColor redColor]];
   UILabel *label2 = [self addLabel:@"如果无法使用APP,请用safari打开max77.cn重新安装" color:[UIColor blueColor]];
   label2.frame = CGRectMake(label2.frame.origin.x, label1.frame.size.height+label1.frame.origin.y, label1.frame.size.width, label1.frame.size.height);
    startY = label2.frame.size.height+label2.frame.origin.y;
    
    //begin
    MajorAppTiCellChild1 *child1 = [[MajorAppTiCellChild1 alloc] initWithFrame:CGRectMake(10, label2.frame.origin.y+label2.frame.size.height+10, frame.size.width-20,IF_IPHONE?120:150)];
    [self addSubview:child1];
    
    child1.help = ^{
        @strongify(self)
        self.help();
    };
    child1.webHistory = ^{
        @strongify(self)
        self.webHistory();
    };
    child1.myFaritive = ^{
        @strongify(self)
        self.myFaritive();
    };
    
    child1.zhibo = ^{
        @strongify(self)
        [self btn1Event:nil];
    };
    child1.share = ^{
        @strongify(self)
        [self shareApp];
    };
    child1.playRecord = ^{
        @strongify(self)
        self.playRecord();
    };
    child1.registe = ^{
        @strongify(self)
        [self clicHy];
    };
    
    child1.search = ^{
        @strongify(self)
        [self clickSearchClick];
    };
         //end
    
   /* UIButton *btnhy = [UIButton buttonWithType:UIButtonTypeCustom];//vip按钮
    btnhy.frame = CGRectMake(5, startY, frame.size.width-10, (frame.size.width-10)*0.153);
    [self addSubview:btnhy];[btnhy setBackgroundImage:[UIImage imageNamed:@"AppMain.bundle/vipbtn.png"] forState:UIControlStateNormal];
    [btnhy addTarget:self action:@selector(clicHy) forControlEvents:UIControlEventTouchUpInside];
    self.vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, btnhy.frame.size.width-5, btnhy.frame.size.height)];
    self.vipLabel.textAlignment = NSTextAlignmentLeft;
    self.vipLabel.textColor = [UIColor whiteColor];
    self.vipLabel.font = [UIFont boldSystemFontOfSize:14];
    self.vipLabel.text = @"2020/09/09";
    [btnhy addSubview:self.vipLabel];*/
    [self.vipLabel bk_whenTapped:^{
        @strongify(self)
        [self clicHy];
    }];
    startY+=(child1.frame.size.height+child1.frame.origin.y);
   /* UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];//全网搜索电影
    btnSearch.frame = CGRectMake(5, startY, frame.size.width-10, (frame.size.width-10)*0.1949);
    [self addSubview:btnSearch];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"AppMain.bundle/seach.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(clickSearchClick) forControlEvents:UIControlEventTouchUpInside];
    
    startY+=btnSearch.frame.size.height;*/
    float offsetY = 0;

     for( ii = 0;ii<urls.count && ii<2;ii++){
        NSInteger row = ii/coum;
        NSInteger column = ii%coum;
        float x = column * (width);
        float y = row * (height)+startY;
        if (ii==1) {
            offsetY = 100;
        }
        else if(ii==2){
            offsetY = 200;
        }
        else if(ii==3){
            offsetY = 350;
        }
        MajorAppTjView *v = [[MajorAppTjView alloc] initWithFrame:CGRectMake(x, y-40-20, width, height-30) url:urls[ii] title:titles[ii] offsetY:offsetY];
         v.transform = CGAffineTransformMakeScale(0.8, 0.8);
        if (ii==0) {
            self.lastWebView = v;
        }
        [self addSubview:v];
        v.delegate = self;
     }
    //区
    /*
    offsetY = 400;
    float witdth3 = frame.size.width;
    float height3 = height+200;
    {
        MajorAppTjView *v = [[MajorAppTjView alloc] initWithFrame:CGRectMake(0, height+startY, witdth3, height3) url:urls[ii] title:titles[ii] offsetY:offsetY];
        if (ii==0) {
            self.lastWebView = v;
        }
        [self addSubview:v];
        v.delegate = self;
        ii++;
     }
    {
        offsetY = 0;
        MajorAppTjView *v = [[MajorAppTjView alloc] initWithFrame:CGRectMake(0, height+height3+startY, witdth3, height3+200) url:urls[ii] title:titles[ii] offsetY:offsetY];
              if (ii==0) {
                  self.lastWebView = v;
              }
              [self addSubview:v];
              v.delegate = self;
              ii++;
        height3+=200;
     }*/
    
    {
        /*
        self.arrayPic = @[@"AppMain.bundle/sort_dyzb",@"AppMain.bundle/sort_mh",@"AppMain.bundle/sort_dszb",@"AppMain.bundle/sort_rmb"];
        UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView  = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
        [self addSubview:self.collectionView];
        self.collectionView.backgroundColor = [UIColor blackColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
        [self addSubview:self.collectionView];
         itemSpacing = 10;
        int colume = 4;
        cellW = (frame.size.width-8-itemSpacing*colume)/colume;
        cellH = cellW*(80.0/202);

        self.cellSizeH += cellH+itemSpacing*2;
        self.collectionView.frame  = CGRectMake(4,btnhy.frame.origin.y+ btnhy.frame.size.height+btnSearch.frame.size.height, frame.size.width-8, cellH+itemSpacing*2);*/
    }
    
   // self.cellSizeH+=self.collectionView.frame.size.height+self.collectionView.frame.size.height;
    self.cellSizeH+=child1.frame.size.height+40;
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
        float startY = GetAppDelegate.appStatusBarH;
        self.searchCtrl.view.frame = CGRectMake(0, startY, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20));
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
       
        self.buyVipCtrl = [[AppVipBuyCtrl alloc] initWithNibName:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"AppVipBuyCtrl":@"AppVipBuyCtrl_ipad" bundle:nil];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return itemSpacing;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.arrayPic.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ContentCollection";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *image = UIImageFromNSBundlePngPath([self.arrayPic objectAtIndex:indexPath.row]);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [cell.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {//电影直播
        __weak __typeof__(self) weakSelf = self;
        [MajorPermissions playClickPerMissions:MajorZhiboCell_key pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf btn1Event:nil];
            }
        }];
    }
    else if(indexPath.row==-1){//福利漫画
        [MajorPermissions playClickPerMissions:MajorNovel_ZyNeiHanPlug pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                if([MainMorePanel getInstance].morePanel.manhuaurl.count>0){
                    //[MobClick event:@"neihan_btn"];
                    MajorCartoonCtrl *ctrl = [[MajorCartoonCtrl alloc] initWithNibName:nil bundle:nil];
                    ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
                    [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:ctrl animated:YES completion:nil];
                }
            }
        }];
    }
    else if(indexPath.row==1){//破解漫画
        [MajorPermissions playClickPerMissions:MajorNovel_ZyCartoonPlug pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
                UIView *view = [GetAppDelegate getRootCtrlView];
                MajorZyCartoonPlug *v = [view viewWithTag:TmpTopViewTag];
                if (!v) {
                    v = [[MajorZyCartoonPlug alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
                    [view addSubview:v];
                    v.tag = TmpTopViewTag;
                }
            }
        }];
        
    }
    else if(indexPath.row==2){//91gril
        [MajorPermissions playClickPerMissions:MajorHotCell_key pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                //[MobClick event:@"meinv_btn"];
                WebConfigItem *item = [[WebConfigItem alloc] init];
                item.url = @"http://m.leshitya.com/";
                [MarjorWebConfig getInstance].webItemArray = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
//                UIViewController *controller = [[NSClassFromString(@"PinUpController") alloc] initWithNibName:@"PinUpController" bundle:nil];
//                controller.modalPresentationStyle = UIModalPresentationFullScreen;
//                [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:controller animated:YES completion:nil];
            }
        }];
    }
    else if(indexPath.row==-1){//湖南卫视
        [MajorPermissions playClickPerMissions:MajorLifeCell_LivePlug pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                //[MobClick event:@"diansi_btn"];
                [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
                UIView *view = [GetAppDelegate getRootCtrlView];
                WebViewLivePlug *v = [view viewWithTag:TmpTopViewTag];
                if (!v) {
                    v = [[WebViewLivePlug alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
                    [view addSubview:v];
                    v.tag = TmpTopViewTag;
                }
            }}];
        
    }
    else if(indexPath.row==3){
       // [self linquhy];
        [self shareApp];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSpacing;
}

-(void)zfautoPlayerWillRemove:(UIImage*)image{
    [self.autoPlayerCtrl.view removeFromSuperview];
    self.autoPlayerCtrl.delegate = nil;
    self.autoPlayerCtrl = nil;
}

-(void)btn1Event:(UIButton*)sender{
    //[MobClick event:@"zhibo_btn"];
    [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
    
    self.autoPlayerCtrl=  [[ZFAutoPlayerViewController alloc] init];
    self.autoPlayerCtrl.delegate = self;
    self.autoPlayerCtrl.view.frame = CGRectMake(0, 0,[MajorSystemConfig getInstance].appSize.width,[MajorSystemConfig getInstance].appSize.height);
    [[GetAppDelegate getRootCtrlView] addSubview: self.autoPlayerCtrl.view];
    [self.autoPlayerCtrl initUI];
    
    
//    [[WebPushManager getInstance] showDateBlock:^(NSArray * _Nonnull ret) {
//        [[self createWebPushAndView] addDataArray:ret isRemoveOldAll:YES];
//    } updateBlock:^(WebPushItem * _Nonnull item, BOOL isRemoveOldAll) {
//        [[self createWebPushAndView] addDataItem:item isRemoveOldAll:isRemoveOldAll];
//    } startHomeBlock:^{
//        huyaNodeInfo *node =  [[MainMorePanel getInstance].morePanel.huyaurl objectAtIndex:0];
//        [[self createWebPushAndView] loadHome];
//        [[WebPushManager getInstance] startWithUrlUsrOldBlock:node.url ];
//    } falidBlock:^{
//
//    }];
}

-(void)shareApp{
    [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
        return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone),@(SSDKPlatformSubTypeWechatTimeline)];
    } value:^NSString *{
        return nil;
    } titleBlock:^NSString *{
        return nil;
    } imageBlock:^UIImage *{
        return nil;
    }urlBlock:^NSString  *{
        return nil;
    }shareViewTileBlock:^NSString *{
        return @"分享app下载地址";
    }];
}
@end
