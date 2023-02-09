
#import "MajorContactView.h"
#import "AppDelegate.h"
#import "MajorSystemConfig.h"
#import "MajorFeedbackKit.h"
#import "MajorModeDefine.h"
#import "ShareSdkManager.h"
#import "MarjorWebConfig.h"
@interface MajorContactView()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>{
    float _cellW,_cellH;
    float _column;
    float totalH;
}
@property(nonatomic,assign)float cellSizeH;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *listArray;

@end

@implementation MajorContactView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(![MajorSystemConfig getInstance].isOpen)
    self.listArray = @[@"问题反馈",@"屏蔽广告网站",@"我要推荐网站",@"论坛",@"分享好友",@"分享朋友圈"];
    else
    self.listArray = @[@"问题反馈",@"屏蔽广告网站",@"我要推荐网站",@"论坛"];
    _column = 4;
    NSInteger line = [self getRows:self.listArray.count columns:_column];
    float w = frame.size.width;
    w = w- 60;
    _cellW = w /_column;
    _cellH = 30;
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, totalH, self.frame.size.width, _cellH*line) collectionViewLayout:carouseLayout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ButtonCell"];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);make.bottom.equalTo(self).mas_offset(-20);
        make.right.equalTo(self).mas_offset(-20);
        make.left.equalTo(self).mas_offset(20);
        if (IF_IPHONE) {
            make.top.equalTo(self).mas_offset(16+30);
        }
        else{
            make.top.equalTo(self).mas_offset(16+50);
        }
    }];
    
    UILabel *label = [[UILabel alloc]init];
    self.headLabel = label;
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(20);
        make.bottom.equalTo(self.collectionView.mas_top);
        make.top.equalTo(self).mas_offset(10);
        make.width.mas_equalTo(self);
    }];
    
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"联系我们" ;
    label.textColor = [UIColor blackColor];
    if (IF_IPHONE) {
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16*AppScaleIphoneH];
    }
    else{
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:24*AppScaleIpadH];
    }
    float lableh = 50;
    if (IF_IPHONE) {
        lableh/=2;
    }
    self.headLabel = label;
    totalH+=(_cellH*line)+18+lableh+20;
    
    self.frame = CGRectMake(0, 0, frame.size.width, totalH);
    self.cellSizeH = self.frame.size.height;
    [self.collectionView reloadData];
    return self;
}

-(NSInteger)getRows:(NSInteger)size columns:(NSInteger)columns{
    if (size < 1 || columns < 1)
        return 0;
    // 整除
    BOOL isDivisible = (size % columns) == 0;
    if (isDivisible) {
        return size / columns;
    } else {
        return size / columns + 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_cellW, _cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ButtonCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    float fontSize = 16;
    if (IF_IPHONE) {
        fontSize = 10*AppScaleIphoneH;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _cellW, _cellH)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = [self.listArray objectAtIndex:indexPath.row];
    label.textColor = RGBCOLOR(76, 76, 76);
    [cell.contentView addSubview:label];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if(row<=2){
        [[MajorFeedbackKit getInstance] openFeedbackViewController:GetAppDelegate.getRootCtrlView.nextResponder];
    }
    else {
        if (row==3) {//http://47.96.26.202:16916/forum.php
                 WebConfigItem *item = [[WebConfigItem alloc] init];
                [MarjorWebConfig getInstance].webItemArray = nil;
                item.url = @"http://47.96.26.202:16916/forum.php";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
        }
        else if (row==4){
            [[ShareSdkManager getInstance] shareHome:(SSDKPlatformSubTypeWechatSession)];
        }
        else if (row==5){
            [[ShareSdkManager getInstance] shareHome:(SSDKPlatformSubTypeWechatTimeline)];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}



- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 2;
    }
    return 2;
}
@end
