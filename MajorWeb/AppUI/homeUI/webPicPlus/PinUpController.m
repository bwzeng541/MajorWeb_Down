//
//  PinUpController.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "PinUpController.h"
#import "PinUpDataModel.h"
#import "ReactiveCocoa.h"
#import "YSCHUDManager.h"
#import "SDWebImageManager.h"
#import "ReferImageView.h"
#import "AppDelegate.h"
#import "YBImageBrowser.h"
#import "PicUpIconsView.h"
#define TopCategoryUILabelViewTag 1

#define PinUpTypeKey @"key"
#define PinUpTypeDes @"des"

#define PinUpReferer @"http://m.mm131.com"
@interface PinUpController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    float _picW,_picH;
    BOOL isTouch;
    CGFloat offsetBeginY;
    BOOL isStautsBarHidden;
    UIView *statusBarView;
    UIButton *btnBack;
}
@property(nonatomic,strong)NSArray *topKeyArray;
@property(nonatomic,copy)NSArray *picArray;
@property(nonatomic,copy)NSString *currentKey;
@property(nonatomic,strong)PinUpDataModel *pinDataModel;
@property(nonatomic,assign)NSInteger selectIndex;
@property(nonatomic,strong)UICollectionView *topCategoryCollectionView;

@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UICollectionView *picCollectionView;

@end

@implementation PinUpController

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [self clearAllAsset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isStautsBarHidden = false;
    self.pinDataModel = [PinUpDataModel getPinDataModel];
    self.topKeyArray = [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:XINGGANMODEL,PinUpTypeKey,@"性感",PinUpTypeDes, nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:XINGGANMODEL1,PinUpTypeKey,@"诱惑",PinUpTypeDes, nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:XINGGANMODEL2,PinUpTypeKey,@"魅力",PinUpTypeDes, nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:XINGGANMODEL3,PinUpTypeKey,@"丰满",PinUpTypeDes, nil],
        [NSDictionary dictionaryWithObjectsAndKeys:CHEMOKEYMODEL,PinUpTypeKey,@"车模",PinUpTypeDes, nil],
        [NSDictionary dictionaryWithObjectsAndKeys:QIPAOMODEL,PinUpTypeKey,@"旗袍",PinUpTypeDes, nil],
        [NSDictionary dictionaryWithObjectsAndKeys:XIAOHUAMODEL,PinUpTypeKey,@"校花",PinUpTypeDes, nil],/*[NSDictionary dictionaryWithObjectsAndKeys:MINGXINGMODEL,PinUpTypeKey,@"明星",PinUpTypeDes, nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:QINGCHUNMODEL,PinUpTypeKey,@"清纯",PinUpTypeDes, nil],*/ nil];
    //创建top
    self.view.backgroundColor = RGBCOLOR(0, 0, 0);
    statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH-20,MY_SCREEN_WIDTH, GetAppDelegate.appStatusBarH)];
    [self.view addSubview:statusBarView];
    statusBarView.backgroundColor = [UIColor clearColor];
    //btnback
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
    [self.view addSubview:btnBack];
    [btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->statusBarView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.height.mas_equalTo(30);
    }];
    [btnBack addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnFav = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btnFav];
    [btnFav setTitle:@"收藏" forState:UIControlStateNormal];
    btnFav.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    btnFav.titleLabel.textColor = [UIColor whiteColor];
    CGSize btnFavSize = [self getCellSize:@"收藏"];
    [btnFav mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.centerY.equalTo(self->btnBack);
        make.width.mas_equalTo(btnFavSize.width);
        make.left.mas_equalTo(self->btnBack.mas_right).mas_offset(10);
    }];
    [btnFav addTarget:self action:@selector(favEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
    self.topCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50) collectionViewLayout:fallLayout];
    fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    fallLayout.minimumInteritemSpacing =1;
    [self.topCategoryCollectionView setCollectionViewLayout:fallLayout];
    [self.topCategoryCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TopCategoryCollection"];
    [self.view addSubview:_topCategoryCollectionView];
    _topCategoryCollectionView.backgroundColor = [UIColor blackColor];
    _topCategoryCollectionView.dataSource = self;
    _topCategoryCollectionView.delegate = self;
    [_topCategoryCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.centerY.equalTo(self->btnBack);
        make.right.mas_equalTo(self.view);
        make.left.mas_equalTo(btnFav.mas_right).mas_offset(10);
    }];
    
    self.contentView = [[UIView alloc] init];
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.right.equalTo(self.view);
        make.top.equalTo(self->_topCategoryCollectionView.mas_bottom).mas_offset(IF_IPHONE?0:10);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view).mas_offset(20);
        make.right.equalTo(self.view).mas_offset(-20);
    }];
    
    
    if (IF_IPHONE) {
        _picW = (MY_SCREEN_WIDTH-60)/2;
    }
    else{
        _picW = (MY_SCREEN_WIDTH-80)/3;
    }
    fallLayout = [[UICollectionViewFlowLayout alloc]init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:fallLayout];
    collectionView.backgroundColor = [UIColor blackColor];
    fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    fallLayout.minimumInteritemSpacing =1;
    [collectionView setCollectionViewLayout:fallLayout];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
    [_contentView addSubview:collectionView];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_contentView);
    }];
    self.picCollectionView = collectionView;
    @weakify(self)
    [RACObserve(self.pinDataModel, updatePinUpList) subscribeNext:^(id x) {
        @strongify(self)
        [self updateData];
    }];
    self.selectIndex = arc4random() % self.topKeyArray.count;
    [self showSouSouUI];
}

-(void)loadFav{
    [self favEvent:nil];
}

-(void)favEvent:(UIButton*)sender{
    [YSCHUDManager showHUDOnView:self.contentView];
    self.selectIndex = -1;
    [self.topCategoryCollectionView reloadData];
    self.currentKey = PINUPSHOUCANG;
    [self.pinDataModel favTheGetCommend:self.currentKey];
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)bl_supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


-(void)back:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateData{
    [YSCHUDManager hideHUDOnView:self.contentView animated:NO];
    if([self.currentKey compare:self.pinDataModel.reqeustKey]==NSOrderedSame){
        self.picArray = [[self.pinDataModel.datasourcePicList reverseObjectEnumerator] allObjects];
        [self.picCollectionView setContentOffset:CGPointZero];
        [self.picCollectionView reloadData];
    }
}

-(void)reqeustKey:(NSString*)key{
    self.currentKey = key;
    [YSCHUDManager showHUDOnView:self.contentView];
    [self.pinDataModel httpTheGetCommend:key];
}

-(void)clearAllAsset{
    self.pinDataModel = nil;
}

-(void)showSouSouUI
{
    [self reqeustKey:[[self.topKeyArray objectAtIndex:self.selectIndex]objectForKey:PinUpTypeKey]];
}

-(BOOL)prefersStatusBarHidden{
    return true;
}

-(void)showStautsBar{
    isStautsBarHidden = false;
    [self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.topCategoryCollectionView==collectionView) {
        if (self.selectIndex>=0  && self.selectIndex<self.topKeyArray.count)
        {
            UICollectionViewCell *cellView = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]];
            UILabel *label = [cellView viewWithTag:TopCategoryUILabelViewTag];
            label.textColor = [UIColor whiteColor];
        }
        self.selectIndex = indexPath.row;
        UICollectionViewCell *cellView = [collectionView cellForItemAtIndexPath:indexPath];
        UILabel *label = [cellView viewWithTag:TopCategoryUILabelViewTag];
        label.textColor = RGBCOLOR(255, 210, 0);
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [self showSouSouUI];
    }
    else{
        NSMutableArray *tempArr = [NSMutableArray array];
        NSDictionary *info = [self.picArray objectAtIndex:indexPath.row];
        NSArray *array = [info objectForKey:DICKEY_Pics];
        [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YBImageBrowserModel *model = [YBImageBrowserModel new];
            model.referer = PinUpReferer;
            [model setUrlWithDownloadInAdvance:[NSURL URLWithString:obj]];
            model.sourceImageView = nil;
            model.maximumZoomScale = 10;
            [tempArr addObject:model];
        }];
        isStautsBarHidden = true;
        [self setNeedsStatusBarAppearanceUpdate];
        PicUpIconsView *v =  [[PicUpIconsView alloc]initWithFrame:self.view.bounds withData:tempArr info:info key:self.currentKey];
        v.parentCtrl = self;
        [self.view addSubview:v];
    }
}

-(CGSize)getCellSize:(NSString*)name{
    NSString *text = name;
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGSize size = [text boundingRectWithSize:CGSizeMake(200,  200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font} context:nil].size;
    return CGSizeMake(size.width+30, _topCategoryCollectionView.bounds.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.topCategoryCollectionView==collectionView) {
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView==self.topCategoryCollectionView) {
        return [self.topKeyArray count];
    }
    return self.picArray.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * CellIdentifier = @"TopCategoryCollection";
    if (collectionView!=self.topCategoryCollectionView) {
        CellIdentifier = @"ContentCollection";
    }
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (collectionView==self.topCategoryCollectionView) {
        UILabel *label = [cell.contentView viewWithTag:TopCategoryUILabelViewTag];
        if (!label) {
            label = [[UILabel alloc]initWithFrame:CGRectZero];
            [cell.contentView addSubview:label];
            label.tag = TopCategoryUILabelViewTag;
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(cell.contentView);
            }];
        }
        if (self.selectIndex>=0 && self.selectIndex==indexPath.row && self.selectIndex<self.topKeyArray.count) {
            label.textColor = RGBCOLOR(255, 210, 0);
        }
        else{
            label.textColor = [UIColor whiteColor];
        }
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [[self.topKeyArray objectAtIndex:indexPath.row]objectForKey:PinUpTypeDes];
    }
    else{
        NSString *request = [[self.picArray objectAtIndex:indexPath.row] objectForKey:DICKEY_Small_pic];
        ReferImageView *imageView = [[ReferImageView alloc] init];
        [imageView loadImageFrom:request webRefer:PinUpReferer];
        [cell.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView);
        }];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView==self.topCategoryCollectionView) {
        NSString *name = [[self.topKeyArray objectAtIndex:indexPath.row]objectForKey:PinUpTypeDes];
        return [self getCellSize:name];
    }
    return CGSizeMake(_picW, 160/120.0 *_picW);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (collectionView!=_topCategoryCollectionView) {
        return 20;
    }
    return 10;
}
@end
