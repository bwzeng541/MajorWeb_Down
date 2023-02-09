//
//  MajorWebCartoonView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/29.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorWebCartoonView.h"
#import "WebCartoonManager.h"
#import "UIImage+webCartoonTools.h"
#import "MainMorePanel.h"
#import "WebTopChannel.h"
#import "YSCHUDManager.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "MajorCartoonCell.h"
#import "MajorCartoonAssetManager.h"
#import "MajorCartoonCtrl.h"
#import "MBProgressHUD.h"
#import "NSObject+UISegment.h"
#import "MarjorCartoonLayout.h"
#import "ShareSdkManager.h"
#import "VipPayPlus.h"
#import "VideoPlayerManager.h"
#import <AdSupport/AdSupport.h>
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "AppDelegate.h"
#define CartoonOffsetFilePath [NSString stringWithFormat:@"%@/%@",WebCartoonAsset,@"offsetConfig"]
#define CartoonImageSizeFilePath [NSString stringWithFormat:@"%@/%@",WebCartoonAsset,@"imageSizeConfig"]
@interface MajorWebCartoonView ()<BURewardedVideoAdDelegate,MajorCartoonCellDelegate,MarjorCartoonLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource,WebTopChannelDelegate>{
    BOOL isTouch;
    CGFloat offsetBeginY;
    CGFloat oldContentH;
    UIView *statusBarView;
    BOOL isStautsBarHidden;
    float stautsBarH ;
    UIView *shareParetenView;
}
@property(assign,nonatomic)NSInteger initSelectIndex;
@property(strong,nonatomic)MBProgressHUD *hubView;
@property(strong,nonatomic)BURewardedVideoAd *rewardedVideoAd;
@property(strong,nonatomic) UIButton *btnBack;
@property(strong,nonatomic)UICollectionView *myCollectionView;
@property(assign,nonatomic)NSInteger willDisplayIndex;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(strong,nonatomic)NSMutableDictionary *imageInfo;
@property(strong,nonatomic)WebTopChannel *webChannelView;
@property(strong,nonatomic)NSMutableDictionary *offsetConfig;
@property(strong,nonatomic)NSMutableDictionary *imageSizeConfig;
@property(strong,nonatomic)NSDate *fireData;
@property(assign,nonatomic)NSInteger fireTime;
@property(strong,nonatomic)NSTimer *recordTimer;
@property(strong,nonatomic)NSTimer *alterTimer;
@end

@implementation MajorWebCartoonView

-(void)dealloc{
    
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    UIResponder *responder = (UIViewController*)self.superview.nextResponder;
    if ([responder isKindOfClass:[NSClassFromString(@"MajorCartoonCtrl") class]]) {
        [(UIViewController*)responder dismissViewControllerAnimated:YES completion:nil];
    }
    [super removeFromSuperview];
}


-(id)initWithFrame:(CGRect)frame index:(NSInteger)index{
    self = [super initWithFrame:frame];
    self.initSelectIndex = index;
    self.fireData = [NSDate date];
    self.fireTime = 480;
    self.isUsePopGesture = true;
    stautsBarH = GetAppDelegate.appStatusBarH;
    self.backgroundColor = [UIColor whiteColor];
    self.offsetConfig = [NSMutableDictionary dictionaryWithCapacity:1];
    self.imageSizeConfig = [NSMutableDictionary dictionaryWithCapacity:1];
    NSDictionary *imageConfig = [NSDictionary dictionaryWithContentsOfFile:CartoonImageSizeFilePath];
    if (imageConfig) {
        [self.imageSizeConfig setDictionary:imageConfig];
    }
    statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,MY_SCREEN_WIDTH, stautsBarH)];
    statusBarView.backgroundColor = [UIColor whiteColor];
    [self addSubview:statusBarView];
    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBack setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
    [self addSubview:self.btnBack];
    self.btnBack.frame = CGRectMake(0, stautsBarH, 40, 40);
    [self.btnBack addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self addWebsBtns];
    [self addBottomBts];
    [self addTableView];
    self.imageInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateOffetToFile) userInfo:nil repeats:YES];
    self.alterTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkAddVideoAlter:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkVipStatus:) name:@"checkVipStatus" object:nil];
     return self;
}

-(void)checkVipStatus:(NSNotification*)object{
    [self addVideoAlter:[NSNumber numberWithBool:true]];
}

-(void)checkAddVideoAlter:(NSNotification*)object{
    [self addVideoAlter:[NSNumber numberWithBool:false]];
}

-(void)addVideoAlter:(NSNumber*)isFocre{
    return;
    if ([VipPayPlus getInstance].systemConfig.vip==General_User) {
        if([isFocre boolValue] ||(self.fireData && [[NSDate date] timeIntervalSinceDate:self.fireData]>self.fireTime)){
            [self.alterTimer invalidate];self.alterTimer = nil;
            self.fireData = nil;
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否关闭提示框" message:nil];
            alertView.buttonFont = [UIFont systemFontOfSize:14];
            __weak __typeof(self)weakSelf = self;
            TYAlertAction *v  = [TYAlertAction actionWithTitle:@"退出"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                       [weakSelf back:nil];
                                                   }];
            [alertView addAction:v];
        
            TYAlertAction *v0  = [TYAlertAction actionWithTitle:@"加入会员"
                                                      style:TYAlertActionStyleDefault
                                                    handler:^(TYAlertAction *action) {
                                                        [[VipPayPlus getInstance] show:false];
                                                    }];
            [alertView addAction:v0];
            TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"看完广告获得功能" style:TYAlertActionStyleDefault handler:^(TYAlertAction *action) {
                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
            [[VipPayPlus getInstance] isVaildOperation:YES isShowAlter:NO plugKey:NSStringFromClass([self class]) stopVideoAdBlock:^(BOOL isSuccess) {
                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                [self.alterTimer invalidate];
                self.alterTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkAddVideoAlter:) userInfo:nil repeats:YES];
                self.fireTime = arc4random()%400 + 600;
                self.fireData = [NSDate date];
            }];
        }];
        [alertView addAction:v1];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
    }
    }
}

-(void)back:(UIButton*)sender{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [self.alterTimer invalidate];self.alterTimer = nil;
    [self updateOffetToFile];
    [self clearAllData];
    [[WebCartoonManager getInstance] stop];
    [(UIViewController*)self.superview.nextResponder dismissViewControllerAnimated:YES completion:nil];
}

-(void)addBottomBts{
    if (shareParetenView) {
        return;
    }
    float popBackW = MY_SCREEN_WIDTH;
    float scale = popBackW/640;
    shareParetenView = [[UIView alloc]initWithFrame:CGRectMake(0,self.bounds.size.height-(stautsBarH-20)-46*scale, popBackW, 46*scale)];
    shareParetenView.backgroundColor = [UIColor whiteColor];
    [self addSubview:shareParetenView];
    {
        float btnsViewh = MY_SCREEN_WIDTH*0.078;//640*50
        float btnh = btnsViewh*1.44/2;
        if (IF_IPAD) {
            btnh *= 0.8;
        }
        float btnw = btnh*4;
        CGSize btnSize = CGSizeMake( btnw,btnh);
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setImage:[UIImage imageNamed:@"CartoonAsset.bundle/share_image"] forState:UIControlStateNormal];
        [shareParetenView addSubview:btn1];
        [btn1 addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn2 setImage:[UIImage imageNamed:@"CartoonAsset.bundle/save_image"] forState:UIControlStateNormal];
        [shareParetenView addSubview:btn2];
        [btn2 addTarget:self action:@selector(saveImagePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn3 setImage:[UIImage imageNamed:@"Brower.bundle/list_share_pyq"] forState:UIControlStateNormal];
        [shareParetenView addSubview:btn3];
        [btn3 addTarget:self action:@selector(shareapp:) forControlEvents:UIControlEventTouchUpInside];
        
       /* UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn4 setImage:[UIImage imageNamed:@"AppMain.bundle/quxiao_ad"] forState:UIControlStateNormal];
        [shareParetenView addSubview:btn4];
        [btn4 addTarget:self action:@selector(quxAd:) forControlEvents:UIControlEventTouchUpInside];
        */[NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn1 viSize:btnSize vi2:nil index:0 count:3];
        [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn2 viSize:btnSize vi2:btn1 index:1 count:3];
        [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:btn3 viSize:btnSize vi2:btn2 index:2 count:3];
       // [NSObject initii:shareParetenView contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)vi:btn4 viSize:btnSize vi2:btn3 index:3 count:4];
    }
}

-(WebCartoonItem*)getVisibieCartoonItem{
    NSArray *arrayCell = self.myCollectionView.visibleCells;
    float h = 0;
    MajorCartoonCell *cellSave = nil;
    for (int i = 0; i<arrayCell.count; i++) {
        MajorCartoonCell *cell =  [arrayCell objectAtIndex:i];
        
        //获取cell在当前屏幕的位置
        CGRect rectInTableView = [self.myCollectionView convertRect:cell.frame toView:self.myCollectionView];
        CGRect rect = [self.myCollectionView convertRect:rectInTableView toView:self.myCollectionView.superview];
        CGRect rectInters = CGRectIntersection(rect, CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT));
        float hh = CGRectGetHeight(rectInters);
        if (hh>h) {
            h = hh;
            cellSave = cell;
        }
    }
    return cellSave.cartoonItem;
}

-(void)saveImagePhoto:(UIButton*)sender{
    [[self getVisibieCartoonItem] saveToDevice];
}

-(void)shareapp:(UIButton*)sender{
    [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
        return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
    } value:^NSString *{
        return nil;
    } titleBlock:^NSString *{
        return nil;
    } imageBlock:^UIImage *{
        return nil;
    }urlBlock:^NSString  *{
        return nil;
    }shareViewTileBlock:^NSString *{
        return @"分享app";
    }];
}

-(void)quxAd:(UIButton*)sender{
    [[VipPayPlus getInstance] isVaildOperation:false plugKey:NSStringFromClass([self class])];
}

-(void)shareImage:(UIButton*)sender{
    UIImage *image = [self getVisibieCartoonItem].getSaveImage;
    if (image) {
        [[ShareSdkManager getInstance] showShareTypeFixType:SSDKContentTypeImage typeArray:^NSArray *{
            return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
        } value:^NSString *{
            return nil;
        } titleBlock:^NSString *{
            return nil;
        } imageBlock:^UIImage *{
            return image;
        }urlBlock:^NSString  *{
            return nil;
        }shareViewTileBlock:^NSString *{
            return @"让好友解释这图片是什么意思";
        }];
    }
}

-(void)addWebsBtns{
            NSArray *array = [MainMorePanel getInstance].morePanel.manhuaurl;
        float startY = stautsBarH+5;
        if (array.count>0) {
            float hh = 25;
            if (IF_IPAD) {
                hh = 40;
            }
            self.webChannelView = [[WebTopChannel alloc] initWithFrame:CGRectMake(self.btnBack.frame.size.width+self.btnBack.frame.origin.x, self.btnBack.frame.origin.y,MY_SCREEN_WIDTH-self.btnBack.frame.size.width-self.btnBack.frame.origin.x, hh)];
            self.webChannelView.delegate = self;
            self.webChannelView.center = CGPointMake(self.webChannelView.center.x, self.btnBack.center.y);
            startY = self.webChannelView.frame.origin.y+self.webChannelView.frame.size.height+5;
            [self addSubview:self.webChannelView];
            [self.webChannelView updateTopArray:array];
            __weak __typeof(self)weakSelf = self;
            self.webChannelView.clickBlock = ^(manhuaurlInfo *item) {
                [weakSelf updateOffetToFile];
                [weakSelf clearAllData];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[WebCartoonManager getInstance] startWithUrlUsrOldBlock:[item.url md5] url:item.url parseInfo:[[MainMorePanel getInstance].morePanel.manhuaParseInfo objectForKey:item.key]];
                });
            };
            self.webChannelView.backgroundColor = [UIColor whiteColor];
            self.webChannelView.collectionView.backgroundColor = [UIColor whiteColor];
            [self.webChannelView hiddenMore];
            [self.webChannelView updateSelect:self.initSelectIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.initSelectIndex inSection:0];
            [self.webChannelView.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
}

-(void)clearAllData{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dealyAdjustOffet) object:nil];
    RemoveViewAndSetNil(self.myCollectionView);
    [self.dataArray removeAllObjects];
    [self addTableView];
}

-(void)addTableView{
    if (!self.myCollectionView) {
        float startY = self.btnBack.frame.origin.y+self.btnBack.frame.size.height;
        MarjorCartoonLayout *layout = [[MarjorCartoonLayout alloc] init];
        layout.delegate = self;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,startY,MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT - startY ) collectionViewLayout:layout];
        self.myCollectionView.bounces = NO;
        [self insertSubview:_myCollectionView belowSubview:shareParetenView];
        self.myCollectionView.backgroundColor = [UIColor blackColor];
        self.myCollectionView.dataSource = self;
        self.myCollectionView.delegate = self;
        [self.myCollectionView registerClass:MajorCartoonCell.class forCellWithReuseIdentifier:@"MajorCartoonCell"];
     }
}

-(UIColor*)selectColor{
    return RGBCOLOR(0, 0, 0);
}

-(UIColor*)unSelectColor{
    return RGBCOLOR(142, 142, 142);
}

-(void)beginUrlRequest{
    [YSCHUDManager showHUDOnView:self.myCollectionView message:@"loading..."];
}


-(void)moveToOlPos:(BOOL)isRemoveOldAll loadIndex:(NSInteger)index{
    [CATransaction begin];
    [self.myCollectionView reloadData];
    [CATransaction setDisableActions:YES];
    [CATransaction commit];
    if (isRemoveOldAll && self.dataArray.count>0) {//查找历史记录offset
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dealyAdjustOffet) object:nil];
        [self performSelector:@selector(dealyAdjustOffet) withObject:nil afterDelay:0.1];
    }
    [YSCHUDManager hideHUDOnView:self.myCollectionView animated:NO];
}

-(void)dealyAdjustOffet{
    NSDictionary *info =  [NSDictionary dictionaryWithContentsOfFile:CartoonOffsetFilePath];
    if (info) {
        [self.offsetConfig setDictionary:info];
    }
    WebCartoonItem *item = [self.dataArray objectAtIndex:0];
    NSDictionary *readInfo = [self.offsetConfig objectForKey:item.typeKey];
    NSInteger movindex= [[readInfo objectForKey:@"index"]integerValue ];
    if (readInfo && movindex<self.dataArray.count) {
         [self.myCollectionView setContentOffset:CGPointMake(0, [[readInfo objectForKey:@"offset"] floatValue])];

     }
}

-(void)updateOffetToFile{
    if (self.dataArray.count>0) {
        WebCartoonItem *item = [self.dataArray objectAtIndex:0];
        NSDictionary *info = @{@"index":@(self.willDisplayIndex),@"offset":@(self.myCollectionView.contentOffset.y),@"myTableView.contentSize":NSStringFromCGSize(self.myCollectionView.contentSize)};
        [self.offsetConfig setObject:info forKey:item.typeKey];
        [self.offsetConfig writeToFile:CartoonOffsetFilePath atomically:YES];
        [self.imageSizeConfig writeToFile:CartoonImageSizeFilePath atomically:YES];
    }
}

-(void)addDataItem:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll{
    if (isRemoveOldAll) {
         [self.dataArray removeAllObjects];
     }
    [self.dataArray addObject:item];
    [self moveToOlPos:isRemoveOldAll loadIndex:self.dataArray.count-1];
}

-(void)addDataArray:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll{
    if (isRemoveOldAll) {
         [self.dataArray removeAllObjects];
     }
    [self.dataArray addObjectsFromArray:item];
    [self moveToOlPos:isRemoveOldAll loadIndex:-1];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isTouch = true;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    isTouch = false;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{/*
    if (isTouch) {
        float vv = scrollView.contentOffset.y;//(vv>10上面搜索消失，<10,上面搜索出现)
        float offsetY = offsetBeginY - vv;
        if (offsetY>10) {//up
             offsetBeginY = vv;
            if (oldContentH>0 && scrollView.contentSize.height>oldContentH+100) {
             }
            [self showBar];
         }
        else if(offsetY<-50 && vv>0){//down
             offsetBeginY = vv;
            [self hideBar];
         }
        oldContentH = scrollView.contentSize.height;
    }*/
}

-(void)saveCartoonImageSize:(NSString *)uuid imageSize:(CGSize)imageSize
{
    if (![self.imageSizeConfig objectForKey:uuid]) {
        [self.imageSizeConfig setObject:NSStringFromCGSize(imageSize) forKey:uuid];
        [self.imageSizeConfig writeToFile:CartoonImageSizeFilePath atomically:YES];
    }
}

-(BOOL)isCanReqeustAdCell:(NSIndexPath*)indexPath{
    return true;
}

-(void)showBar{
    if (isStautsBarHidden!=false) {
        isStautsBarHidden = false;
        self.btnBack.frame = CGRectMake(0, stautsBarH, 40, 40);
        self.webChannelView.frame = CGRectMake(self.btnBack.frame.origin.x+self.btnBack.frame.size.width, self.btnBack.frame.origin.y,MY_SCREEN_WIDTH-self.btnBack.frame.size.width-self.btnBack.frame.origin.x, self.webChannelView.bounds.size.height);
        self.webChannelView.center = CGPointMake(self.webChannelView.center.x, self.btnBack.center.y);
        float startY = self.btnBack.frame.origin.y+self.btnBack.frame.size.height;
        self.myCollectionView.frame = CGRectMake(0,startY,MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT - startY );
        [(MajorCartoonCtrl*)self.superview.nextResponder showStautsBar:isStautsBarHidden];
    }
}

-(void)hideBar{
    if(isStautsBarHidden!=true){
        isStautsBarHidden = true;
        self.btnBack.frame = CGRectMake(0, stautsBarH-100, 40, 40);
        self.webChannelView.frame = CGRectMake(self.btnBack.frame.origin.x+self.btnBack.frame.size.width, self.btnBack.frame.origin.y,MY_SCREEN_WIDTH-self.btnBack.frame.size.width-self.btnBack.frame.origin.x, self.webChannelView.bounds.size.height);
        self.myCollectionView.frame = CGRectMake(0,stautsBarH-20,MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT - (stautsBarH-20) );
        [(MajorCartoonCtrl*)self.superview.nextResponder showStautsBar:isStautsBarHidden];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showBar];
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    self.willDisplayIndex = indexPath.row;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    //1240X456
    return [self carToonItemSize:indexPath.row];
    //WebCartoonItem *item = [self.dataArray objectAtIndex:indexPath.row];
    //return  CGSizeMake(MY_SCREEN_WIDTH, item.imageSize.height+item.adSize.height);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.dataArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MajorCartoonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MajorCartoonCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell configWithConfig:[self.dataArray objectAtIndex:indexPath.row] index:indexPath.row tableView:collectionView];
    return cell;
}

-(CGSize)carToonItemSize:(NSInteger)index{
    WebCartoonItem *item = [self.dataArray objectAtIndex:index];
    NSString *sizeStr = [self.imageSizeConfig objectForKey:item.uuid];
    if (sizeStr) {
      CGSize size =  CGSizeFromString(sizeStr);
        return CGSizeMake(MY_SCREEN_WIDTH,(MY_SCREEN_WIDTH / size.width)*size.height);
    }
    return  CGSizeMake(MY_SCREEN_WIDTH, item.imageSize.height+item.adSize.height);
}

-(NSInteger)carToonItemNumber{
    return self.dataArray.count;
}


#pragma mark --BUFullscreenVideoAdDelgate
-(void)addWaitView{
    self.hubView = [[MBProgressHUD alloc] initWithView:self];
    [self.hubView showAnimated:YES];
    self.hubView.removeFromSuperViewOnHide = YES;
    [self addSubview:self.hubView];
}

-(void)removeWaitView{
    [self.hubView hideAnimated:NO];
    self.hubView=nil;
}

-(void)requesFullVideoAd{
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:@"900546826" rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self addWaitView];
    [self.rewardedVideoAd loadAdData];
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"reawrded video did load");
    [self removeWaitView];
    /*__weak __typeof__(self) weakSelf = self;
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否显示激励视频" message:nil];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"关闭"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                               }];
    [alertView addAction:v];
    TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"展示激励视频" style:TYAlertActionStyleDefault handler:^(TYAlertAction *action) {*/
        [self.rewardedVideoAd showAdFromRootViewController:self.superview.nextResponder];
   /* }];
    [alertView addAction:v1];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];*/
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video will visible");
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video did close");
    self.fireData = [NSDate date];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded video did click");
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"rewarded video material load fail");
    self.hubView.label.text = @"获取广告失败";
    [self.hubView hideAnimated:YES afterDelay:2];
    self.hubView = nil;
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
   
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewarded verify failed");
    [self removeWaitView];
    self.fireData = [NSDate date];
 }

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    
}


- (BOOL)isValidGesture:(CGPoint)point{
    if (point.x<self.bounds.size.width/2) {
        return true;
    }
    return false;
}
@end
