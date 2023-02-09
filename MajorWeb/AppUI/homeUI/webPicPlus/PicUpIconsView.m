//
//  PicUpIconsView.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/4.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "PicUpIconsView.h"
#import "YBImageBrowser.h"
#import "YBImageBrowserCell.h"
#import "SDWebImageManager.h"
#import "AppDelegate.h"
#import "PicUpIconsView+VideoNativeAd.h"
#import "PinUpController.h"
#import "JMDefine.h"
#import "PinUpDataModel.h"
#import "NSString+MKNetworkKitAdditions.h"
#define TopCategoryUILabelViewTag 1
@interface PicUpIconsView()<UICollectionViewDelegate,UICollectionViewDataSource,YBImageBrowserDataSource,YBImageBrowserCellDelegate,YBImageBrowserDelegate>{
    float _picW;
    UIButton *btnBack;
    UIButton *btnFav ;
}
@property(nonatomic,strong)NSMutableArray *topKeyArray;
@property(nonatomic,assign)NSInteger selectIndex;
@property(nonatomic,strong)UICollectionView *topCategoryCollectionView;
@property(nonatomic,strong)NSArray *picArray;
@property(nonatomic,copy)NSDictionary *assetInfo;
@property(nonatomic,copy)NSString *key;
@property(nonatomic,copy)NSString *uuid;
@property(nonatomic,strong)UICollectionView *collectionView;
@end
@implementation PicUpIconsView
-(void)dealloc{
    [self stopVideoNative];
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame withData:(NSArray*)array info:(NSDictionary*)info key:(NSString*)key{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    self.assetInfo = info;
    self.key = key;
    self.uuid = [[info objectForKey:DICKEY_Small_pic] md5];
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,MY_SCREEN_HEIGHT, kStatusBarHeight)];
    statusBarView.backgroundColor = [UIColor clearColor];
    [self addSubview:statusBarView];
    
    self.topKeyArray = [NSMutableArray arrayWithArray:@[@"一列",@"二列",@"三列",@"四列"]];
    if (IF_IPAD) {
        [self.topKeyArray addObject:@"五列"];
        [self.topKeyArray addObject:@"六列"];
    }
     btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
    [self addSubview:btnBack];
    [btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(statusBarView.mas_bottom);
        make.left.equalTo(self);
        make.width.height.mas_equalTo(30);
    }];
    [btnBack addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    btnFav = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btnFav];
    [self updateFavBtn];
    [btnFav addTarget:self action:@selector(favEvent:) forControlEvents:UIControlEventTouchUpInside];
    //132*52;
    [btnFav mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self->btnBack);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(66);
    }];
    
    self.picArray = array;
    UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
    self.topCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50) collectionViewLayout:fallLayout];
    fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    fallLayout.minimumInteritemSpacing =1;
    [self.topCategoryCollectionView setCollectionViewLayout:fallLayout];
    [self.topCategoryCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TopCategoryCollection"];
    [self addSubview:_topCategoryCollectionView];
    _topCategoryCollectionView.backgroundColor = [UIColor blackColor];
    _topCategoryCollectionView.dataSource = self;
    _topCategoryCollectionView.delegate = self;
    [_topCategoryCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.centerY.equalTo(self->btnBack);
        make.right.mas_equalTo(btnFav.mas_left).mas_offset(-5);
        make.left.mas_equalTo(self->btnBack.mas_right).mas_offset(10);
    }];
    if (IF_IPHONE) {
        self.selectIndex=3;
        [self updateLine:4];
    }
    else{
        self.selectIndex=5;
        [self updateLine:6];
    }
    return self;
}

-(void)updateFavBtn{
   BOOL ret = [[PinUpDataModel getPinDataModel] favTheBoolCommend:PINUPSHOUCANG uuid:self.uuid];
    if (ret) {
        [btnFav setImage:UIImageFromNSBundlePngPath(@"PicUpPlus.bundle/quxiao") forState:UIControlStateNormal];
    }
    else{
        [btnFav setImage:UIImageFromNSBundlePngPath(@"PicUpPlus.bundle/tianjia") forState:UIControlStateNormal];
    }
}

-(void)favEvent:(UIButton*)sender{
    BOOL ret = [[PinUpDataModel getPinDataModel] favTheBoolCommend:PINUPSHOUCANG uuid:self.uuid];
    if (ret) {
        [[PinUpDataModel getPinDataModel] favTheDelCommend:PINUPSHOUCANG uuid:self.uuid];
    }
    else{
        [[PinUpDataModel getPinDataModel] favTheAddCommend:PINUPSHOUCANG object:self.assetInfo uuid:self.uuid];
    }
    [self updateFavBtn];
}

-(void)updateLine:(NSInteger)row{
    if (IF_IPHONE) {
        _picW = (MY_SCREEN_WIDTH-10)/row;
    }
    else{
        _picW = (MY_SCREEN_WIDTH-12)/row;
    }
    RemoveViewAndSetNil(self.collectionView);
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView  = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:YBImageBrowserCell.class forCellWithReuseIdentifier:@"PicUpIconsCell"];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self).mas_offset(0);
        make.left.equalTo(self).mas_offset(0);
        make.top.equalTo(self->btnBack.mas_bottom).mas_offset(10+(IF_IPHONE?0:10));
    }];
    [self.collectionView reloadData];
}

- (void)back:(UIButton*)sender{
    RemoveViewAndSetNil(self.collectionView);
    [[SDWebImageManager sharedManager].imageDownloader cancelAllDownloads];
    [self.picArray makeObjectsPerformSelector:@selector(cancelTaskWithDownloadToken)];
    [self removeFromSuperview];
   PinUpController *v =   (PinUpController*)self.parentCtrl;
    [v showStautsBar];
    if([self.key isEqualToString:PINUPSHOUCANG]){
        [v loadFav];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if(collectionView!=self.collectionView)
        return 10;
    return 40;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    //1240X456
    if (self.collectionView==collectionView) {
        return CGSizeMake(_picW, 160/120.0 *_picW);
    }
    if (collectionView==self.topCategoryCollectionView) {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        NSString *name = [self.topKeyArray objectAtIndex:indexPath.row];
        NSString *text = name;
        CGSize size = [text boundingRectWithSize:CGSizeMake(200,  200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font} context:nil].size;
        return CGSizeMake(size.width+30, collectionView.bounds.size.height);
    }
    return CGSizeZero;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    if (self.collectionView==collectionView) {
        return self.picArray.count;
    }
    return self.topKeyArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView==self.topCategoryCollectionView) {
        NSString * CellIdentifier = @"TopCategoryCollection";
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
        label.text = [self.topKeyArray objectAtIndex:indexPath.row];
        return cell;
    }
    else{
        YBImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicUpIconsCell" forIndexPath:indexPath];
        cell.model = [self.picArray objectAtIndex:indexPath.row];
        cell.cancelDragImageViewAnimation = NO;
        [cell removeAllGestureAndNotification];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *keyUUID = [self.key md5];
    if (collectionView==self.collectionView) {
        if (keyUUID && [self isVaild:keyUUID]) {
            YBImageBrowser *v = [YBImageBrowser new];
            [v setYb_supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
            v.dataSource = self;
            v.delegate = self;
            v.currentIndex = indexPath.row;
            [(UIViewController*)self.superview.nextResponder presentViewController:v animated:NO completion:nil];
        }
    }
    else{
        if (indexPath.row<self.topKeyArray.count-1) {
            if (keyUUID && ![self isVaild:keyUUID]) {
                return;
            }
        }
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
        [self updateLine:indexPath.row+1];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.topCategoryCollectionView==collectionView) {
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}


- (NSInteger)numberInYBImageBrowser:(YBImageBrowser *)imageBrowser{
    return [self.picArray count];
}

- (YBImageBrowserModel *)yBImageBrowser:(YBImageBrowser *)imageBrowser modelForCellAtIndex:(NSInteger)index{
    YBImageBrowserModel *value = [self.picArray objectAtIndex:index];
    value.rowIndex = index;
    return value;
}

- (void)addMaskByYBImageBrowserCell:(YBImageBrowser*)imageBrowser imageBrowserCell:(YBImageBrowserCell *)imageBrowserCell {
    if (false/*imageBrowserCell.model.rowIndex>=3 && ![[WelfareManager getInstance] isWelfSupreVip]*/) {//检查是否是vip
        [imageBrowserCell removeAllGestureAndNotification ];
        if (![imageBrowserCell.contentView viewWithTag:101]) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:effect];
            view.frame = imageBrowserCell.imageView.bounds;
            view.userInteractionEnabled = NO;
            view.tag=100;
            [imageBrowserCell.imageView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(imageBrowserCell.imageView);
            }];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];//447X86
            [btn addTarget:self action:@selector(pressVip:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:UIImageFromNSBundlePngPath(@"buy_super_vip") forState:UIControlStateNormal];
            float w = 447,h=86;
            if (IF_IPHONE) {
                w/=2;h/=2;
            }
            btn.tag = 101;
            [imageBrowserCell.contentView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(view);
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(h);
            }];
        }
    }
    else{
        [[imageBrowserCell.contentView viewWithTag:101] removeFromSuperview];
        [[imageBrowserCell.imageView viewWithTag:100] removeFromSuperview];
        [imageBrowserCell addAllGestureAndNotification];
        if (imageBrowserCell.model.rowIndex>=3 && imageBrowserCell.model.rowIndex%4==0) {
            [self startVideoNative];
        }
    }
}

- (BOOL)yBImageBrowserIsCanExcel:(YBImageBrowser*)imageBrowser clickFunctionWithName:(NSString *)functionName imageModel:(YBImageBrowserModel *)imageModel {
    return true;
 /*   if (imageModel.rowIndex>=3 && ![[WelfareManager getInstance] isWelfSupreVip]) {//检查是否是vip
        [self pressVip:nil];
        return false;
    }
    return true;*/
}

-(void)pressVip:(UIButton*)sender
{
  //  [[WelfareManager getInstance] showUnVaildBuyUI];
}
@end
