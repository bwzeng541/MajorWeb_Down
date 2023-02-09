//
//  GoBackWebView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/10.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "GoBackWebView.h"
#import "MarjorWebConfig.h"
#import "BaseHeaderFlowLayout.h"
#import "Record.h"
#import "AppDelegate.h"
#import "ReactiveCocoa.h"
@interface GoBackWebView()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>{
    float _cellW,_cellH;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *arrayList;
@end

@implementation GoBackWebView

-(instancetype)initWithFrame:(CGRect)frame bottomOffsetY:(float)bottomOffsetY{
    self = [super initWithFrame:frame];
    self.arrayList = [MarjorWebConfig getFavoriteOrHistroyData:true];
    UIView *maskView = [[UIView alloc]initWithFrame:self.bounds];
     [self addSubview:maskView];
    __weak __typeof(self)weakSelf = self;
    [maskView bk_whenTapped:^{
        [weakSelf clickBack];
    }];
    maskView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
    
    float hh = 76;
    if (IF_IPHONE) {
        hh=35;
    }
    _cellW = self.bounds.size.width-40;
    _cellH = 30;
    BaseHeaderFlowLayout * carouseLayout = [[BaseHeaderFlowLayout alloc] init];
    carouseLayout.sectionHeadersPinToVisibleBoundsAll = YES;
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    carouseLayout.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, hh);  //设置headerView大小
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ButtonCell"];

    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];  //  一定要设置
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.scrollEnabled = YES;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(-bottomOffsetY);
        make.right.equalTo(self).mas_offset(-20);
        make.left.equalTo(self).mas_offset(20);
        make.height.equalTo(self).multipliedBy(0.3);
    }];
    UIView *backView = [[UIView alloc] init];
    [self insertSubview:backView belowSubview:_collectionView];
    backView.backgroundColor = [UIColor whiteColor];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self);
        make.height.bottom.equalTo(self->_collectionView);
    }];
    @weakify(self)
    [RACObserve(GetAppDelegate,isHistoryUpdate) subscribeNext:^(id x) {
        @strongify(self)
        self.arrayList = [MarjorWebConfig getFavoriteOrHistroyData:true];
        [self.collectionView reloadData];
    }];
    return self;
}

-(void)clickBack{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
        return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_cellW, _cellH+5);
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    [[headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    float sizeFont = 36;
    if (IF_IPHONE) {
        sizeFont/=2;
    }
    else{
        sizeFont  =30;
    }
    UILabel *labelLeft = [[UILabel alloc] initWithFrame:headerView.bounds];
    labelLeft.text = @"快速返回";
    [headerView addSubview:labelLeft];
    labelLeft.textAlignment = NSTextAlignmentLeft;
    labelLeft.font = [UIFont fontWithName:@"Helvetica-Bold" size:sizeFont];
    labelLeft.textColor = [UIColor blackColor];
    
    UILabel *labelRight = [[UILabel alloc] initWithFrame:headerView.bounds];
    labelRight.text = @"所有历史记录";
    labelRight.tag = indexPath.section;
    [headerView addSubview:labelRight];
    labelRight.textAlignment = NSTextAlignmentRight;
    labelRight.font = [UIFont systemFontOfSize:sizeFont*0.5];
    labelRight.textColor = RGBCOLOR(159, 159, 159);
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellIdentifier = @"ButtonCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSString *imageName = @"AppMain.bundle/home_ls";
    Record *record = [self.arrayList objectAtIndex:indexPath.row];
    float ww = 33;
    float fontSize = 37;
    if (IF_IPHONE) {
        ww/=2;
        fontSize = 12*AppScaleIphoneH;
    }
    
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0,(_cellH-ww)/2, ww, ww)];
    imageView.image = [UIImage imageNamed:imageName];
    [cell.contentView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+3, 0, _cellW-(imageView.frame.origin.x+imageView.frame.size.width+3), _cellH)];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.dk_textColorPicker = DKColorPickerWithKey(NEWSTITLE);
    if(IF_IPAD)
    label.font = [UIFont systemFontOfSize:fontSize/2];
        else
    label.font = [UIFont systemFontOfSize:10];
    [cell.contentView addSubview:label];
    label.text =  record.titleName;
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+3, _cellH/2, _cellW-(imageView.frame.origin.x+imageView.frame.size.width+3), _cellH)];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label];
        if(IF_IPAD)
        label.font = [UIFont systemFontOfSize:10];
            else
        label.font = [UIFont systemFontOfSize:fontSize/1.5];
        label.text =  record.titleUrl;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Record *record = [self.arrayList objectAtIndex:indexPath.row];
    if (self.clickBlock) {
        self.clickBlock(record.titleUrl);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 2;
    }
    return 2;
}

@end
