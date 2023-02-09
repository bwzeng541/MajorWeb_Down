//
//  HuanCunCtrl.m
//  WatchApp
//
//  Created by zengbiwang on 2018/4/27.
//  Copyright © 2018年 cxh. All rights reserved.
//
#if DoNotKMPLayerCanShareVideo
#else
#import "HuanCunCtrl.h"
#import "UcTableViewCell.h"
#import "AppDelegate.h"
#import "UIDevice+YSCKit.h"
#import "Toast+UIView.h"
#import "BlocksKit+UIKit.h"
#import "Masonry.h"
#import "VideoPlayerManager.h"
#import "FileDonwPlus.h"
#import "GetGoldView.h"
#import "MajorGoldManager.h"
#import "VideoPlayerManager+Down.h"
#import "BUDFeedAdTableViewCell.h"
#import <BUAdSDK/BUAdSDK.h>
#import "WebDesListView.h"
#import "IQUIWindow+Hierarchy.h"
#import "VipPayPlus.h"
#import "TmpSetView.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"
#import "FileWebDownLoader.h"
#import "MarjorWebConfig.h"
#import "YTKNetworkPrivate.h"
#import "MainMorePanel.h"
#import "YYCache.h"
#import "VideoSortView.h"
#import "UIAlertAction+MajorValue.h"
#import "MajorPermissions.h"
#import "helpFuntion.h"
static YYCache *sortCache = nil;


#define HuanCunGukanCilck [NSString stringWithFormat:@"%@/huankanclicksfsf",VIDEOCACHESROOTPATH]
@interface HuanCunCtrl ()<BUNativeAdsManagerDelegate,BUNativeAdDelegate,BUVideoAdViewDelegate,VideoSortViewDelegate>
@property(strong,nonatomic)BUNativeAdsManager *adManager;
@property(strong,nonatomic)UIView *adNativeView;
@property(strong,nonatomic)NSMutableArray *nativeAdDataArray;
@property(strong,nonatomic)NSString *cellID;
@property(strong,nonatomic)IBOutlet UILabel *toplabelDes;
@property(strong,nonatomic)IBOutlet UILabel *goldlabelDes;
@property(strong,nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)IBOutlet UIButton *btnBack;
@property(strong,nonatomic)IBOutlet UIButton *btnEdit;
@property(strong,nonatomic)IBOutlet UIImageView *killImageView;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(strong,nonatomic)NSMutableArray *dataKeyArray;
@property(strong,nonatomic)NSMutableArray *showKeyArray;
@property(strong,nonatomic)NSMutableDictionary *clickInfo;
@property(strong,nonatomic)MBProgressHUD *videoPrgress;
@property(strong,nonatomic)NSTimer *videoExportTimer;
@property(assign,nonatomic)BOOL isEdit;
@property(copy,nonatomic)NSString* videoExportMsg;
@property(assign,nonatomic)float exportProgress;
@property(assign,nonatomic)float stepProgress;
@property(strong,nonatomic)UIView *maskVipView;
@property(strong,nonatomic)IBOutlet UIView *bottomView;
@property(strong,nonatomic)IBOutlet UIButton *btnCreateDir;
@property(strong,nonatomic)IBOutlet UIButton *btnDelDir;
@property(copy,nonatomic)NSString *sortKey;
@property(strong,nonatomic)VideoSortView *sortVideoView;
@property(assign,nonatomic)BOOL isSaveOperation;
@end

@implementation HuanCunCtrl

+(void)sycnSortTable{
    //sortCache = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/videoSortTable",VIDEOCACHESROOTPATH]];
}

-(void)dealloc{
    GetAppDelegate.globalWebDesList.alpha = 1;
    NSLog(@"%s",__FUNCTION__);
}

-(IBAction)pressBack:(id)sender{
    [self.videoExportTimer invalidate];self.videoExportTimer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.delegate hc_back_Event];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickBack" object:nil];
}

-(IBAction)pressEdit:(id)sender{
    self.isEdit = !self.isEdit;
    if(self.isEdit &&  [[VipPayPlus getInstance] isCanPlayVideoAd:false]){
        /*20200214取消广告
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
        [[VipPayPlus getInstance] tryPlayVideoAd:false block:^(BOOL isSuccess) {
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
        }];*/
    }
    if (self.isEdit) {
        [_btnEdit setTitle:@"取消" forState:UIControlStateNormal];
    }
    else{
        [_btnEdit setTitle:@"删除" forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UcBtnTitleChangeNotifi object:[NSNumber numberWithBool:self.isEdit]];
}

- (void)reloadAllData{
    self.dataArray = [NSMutableArray arrayWithArray:[[AppWtManager getInstanceAndInit]getWtCallBack:DOWNAPICONFIG.msgappf10]];
    self.dataKeyArray = [NSMutableArray arrayWithArray:[[AppWtManager getInstanceAndInit] getWtCallBack:DOWNAPICONFIG.msgappf4]];
    self.showKeyArray = [NSMutableArray arrayWithCapacity:10];
    [self.dataKeyArray addObjectsFromArray:[[AppWtManager getInstanceAndInit]getWtCallBack:DOWNAPICONFIG.msgappf13]];
    [self.dataArray addObjectsFromArray:[[AppWtManager getInstanceAndInit]getWtCallBack:DOWNAPICONFIG.msgappf14]];
    [self updateSyncSort];
    [self reloadCellAdView];
}

//同步key值
-(void)updateSyncKey{
    NSMutableArray *array = [NSMutableArray arrayWithObject:@{Sort_key_uuid:HuanCunDirKey,Sort_key_name:@"下载管理"}];
   NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    if (arrayRet.count>0) {
        [array addObjectsFromArray:arrayRet];
    }
    [_sortVideoView updateArray:array];
}

//同步类别
-(void)updateSyncSort{
    [self.showKeyArray removeAllObjects];
    self.toplabelDes.text = @"文件夹未知错误";
    self.btnDelDir.hidden = NO;
    NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    if ([self.sortKey compare:HuanCunDirKey]==NSOrderedSame) {
        self.toplabelDes.text = @"下载管理";
        self.btnDelDir.hidden = YES;
    }
    else{
        for (int i = 0; i < arrayRet.count; i++) {
            if(self.sortKey && [[[arrayRet objectAtIndex:i] objectForKey:Sort_key_uuid]compare:self.sortKey]==NSOrderedSame){
                self.toplabelDes.text = [[arrayRet objectAtIndex:i] objectForKey:Sort_key_name];
                break;
            }
        }
    }
    //过滤无效值
    for(int i = 0 ;i < self.dataKeyArray.count;i++){
        if ([self.sortKey compare:HuanCunDirKey]==NSOrderedSame) {
            //找到所有不在sortCache里面的值
            BOOL isCanAdd = true;
            for (int j = 0; j < arrayRet.count; j++) {
                NSString *keyValue = [NSString stringWithFormat:@"%@_%@",[self.dataKeyArray objectAtIndex:i],[[arrayRet objectAtIndex:j] objectForKey:Sort_key_uuid]];
                if([sortCache objectForKey:keyValue]){
                    isCanAdd  = false;
                    break;
                }
            }
            if (isCanAdd) {
                [self.showKeyArray addObject:[self.dataKeyArray objectAtIndex:i]];
            }
        }
        else{
            //找到在里面的值
            BOOL isCanAdd = false;
                 NSString *keyValue = [NSString stringWithFormat:@"%@_%@",[self.dataKeyArray objectAtIndex:i],self.sortKey];
                if([sortCache objectForKey:keyValue]){
                    isCanAdd  = true;
                 }
            if (isCanAdd) {
                [self.showKeyArray addObject:[self.dataKeyArray objectAtIndex:i]];
            }
        }
    }
    [self.tableView reloadData];
    [_sortVideoView updateSelect:self.sortKey];
}

- (void)reloadCellAdView{
    if (self.nativeAdDataArray.count>0) {
        [self.adNativeView removeFromSuperview];
        BUNativeAd *nativeAd = [self.nativeAdDataArray objectAtIndex:arc4random()%self.nativeAdDataArray.count];
        float h =  [self nativeAdHeight:nativeAd];
        BOOL isVideoCell = NO;
        nativeAd.rootViewController = [[UIApplication sharedApplication].keyWindow currentViewController];
        nativeAd.delegate = self;
        UITableViewCell<BUDFeedCellProtocol> *cell = nil;
        NSString *className = nil;
        if (nativeAd.data.imageMode == BUFeedADModeSmallImage) {
           className = @"BUDFeedAdLeftTableViewCell";
        } else if (nativeAd.data.imageMode == BUFeedADModeLargeImage) {
            className = @"BUDFeedAdLargeTableViewCell";
        } else if (nativeAd.data.imageMode == BUFeedADModeGroupImage) {
            className = @"BUDFeedAdGroupTableViewCell";
        } else if (nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
            // 设置代理，用于监听播放状态
            className = @"BUDFeedVideoAdTableViewCell";
            isVideoCell = YES;
        }
        cell = [[NSClassFromString(className) alloc] init];
        float offsetFixY = self.goldlabelDes.frame.origin.y+self.goldlabelDes.frame.size.height;
        [cell setFrame:CGRectMake(0, offsetFixY, MY_SCREEN_WIDTH, h)];
        [self configCell:nativeAd cell:cell isVideo:isVideoCell];
        self.adNativeView = cell;
        BUDFeedAdBaseTableViewCell*cellVV = (BUDFeedAdBaseTableViewCell*)cell;
        cellVV.iv1.frame = CGRectMake(0, 0, MY_SCREEN_WIDTH, h);
        cellVV.separatorLine.hidden =
        cellVV.adTitleLabel.hidden =
        cellVV.adDescriptionLabel.hidden = NO;
        cellVV.nativeAdRelatedView.dislikeButton.hidden =
        cellVV.nativeAdRelatedView.adLabel.hidden =
        cellVV.nativeAdRelatedView.logoImageView.hidden =
        cellVV.nativeAdRelatedView.logoADImageView.hidden = NO;
        [self.view addSubview:self.adNativeView];
        CGRect rect = self.tableView.frame;
        self.tableView.frame = CGRectMake(rect.origin.x,cell.frame.origin.y+h, rect.size.width, self.killImageView.frame.origin.y-cell.frame.origin.y-h);
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startToBatchVideoCaches" object:nil];
    GetAppDelegate.globalWebDesList.alpha = 0;
    sortCache = nil;
    if (!sortCache) {
        sortCache = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/videoSortTable",VIDEOCACHESROOTPATH]];
    }
    self.sortKey = HuanCunDirKey;
    [[AppWtManager getInstanceAndInit]getWtCallBack:DOWNAPICONFIG.msgappf0];
    // Do any additional setup after loading the view from its nib.
    float offsetFixY = GetAppDelegate.appStatusBarH-20;
    self.cellID = @"sfsf";
    self.toplabelDes.text = @"下载管理";
    CGRect rect = self.toplabelDes.frame;
    rect.origin = CGPointMake(rect.origin.x, rect.origin.y+offsetFixY);
    self.toplabelDes.frame = rect;
    
    rect = self.goldlabelDes.frame;
    rect.origin = CGPointMake(rect.origin.x, rect.origin.y+offsetFixY);
    self.goldlabelDes.frame = rect;
    
    rect = self.tableView.frame;
    rect.origin = CGPointMake(rect.origin.x, rect.origin.y+offsetFixY);
    self.tableView.frame = rect;
    
    rect = self.btnBack.frame;
    rect.origin = CGPointMake(rect.origin.x, rect.origin.y+offsetFixY);
    self.btnBack.frame = rect;
    
    rect = self.btnEdit.frame;
    rect.origin = CGPointMake(rect.origin.x, rect.origin.y+offsetFixY);
    self.btnEdit.frame = rect;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([UcTableViewCell class]) bundle:nil] forCellReuseIdentifier:self.cellID];
    //广告cellView
    [self.tableView registerClass:[BUDFeedAdLeftTableViewCell class] forCellReuseIdentifier:@"BUDFeedAdLeftTableViewCell"];
    [self.tableView registerClass:[BUDFeedAdLargeTableViewCell class] forCellReuseIdentifier:@"BUDFeedAdLargeTableViewCell"];
    [self.tableView registerClass:[BUDFeedAdGroupTableViewCell class] forCellReuseIdentifier:@"BUDFeedAdGroupTableViewCell"];
    [self.tableView registerClass:[BUDFeedAdGroupTableViewCell class] forCellReuseIdentifier:@"BUDFeedVideoAdTableViewCell"];
    //end
    self.clickInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:HuanCunGukanCilck];
    if (info) {
        [self.clickInfo setDictionary:info];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateDataChange:) name:@"updateDataChange" object:nil];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).mas_offset(-(GetAppDelegate.appStatusBarH-20));
        make.width.mas_equalTo(MY_SCREEN_WIDTH);
        make.height.mas_equalTo(32);
    }];
    //640X53
    float killImageViewH = 31.0/640* MY_SCREEN_WIDTH;
    [self.killImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
        make.width.mas_equalTo(MY_SCREEN_WIDTH);
        make.height.mas_equalTo(killImageViewH);
    }];
    rect = self.tableView.frame;
    //self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.view.bounds.size.height-killImageViewH-rect.origin.y);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(MY_SCREEN_WIDTH);
        make.top.mas_equalTo(rect.origin.y);
        make.bottom.equalTo(self.killImageView.mas_top);
    }];
    self.sortVideoView = [[VideoSortView alloc] initWithFrame:CGRectZero];
    [self.bottomView addSubview:self.sortVideoView];
    self.sortVideoView.delegate = self;
    [self.sortVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.bottomView);
        make.right.equalTo(self.btnCreateDir.mas_left).mas_offset(-10);
    }];
    [self updateSyncKey];
    @weakify(self)
    
    [self update4GDownState];
    [self.killImageView bk_whenTapped:^{
//        @strongify(self)
//        [MarjorWebConfig getInstance].isAllows4GDownMode = ![MarjorWebConfig getInstance].isAllows4GDownMode;
//        [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
//        [self update4GDownState];
//        if ([MarjorWebConfig getInstance].isAllows4GDownMode) {
//            [self.view makeToast:@"已经开启4G网络下载视频" duration:1 position:@"center"];
//        }
//        else{
//            [self.view makeToast:@"关闭4G网络下载" duration:1 position:@"center"];
//        }
    }];
   /* [RACObserve([VipPayPlus getInstance],isLogin) subscribeNext:^(id x) {
        if (![VipPayPlus getInstance].systemConfig.vip && ![[VipPayPlus getInstance] isVaildOperationCheck:@"HuanCunCtrl"]) {
            GetAppDelegate.backGroundDownMode = false;
        }
    }];*/
    
    if( GetAppDelegate.fileWebDown.running){//用电脑访问下面网址，就可以把手机视频导出到电脑
        NSString *url = [NSString stringWithFormat:@"http://%@:%lu",[GetAppDelegate.fileWebDown.serverURL host],(unsigned long)GetAppDelegate.fileWebDown.port ];
        self.goldlabelDes.text = [NSString stringWithFormat:@"用电脑访问网址%@,就可以把手机视频导出到电脑",url];
    }
    else{
        self.goldlabelDes.text = @"服务器启动失败，需要同一个WIFI下面，请重启APP";
    }
    [self loadNativeAds];
   // [self showVipTest];
    [self reloadAllData];
    //进来直接弹视频
    [self showFullVideoAd];
}

-(void)showFullVideoAd{
    if([[VipPayPlus getInstance]isCanShowFullVideo]){
           [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
           [[VipPayPlus getInstance] tryShowFullVideo:^{
             [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
               [[VipPayPlus getInstance] tryPlayVideoFinish];
           }];
        }
       else{
       }
}

-(void)showVipTest{
    if([VipPayPlus getInstance].systemConfig.vip==Recharge_User)return;
    if([[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:@"HuanCunCtrl" nCount:1 isUseYYCache:NO time:nil])return;
    if (!self.maskVipView) {
        self.maskVipView = [[UIView alloc] init];
        [self.view addSubview:_maskVipView];
        [self.maskVipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        self.maskVipView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        self.maskVipView.userInteractionEnabled = YES;
    }
    @weakify(self)
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"看视频广告,获得功能" message:nil];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                             style:TYAlertActionStyleCancel
                                           handler:^(TYAlertAction *action) {
                                               @strongify(self)
                                               [self pressBack:nil];
                                           }];
    [alertView addAction:v];
    TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"YES"
                                              style:TYAlertActionStyleDefault
                                            handler:^(TYAlertAction *action) {
                                                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
                                                [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                    @strongify(self)
                                                    if (isSuccess) {
                                                        [[helpFuntion gethelpFuntion] isValideOneDay:@"HuanCunCtrl" nCount:1 isUseYYCache:NO time:nil];
                                                       // GetAppDelegate.isWatchHomeVideo = true;
                                                    }
                                                    [self.maskVipView removeFromSuperview];
                                                    self.maskVipView = nil;
                                                    [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                                                 }isShowAlter:true isForce:false];
                                            }];
    [alertView addAction:v1];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}

- (void)update4GDownState{
    self.killImageView.image = [UIImage imageNamed:@"bround_down_pic"] ;
}

- (void)loadNativeAds {
    if (!GetAppDelegate.isWatchHomeVideo && [VipPayPlus getInstance].systemConfig.vip==General_User) {
        BUNativeAdsManager *nad = [BUNativeAdsManager new];
        BUAdSlot *slot1 = [[BUAdSlot alloc] init];
        slot1.ID = @"908710121";
        slot1.AdType = BUAdSlotAdTypeFeed;
        slot1.position = BUAdSlotPositionTop;
        slot1.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
        slot1.isSupportDeepLink = YES;
        nad.adslot = slot1;
        nad.delegate = self;
        self.adManager = nad;
        [nad loadAdDataWithCount:3];
    }
}

- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    self.nativeAdDataArray = [[NSMutableArray alloc] initWithArray:nativeAdDataArray];
    [self reloadCellAdView];
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error{
    
}

-(void)updateDataChange:(NSNotification*)object{
    [self reloadAllData];
}

-(void)delFileFromCell:(NSString*)uuid url:(NSString*)url title:(NSString*)title{
    [self delFileFromKey:uuid];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:url,@"parma0",[NSString stringWithFormat:@"%@",title],@"parma1", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:DOWNAPICONFIG.msgapp2 object:info];
    NSMutableDictionary *infoPost =  [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf17];
    [infoPost setObject:@[uuid] forKey:@"param4"];
    [[AppWtManager getInstanceAndInit] getWtCallBack:infoPost];
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self reloadAllData];
                   });
}

-(void)delFileFromKey:(NSString*)uuid{
    [self removeFormCache:uuid];
    [self removeDataNotReload:uuid];
}

-(void)removeDataNotReload:(NSString*)uuid{
    [self.clickInfo removeObjectForKey:uuid];
    [self.clickInfo writeToFile:HuanCunGukanCilck atomically:YES];
    NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf15];
    [info setObject:@[uuid] forKey:@"param4"];
    [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf11];
    [info setObject:@[uuid] forKey:@"param4"];
    [[AppWtManager getInstanceAndInit] getWtCallBack:info];
}

-(BOOL)delFileFromUUID:(NSString*)uuid{
 //   dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self delFileFromKey:uuid];
   //     dispatch_async(dispatch_get_main_queue()
     //                  , ^{
                           [self reloadAllData];
       //                });
    //});
    return true;
}
-(BOOL)huanZcunEvent:(NSInteger)type uuid:(NSString*)uuid{
    if (!self.isEdit) {
        return false;
    }
    return [self delFileFromUUID:uuid];
}

-(NSString*)getRealLocalPath:(NSString*)path name:(NSString*)name uuid:(NSString*)uuid{
    if ([path rangeOfString:@"/Web/videopath"].location!=NSNotFound) {
        NSString *fixbug = [path stringByReplacingOccurrencesOfString:@".m3u8" withString:@"/1.ts"];
        path = [VideoPlayerManager tryToPathConvert:path uuid:uuid];
        if (![[NSFileManager defaultManager]fileExistsAtPath:path] || [[NSFileManager defaultManager]fileExistsAtPath:fixbug]) {
            //reDownAlter
            NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf28];
            [info setObject:@[uuid,[NSString stringWithFormat:@"%@无法播放",name]] forKey:@"param4"];
            [[AppWtManager getInstanceAndInit] getWtCallBack:info];
            return nil;
        }
    }
    return path;
}

-(void)playFromHuanCun:(NSString*)path name:(NSString*)name uuid:(NSString*)uuid{
//   NSString *path1  = [NSString stringWithFormat:@"http://localhost:%d/%@/%@.m3u8",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,uuid];
//    NSString *path2 = [self getRealLocalPath:path name:name uuid:uuid];
//    if ([[NSFileManager defaultManager]fileExistsAtPath:path2]) {
//        path = path2;
//    }
//    else{
//        path= path1;
//    }
    path = [self getRealLocalPath:path name:name uuid:uuid];
    if (path) {
        [self.clickInfo setObject:[NSMutableDictionary dictionaryWithCapacity:1] forKey:uuid];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.clickInfo writeToFile:HuanCunGukanCilck atomically:YES];
        });
        if ([path rangeOfString:@"http://"].location != NSNotFound) {
            [self playHuanCun:[NSURL URLWithString:path] name:name];
        }
        else{
            [self playHuanCun:[NSURL fileURLWithPath:path] name:name];
        }
    }
}

#pragma mark--保存视频
- (void)saveVideo:(NSString*)path name:(NSString*)name uuid:(NSString*)uuid{
    path = [self getRealLocalPath:path name:name uuid:uuid];
    if (path) {
        __weak typeof(self)weakSelf = self;
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied) {
            [weakSelf.view makeToast:@"请求设置中打开保存图片权限" duration:1 position:@"center"];
        } else if(status == PHAuthorizationStatusNotDetermined){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                     [weakSelf saveSuccessWithAlter:path];
                    });
                } else {
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized){
            dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf saveSuccessWithAlter:path];
            });
        }
    }
    else{
        [self.view makeToast:@"未知错误无法保存" duration:1 position:@"center"];
    }
}

- (void)saveSuccessWithAlter:(NSString*)path{
    
    BOOL ret = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path);
    NSString *vv = NSStringFromClass([self.view.superview.superview class]);
    BOOL isCreateNew = [vv isEqualToString:@"MajorSetView"];
    __weak typeof(self)weakSelf = self;
    if (ret) {
        //保存相册核心代码
        [weakSelf showFullVideoAd];
        [weakSelf saveVideoOpertion:path];
       /* TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否把视频导出到相册" message:nil];
        TYAlertAction *quxiao  = [TYAlertAction actionWithTitle:@"取消"
                                                          style:TYAlertActionStyleCancel
                                                        handler:^(TYAlertAction *action) {
                                                            
                                                        }];
        [alertView addAction:quxiao];
        if ([VipPayPlus getInstance].systemConfig.vip!=General_User) {
            TYAlertAction *daochu  = [TYAlertAction actionWithTitle:@"导出"
                                                              style:TYAlertActionStyleDefault
                                                            handler:^(TYAlertAction *action) {
                                                                [weakSelf saveVideoOpertion:path];
                                                            }];
            [alertView addAction:daochu];
        }
        else{
            TYAlertAction *daochu1  = [TYAlertAction actionWithTitle:@"开通会员"
                                                              style:TYAlertActionStyleDefault
                                                            handler:^(TYAlertAction *action) {
                                                                if (!isCreateNew) {
                                                                    [[VipPayPlus getInstance] show:false];
                                                                }
                                                                [TmpSetView hidenTmpSetView];
                                                            }];
            [alertView addAction:daochu1];
            
            TYAlertAction *daochu  = [TYAlertAction actionWithTitle:@"看视频广告导出"
                                                          style:TYAlertActionStyleDefault
                                                        handler:^(TYAlertAction *action) {
                                                            [weakSelf saveVideoOpertion:path];
                                                        }];
            [alertView addAction:daochu];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
        });*/
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"未知错误无法保存" duration:1 position:@"center"];
        });
    }
}

-(void)saveVideoOpertion:(NSString*)path{
    float maxTime = 90;
  //  if ([VipPayPlus getInstance].systemConfig.vip!=General_User) {
        maxTime = 2;
    //}
    self.isSaveOperation = false;
    if ( !self.videoPrgress) {//90秒最大视频时间
        self.exportProgress = 0;
        self.stepProgress = 1.0/maxTime;
        self.videoPrgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.videoExportTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateVideoExportProgress:)  userInfo:nil repeats:YES];
    }
    self.videoPrgress.label.text = @"视频转换中...";
    self.videoPrgress.mode = MBProgressHUDModeDeterminateHorizontalBar;
    [self.videoPrgress showAnimated:YES];
    if ([VipPayPlus getInstance].systemConfig.vip!=Recharge_User && [[VipPayPlus getInstance] isCanPlayVideoAd2]) {
        __weak typeof(self)weakSelf = self;
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
        [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
            [weakSelf updateleaveTime:isSuccess path:path];
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
        }isShowAlter:true isForce:false];
    }
    else{
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        self.isSaveOperation = true;
    }
}

-(void)updateleaveTime:(BOOL)isSuccess path:(NSString*)path{
    if(self.videoPrgress||!self.isSaveOperation)
    {
        self.isSaveOperation = true;
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        self.videoPrgress.label.text = @"视频导出到相册中...";
        self.stepProgress =  (1-self.videoPrgress.progress)/3.0;
    }
}

-(void)updateVideoExportProgress:(NSTimer*)timer{
    self.videoPrgress.progress += self.stepProgress;
    if (self.videoPrgress.progress>=1) {
        [self.videoExportTimer invalidate];
        self.videoExportTimer = nil;
        [self.videoPrgress hideAnimated:YES];
        RemoveViewAndSetNil(self.videoPrgress);
        [self.view makeToast:self.videoExportMsg duration:1 position:@"center"];
    }
    else if(self.videoPrgress.progress>0.5){
        self.videoPrgress.label.text = @"视频导出到相册中...";
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        self.videoExportMsg = [NSString stringWithFormat:@"保存视频失败%@", error.localizedDescription];
        [self.view makeToast:self.videoExportMsg duration:1 position:@"center"];
    }
    else {
        self.videoExportMsg = @"保存视频成功";
    }
}
//end

-(void)playHuanCun:(NSURL*)urlPath name:(NSString*)name{
    [[VideoPlayerManager getVideoPlayInstance] playWithUrl:[urlPath absoluteString] title:name referer:nil saveInfo:nil replayMode:false  rect:CGRectZero throwUrl:nil isUseIjkPlayer:false];
}

-(id)findObjectFromKey:(NSString*)key{
    id object = nil;
    for (NSInteger i=0; i < self.dataArray.count; i++) {
        object = [self.dataArray objectAtIndex:i];
        if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSClassFromString(@"GuanliNSDictionary") class]]) {
            NSString *_uuid  = [object objectForKey:StateUUIDKEY];
            NSString *_uuid2  = [object objectForKey:key];
            if (_uuid && [_uuid compare:key]==NSOrderedSame) {
                object = [self.dataArray objectAtIndex:i];
                break;
            }
            else if (_uuid2){
                object = _uuid2;
                break;
            }
        }
        else{
            break;
        }
    }
    return object;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.showKeyArray objectAtIndex:indexPath.row];
    id value = [self findObjectFromKey:key];
    if (![value isKindOfClass:[BUNativeAd class]]) {
        UcTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell tryPlay];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{;
    return self.showKeyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [self.showKeyArray objectAtIndex:indexPath.row];
    UITableViewCell *retCell;
    id value = [self findObjectFromKey:key];
    if (![value isKindOfClass:[BUNativeAd class]]) {
        UcTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellID];
        if(cell == nil)
        {
            cell = (UcTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:self.cellID];
        }
        [cell initCellInfo:value];
        __weak typeof(self)weakSelf = self;
        cell.clickBlock = ^BOOL(NSInteger type,NSString*uuid) {
            return [weakSelf huanZcunEvent:type uuid:uuid];
        };
        cell.getEditBlock = ^BOOL{
            return weakSelf.isEdit;
        };
        cell.playBlock  = ^(NSString*path,NSString*name,NSString *uuid) {
            [weakSelf playFromHuanCun:path name:name uuid:uuid];
        };
        cell.playValueBlock = ^NSDictionary*(NSString *uuir) {
            return [weakSelf.clickInfo objectForKey:uuir];
        };
        cell.delValueBlock = ^(NSString *uuid) {
            [weakSelf showFullVideoAd];
            [weakSelf delFileFromUUID:uuid];
        };
        cell.saveBlock = ^(NSString*path,NSString*name,NSString *uuid) {
            [weakSelf saveVideo:path name:name uuid:uuid];
        };
        cell.reDownBlock = ^(NSString *url, NSString *name, NSString *uuid) {
            [weakSelf delFileFromCell:uuid  url:url title:name];
        };
        cell.jionDirBlock = ^(NSString *uuid) {
            [weakSelf  jionDir:uuid];
        };
        [cell updateBtnEdit:_isEdit];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        retCell = cell;
    }
    else {
            BOOL isVideoCell = NO;
            BUNativeAd *nativeAd = (BUNativeAd *)value;
        id  vvv = [[UIApplication sharedApplication].keyWindow currentViewController];
            nativeAd.rootViewController = vvv;
            nativeAd.delegate = self;
            UITableViewCell<BUDFeedCellProtocol> *cell = nil;
            if (nativeAd.data.imageMode == BUFeedADModeSmallImage) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"BUDFeedAdLeftTableViewCell" forIndexPath:indexPath];
            } else if (nativeAd.data.imageMode == BUFeedADModeLargeImage) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"BUDFeedAdLargeTableViewCell" forIndexPath:indexPath];
            } else if (nativeAd.data.imageMode == BUFeedADModeGroupImage) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"BUDFeedAdGroupTableViewCell" forIndexPath:indexPath];
            } else if (nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"BUDFeedVideoAdTableViewCell" forIndexPath:indexPath];
                // 设置代理，用于监听播放状态
                isVideoCell = YES;
            }
            [self configCell:nativeAd cell:cell isVideo:isVideoCell];
            return cell;
    }
    return retCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [self.showKeyArray objectAtIndex:indexPath.row];
    id value = [self findObjectFromKey:key];
    if ([value isKindOfClass:[BUNativeAd class]]) {
        BUNativeAd *nativeAd = (BUNativeAd *)value;
        return  [self nativeAdHeight:nativeAd];
    }
    return 81;
}


-(void)configCell:(BUNativeAd*)nativeAd cell:( UITableViewCell<BUDFeedCellProtocol> *)cell isVideo:(BOOL)isVideoCell{
    BUInteractionType type = nativeAd.data.interactionType;
    if (cell) {
        [cell refreshUIWithModel:nativeAd];
        if (isVideoCell) {
            BUDFeedVideoAdTableViewCell *videoCell = (BUDFeedVideoAdTableViewCell *)cell;
            videoCell.nativeAdRelatedView.videoAdView.delegate = self;
            [nativeAd registerContainer:videoCell withClickableViews:@[videoCell.creativeButton]];
        } else {
            if (type == BUInteractionTypeDownload) {
                [cell.customBtn setTitle:@"点击下载" forState:UIControlStateNormal];
                [nativeAd registerContainer:cell withClickableViews:@[cell.customBtn]];
            } else if (type == BUInteractionTypePhone) {
                [cell.customBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
                [nativeAd registerContainer:cell withClickableViews:@[cell.customBtn]];
            } else if (type == BUInteractionTypeURL) {
                [cell.customBtn setTitle:@"外部拉起" forState:UIControlStateNormal];
                [nativeAd registerContainer:cell withClickableViews:@[cell.customBtn]];
            } else if (type == BUInteractionTypePage) {
                [cell.customBtn setTitle:@"内部拉起" forState:UIControlStateNormal];
                [nativeAd registerContainer:cell withClickableViews:@[cell.customBtn]];
            } else {
                [cell.customBtn setTitle:@"无点击" forState:UIControlStateNormal];
            }
        }
    }
}

-(float)nativeAdHeight:(BUNativeAd*)nativeAd{
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    if (nativeAd.data.imageMode == BUFeedADModeSmallImage) {
        return [BUDFeedAdLeftTableViewCell cellHeightWithModel:nativeAd width:width height:0];
    } else if (nativeAd.data.imageMode == BUFeedADModeLargeImage) {
        return [BUDFeedAdLargeTableViewCell cellHeightWithModel:nativeAd width:width height:0];
    } else if (nativeAd.data.imageMode == BUFeedADModeGroupImage) {
        return [BUDFeedAdGroupTableViewCell cellHeightWithModel:nativeAd width:width height:0];
    } else if (nativeAd.data.imageMode == BUFeedVideoAdModeImage) {
        return [BUDFeedVideoAdTableViewCell cellHeightWithModel:nativeAd width:width height:0];
    }
    return 50;
}

#pragma mark --createDir

-(IBAction)pressDelDir:(id)sender{
    __weak typeof(self) wself = self;
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"删除此文件夹" message:@"同时将删除该文件夹下所有视频"];
   
   TYAlertAction * v = [TYAlertAction actionWithTitle:@"确定?"
                             style:TYAlertActionStyleDestructive
                           handler:^(TYAlertAction *action) {
                               [wself delDirFromUUID:self.sortKey];
                           }];
    [alertView addAction:v];
    
     v  = [TYAlertAction actionWithTitle:@"NO"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                                   
                                               }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}

-(void)delDirFromUUID:(NSString*)uuid{
    NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    NSMutableArray *arrayOp = [NSMutableArray arrayWithCapacity:1];
    if(arrayRet.count>0){
        [arrayOp addObjectsFromArray:arrayRet];
    }
    for (int i = 0; i < arrayOp.count; i++) {
        if ([[[arrayOp objectAtIndex:i] objectForKey:Sort_key_uuid] compare:uuid]==NSOrderedSame) {
            [arrayOp removeObjectAtIndex:i];
            [sortCache setObject:arrayOp forKey:Sort_YYCache_Sort_Value_key];
            break;
        }
    }
   NSArray *array =  [sortCache allCacheKey];
    if (array.count>0) {
        NSMutableArray *delArray = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *arrayNew = [NSMutableArray arrayWithArray:array];
        for (int i = 0;i<arrayNew.count;i++) {
            if([[arrayNew objectAtIndex:i] rangeOfString:uuid].location!=NSNotFound){
                [delArray addObject:[arrayNew objectAtIndex:i]];
            }
        }
        for (int i = 0; i <delArray.count; i++) {
            NSString *key = [delArray objectAtIndex:i];
            [sortCache removeObjectForKey:key];
            NSArray *array = [key componentsSeparatedByString:@"_"];
            if (array.count>1) {
                [self removeDataNotReload:[array objectAtIndex:0]];
            }
        }
        self.sortKey = HuanCunDirKey;
        [self reloadAllData];
        [self updateSyncKey];
    }
}

-(IBAction)pressCreateDir:(id)sender{
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建文件夹" message:@"输入文件夹名字" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"文件夹名";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        NSString *text = envirnmentNameTextField.text;
        if (text.length>1) {
            NSString *  uuid =  [YTKNetworkUtils md5StringFromString:text];
            if(![wself findSortKeyExit:uuid]){
                [wself addNetSortVideo:uuid name:text];
            }
            else{
                [self.view makeToast:@"该文件夹已存在，请输入不同名字" duration:2 position:@"center"];
            }
         }
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(void)addNetSortVideo:(NSString*)key name:(NSString*)name{
    NSMutableArray *arrat = [NSMutableArray arrayWithCapacity:10];
    NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    if (arrayRet.count>0) {
        [arrat addObjectsFromArray:arrayRet];
    }
    [arrat addObject:@{Sort_key_uuid:key,Sort_key_name:name}];
    [sortCache setObject:arrat forKey:Sort_YYCache_Sort_Value_key];
    [self updateSyncKey];
}

-(BOOL)findSortKeyExit:(NSString*)key{
    NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    if (arrayRet.count==0) {
        return false;
    }
    for (int i = 0; i < arrayRet.count; i++) {
        if([key compare:[[arrayRet objectAtIndex:i] objectForKey:Sort_key_uuid]]==NSOrderedSame){
            return true;
        }
    }
    return false;
}

-(void)jionDir:(NSString*)uuid{
    __block NSString *jionKey = uuid;
    NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    __weak typeof(self) wself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择文件夹" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"下载管理" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [wself addKeyFromCacheSortKey:jionKey sortKey:HuanCunDirKey];
    }]];
    for (int i = 0; i < arrayRet.count; i++) {
       NSString *uuid = [[arrayRet objectAtIndex:i] objectForKey:Sort_key_uuid];
        NSString *name = [[arrayRet objectAtIndex:i] objectForKey:Sort_key_name];
        UIAlertAction *atter =  [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself addKeyFromCacheSortKey:jionKey sortKey:action.contentValue];
        }];
        atter.contentValue = uuid;
        [alertController addAction:atter];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(void)addKeyFromCacheSortKey:(NSString*)uuid sortKey:(NSString*)sortKey{
    if([self.sortKey compare:sortKey]==NSOrderedSame){//当前类别等于添加的类别
        return;
    }
    [self removeAllCacheSort:uuid sortKey:sortKey];
}

-(void)removeAllCacheSort:(NSString*)key sortKey:(NSString*)sortKey{
    if ([self.sortKey compare:sortKey]==NSOrderedSame) {
        return;
    }
    //key_sortKey
    [self removeFormCache:key];
    if ([sortKey compare:HuanCunDirKey]!=NSOrderedSame) {
        NSString  *keyValue = [NSString stringWithFormat:@"%@_%@",key,sortKey];
        [sortCache setObject:@"1" forKey:keyValue];
    }
    [self updateSyncSort];
    [self.view makeToast:@"已加入文件夹" duration:2 position:@"center"];
}

-(void)removeFormCache:(NSString*)key{
    NSArray *arrayRet = (NSArray*)[sortCache objectForKey:Sort_YYCache_Sort_Value_key];
    for (int i = 0; i < arrayRet.count; i++) {
        NSString *keyValue =  [NSString stringWithFormat:@"%@_%@",key,[[arrayRet objectAtIndex:i] objectForKey:Sort_key_uuid]];
        [sortCache removeObjectForKey:keyValue];
    }
}

-(void)click_video_sort_view:(NSString*)key{
    self.sortKey = key;
    [self updateSyncSort];
    [self updateSyncKey];
}
@end
#endif
