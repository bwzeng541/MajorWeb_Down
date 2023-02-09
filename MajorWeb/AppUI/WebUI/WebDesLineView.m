//
//  WebDesLineView.m
//  WatchApp
//
//  Created by zengbiwang on 2017/11/28.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "WebDesLineView.h"
@interface WebDesLineView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *listArray;
@property(nonatomic,assign)NSInteger selectIndex;

@end
@implementation WebDesLineView


-(instancetype)init{
    self = [super init];
    return self;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    self.listArray = nil;
    self.collectionView = nil;
}

-(void)removeFromSuperview{
    self.linePipeBlock = nil;self.lineNoPipeBlock = nil;
    [super removeFromSuperview];
}

-(void)initPipeData:(NSArray*)array{
    if (!self.collectionView) {
        self.selectIndex = 0;
        UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
        CGRect rect = CGRectMake(2,0, self.bounds.size.width-4, self.bounds.size.height);
        self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:fallLayout];
        fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        fallLayout.minimumInteritemSpacing =1;
        [self.collectionView setCollectionViewLayout:fallLayout];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PipeLineCellView"];
        _collectionView.backgroundColor = RGBCOLOR(154, 30, 245);
        [self addSubview:_collectionView];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    self.listArray = array;
    [self.collectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"PipeLineCellView";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc]initWithFrame:cell.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
    if (self.selectIndex == indexPath.row) {
        label.backgroundColor = [UIColor blackColor];
    }
    else{
        label.backgroundColor = [UIColor clearColor];
    }
    label.textColor = [UIColor whiteColor];
    if(IF_IPHONE)
    label.font = [UIFont systemFontOfSize:10];
    else{
        label.font = [UIFont systemFontOfSize:15];
    }
    label.text = [NSString stringWithFormat:@"线路%ld",indexPath.row+1];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.linePipeBlock) {
        self.selectIndex = indexPath.row;
        [self.collectionView reloadData];
        self.linePipeBlock([self.listArray objectAtIndex:indexPath.row]);
    }
    else if (self.lineNoPipeBlock){
        self.selectIndex = indexPath.row;
        [self.collectionView reloadData];
        self.lineNoPipeBlock(indexPath.row);
    }
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listArray count];
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float hh = collectionView.bounds.size.height  ;
    float ww = hh;
    return CGSizeMake(ww*1.8, hh);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}
@end
