//
//  MarjorNewSortView.m
//  MajorWeb
//
//  Created by zengbiwang on 2020/4/3.
//  Copyright © 2020 cxh. All rights reserved.
//

#import "MarjorNewSortView.h"
#import "MajorModeDefine.h"
#import "MainMorePanel.h"
#import "MarjorWebConfig.h"
#import "QRWKWebview.h"
#define SortLabelTag 1
@interface MarjorNewSortView()<QRWKWebviewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    float itemSortSpacing,itemMoreSpacing;
    float sortCellW,sortCellH,morePancelW,morePancelH;
    UICollectionView *sortCollectionView;
    UICollectionView *morePanelCollectionView;
    UIColor *colorTitle;
    UILabel *topDabel,*topDetail;
    NSInteger selectIndex;
}
@property(strong,nonatomic)QRWKWebview *webView;
@property(strong,nonatomic)morePanelInfo *panelInfo;
@property(strong,nonatomic)onePanel *onePanel;
@property(nonatomic,strong)NSArray *listArrayData;
@end
@implementation MarjorNewSortView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blueColor];
    self.webView = [[QRWKWebview alloc] initWithFrame:self.bounds uuid:nil userAgent:nil isExcutJs:true];
    self.webView.isUseChallenge = false;
    self.webView.qrWkdelegate = self;
    [self addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.webView loadUrl:@"http://maxdownapp.oss-cn-hangzhou.aliyuncs.com/max_home.html"];
    return self;
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    sortCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    sortCollectionView.scrollEnabled = NO;
    sortCollectionView.dataSource = self;
    sortCollectionView.delegate = self;
    sortCollectionView.backgroundColor = [UIColor whiteColor];
    [sortCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ButtonCell"];
    [self addSubview:sortCollectionView];
     [sortCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.bottom.left.right.equalTo(self);
         make.height.mas_equalTo(120);
    }];
    sortCollectionView.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    topDabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:topDabel];
    [topDabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        if (IF_IPAD) {
            make.top.equalTo(self).mas_offset(10);
        }
        else{
            make.top.equalTo(self);
        }
        make.height.mas_equalTo(30);
    }];
    topDabel.textAlignment = NSTextAlignmentCenter;
    topDabel.text = @"最热门网站";
    float fontSize = 16*AppScaleIphoneH;
    if (!IF_IPHONE) {
        fontSize = 24*AppScaleIpadH;
    }
    topDabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize*1.2];
    topDetail = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:topDetail];
    [topDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(15);
        make.top.equalTo(self->topDabel.mas_bottom);
    }];
    topDetail.textAlignment = NSTextAlignmentCenter;
    topDetail.text = @"描述hhhh";
    topDetail.font = [UIFont systemFontOfSize:fontSize*0.45];
   UICollectionViewFlowLayout* carouseLayout1 = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout1.scrollDirection = UICollectionViewScrollDirectionVertical;
     morePanelCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout1];
    morePanelCollectionView.scrollEnabled = YES;
    morePanelCollectionView.dataSource = self;
    morePanelCollectionView.delegate = self;
    morePanelCollectionView.backgroundColor = [UIColor whiteColor];
    [morePanelCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"DeailtCell"];
    [self addSubview:morePanelCollectionView];
    [morePanelCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self->topDetail.mas_bottom);
        make.bottom.equalTo(self->sortCollectionView.mas_top).mas_offset(-5);
    }];
    
    return self;
}

-(BOOL)qrLinkActivatedHandle:(NSString*)url object:(id)object{
    if(![url isEqualToString:[self.webView.webView.URL absoluteString]]){
          //[self.qrNativeDelegate qrNative_click_callback:url];
        WebConfigItem *v = [[WebConfigItem alloc] init];
        v.url = url;
        if (self.clickBlock) {
                self.clickBlock(v, nil);
            }
      return true;
      }
    return false;
}

-(void)updateSortData:(NSArray*)array{
    itemSortSpacing = 4;
    int colume = 4;
    sortCellW = (self.frame.size.width-8-itemSortSpacing*colume)/colume;
    sortCellH = (sortCollectionView.frame.size.height-itemSortSpacing)/4;
    morePancelW = sortCellW;
    morePancelH = sortCellH;
    self.listArrayData = array;
    selectIndex = 0;
    [self updateOnePanel];
    [self->sortCollectionView reloadData];
 }

-(void)updateOnePanel{
    if (selectIndex<self.listArrayData.count) {
        self.panelInfo = [self.listArrayData objectAtIndex:selectIndex];
        UIColor *b = RGBCOLOR(159, 159, 159);
        if (self.panelInfo && self.panelInfo.color_R && self.panelInfo.color_G && self.panelInfo.color_B) {
            b = RGBCOLOR([self.panelInfo.color_R floatValue], [self.panelInfo.color_G floatValue], [self.panelInfo.color_B floatValue]);
            colorTitle = b;
             self.onePanel = [[MainMorePanel getInstance].arraySort.arraySort objectAtIndex:[self.panelInfo.type intValue]];
            [morePanelCollectionView reloadData];
            topDabel.text = self.onePanel.headerName;
            topDabel.textColor = colorTitle;
            topDetail.textColor = RGBCOLOR(159, 159, 159);
            topDetail.text = self.panelInfo.des;
        }
     }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView==sortCollectionView) {
        return CGSizeMake(sortCellW, sortCellH);
    }
    else{
        return CGSizeMake(morePancelW, morePancelH);
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView==sortCollectionView) {
        return self.listArrayData.count;
    }
    else if(collectionView==morePanelCollectionView){
        return [self.onePanel.array count];
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     UICollectionViewCell * cell = nil;
     float fontSize = 14;
    if (IF_IPHONE) {
        fontSize = 10*AppScaleIphoneH;
    }
    if (collectionView==sortCollectionView) {
        cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell" forIndexPath:indexPath];
        [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
        morePanelInfo *panelInfo = [self.listArrayData objectAtIndex:indexPath.row];
        if (panelInfo.type && [panelInfo.type intValue]<[MainMorePanel getInstance].arraySort.arraySort.count) {
           onePanel * onePanel = [[MainMorePanel getInstance].arraySort.arraySort objectAtIndex:[panelInfo.type intValue]];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,sortCellW,sortCellH)];
            label.textAlignment = NSTextAlignmentCenter;
            if (selectIndex!=indexPath.row) {
                label.backgroundColor = RGBCOLOR(237, 237, 237);
            }
            else{
                label.backgroundColor = RGBCOLOR(184, 184, 184);
            }
            label.text  = onePanel.headerName;
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
            UIColor *a = RGBCOLOR(0, 0, 0);
            if (panelInfo && panelInfo.color_R && panelInfo.color_G && panelInfo.color_B) {
                a = RGBCOLOR([panelInfo.color_R floatValue], [panelInfo.color_G floatValue], [panelInfo.color_B floatValue]);
             }
            label.textColor = a;
            label.tag = SortLabelTag;
            [cell.contentView addSubview:label];
        }
        return cell;
    }
    else{
        cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DeailtCell" forIndexPath:indexPath];
        [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
        WebConfigItem *item = [self.onePanel.array objectAtIndex:indexPath.row];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,morePancelW,morePancelH)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = colorTitle?colorTitle:RGBCOLOR(76, 76, 76);
        [cell.contentView addSubview:label];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
        label.text =  item.name;
        
        return cell;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView==sortCollectionView) {
       UILabel *unS =  [[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]].contentView viewWithTag:SortLabelTag];
        unS.backgroundColor = RGBCOLOR(237, 237, 237);
        selectIndex = indexPath.row;
       unS =  [[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]].contentView viewWithTag:SortLabelTag];
        unS.backgroundColor =  RGBCOLOR(184, 184, 184);
        [self updateOnePanel];
    }
    else{
        WebConfigItem *v = [self.onePanel.array objectAtIndex:indexPath.row];
        [MarjorWebConfig getInstance].webItemArray = self.onePanel.array;
        if (self.clickBlock) {
            self.clickBlock(v, nil);
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}



- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return itemSortSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSortSpacing;
}
@end
