
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
@interface MajorHomeContentView()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>
{

}
@property(nonatomic,assign)NSInteger cellPos;
@property(nonatomic,strong)MajorHistoryAndFavoriteAllView *showAllListView;
@property(nonatomic,strong)HistoryAndFavoriteCell *historyCell;
@property(nonatomic,strong)HistoryAndFavoriteCell *favoriteCell;
@property(nonatomic,strong)HistoryAndFavoriteCell *videoHistoryCell;
@property(nonatomic,strong)HistoryAndFavoriteCell *userHomeMainCell;
@property(nonatomic,strong)MajorContactView *contactViewCell;
@property(nonatomic,strong)MajorAppTipsCell  *appTipsViewCell;
@property(nonatomic,strong)WebBoardViewCell *boardViewCell;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *arrayMiddCellView;
@end
@implementation MajorHomeContentView

-(void)createCollectionView{
    if(_collectionView)return;
    self.backgroundColor = [UIColor whiteColor];
    self.arrayMiddCellView = [NSMutableArray arrayWithCapacity:10];
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"HistoryAndFavoriteCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"WebBoardViewCell"];
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
        if (self.cellPos==0) {
            size =[self getCellSize:0];
        }
        else{
            size = [self getCellSize:[self.arrayMiddCellView count]+6];
        }
        CGSize sizeboard = CGSizeZero;
        self.appTipsViewCell = [[MajorAppTipsCell alloc] initWithFrame:CGRectMake(0, 0,size.width,size.height)];
        if (self.cellPos==0) {
            size = [self getCellSize:1];
            sizeboard = [self getCellSize:6];
        }
        else{
            size = [self getCellSize:0];
            sizeboard = [self getCellSize:5];
        }
        self.historyCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.favoriteCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.videoHistoryCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.userHomeMainCell = [[HistoryAndFavoriteCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.contactViewCell = [[MajorContactView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.boardViewCell = [[WebBoardViewCell alloc] initWithFrame:CGRectMake(0, 0, sizeboard.width, sizeboard.height)];
        [self.boardViewCell initWebBoarViewCell];
        
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
        };
        self.videoHistoryCell.liveShowBlock = ^(NSArray *array, MajorShowAllContentType contentType) {
            @strongify(self)
            if (self.tansuoBlock) {
                self.tansuoBlock();
            }
        };
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
    NSArray *vv = [MainMorePanel getInstance].morePanel.morePanel;
    if ( vv.count>0 ) {
        for (int i = 0; i < vv.count; i++) {
            MorePanelCell *v = [[MorePanelCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,10) morePanelInfo:[vv objectAtIndex:i]];
            if (v) {
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.collectionView reloadData];
                        });
                    }
                };
                BOOL ii = [v.panelDes isEqualToString:[MarjorWebConfig getInstance].overHeadKey];
                if (ii) {
                    if (self.arrayMiddCellView.count>0) {
                        [self.arrayMiddCellView insertObject:v atIndex:0];
                    }
                    else{
                        [self.arrayMiddCellView addObject:v];
                    }
                }
                else{
                    [self.arrayMiddCellView addObject:v];
                }
            }
        }
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
        self.showAllListView.liveBackBlock = ^{
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
    NSInteger pos = self.cellPos;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:(pos==0)?2:1 inSection:0]]];
}

-(void)updateVideoHisotryCell{
    [self.videoHistoryCell initListArray:[MarjorWebConfig getVideoHistoryAndUserTableData:KEY_TABEL_VIDEOHISTORY] name:@"播放记录" contentType:Major_Video_Type];
    NSInteger pos = self.cellPos;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:(pos==0)?3:2 inSection:0]]];
}

-(void)updateFavoriteCell{
    NSArray* array =[MarjorWebConfig getFavoriteOrHistroyData:false];
    NSMutableArray *arrayRet = [NSMutableArray arrayWithArray:array];
    [self.favoriteCell initListArray:arrayRet name:@"我的收藏" contentType:Major_Favortite_Type];
    NSInteger pos = self.cellPos;
    if (pos==0) {
        pos = self.arrayMiddCellView.count+4;
    }
    else{
        pos = self.arrayMiddCellView.count+3;
    }
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:pos inSection:0]]];
}

-(void)updateUserMainHomeCell
{
    [self.userHomeMainCell initListArray:[MarjorWebConfig getVideoHistoryAndUserTableData:KEY_TABEL_USERMAINHOME] name:@"用户首页" contentType:Major_UserHomeMain_Type];
    NSInteger pos = self.cellPos;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:(pos==0)?1:0 inSection:0]]];
}

-(void)removeFromSuperview{
    
    [super removeFromSuperview];
}

-(CGSize)getCellSize:(NSInteger)index{
        NSInteger pos =self.cellPos;
        if ((pos==0 && index==0)||(pos==1 && (index==self.arrayMiddCellView.count+6))) {
            float hh = 80;
            if (IF_IPAD) {
                hh=120;
            }
            return CGSizeMake(self.bounds.size.width, hh);
        }
        int startY = 0;
        if (pos==0) {
            startY = 1;
        }
        else{
            startY = 0;
        }
        if (((index)>=(startY)&&(index)<=(2+startY))||(index==self.arrayMiddCellView.count+3+startY)||(index==self.arrayMiddCellView.count+4+startY)) {
            if (index==startY+0) {
                 return CGSizeMake(self.bounds.size.width, self.userHomeMainCell.cellSizeH);
            }
            else if (index==startY+1) {
                return CGSizeMake(self.bounds.size.width, self.historyCell.cellSizeH);
            }
            else if (index==startY+2){
                return CGSizeMake(self.bounds.size.width, self.videoHistoryCell.cellSizeH);
            }
            else if(index==self.arrayMiddCellView.count+startY+3)
            {
                return CGSizeMake(self.bounds.size.width, self.favoriteCell.cellSizeH);
            }
            else if(index==self.arrayMiddCellView.count+startY+4)
            {
                return CGSizeMake(self.bounds.size.width, self.contactViewCell.cellSizeH);
            }
        }
        else if (index==self.arrayMiddCellView.count+startY+5){
            if (IF_IPAD) {
                return CGSizeMake(self.bounds.size.width, 250*AppScaleIpadH);
            }
            else {
                return CGSizeMake(self.bounds.size.width, (200)*AppScaleIphoneH);
            }
        }
        else{
            MorePanelCell *cell = [self.arrayMiddCellView objectAtIndex:index-(3+startY)];
            return cell.panelCellSize;
        }
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
   return  [self getCellSize:indexPath.row];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.arrayMiddCellView count]+7;//历史记录和顶部button+电影filmhome+播放记录+联系我们+功能说明
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
    if ((self.cellPos==0 && indexPath.row==0)||(self.cellPos==1 && indexPath.row==self.arrayMiddCellView.count+6)) {
        middleView = self.appTipsViewCell;
        CGSize size = [self getCellSize:indexPath.row];
        cell.contentView.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    else if (indexPath.row==0+pos) {
        middleView = self.userHomeMainCell;
        cell.contentView.bounds = CGRectMake(0,0,cell.bounds.size.width, self.userHomeMainCell.cellSizeH);
    }
    else if (indexPath.row==1+pos) {
        middleView = self.historyCell;
        cell.contentView.bounds = CGRectMake(0,0,cell.bounds.size.width, self.historyCell.cellSizeH);
    }
    else if (indexPath.row==2+pos) {
        middleView = self.videoHistoryCell;
        cell.contentView.bounds = CGRectMake(0,0,cell.bounds.size.width, self.videoHistoryCell.cellSizeH);
    }
    else if (indexPath.row==self.arrayMiddCellView.count+3+pos){
        middleView = self.favoriteCell;
        cell.contentView.bounds = CGRectMake(0,0,cell.bounds.size.width, self.favoriteCell.cellSizeH);
    }
    else if (indexPath.row==self.arrayMiddCellView.count+4+pos){
        middleView = self.contactViewCell;
        cell.contentView.bounds = CGRectMake(0,0,cell.bounds.size.width, self.contactViewCell.cellSizeH);
    }
    else if (indexPath.row==self.arrayMiddCellView.count+5+pos){
        CellIdentifier = @"WebBoardViewCell";
        middleView = self.boardViewCell;
        CGSize size = [self getCellSize:indexPath.row];
        cell.contentView.bounds = CGRectMake(0,0,size.width, size.height);
    }
    else if(indexPath.row>=(3+pos)){
        middleView = [self.arrayMiddCellView objectAtIndex:indexPath.row-(3+pos)];
        cell.contentView.bounds = CGRectMake(0,0,((MorePanelCell*)middleView).panelCellSize.width, ((MorePanelCell*)middleView).panelCellSize.height);
    }
    UIColor *backColor =[UIColor whiteColor];
    UIColor  *fontColor = [UIColor blackColor];
    if (indexPath.row%2==0) {
        backColor = RGBCOLOR(242,242,242);
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
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 20*AppScaleIphoneH;
    }
    return 10;
}



@end
