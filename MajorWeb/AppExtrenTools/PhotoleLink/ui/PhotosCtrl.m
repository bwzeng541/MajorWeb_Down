//
//  PhotosCtrl.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "PhotosCtrl.h"
#import "PhotoLinkPlug.h"
#import "XG_AssetPickerController.h"
#import "XG_AssetModel.h"
#import "FLAnimatedImageView.h"
#import "PhotosAddCtrl.h"
#import "UIImage+ThrowScreenTools.h"
#import "PhotosAblmeView.h"
#import "ReactiveCocoa.h"
#import "DNLAController.h"
#import "TYAlertAction+TagValue.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "YSCHUDManager.h"
@interface PhotosCtrl ()<XG_AssetPickerManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,XG_AssetPickerControllerDelegate,PhotosAddCtrlDelegate,PhotosAblmeViewDelegate>{
    float cellW,cellH,itemSpacing;
    BOOL isEdit;
    NSInteger playSpeed;
}
@property(nonatomic,strong)PhotosAddCtrl *addCtrl;
@property(nonatomic,strong)NSMutableArray *ablumeArray;
@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;
@property(nonatomic,weak)IBOutlet UIButton *btnEdit;
@property(nonatomic,weak)IBOutlet UIView *topView;
@property(nonatomic,weak)IBOutlet UIView *lineView;
@property(nonatomic,weak)IBOutlet UIView *bottomView;
@property(nonatomic,weak)IBOutlet UIButton *btnBack;
@property(nonatomic,weak)IBOutlet UIImageView *linkImageView;
@property(nonatomic,weak)IBOutlet UIImageView *speedImageView;
@property(nonatomic,weak)IBOutlet UILabel *speedLabel;

@end

@implementation PhotosCtrl


-(void)photos_add_ctrl_will_remove{
    [self.addCtrl.view removeFromSuperview];
    self.addCtrl = nil;
    [self reloadData];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [[PhotoLinkPlug PhotoLinkPlug] stopPhotoServer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updatePlaySpeed:3];
    [[PhotoLinkPlug PhotoLinkPlug] startPhotoServer];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"AblumeCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    @weakify(self)
    self.speedImageView.userInteractionEnabled = YES;
    [self.speedImageView bk_whenTapped:^{
        @strongify(self)
        [self showSpeedAlter];
    }];
    
}

-(void)showSpeedAlter{
    TYAlertView *alertView = nil;
    alertView.buttonFont = [UIFont systemFontOfSize:14];
    PhotosCtrl * __weak weakSelf = self;
    alertView = [TYAlertView alertViewWithTitle:@"设置播放速度" message:@""];
    
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"退出"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                               }];
    [alertView addAction:v];
    for (int i = 0; i < 3; i++) {
        int j = (i+1)*2;
        TYAlertAction *tn  = [TYAlertAction actionWithTitle:[NSString stringWithFormat:@"%d秒",j]
                                                      style:TYAlertActionStyleDefault
                                                    handler:^(TYAlertAction *action) {
                                                        [weakSelf updatePlaySpeed:action.tagValue];
                                                    }];
        [alertView addAction:tn];
        tn.tagValue = j;
    }
    [alertView showInWindowWithBackgoundTapDismissEnable:YES];
}

-(void)initUI{
    itemSpacing = 10;
    cellW = (self.collectionView.bounds.size.width-itemSpacing*2)/2;
    cellH = cellW;
    // Do any additional setup after loading the view from its nib.
    [self reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (BOOL)xg_picker_manager_isAssetVaild:(PHAsset*)asset{
    if(asset.mediaType == PHAssetMediaTypeImage)
    return true;
    return false;
}

- (void)openAlbum{
    __weak typeof (self) weakSelf = self;
    isEdit = false;
    [self reloadData];
    [XG_AssetPickerManager manager].delagte = self;
    [[XG_AssetPickerManager manager] handleAuthorizationWithCompletion:^(XG_AuthorizationStatus aStatus) {
        if (aStatus == XG_AuthorizationStatusAuthorized) {
            [weakSelf showAssetPickerController];
        }else{
            [weakSelf showAlert];
        }
    }];
}

- (void)showAssetPickerController{
    XG_AssetPickerOptions *options = [[XG_AssetPickerOptions alloc]init];
    options.maxAssetsCount = 100;
    options.videoPickable = NO;
    options.pickedAssetModels = nil;
    XG_AssetPickerController *photoPickerVc = [[XG_AssetPickerController alloc] initWithOptions:options delegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)exportImageToLocal:(PHAsset*)asset assetKey:(NSString*)assetKey  dirName:(NSString*)dirName isAddIcon:(BOOL)isAddIcon{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    option.synchronous = YES;
    
    //小图标h这里是
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = cellW * multiple;
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
        NSString *uuid = [NSString uniqueString];
        for (int i = 0; i < assets.count; i++) {
            XG_AssetModel *model =  [assets objectAtIndex:i];
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

/*


 
 */
- (void)showAlert{
    TYAlertView *alertView = nil;
    alertView.buttonFont = [UIFont systemFontOfSize:10];
         alertView = [TYAlertView alertViewWithTitle:@"未开启相册权限，是否去设置中开启？" message:@""];
        
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"退出"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                   }];
    [alertView addAction:v];
    
    v  = [TYAlertAction actionWithTitle:@"设置"
                                  style:TYAlertActionStyleDefault
                                handler:^(TYAlertAction *action) {
                                    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                    if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                                        [[UIApplication sharedApplication] openURL:settingsURL];
                                    }
                                }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}


-(void)reloadData{
    NSArray *array = [[PhotoLinkPlug PhotoLinkPlug].photoCache allCacheKey];
    if (array.count>0) {
        self.ablumeArray = [NSMutableArray arrayWithArray:array];
    }
    [self.collectionView reloadData];
}

-(IBAction)pressBack:(UIButton*)sender{
    if([self.delegate respondsToSelector:@selector(willRemoveThrowLoad:)]){
        [self.delegate willRemoveThrowLoad:self];
    }
    else{    [self dismissViewControllerAnimated:YES completion:nil];}
}

-(void)updatePlaySpeed:(NSInteger)speed{
    playSpeed = speed;
    [[PhotoLinkPlug PhotoLinkPlug] changePlaySpeed:playSpeed];
    self.speedLabel.text = [NSString stringWithFormat:@"图片播放速度:%d秒",speed];
}


-(IBAction)pressEdit:(UIButton*)sender{
    isEdit = !isEdit;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoUpdateEdit" object:@(isEdit)];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return [self.ablumeArray count]+1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSpacing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellIdentifier = @"AblumeCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *arraySubView = [cell.contentView subviews];
    [arraySubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    if (indexPath.row==0) {
        imageView.image = [UIImage imageNamed:@"photo_add"];
    }
    else{
        PhotosAblmeView *view = [[PhotosAblmeView alloc] initWithFrame:cell.contentView.bounds];
        [view updateUUID:[self.ablumeArray objectAtIndex:indexPath.row-1] index:indexPath.row-1];
        view.delegate = self;
        imageView = view;
        cell.contentView.clipsToBounds = YES;
    }
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (0==indexPath.row) {
        [self openAlbum];
    }
    else{
    }
}


-(void)photos_ablme_add:(NSInteger)index{
    self.addCtrl= [[PhotosAddCtrl alloc] initWithNibName:@"PhotosAddCtrl" dirKey:[self.ablumeArray objectAtIndex:index]];
    self.addCtrl.view.frame = self.view.bounds;
    self.addCtrl.delegate = self;
    [self.addCtrl initUI];
    [self.view addSubview:self.addCtrl.view];
}

-(void)photos_ablme_exce:(BOOL)isPlay index:(NSInteger)index{
    if (isPlay) {
        [[PhotoLinkPlug PhotoLinkPlug] startLinkDir:[self.ablumeArray objectAtIndex:index]];
        [[PhotoLinkPlug PhotoLinkPlug] changePlaySpeed:playSpeed];
    }
    else{
        [[PhotoLinkPlug PhotoLinkPlug] removeAssetFromDirName:[self.ablumeArray objectAtIndex:index]];
        [self.ablumeArray removeObjectAtIndex:index];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index+1 inSection:0];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

@end
