//
//  VideosCtrl.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/25.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VideosCtrl.h"
#import "XG_AssetPickerManager.h"
#import "XG_AlbumModel.h"
#import "XG_AssetCell.h"
#import "VideoPlayerManager.h"
#import "PhotoLinkPlug.h"
#import "YSCHUDManager.h"
#import "AppDelegate.h"
@interface VideosCtrl ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    float cellW,cellH;
}
@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;
@property(nonatomic,weak)IBOutlet UIButton *btnBack;
@property(nonatomic,weak)IBOutlet UIButton *btnHelp;
@property(nonatomic,weak)IBOutlet UIView *topView;
@property(nonatomic,weak)IBOutlet UIView *lineView;
@property(nonatomic,strong)NSMutableArray *assetArray;
@end

@implementation VideosCtrl

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [[PhotoLinkPlug PhotoLinkPlug] stopPhotoServer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[PhotoLinkPlug PhotoLinkPlug] startPhotoServer];
    self.btnHelp.hidden = YES;
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).mas_offset(GetAppDelegate.appStatusBarH);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom).mas_offset(5);
    }];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).mas_offset(GetAppDelegate.appStatusBarH-20);
        make.left.equalTo(self.view).mas_offset(10);
        make.right.equalTo(self.view).mas_offset(-10);
        make.top.equalTo(self.lineView.mas_bottom).mas_offset(19);
    }];
}

-(void)initUI{
    [self.collectionView registerNib:[UINib nibWithNibName:@"XG_AssetCell" bundle:nil] forCellWithReuseIdentifier:@"XG_AssetCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    cellW = (self.collectionView.bounds.size.width*0.9)/3;
    cellH = cellW;
    __weak typeof (self) weakSelf = self;
    [[XG_AssetPickerManager manager] handleAuthorizationWithCompletion:^(XG_AuthorizationStatus aStatus) {
        if (aStatus == XG_AuthorizationStatusAuthorized) {
            [weakSelf getVideoAsset ];
        }else{
            [weakSelf showAlert];
        }
    }];
}

-(IBAction)pressHelp:(id)sender{
    NSURL *url =  [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"投屏帮助" ofType:@"mov"]] ;
//    [[ThrowVideoManager getInstance] playWithUrl:[url absoluteString] title:@"投屏帮助" referer:nil saveInfo:nil replayMode:NO rect:DefalutVideoRect throwUrl:[url absoluteString]];
}

-(IBAction)pressBack:(id)sender{
    if([self.delegate respondsToSelector:@selector(willRemoveThrowLoad:)]){
        [self.delegate willRemoveThrowLoad:self];
    }
    else {
     [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)getVideoAsset{
    self.assetArray = [NSMutableArray arrayWithCapacity:10];
    __weak typeof (self) weakSelf = self;
    [[XG_AssetPickerManager manager] getAllVideo:^(NSArray<XG_AlbumModel *> *models) {
        for (int i = 0;i<models.count;i++) {
            XG_AlbumModel  *modelT = (XG_AlbumModel*)[models objectAtIndex:i];
            [weakSelf.assetArray addObjectsFromArray:modelT.assetArray];
        }
        [weakSelf.collectionView reloadData];
    }];
}

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




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return [self.assetArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XG_AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XG_AssetCell" forIndexPath:indexPath];
    XG_AssetModel *model = self.assetArray[indexPath.row];
    cell.model = model;
    cell.selectImageView.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [YSCHUDManager showHUDOnView:self.view message:@"资源导入中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XG_AssetModel *model = self.assetArray[indexPath.row];
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info)
         {
             NSString * sandboxExtensionTokenKey = info[@"PHImageFileSandboxExtensionTokenKey"];
             NSArray * arr = [sandboxExtensionTokenKey componentsSeparatedByString:@";"];
             NSString * filePath = [arr[arr.count - 1] pathExtension];
             AVURLAsset *urlAsset = (AVURLAsset *)asset;
             NSURL *url = urlAsset.URL;
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSString *file = [[PhotoLinkPlug PhotoLinkPlug] addVideThrow:[NSData dataWithContentsOfURL:url] fileName:[NSString stringWithFormat:@"tmp.%@",filePath]];
                 [[VideoPlayerManager getVideoPlayInstance] playWithUrl:[[NSURL fileURLWithPath:file] absoluteString] title:@"相册" referer:nil saveInfo:nil replayMode:NO rect:DefalutVideoRect throwUrl:[PhotoLinkPlug PhotoLinkPlug].photoLinkUrl isUseIjkPlayer:false];
                 [YSCHUDManager hideHUDOnView:self.view animated:YES];
             });
             
         }];
    });
}
@end
