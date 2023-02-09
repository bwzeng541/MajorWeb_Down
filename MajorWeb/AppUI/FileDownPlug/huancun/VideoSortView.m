//
//  VideoSortView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VideoSortView.h"
@interface VideoSortView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *sortVideoData;
@property(nonatomic,copy)NSString *selectKey;
@end

@implementation VideoSortView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:fallLayout];
    fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    fallLayout.minimumInteritemSpacing =1;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    [self.collectionView setCollectionViewLayout:fallLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"VideoSortCell"];
    [self addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    return self;
}

-(void)updateArray:(NSArray*)sortArray{
    self.sortVideoData = sortArray;
    [_collectionView reloadData];
}

-(void)updateSelect:(NSString*)key{
    self.selectKey = key;
    [_collectionView reloadData];
}


#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(click_video_sort_view:)]) {
        [self.delegate click_video_sort_view:[[self.sortVideoData objectAtIndex:indexPath.row] objectForKey:Sort_key_uuid]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
   
   
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.sortVideoData count];
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"VideoSortCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView= [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"huancun_btn_"];
    [cell.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(cell.contentView);
    }];
    
   UILabel* label = [[UILabel alloc]initWithFrame:CGRectZero];
    [cell.contentView addSubview:label];
     [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(cell.contentView);
    }];
    label.font = [UIFont systemFontOfSize:12];
    if ([[[self.sortVideoData objectAtIndex:indexPath.row] objectForKey:Sort_key_uuid] compare:self.selectKey]==NSOrderedSame) {
        label.textColor = RGBCOLOR(70,160, 255);
    }
    else{
        label.textColor = [UIColor whiteColor];
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [[self.sortVideoData objectAtIndex:indexPath.row] objectForKey:Sort_key_name];
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    NSString *text = [[self.sortVideoData objectAtIndex:indexPath.row] objectForKey:Sort_key_name];
    CGSize size = [text boundingRectWithSize:CGSizeMake(200,  200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font} context:nil].size;
    return CGSizeMake(size.width+20,collectionView.bounds.size.height-5);
    
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

@end
