//
//  MajorHomeBaesCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/24.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorSortCell.h"
#import "MajorWebCartoonView.h"
#import "WebCartoonManager.h"
#import "AppDelegate.h"
#import "MainMorePanel.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "MajorCartoonCtrl.h"
#import "MajorZyCartoonPlug.h"
#import "WebViewLivePlug.h"
#import "WebPushView.h"
#import "WebPushManager.h"
#import "MarjorRedBag.h"
#import "MarjorWebConfig.h"
#import "VipPayPlus.h"
#import "Toast+UIView.h"
#import "VideoPlayerManager.h"
#import "ThrowWebController.h"
#import "AppDelegate.h"
#import "MajorPrivacyHome.h"
#import "helpFuntion.h"
#import "ShareSdkManager.h"
#import "MajorPermissions.h"
#import "ZFAutoPlayerViewController.h"
#define MajorLifeCell_LivePlug @"MajorLifeCell_LivePlug"
#define MajorNovel_ZyCartoonPlug @"MajorNovel_ZyCartoonPlug"
#define MajorNovel_ZyNeiHanPlug @"MajorNovel_Neihan_Btn"
#define MajorHotCell_key @"majorHotCell_meinv"
#define MajorZhiboCell_key @"majorHotCell_zhibo"
#define MajorSortMaxTimes 5

#define VipMajorPrivacyHomeTimes @"vip_plus_watch_privaacy_home_times"
#define VipMajorPrivacyHomeTimesVaildCount  1

@interface MajorSortCell()<UICollectionViewDelegate,UICollectionViewDataSource>{
    float itemSpacing;
    float cellW,cellH;
    UIButton* sortBtnPress ;
    NSInteger videoWatchTimes;
    NSInteger changeVideoBtnTimes;
    UIButton* videoBtn;
}
@property(nonatomic,strong)ZFAutoPlayerViewController *autoPlayerCtrl;
@property(nonatomic,strong)UIView *checkVipView;
@property(nonatomic,strong)NSTimer *checkVaildTimer;
@property(nonatomic,strong)NSDate *fireTime;
@property(nonatomic,strong)NSTimer *checkDjsTimer;
@property(nonatomic,assign)NSInteger currentIndex;
@property(nonatomic,strong)NSArray *arrayPic;
@property(nonatomic,assign)float cellSizeH;
@property(nonatomic,strong)UICollectionView *collectionView;
@end

@implementation MajorSortCell

-(void)updateHeadColor:(UIColor*)color{
    
}

-(void)updateRightLableState{
    
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.arrayPic = nil;// @[@"AppMain.bundle/sort_dyzb",@"AppMain.bundle/sort_mh",@"AppMain.bundle/sort_dszb",@"AppMain.bundle/sort_rmb"];
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView  = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
    [self addSubview:self.collectionView];
    //95 24
     itemSpacing = 10;
    int colume = 4;
    cellW = (frame.size.width-8-itemSpacing*colume)/colume;
    cellH =0* cellW*(80.0/202);
    self.cellSizeH = cellH*0+itemSpacing*2;
    self.collectionView.frame  = CGRectMake(4, 0, frame.size.width-8, self.cellSizeH*0);

    //添加会员条码622X74
    self.fireTime = [NSDate date];
    if (!sortBtnPress) {
        sortBtnPress = [UIButton buttonWithType:UIButtonTypeCustom];
        [sortBtnPress setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/qhy") forState:UIControlStateNormal];
        float ww = self.collectionView.frame.size.width;
        float hh = ww*0.11;
        //beging 54 298
        ww = frame.size.width-8;
        hh = ww*0.11;
        //end
        [sortBtnPress setFrame:CGRectMake(self.collectionView.frame.origin.x, (self.collectionView.frame.origin.y+self.collectionView.frame.size.height)*0, ww, hh)];
        [self addSubview:sortBtnPress];
        self.cellSizeH+=hh;
        self.bounds = CGRectMake(0, 0, frame.size.width, self.cellSizeH);
        [sortBtnPress addTarget:self action:@selector(pressBtn) forControlEvents:UIControlEventTouchUpInside];
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkTimerVaild) userInfo:nil repeats:YES];
        
        {/*
             videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [videoBtn setFrame:CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y+self.collectionView.frame.size.height+hh*1.2, ww, hh)];
            self.cellSizeH+=hh*1.2;
            [self addSubview:videoBtn];
            [self updateAdVideoState];
            
            if (!self.checkDjsTimer) {
                                self.checkDjsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sjsTimer:) userInfo:nil repeats:YES];
                            }
*/
        }
    }
    self.clipsToBounds=YES;
    return self;
}

-(void)updateAdVideoState{
    [videoBtn removeTarget:self action:@selector(pressPlayAd) forControlEvents:UIControlEventTouchUpInside];
    if ([VipPayPlus getInstance].systemConfig.vip!=Recharge_User) {
        [videoBtn addTarget:self action:@selector(pressPlayAd) forControlEvents:UIControlEventTouchUpInside];
        [videoBtn setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/lhy") forState:UIControlStateNormal];
    }
    else
    {
        [videoBtn setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/lhy_") forState:UIControlStateNormal];
    }
}

-(void)pressPlayAd{
    static BOOL isClickIt = false;
    if ([[VipPayPlus getInstance] isCanPlayVideoAdTows]) {
        isClickIt = true;
        NSLog(@"pressPlayAd0");
         [[VipPayPlus getInstance]reqeustVideoAd:^(BOOL isSuccess) {
               if (isSuccess) {
                   //[MobClick event:@"video_btn"];
                   [[helpFuntion gethelpFuntion] isValideOneDay:WatchVideoAdEveryDay4TimesKey nCount:WatchVideoAdEveryDay4Times isUseYYCache:NO time:nil];
                   [self updateAdVideoState];
               }
           } isShowAlter:YES isForce:false];
        NSLog(@"pressPlayAd1");
    }
    else{
        if (!isClickIt) {
                [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@"请等待%ld秒后再领取",(25-self.currentIndex)] duration:2 position:@"center"];
        }
    }
}

-(void)sjsTimer:(NSTimer*)timer{
    self.currentIndex++;
    if (self.currentIndex>=25) {
        self.currentIndex = 25;
        [self.checkDjsTimer invalidate];self.checkDjsTimer = nil;
    }
}

//有效性检查
-(void)checkTimerVaild{
    WeiXinBtnInfo *wxBtnInfo =  [MainMorePanel getInstance].morePanel.wxBtnInfo;
    if([MarjorWebConfig isValid:wxBtnInfo.beginTime a2:wxBtnInfo.endTime]){
        sortBtnPress.alpha =1;
    }
    else{
        sortBtnPress.alpha =0;
    }
    [self updateAdVideoState];
}

-(void)updateHideBtnPress{
    sortBtnPress.hidden = YES;
    [self.checkVaildTimer invalidate];self.checkVaildTimer = nil;
    self.checkVaildTimer = [NSTimer scheduledTimerWithTimeInterval:changeVideoBtnTimes target:self selector:@selector(showHideBtnPress) userInfo:nil repeats:YES];
}

-(void)showHideBtnPress{
    [self.checkVaildTimer invalidate];self.checkVaildTimer = nil;
    sortBtnPress.hidden = NO;
}

-(void)pressBtn{
#if DEBUG
#else
   /* if ([VipPayPlus getInstance].systemConfig.vip != Recharge_User) {
        //232X63 400X710
        [self.checkVipView removeFromSuperview];
        self.checkVipView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        self.checkVipView.backgroundColor = [UIColor blackColor];
        __weak __typeof__(self) weakSelf = self;
        [self.checkVipView bk_whenTapped:^{
            [weakSelf.checkVipView removeFromSuperview];weakSelf.checkVipView = nil;
        }];
        UIImageView *imageview1 = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(@"privacy_tishi")];
        [self.checkVipView addSubview:imageview1];
        [imageview1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.checkVipView);
            make.top.equalTo(self.checkVipView).mas_offset(GetAppDelegate.appStatusBarH-20);
            make.height.mas_equalTo(MY_SCREEN_WIDTH*(710.0/400));
        }];
        UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBack setImage:UIImageFromNSBundlePngPath(@"privacy_cz_vip") forState:UIControlStateNormal];
        [self.checkVipView addSubview:btnBack];
        [btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.checkVipView);
            make.bottom.equalTo(self.checkVipView.mas_bottom).mas_offset(-(GetAppDelegate.appStatusBarH-20)-100);
            make.height.mas_equalTo(IF_IPAD?63:32);//
            make.width.mas_equalTo(IF_IPAD?232:116);//
        }];
        [btnBack bk_addEventHandler:^(id sender) {
            [weakSelf.checkVipView removeFromSuperview];weakSelf.checkVipView = nil;
            [[VipPayPlus getInstance] show:false];
        } forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_checkVipView];
        return;
    }*/
#endif
    __weak __typeof__(self) weakSelf = self;
    [MajorPermissions playClickPerMissions:VipMajorPrivacyHomeTimes pressmission:^(BOOL isSuccess) {
        if (isSuccess) {
            [weakSelf intoPrivae];
        }
    }];
//    BOOL ishelp = [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:VipMajorPrivacyHomeTimes nCount:VipMajorPrivacyHomeTimesVaildCount isUseYYCache:NO time:nil];
//    if (!ishelp) {
//        [self intoPrivae];
//        return;
//    }
//    [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
//    [[VipPayPlus  getInstance] reqeustVideoAd:^(BOOL isSuccess) {
//        if (isSuccess) {
//            GetAppDelegate.isWatchHomeVideo = YES;
//        }
//        [[helpFuntion gethelpFuntion] isValideOneDay:VipMajorPrivacyHomeTimes nCount:VipMajorPrivacyHomeTimesVaildCount isUseYYCache:NO time:nil];
//         [self intoPrivae];
//        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
//    } isShowAlter:YES];
}

- (void)intoPrivae{
    UIView *parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    MajorPrivacyHome*   majorPrivacyHomeView = [[MajorPrivacyHome alloc] init];
    majorPrivacyHomeView.frame =  CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
    [parentView addSubview:majorPrivacyHomeView];
    [majorPrivacyHomeView initUI];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.arrayPic.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ContentCollection";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *image = UIImageFromNSBundlePngPath([self.arrayPic objectAtIndex:indexPath.row]);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [cell.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {//电影直播
        __weak __typeof__(self) weakSelf = self;
        [MajorPermissions playClickPerMissions:MajorZhiboCell_key pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf btn1Event:nil];
            }
        }];
    }
    else if(indexPath.row==-1){//福利漫画
        [MajorPermissions playClickPerMissions:MajorNovel_ZyNeiHanPlug pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                if([MainMorePanel getInstance].morePanel.manhuaurl.count>0){
                    //[MobClick event:@"neihan_btn"];
                    MajorCartoonCtrl *ctrl = [[MajorCartoonCtrl alloc] initWithNibName:nil bundle:nil];
                    ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
                    [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:ctrl animated:YES completion:nil];
                }
            }
        }];
    }
    else if(indexPath.row==1){//破解漫画
        [MajorPermissions playClickPerMissions:MajorNovel_ZyCartoonPlug pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
                UIView *view = [GetAppDelegate getRootCtrlView];
                MajorZyCartoonPlug *v = [view viewWithTag:TmpTopViewTag];
                if (!v) {
                    v = [[MajorZyCartoonPlug alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
                    [view addSubview:v];
                    v.tag = TmpTopViewTag;
                }
            }
        }];
        
    }
    else if(indexPath.row==2){//91gril
        [MajorPermissions playClickPerMissions:MajorHotCell_key pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                //[MobClick event:@"meinv_btn"];
                WebConfigItem *item = [[WebConfigItem alloc] init];
                item.url = @"http://m.leshitya.com/";
                [MarjorWebConfig getInstance].webItemArray = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
//                UIViewController *controller = [[NSClassFromString(@"PinUpController") alloc] initWithNibName:@"PinUpController" bundle:nil];
//                controller.modalPresentationStyle = UIModalPresentationFullScreen;
//                [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:controller animated:YES completion:nil];
            }
        }];
    }
    else if(indexPath.row==-1){//湖南卫视
        [MajorPermissions playClickPerMissions:MajorLifeCell_LivePlug pressmission:^(BOOL isSuccess) {
            if (isSuccess) {
                //[MobClick event:@"diansi_btn"];
                [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
                UIView *view = [GetAppDelegate getRootCtrlView];
                WebViewLivePlug *v = [view viewWithTag:TmpTopViewTag];
                if (!v) {
                    v = [[WebViewLivePlug alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
                    [view addSubview:v];
                    v.tag = TmpTopViewTag;
                }
            }}];
        
    }
    else if(indexPath.row==3){
       // [self linquhy];
        [self shareApp];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSpacing;
}

-(WebPushView*)createWebPushAndView{
    UIView *view = [GetAppDelegate getRootCtrlView];
    WebPushView *v = [view viewWithTag:TmpTopViewTag];
    if (!v) {
        v = [[WebPushView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        [view addSubview:v];
        v.tag = TmpTopViewTag;
    }
    return v;
}

-(void)zfautoPlayerWillRemove:(UIImage*)image{
    [self.autoPlayerCtrl.view removeFromSuperview];
    self.autoPlayerCtrl.delegate = nil;
    self.autoPlayerCtrl = nil;
}

-(void)btn1Event:(UIButton*)sender{
    //[MobClick event:@"zhibo_btn"];
    [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
    
    self.autoPlayerCtrl=  [[ZFAutoPlayerViewController alloc] init];
    self.autoPlayerCtrl.delegate = self;
    self.autoPlayerCtrl.view.frame = CGRectMake(0, 0,[MajorSystemConfig getInstance].appSize.width,[MajorSystemConfig getInstance].appSize.height);
    [[GetAppDelegate getRootCtrlView] addSubview: self.autoPlayerCtrl.view];
    [self.autoPlayerCtrl initUI];
    
    
//    [[WebPushManager getInstance] showDateBlock:^(NSArray * _Nonnull ret) {
//        [[self createWebPushAndView] addDataArray:ret isRemoveOldAll:YES];
//    } updateBlock:^(WebPushItem * _Nonnull item, BOOL isRemoveOldAll) {
//        [[self createWebPushAndView] addDataItem:item isRemoveOldAll:isRemoveOldAll];
//    } startHomeBlock:^{
//        huyaNodeInfo *node =  [[MainMorePanel getInstance].morePanel.huyaurl objectAtIndex:0];
//        [[self createWebPushAndView] loadHome];
//        [[WebPushManager getInstance] startWithUrlUsrOldBlock:node.url ];
//    } falidBlock:^{
//        
//    }];
}

-(void)shareApp{
    [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
        return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone),@(SSDKPlatformSubTypeWechatTimeline)];
    } value:^NSString *{
        return nil;
    } titleBlock:^NSString *{
        return nil;
    } imageBlock:^UIImage *{
        return nil;
    }urlBlock:^NSString  *{
        return nil;
    }shareViewTileBlock:^NSString *{
        return @"分享app下载地址";
    }];
}

-(void)linquhy{
    //[MobClick event:@"huiyuan_btn"];
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"看两次视频广告,获得一天会员" message:nil];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                                    HomeAdShow *show =  [MainMorePanel getInstance].morePanel.homeADshow;
                                                   if([MarjorWebConfig isValid:show.beginTime a2:show.endTime]){
                                                       [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
                                                       [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                            if (isSuccess) {
                                                               GetAppDelegate.isWatchHomeVideo = true;
                                                                [self watchFinishAtler];
                                                           }
                                                           [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                                                        }isShowAlter:false isForce:false];
                                                   }
                                                   else{
                                                    }
                                               }];
    [alertView addAction:v];
    NSInteger times = [[VipPayPlus getInstance] getWatchVideoTimes];
    NSArray *array = nil;
    if (times==0) {
        array = @[@"视频1",@"视频2"];
    }
    else if(times==1){
        array = @[@"已观看",@"视频2"];
    }
    else {
        array = @[@"已观看",@"已观看"];
    }
    for (int i = 0; i < array.count; i++) {
        TYAlertAction *v1  = [TYAlertAction actionWithTitle:[array objectAtIndex:i]
                                                      style:TYAlertActionStyleDefault
                                                    handler:^(TYAlertAction *action) {
                                                        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
                                                        [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                            if (isSuccess) {
                                                                GetAppDelegate.isWatchHomeVideo = true;
                                                                [self watchFinishAtler];
                                                            }
                                                            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                                                        }isShowAlter:false isForce:false];
                                                    }];
        [alertView addAction:v1];
    }
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}

-(void)watchFinishAtler{
    NSInteger times = [[VipPayPlus getInstance] updateWatchVideoTimes];
    if (times<2) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜你获得本次会员" duration:2 position:@"center"];
    }
    else{
        [[UIApplication sharedApplication].keyWindow makeToast:@"恭喜你获得今天会员" duration:2 position:@"center"];
    }
}
@end
