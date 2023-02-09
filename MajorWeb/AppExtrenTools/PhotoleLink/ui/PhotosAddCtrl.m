//
//  PhotosAddCtrl.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "PhotosAddCtrl.h"
#import "XG_AssetPickerController.h"
#import "PhotoLinkPlug.h"
#import "SavePhotoInfo.h"
#import "SelectedAssetCell.h"
#import "YSCHUDManager.h"
@interface PhotosAddCtrl ()<XG_AssetPickerManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,XG_AssetPickerControllerDelegate>{
    float cellH,cellW,itemSpacing;
}
@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;
@property(nonatomic,weak)IBOutlet UIButton *btnBack;
@property(nonatomic,weak)IBOutlet UIButton *btnPlay;
@property(nonatomic,weak)IBOutlet UIView *topView;
@property(nonatomic,weak)IBOutlet UIView *bottomView;

@property(nonatomic,strong)NSMutableArray *assetArray;
@property(nonatomic,copy)NSString *dirUUID;
@end

@implementation PhotosAddCtrl

- (BOOL)xg_picker_manager_isAssetVaild:(PHAsset*)asset{
    if(asset.mediaType == PHAssetMediaTypeImage)
        return true;
    return false;
}


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(id)initWithNibName:(NSString *)nibNameOrNil  dirKey:(NSString*)dirKey{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    self.dirUUID = dirKey;
    return self;
}

-(IBAction)playDir:(id)sender{
    [[PhotoLinkPlug PhotoLinkPlug] startLinkDir:self.dirUUID];

}

-(IBAction)pressBack:(id)sender{
    if (self.assetArray.count==0) {
        [[PhotoLinkPlug PhotoLinkPlug] removeAssetFromDirName:self.dirUUID];
    }
    [self.delegate photos_add_ctrl_will_remove];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)initUI{
    //itemSpacing = 5
    cellW = (self.collectionView.bounds.size.width*0.9 )/3;
    cellH = cellW;
    [self.collectionView registerClass:[SelectedAssetCell class] forCellWithReuseIdentifier:@"SelectedAssetCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"addCell"];
    self.collectionView.delegate=self;
    self.collectionView.dataSource = self;
    CGRect rect = self.bottomView.bounds;
    //584*77
    float h = rect.size.height;
    float w = h*(640/77.0);
    _btnPlay.frame = CGRectMake((rect.size.width-w)/2, 0, w, h);
    [_btnPlay setImage:[UIImage imageNamed:@"photo_play_list"] forState:UIControlStateNormal];
    [self reloadData];
}

-(void)reloadData{
    NSArray *array = (NSArray*)[[PhotoLinkPlug PhotoLinkPlug].photoCache objectForKey:self.dirUUID];
    self.assetArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
}

-(void)exportImageToLocal:(PHAsset*)asset assetKey:(NSString*)assetKey  dirName:(NSString*)dirName isAddIcon:(BOOL)isAddIcon{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    option.synchronous = YES;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = cellW*2 * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        NSString *extName = [[[info objectForKey:@"PHImageFileURLKey"] absoluteString] pathExtension];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [[PhotoLinkPlug PhotoLinkPlug] addAssetToLocal:imageData iconImage:result assetKey:assetKey  extName:extName dirName:dirName  ];
            
        }
         ];
    }];
}

- (void)assetPickerController:(XG_AssetPickerController *)picker didFinishPickingAssets:(NSArray<XG_AssetModel *> *)assets{
    
    [YSCHUDManager showHUDOnView:self.view message:@"资源添加中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *uuid = self.dirUUID;
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *removeTmp = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < self.assetArray.count; i++) {
            BOOL isCanRemove = true;
            SavePhotoInfo *vv =  [self.assetArray objectAtIndex:i];
            for (int j = 0; j < assets.count; j++) {
                XG_AssetModel *mode = [assets objectAtIndex:j];
                if ([mode.asset.localIdentifier rangeOfString:vv.uuid].location!=NSNotFound) {
                    isCanRemove = false;
                    break;
                }
            }
            NSString *file = [[PhotoLinkPlug PhotoLinkPlug] getAssetToLocal:vv.fileName dirName:vv.dirName];
            if (isCanRemove) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
                    [[PhotoLinkPlug PhotoLinkPlug] removeAssetToLocal:vv.uuid fileName:vv.fileName dirName:vv.dirName];
                }
                [removeTmp addObject:vv];
            }
        }
        [self.assetArray removeObjectsInArray:removeTmp];
        
        for (int j = 0; j < assets.count; j++) {
            XG_AssetModel *mode = [assets objectAtIndex:j];
            BOOL isAdd = true;
            for (int i = 0; i < self.assetArray.count; i++) {
                SavePhotoInfo *pp =  [self.assetArray objectAtIndex:i];
                if ([mode.asset.localIdentifier rangeOfString:pp.uuid].location!=NSNotFound) {
                    isAdd = false;
                    break;
                }
            }
            if(isAdd)
                [tmpArray addObject:mode];
        }
        
        for (int i = 0; i < tmpArray.count; i++) {
            XG_AssetModel *model =  [tmpArray objectAtIndex:i];
            [self exportImageToLocal:model.asset assetKey:model.asset.localIdentifier  dirName:uuid isAddIcon:i==0];
        }
        [XG_AssetPickerManager manager].delagte = nil;
        [self reloadData];
        [YSCHUDManager hideHUDOnView:self.view animated:YES];
    });
  
}

- (void)assetPickerControllerDidCancel:(XG_AssetPickerController *)picker{
    
    [XG_AssetPickerManager manager].delagte = nil;
}

- (void)onDeleteBtnClick:(UIButton *)sender{
    SelectedAssetCell *cell = (SelectedAssetCell *)sender.superview.superview;
    NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];
    [self.collectionView performBatchUpdates:^{
        [cell removeAsset];
        [self.assetArray removeObjectAtIndex:indexpath.row];
        [self.collectionView deleteItemsAtIndexPaths:@[indexpath]];
 
    } completion:^(BOOL finished) {
        
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return [self.assetArray count]+1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellIdentifier = @"addCell";
    if (self.assetArray.count==indexPath.row) {
        UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.image = [UIImage imageNamed:@"add_pic"];
        NSArray *arraySubView = [cell.contentView subviews];
        [arraySubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cell.contentView addSubview:imageView];
        return cell;
    }
    else{
        SelectedAssetCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectedAssetCell" forIndexPath:indexPath];
        cell.model = [self.assetArray objectAtIndex:indexPath.row];
        cell.contentView.clipsToBounds = YES;
        [cell.deleteBtn addTarget:self action:@selector(onDeleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.assetArray.count==indexPath.row) {
        [self showAssetPickerController];
    }
    else{
        
    }
}
/*
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSpacing;
}*/

- (NSMutableArray*)syncPickedAssetModels:(NSArray*)array{
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < array.count; i++) {
       XG_AssetModel *v = [array objectAtIndex:i];
        for (int j = 0; j < self.assetArray.count; j++) {
           SavePhotoInfo *pp =  [self.assetArray objectAtIndex:j];
            if (v.asset && [v.asset.localIdentifier rangeOfString:pp.uuid].location!=NSNotFound) {
                [arrayTmp addObject:v];
                break;
            }
        }
    }
    return arrayTmp;
}

- (void)showAssetPickerController{
    XG_AssetPickerOptions *options = [[XG_AssetPickerOptions alloc]init];
    options.maxAssetsCount = 100;
    options.videoPickable = YES;
    NSMutableArray<XG_AssetModel *> *array = nil;
    [array removeLastObject];//去除占位model
    options.pickedAssetModels = array;
    XG_AssetPickerController *photoPickerVc = [[XG_AssetPickerController alloc] initWithOptions:options delegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];
    [(UIViewController*)self.view.superview.nextResponder  presentViewController:nav animated:YES completion:nil];
}

@end
