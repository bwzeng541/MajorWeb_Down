
#import "MajorHomeContentView.h"
#import "HistoryAndFavoriteCell.h"
#import "AppDelegate.h"
#import "MarjorWebConfig.h"
#import "WebBoardViewCell.h"
#import "MajorHistoryAndFavoriteAllView.h"
#import "WebUrlTailorManager.h"
#import "Record.h"
#import "MainMorePanel.h"
#import "MorePanelCell.h"
#import "MajorContactView.h"
#import "MajorAppTipsCell.h"
#import "MajorHotCell.h"
#import "MajorNovelCell.h"
#import "MajorLifeCell.h"
#import "MajorSortCell.h"
#import "MajorAppTjCell.h"
#import "BeatifySearchView.h"
#import "NSObject+UISegment.h"
#import "ThrowWebController.h"
#import "MarjorNewSortView.h"
#define HeaderDesKey @"HeaderDesKey"
#define HeaderStateKey  @"HeaderStateKey"
#define HeaderIconKey  @"HeaderIconKey"
@interface MajorHomeContentView()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate,BeatifySearchViewDelegate>
{
    float cellStep;
    UIView *lastView;
}
@property(nonatomic,strong)NSMutableArray *listArray;
@property(nonatomic,assign)NSInteger cellPos;
@property(nonatomic,strong)MajorHistoryAndFavoriteAllView *showAllListView;
@property(nonatomic,strong)HistoryAndFavoriteCell *historyCell;
@property(nonatomic,strong)HistoryAndFavoriteCell *favoriteCell;
@property(nonatomic,strong)HistoryAndFavoriteCell *videoHistoryCell;
@property(nonatomic,strong)HistoryAndFavoriteCell *userHomeMainCell;
@property(nonatomic,strong)MajorContactView *contactViewCell;
@property(nonatomic,strong)MajorAppTjCell *appTjCell;
@property(nonatomic,strong)MajorAppTipsCell  *appTipsViewCell;
@property(nonatomic,strong)MajorAppTipsCell  *appBottomTipsViewCell;
@property(nonatomic,strong)WebBoardViewCell *boardViewCell;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)MajorHotCell *hotViewCell;
@property(nonatomic,strong)MajorNovelCell  *novelViewCell;
@property(nonatomic,strong)MajorLifeCell  *lifeViewCell;
@property(nonatomic,strong)MajorSortCell  *sortViewCell;
@property(nonatomic,strong)NSMutableArray *arrayMiddCellView;
@property(strong,nonatomic)BeatifySearchView *searchView;
@property(strong,nonatomic)MarjorNewSortView *marjorSortView;
@end
@implementation MajorHomeContentView

-(void)beatifySearchClick:(NSString*)url{
    [self.searchView removeFromSuperview];
    self.searchView = nil;
    WebConfigItem *item = [[WebConfigItem alloc] init];
    item.url = url;
    [MarjorWebConfig getInstance].webItemArray = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)beatifySearchBack{
    [self.searchView removeFromSuperview];
    self.searchView = nil;
}

-(void)beatifySearchHome{
    [self.searchView removeFromSuperview];
    self.searchView = nil;
}

-(void)beatifySearchSet{
    [self.searchView removeFromSuperview];
    self.searchView = nil;
}

-(void)beatifySearchNavigation{
    [self.searchView removeFromSuperview];
    self.searchView = nil;
}

-(void)createCollectionView{
    if(_collectionView)return;
    cellStep = 0;
    self.backgroundColor = [UIColor whiteColor];
    /*
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"最新电影" forState:UIControlStateNormal];//网站导航
    [btn1.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [btn1 setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self addSubview:btn1];
    
    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn0 setTitle:@"App帮助" forState:UIControlStateNormal];//网站导航
    [btn0.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [btn0 setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self addSubview:btn0];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"网站导航" forState:UIControlStateNormal];//
    [btn2.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [btn2 setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self addSubview:btn2];
    [NSObject initiiWithFrame:self contenSize:CGSizeMake(self.bounds.size.width, 50) vi:btn1 viSize:CGSizeMake(100, 50) vi2:nil index:0 count:3];
    [NSObject initiiWithFrame:self contenSize:CGSizeMake(self.bounds.size.width, 50) vi:btn0 viSize:CGSizeMake(100, 50) vi2:btn1 index:1 count:3];
    [NSObject initiiWithFrame:self contenSize:CGSizeMake(self.bounds.size.width, 50) vi:btn2 viSize:CGSizeMake(100, 50) vi2:btn0 index:2 count:3];
    btn1.frame = CGRectMake(btn1.frame.origin.x, 0, 100, 50);
    btn2.frame = CGRectMake(btn2.frame.origin.x, 0, 100, 50);
    btn0.frame = CGRectMake(btn0.frame.origin.x, 0, 100, 50);

    [btn1 addTarget:self action:@selector(gotoNew) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(gotoNative) forControlEvents:UIControlEventTouchUpInside];
    [btn0 addTarget:self action:@selector(gotoHelp) forControlEvents:UIControlEventTouchUpInside];
*/
    self.marjorSortView = [[MarjorNewSortView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.marjorSortView];
    [self.marjorSortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.5);
    }];
    @weakify(self)
    self.marjorSortView.clickBlock = ^(WebConfigItem * _Nonnull item, id  _Nonnull view) {
        @strongify(self)
        [self loadFromUseCell:item];
    };
    self.arrayMiddCellView = [NSMutableArray arrayWithCapacity:10];
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    carouseLayout.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, 50);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    _collectionView.showsVerticalScrollIndicator = false;
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.marjorSortView.mas_top);
    }];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"HistoryAndFavoriteCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"WebBoardViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    if(lastView)
    [self bringSubviewToFront:lastView];
}

-(void)gotoHelp{
         NSString *url = [MainMorePanel getInstance].morePanel.toolsurl;
        ThrowWebController *webVC = [[ThrowWebController alloc] initWithAddress:url?url:@"http://www.baidu.com"];
        webVC.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        nav.navigationBar.tintColor = [UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:NULL];
        webVC.showsToolBar = YES;
        webVC.navigationType = 1;
        //[MobClick event:@"jionWeixin_btn"];
 }

-(void)gotoNew{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UICollectionViewScrollPositionTop) animated:NO];
}

-(void)gotoNative{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:(UICollectionViewScrollPositionTop) animated:NO];
}

-(void)initContentData
{
    @weakify(self)
    if (!self.historyCell) {
        float hh = 60;
        if (IF_IPAD) {
            hh = 120;
        }
        self.cellPos = (NSInteger)GetAppDelegate.isAppTipsViewTop;
        CGSize size = CGSizeZero;
  
        size = [self getCellSize:[NSIndexPath indexPathForRow:0 inSection:0]];//提示或者电影播放器
        CGSize sizeboard = CGSizeZero;//底部标签不要，设置00
        self.appTipsViewCell = [[MajorAppTipsCell alloc] initTextType:0 frame:CGRectMake(0, 0,size.width,size.height)];self.appTipsViewCell.hidden = YES;
        self.appBottomTipsViewCell = [[MajorAppTipsCell alloc] initTextType:1 frame:CGRectMake(0, 0,size.width,size.height)];self.appBottomTipsViewCell.hidden = YES;
        size = [self getCellSize:[NSIndexPath indexPathForRow:0 inSection:1]];//首页
        self.historyCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.favoriteCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.videoHistoryCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.userHomeMainCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
         self.appTjCell = [[MajorAppTjCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sizeboard.height)];
        //self.contactViewCell = [[MajorContactView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.boardViewCell = [[WebBoardViewCell alloc] initWithFrame:CGRectMake(0, 0, sizeboard.width, sizeboard.height)];
        self.hotViewCell = [[MajorHotCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sizeboard.height)];
        self.novelViewCell = [[MajorNovelCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sizeboard.height)];
        self.lifeViewCell = [[MajorLifeCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sizeboard.height)];
        self.sortViewCell = [[MajorSortCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sizeboard.height)];
        [self.boardViewCell initWebBoarViewCell];
        
        self.appTjCell.clickTjCellBlock = ^(NSString * _Nonnull url, id  _Nonnull view) {
            WebConfigItem *item = [[WebConfigItem alloc] init];
            item.url = url;
            [MarjorWebConfig getInstance].webItemArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        };
        @weakify(self)
        self.appTjCell.playRecord = ^{
            @strongify(self)
            if (self.tansuoBlock) {
                self.tansuoBlock();
            }
        };
        self.appTjCell.webHistory = ^{
            @strongify(self)
            NSArray* array =[MarjorWebConfig getFavoriteOrHistroyData:true];
            NSMutableArray *arrayRet = [NSMutableArray arrayWithArray:array];
            [self showAllView:arrayRet isFavorite:false];
        };
        self.appTjCell.myFaritive = ^{
            @strongify(self)
            NSArray* array =[MarjorWebConfig getFavoriteOrHistroyData:false];
             NSMutableArray *arrayRet = [NSMutableArray arrayWithArray:array];
            [self showAllView:arrayRet isFavorite:true];
        };
        self.appTjCell.clickSearch = ^(NSString * _Nonnull name) {
            @strongify(self)
            self.searchView = [[BeatifySearchView alloc] init];
            [self.superview addSubview:self.searchView];
            [self.searchView initWebs:false];
            if (name) {
                [self.searchView startSearch:name];
            }
            self.searchView.delegate = self;
            [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.superview);
                make.bottom.equalTo(self.superview);
                make.top.equalTo(self.superview).mas_offset(GetAppDelegate.appStatusBarH);
            }];
        };
        self.appTjCell.help = ^{
            @strongify(self)
            [self gotoHelp];
        }; 
        self.historyCell.liveClickBlock = ^(NSString *url, NSString *name) {
            WebConfigItem *item = [[WebConfigItem alloc] init];
            item.url = url;
            [MarjorWebConfig getInstance].webItemArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        };
        self.favoriteCell.liveClickBlock = ^(NSString *url, NSString *name) {
            WebConfigItem *item = [[WebConfigItem alloc] init];
            item.url = url;
            [MarjorWebConfig getInstance].webItemArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        };
        self.videoHistoryCell.liveClickBlock = ^(NSString *url, NSString *name) {
            WebConfigItem *item = [[WebConfigItem alloc] init];
            item.url = url;
            [MarjorWebConfig getInstance].webItemArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        };
        self.userHomeMainCell.liveClickBlock = ^(NSString *url, NSString *name) {
            WebConfigItem *item = [[WebConfigItem alloc] init];
            item.url = url;
            [MarjorWebConfig getInstance].webItemArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        };
        self.historyCell.liveShowBlock = ^(NSArray *array, MajorShowAllContentType contentType) {
            @strongify(self)
            [self showAllView:array isFavorite:contentType==Major_Favortite_Type];
        };
        self.favoriteCell.liveShowBlock = ^(NSArray *array, MajorShowAllContentType contentType) {
            @strongify(self)
            [self showAllView:array isFavorite:contentType==Major_Favortite_Type];
        };//把self.historyCell.liveShowBlock和self.favoriteCell.liveShowBlock 调用加在videoHistoryCell
        self.videoHistoryCell.liveShowBlock = ^(NSArray *array, MajorShowAllContentType contentType) {
            @strongify(self)
            if (self.tansuoBlock) {
                self.tansuoBlock();
            }
        };
        self.videoHistoryCell.favoriteShowBlock = ^{
            @strongify(self)
            NSArray* array =[MarjorWebConfig getFavoriteOrHistroyData:false];
            NSMutableArray *arrayRet = [NSMutableArray arrayWithArray:array];
            [self showAllView:arrayRet isFavorite:true];
        };
        self.videoHistoryCell.historyShowBlock = ^{
            @strongify(self)
            NSArray* array =[MarjorWebConfig getFavoriteOrHistroyData:true];
            NSMutableArray *arrayRet = [NSMutableArray arrayWithArray:array];
            [self showAllView:arrayRet isFavorite:false];
        };
        //home_shangyici
        float ww = 339,ww2 = 59;
        hh = 51;
        if (IF_IPHONE) {
            ww/=2;hh/=2;ww2/=2;
        }
        CGRect rect = CGRectMake((self.bounds.size.width-ww-ww2)/2, (self.bounds.size.height-hh-20), ww+ww2, hh);
       // lastView = [[UIView alloc] initWithFrame:rect];//393X51 59X51
       // [self addSubview:lastView];
       /* UIButton *btnOpenLast = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOpenLast.frame = CGRectMake(0, 0, ww, hh);
        [btnOpenLast setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_shangyici") forState:UIControlStateNormal];
        [lastView addSubview:btnOpenLast];
        [btnOpenLast bk_addEventHandler:^(id sender) {
            @strongify(self)
            NSString *lastUrl = [MarjorWebConfig getLastHistoryUrl];
            if ([lastUrl length ]>0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSpotLightUrl" object:lastUrl];
            }
            [self->lastView removeFromSuperview];
            self->lastView = nil;
        } forControlEvents:UIControlEventTouchUpInside];
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClose.frame = CGRectMake(ww, 0, ww2, hh);
        [btnClose setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_shangyici_x") forState:UIControlStateNormal];
        [lastView addSubview:btnClose];
        [btnClose bk_addEventHandler:^(id sender) {
            @strongify(self)
            [self->lastView removeFromSuperview];
            self->lastView = nil;
        } forControlEvents:UIControlEventTouchUpInside];*/
    }
    [RACObserve(GetAppDelegate,isHistoryUpdate) subscribeNext:^(id x) {
        @strongify(self)
        [self updateHisotryCell];
     }];
    [RACObserve(GetAppDelegate,isVideoHistoryUpdate) subscribeNext:^(id x) {
        @strongify(self)
        [self updateVideoHisotryCell];
    }];
    [RACObserve(GetAppDelegate,isFavoriteUpdate) subscribeNext:^(id x) {
        @strongify(self)
        [self updateFavoriteCell];
    }];
    [RACObserve(GetAppDelegate,isUserMainHomeUpdate) subscribeNext:^(id x) {
        @strongify(self)
        [self updateUserMainHomeCell];
    }];

    [RACObserve([MainMorePanel getInstance],arraySort) subscribeNext:^(id x) {
        @strongify(self)
        [self tryUpdateInfo];
    }];
    [self createCollectionView];
    [self.collectionView reloadData];
}

-(void)loadFromUseCell:(WebConfigItem*)item{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)tryUpdateInfo{
    [self.arrayMiddCellView removeAllObjects];
    self.listArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *vv = [MainMorePanel getInstance].morePanel.morePanel;
    cellStep = [MainMorePanel getInstance].morePanel.manhuaurl.count>0?3:0;
    if ( vv.count>0 ) {
        [self.marjorSortView updateSortData:vv];
        NSMutableArray *panelArray = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < vv.count; i++) {
            MorePanelCell *v = [[MorePanelCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,10) morePanelInfo:[vv objectAtIndex:i]];
            if (v) {
                NSMutableDictionary *infoSave = [NSMutableDictionary dictionaryWithCapacity:1];
                [infoSave setObject:v.onePanel forKey:OnePlayKey];
                @weakify(self)
                v.clickBlock = ^(WebConfigItem *item,id view) {
                    @strongify(self)
                    [self loadFromUseCell:item];
                    /*//取消点击移动到最上面
                    NSInteger pos = [self.arrayMiddCellView indexOfObject:view];
                    if (pos>0) {
                        [self.arrayMiddCellView exchangeObjectAtIndex:pos withObjectAtIndex:0];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.collectionView reloadData];
                        });
                    }*/
                };
                v.clickOverheadBlock = ^(id view){
                    NSInteger pos = [self.arrayMiddCellView indexOfObject:view];
                    if (pos>0) {
                        [self.arrayMiddCellView exchangeObjectAtIndex:pos withObjectAtIndex:0];
                        [self.listArray exchangeObjectAtIndex:pos withObjectAtIndex:0];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.collectionView reloadData];
                        });
                    }
                };
                BOOL ii = [v.panelDes isEqualToString:[MarjorWebConfig getInstance].overHeadKey];
                NSMutableAttributedString *stringA = v.headerName?v.headerName:@"未知错误";
                NSMutableDictionary *headInfo = [NSMutableDictionary dictionaryWithCapacity:1];
                [headInfo setObject:v.colorTitle?@(true):@(false) forKey:HeaderStateKey];
                [headInfo setObject:stringA forKey:HeaderDesKey];
                [headInfo setObject:v.iconUrl?v.iconUrl:@"AppMain.bundle/headerIcon.png" forKey:HeaderIconKey];
                [infoSave setObject:stringA forKey:OneHeaderStringKey];
                [panelArray addObject:infoSave];
                if (ii) {
                    if (self.arrayMiddCellView.count>0) {
                        [self.arrayMiddCellView insertObject:v atIndex:0];
                        [self.listArray insertObject:headInfo atIndex:0];
                    }
                    else{
                        [self.arrayMiddCellView addObject:v];
                        [self.listArray addObject:headInfo];
                    }
                }
                else{
                    [self.arrayMiddCellView addObject:v];
                    [self.listArray addObject:headInfo];
                }
            }
            break;
        }
        [[MainMorePanel getInstance] updateValidPanel:panelArray];
        [self.collectionView reloadData];
    }
}

-(void)showAllView:(NSArray*)list isFavorite:(BOOL)isFavorite{
    if (!self.showAllListView) {
        MajorShowAllContentType contentType = Major_Favortite_Type;
        if (!isFavorite) {
            contentType = Major_History_Type;
        }
        self.showAllListView = [[MajorHistoryAndFavoriteAllView alloc]initWithFrame:self.superview.bounds array:list type:contentType];
        [self.superview addSubview:self.showAllListView];
        @weakify(self)
        self.showAllListView.liveClickBlock = ^(NSString *url, NSString *name) {
            @strongify(self)
            [self.showAllListView removeFromSuperview];
            self.showAllListView = nil;
            WebConfigItem *item = [[WebConfigItem alloc] init];
            item.url = url;
            [MarjorWebConfig getInstance].webItemArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        };
        self.showAllListView.backBlock = ^{
            @strongify(self)
            [MarjorWebConfig getInstance].webItemArray = nil;
            [self updateHisotryAndFavorite];
             [self.showAllListView removeFromSuperview];
            self.showAllListView = nil;
        };
    }
    
}

-(void)updateHisotryAndFavorite;
{
    [self updateFavoriteCell];
    [self updateHisotryCell];
    [self.collectionView reloadData];
}

-(void)addWebBoradView:(UIView*)view{
    if (view) {
        [self.boardViewCell addWebClidView:view];
    }
}

-(void)updateHisotryCell{
    [self.historyCell initListArray:[MarjorWebConfig getFavoriteOrHistroyData:YES] name:@"历史记录" contentType:Major_History_Type];
   // [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1+self.arrayMiddCellView.count]]];
    [self.collectionView reloadData];
}

-(void)updateVideoHisotryCell{
    [self.videoHistoryCell initListArray:[MarjorWebConfig getVideoHistoryAndUserTableData:KEY_TABEL_VIDEOHISTORY] name:@"播放记录" contentType:Major_Video_Type];
    [UIView performWithoutAnimation:^{
   // [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]];
    }];
    [self.collectionView reloadData];
}

-(void)updateFavoriteCell{
    NSArray* array =[MarjorWebConfig getFavoriteOrHistroyData:false];
    NSMutableArray *arrayRet = [NSMutableArray arrayWithArray:array];
    [self.favoriteCell initListArray:arrayRet name:@"我的收藏" contentType:Major_Favortite_Type];
    [UIView performWithoutAnimation:^{
    //[self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1+self.arrayMiddCellView.count]]];
    }];
    [self.collectionView reloadData];
}

-(void)updateUserMainHomeCell
{
    [self.userHomeMainCell initListArray:[MarjorWebConfig getVideoHistoryAndUserTableData:KEY_TABEL_USERMAINHOME] name:@"用户首页" contentType:Major_UserHomeMain_Type];
    [UIView performWithoutAnimation:^{
   // [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
    }];
    [self.collectionView reloadData];
}

-(void)removeFromSuperview{
    
    [super removeFromSuperview];
}

-(CGSize)getCellSize:(NSIndexPath*)indexPath{
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;

        if (section==0) {//增加一个推荐cell
            if ((cellStep==0 && row==1)||(cellStep==3 && row==2)) {
                float hh = 80;
                if (IF_IPAD) {
                    hh=120;
                }hh=0;
                return CGSizeMake(self.bounds.size.width, hh);
            }
            else if ((cellStep==0 && row==2)||(cellStep==3 && row==3)){
                return CGSizeMake(self.bounds.size.width, self.userHomeMainCell.cellSizeH);
            }
            else if((cellStep==0 && row==3)||(cellStep==3 && row==4)){
                return CGSizeMake(self.bounds.size.width, self.sortViewCell.cellSizeH);
            }
            else if((cellStep==0 && row==4)||(cellStep==3 && row==5)){
                return CGSizeMake(self.bounds.size.width, self.videoHistoryCell.cellSizeH);
            }
            else if((cellStep==3 && row==1)){//remnzhibo
                return CGSizeMake(self.bounds.size.width, self.hotViewCell.cellSizeH);
            }
            else if((cellStep==3 && row==6)){//xiaoshuomanhua
                return CGSizeMake(self.bounds.size.width, self.novelViewCell.cellSizeH);
            }
            else if((cellStep==3 && row==7)){//xiaoshuomanhua
                return CGSizeMake(self.bounds.size.width, self.lifeViewCell.cellSizeH);
            }
            else if((cellStep==3 && indexPath.row==0)||(cellStep==0 && indexPath.row==0)){
                return CGSizeMake(self.bounds.size.width, self.appTjCell.cellSizeH);
            }
        }
        else if(section==1+self.arrayMiddCellView.count){
            if (row==0) {
                return CGSizeMake(self.bounds.size.width, self.favoriteCell.cellSizeH);
            }
            else if(row==1){
                return CGSizeMake(self.bounds.size.width, self.historyCell.cellSizeH);
            }
            else{
                float hh = 115;
                if (IF_IPAD) {
                    hh=180;
                }
                return CGSizeMake(self.bounds.size.width, hh);
                // return CGSizeMake(self.bounds.size.width, self.contactViewCell.cellSizeH);
            }
        }
        else{
            MorePanelCell *cell = [self.arrayMiddCellView objectAtIndex:row];
            return cell.panelCellSize;
        }
    return CGSizeMake(0, 0);
}

-(void)updateSectionState:(NSInteger)pos{
    NSMutableDictionary *info = [self.listArray objectAtIndex:pos];
    BOOL retNew = ![[info objectForKey:HeaderStateKey] boolValue];
    [info setObject:[NSNumber numberWithBool:retNew] forKey:HeaderStateKey];
    [self.collectionView reloadData];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if(section==0 || (section==1+self.arrayMiddCellView.count))
        return CGSizeMake(self.collectionView.bounds.size.width, 10);
    return CGSizeMake(self.collectionView.bounds.size.width, 80);
}
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    [[headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(indexPath.section==0 || (indexPath.section==1+self.arrayMiddCellView.count)){
        return headerView;
    }
    NSDictionary *info = [self.listArray objectAtIndex:indexPath.section-1];
    CGSize size = headerView.bounds.size;
    size.height=70;
    UIImageView *imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80-size.height*0.55, size.height*0.55, size.height*0.55)];
    [headerView addSubview:imageIcon];
    NSString *iconUrl = [info objectForKey:HeaderIconKey];
    NSString *tmpIcon = @"AppMain.bundle/headerIcon.png";
    if ([iconUrl rangeOfString:tmpIcon].location!=NSNotFound) {
        imageIcon.image = [UIImage imageNamed:tmpIcon];
    }
    else{
        [imageIcon sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:tmpIcon]];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageIcon.frame.size.width+imageIcon.frame.origin.x+10,80-size.height,size.width-20,size.height)];
    imageIcon.center = CGPointMake(imageIcon.center.x, label.center.y);
    label.attributedText = [info objectForKey:HeaderDesKey];
    label.tag = indexPath.section-1;
    label.userInteractionEnabled =YES;
    label.numberOfLines =2;
    __weak __typeof(self)weakSelf = self;
    [label bk_whenTapped:^{
        [weakSelf updateSectionState:label.tag];
    }];
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
   return  [self getCellSize:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2+self.arrayMiddCellView.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section==0) {
        return 5+cellStep;
    }
    else if(section==1+self.arrayMiddCellView.count){
        return 3;
    }
    else{//中间list
        NSInteger pos = section-1;
        if (pos<self.arrayMiddCellView.count) {
            NSDictionary*info = [self.listArray objectAtIndex:section-1];
            if([[info objectForKey:HeaderStateKey] boolValue]){
                return 1;
            }
            return 0;
        }
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellIdentifier = @"HistoryAndFavoriteCell";
    MajorHomeBaesCell *middleView=nil;
    NSInteger pos =0;
    if (self.cellPos==0) {
        pos = 1;
    }
    else{
        pos = 0;
    }
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.section==0) {//增加了一个推荐cell
        if ((cellStep==0 && indexPath.row==1)||(cellStep==3 && indexPath.row==2)) {
            middleView = self.appTipsViewCell;
        }
        else if((cellStep==0 && indexPath.row==2)||(cellStep==3 && indexPath.row==3)){
            middleView = self.userHomeMainCell;
        }
        else if ((cellStep==0 && indexPath.row==3)||(cellStep==3 && indexPath.row==4)){
            middleView = self.sortViewCell;
        }
        else if ((cellStep==0 && indexPath.row==4)||(cellStep==3 && indexPath.row==5)){
            middleView = self.videoHistoryCell;
        }
        else if ((cellStep==3 && indexPath.row==1)){//remnzhibo
            middleView = self.hotViewCell;
        }
        else if ((cellStep==3 && indexPath.row==6)){//xiaoshuomanhua
            middleView = self.novelViewCell;
        }
        else if ((cellStep==3 && indexPath.row==7)){//xiaoshuomanhua
            middleView = self.lifeViewCell;
        }
        else if ((cellStep==3 && indexPath.row==0)||(cellStep==0 && indexPath.row==0)){
            middleView = self.appTjCell;
        }
        CGSize size = [self getCellSize:indexPath];
        cell.contentView.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    else if (indexPath.section==1+self.arrayMiddCellView.count) {
        if (indexPath.row==0) {
            middleView = self.favoriteCell;
        }
        else if(indexPath.row==1){
            middleView = self.historyCell;
        }
        else if(indexPath.row==2){
            middleView = self.appBottomTipsViewCell;
            //middleView = self.contactViewCell;
        }
        CGSize size = [self getCellSize:indexPath];
        cell.contentView.bounds = CGRectMake(0,0,size.width,size.height);
    }
    else {
        middleView = [self.arrayMiddCellView objectAtIndex:indexPath.section-1];
        cell.contentView.bounds = CGRectMake(0,0,((MorePanelCell*)middleView).panelCellSize.width, ((MorePanelCell*)middleView).panelCellSize.height);
    }
    UIColor *backColor =[UIColor whiteColor];
    UIColor  *fontColor = [UIColor blackColor];
    if (indexPath.row%2==0) {
       // backColor = RGBCOLOR(248,248,248);
        fontColor = RGBCOLOR(255,126,0);
    }
    
    middleView.backgroundColor = backColor;
    [middleView updateHeadColor:fontColor];
    middleView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:middleView];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPAD) {
        return 5;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 40*AppScaleIphoneH;
    }
    return 10;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [lastView removeFromSuperview];lastView = nil;
}

@end
