//
//  MajorAppTiCellChild1.m
//  MajorWeb
//
//  Created by zengbiwang on 2020/4/2.
//  Copyright © 2020 cxh. All rights reserved.
//

#import "MajorAppTiCellChild1.h"
#import "NSObject+UISegment.h"
@interface MajorAppTiCellChild1()<UICollectionViewDelegate,UICollectionViewDataSource>{
    float cellW,cellH;
    float itemSpacing;
}
@property(strong,nonatomic)NSMutableArray *listArray;
@property(strong,nonatomic)UICollectionView *collectionView;
@end
@implementation MajorAppTiCellChild1

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.listArray = [NSMutableArray arrayWithArray:@[@"AppMain.bundle/child1_bfjl",@"AppMain.bundle/child1_lsjl",@"AppMain.bundle/child1_sc",@"AppMain.bundle/child1_zb",@"AppMain.bundle/child1_help",@"AppMain.bundle/child1_share"]];
    
    self.backgroundColor = [UIColor whiteColor];
    itemSpacing = 10;
    int colume = 3;
    cellW = (frame.size.width-8-itemSpacing*colume)/colume;
    cellH = cellW*(49/197.0);
    
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
           carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView  = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    self.collectionView.frame = CGRectMake(0, 0, frame.size.width, 2*(cellH+itemSpacing));
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
    [self addSubview:self.collectionView];
    
    float btnh = self.frame.size.height-(itemSpacing+cellH)*2;
    float btnw = 5.1*btnh;
    float starty = (itemSpacing+cellH)*2;
    float offsetH = 0;
    if(btnw*2>=self.frame.size.width){
        btnw = (self.frame.size.width-20)/2;
        offsetH = fabsf(btnh-btnw/5.5);
        btnh = btnw / 5.5;
    }
    if (offsetH>0) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-offsetH);
    }
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/child1_zc") forState:UIControlStateNormal];
    btn1.frame = CGRectMake(0, starty, btnw, btnh);
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(frame.size.width-btnw, starty, btnw,  btnh);
    [btn2 setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/child1_search") forState:UIControlStateNormal];
    [self addSubview:btn1];[self addSubview:btn2];
    [btn1 addTarget:self action:@selector(pressZc) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(presssearch) forControlEvents:UIControlEventTouchUpInside];

    return self;
}

-(void)pressZc{
    self.registe();
}

-(void)presssearch{
    self.search();
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        self.playRecord();
    }
    else if(indexPath.row==1){
        self.webHistory();
    }
    else if(indexPath.row==2){
        self.myFaritive();
    }
    else if(indexPath.row==3){
        self.zhibo();
    }
    else if(indexPath.row==4){
        self.help();
    }
    else if(indexPath.row==5){
        self.share();
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.listArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ContentCollection";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *image = UIImageFromNSBundlePngPath([self.listArray objectAtIndex:indexPath.row]);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [cell.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
   // imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    return cell;
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

@end
