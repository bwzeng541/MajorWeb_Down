//
//  MorePanelCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MorePanelCell.h"
#import "MainMorePanel.h"
#import "MarjorWebConfig.h"
@interface MorePanelCell()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>{
    float cellH,cellW;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(assign,nonatomic)CGSize panelCellSize;
@property(assign,nonatomic)BOOL isOverHeadState;
@property(strong,nonatomic)onePanel *onePanel;
@property(strong,nonatomic)UIColor *colorTitle;
@property(copy,nonatomic)NSString *panelDes;
@property(copy,nonatomic)NSString *iconUrl;
@property(nonatomic,copy)NSMutableAttributedString *headerName;
@end
@implementation MorePanelCell

-(instancetype)initWithPrivacyFrame:(CGRect)frame morePanelInfo:(morePanelInfo*)panelInfo onePanel:(onePanel*)onePanel{
    self = [super initWithFrame:frame];
    self.panelDes = panelInfo.type;
    self.onePanel = onePanel;
    [self initPanleView:panelInfo frame:frame];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame morePanelInfo:(morePanelInfo*)panelInfo{
    if (panelInfo.type && [panelInfo.type intValue]<[MainMorePanel getInstance].arraySort.arraySort.count) {
        self = [super initWithFrame:frame];
        self.panelDes = panelInfo.type;
        self.onePanel = [[MainMorePanel getInstance].arraySort.arraySort objectAtIndex:[panelInfo.type intValue]];
        [self initPanleView:panelInfo frame:frame];
        return self;
    }
    return nil;
}

-(void)initPanleView:(morePanelInfo*)panelInfo frame:(CGRect)frame{
    self.iconUrl = self.onePanel.iconurl;
    float lableh = 50;
    if (IF_IPHONE) {
        lableh/=2;
    }
    if (true) {//headerName
        //des描述
        float fontSize = 16*AppScaleIphoneH;
        if (!IF_IPHONE) {
            fontSize = 24*AppScaleIpadH;
        }
        NSMutableAttributedString *attrStr = nil;
        if (panelInfo) {
           attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   \n%@",self.onePanel.headerName,panelInfo.des]];
        }
        else{
            attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.onePanel.headerName]];
        }
        NSRange rangeHeader = NSMakeRange(0, [self.onePanel.headerName length]);
        NSRange rangeDes = NSMakeRange(rangeHeader.length, [panelInfo.des length]+4);
        UIColor *a = RGBCOLOR(0, 0, 0);
        UIColor *b = RGBCOLOR(159, 159, 159);
        if (panelInfo && panelInfo.color_R && panelInfo.color_G && panelInfo.color_B) {
            a = RGBCOLOR([panelInfo.color_R floatValue], [panelInfo.color_G floatValue], [panelInfo.color_B floatValue]);
            b = RGBCOLOR([panelInfo.color_R floatValue], [panelInfo.color_G floatValue], [panelInfo.color_B floatValue]);
            self.colorTitle = b;
        }
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize*1.2]
                        range:rangeHeader];
        
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:a
                        range:rangeHeader];
        if(panelInfo){
            [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:fontSize*0.6]
                        range:rangeDes];
            [attrStr addAttribute:NSForegroundColorAttributeName
                        value:RGBCOLOR(159, 159, 159)
                        range:rangeDes];
        }
        self.headerName = attrStr;
    }
    float totalH = 10+lableh+5-lableh;
    int column = 4;
    
    //创建cel
    NSInteger line = [self getRows:self.onePanel.array.count>12?12:self.onePanel.array.count columns:column];
    float w = self.frame.size.width;
    w = w- 60;
    cellW = w /column;
    cellH = 32;
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, totalH, self.frame.size.width, cellH*line) collectionViewLayout:carouseLayout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ButtonCell"];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).mas_offset(-20);
        make.right.equalTo(self).mas_offset(-20);
        make.left.equalTo(self).mas_offset(20);
        if (IF_IPHONE) {
            make.top.equalTo(self).mas_offset(16);
        }
        else{
            make.top.equalTo(self).mas_offset(16);
        }
    }];
    line = 3;
    totalH+=(cellH*line);
    
    self.frame = CGRectMake(0, 0, frame.size.width, totalH+20);
    self.panelCellSize = self.frame.size;
    [self.collectionView reloadData];
    
    @weakify(self)
    
    [RACObserve([MarjorWebConfig getInstance],overHeadKey) subscribeNext:^(id x) {
        @strongify(self)
        [self updateRightLableState];
    }];
}


-(void)rightEventTouch{
    self.isOverHeadState = !self.isOverHeadState;
    if (self.isOverHeadState) {
        [MarjorWebConfig getInstance].overHeadKey = self.panelDes;
        if (self.clickOverheadBlock) {
            self.clickOverheadBlock(self);
        }
    }
    else{
        [MarjorWebConfig getInstance].overHeadKey = @"";
    }
    [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
}

-(void)updateRightLableState{
    if ([self.panelDes isEqualToString:[MarjorWebConfig getInstance].overHeadKey]) {
        self.isOverHeadState = true;
        self.rightLabel.text = @"取消置顶";
    }
    else{
        self.isOverHeadState = false;
        self.rightLabel.text = @"置顶";
    }
}

-(void)updateDate{
    [self.collectionView reloadData];
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
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.onePanel.array count]>12?12:[self.onePanel.array count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ButtonCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    WebConfigItem *item = [self.onePanel.array objectAtIndex:indexPath.row];
    
    float fontSize = 16;
    if (IF_IPHONE) {
        fontSize = 12*AppScaleIphoneH;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,cellW,cellH)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.colorTitle?self.colorTitle:RGBCOLOR(76, 76, 76);
    [cell.contentView addSubview:label];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    label.text =  item.name;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.clickBlock){
        [MarjorWebConfig getInstance].webItemArray = self.onePanel.array;
        self.clickBlock([self.onePanel.array objectAtIndex:indexPath.row],self);
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
    return 2;
}
@end
