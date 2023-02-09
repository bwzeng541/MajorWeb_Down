//
//  VideoPlayerManager+Down.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/22.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "VideoPlayerManager+VideoNativeAd.h"
#import "AppDelegate.h"
#import "MajorSystemConfig.h"
#import "BUDDrawTableViewCell.h"
#import "BUDAdManager.h"
#import "VipPayPlus.h"
static BOOL isShowVideo = false;
static BUNativeAdsManager *adVideoManager = NULL;
static UITableView *adVideoTableView = NULL;
static UIButton *adVideoCloseBtn = NULL;
static NSMutableArray  *nativeVideoAdDataArray = NULL;
static NSInteger  videoStartVideoTimes = 0;
@implementation VideoPlayerManager(VideoNativeAd)
-(void)startVideoNative{
    return;
    videoStartVideoTimes++;
    if(videoStartVideoTimes>1){
        if ([VipPayPlus getInstance].systemConfig.vip!=General_User) return;
        if (!isShowVideo) {
            [self updatePlayAlpha:0];
            [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                isShowVideo = isSuccess;
                [self updatePlayAlpha:1];
            }isShowAlter:true isForce:false];
        }
    }
    return;
    if ([MajorSystemConfig getInstance].isGotoUserModel != 2 && !adVideoManager) {
        BUNativeAdsManager *nad = [BUNativeAdsManager new];
        BUAdSlot *slot1 = [[BUAdSlot alloc] init];
        slot1.ID = @"908710786";
        slot1.AdType = BUAdSlotAdTypeDrawVideo; //必须
        slot1.isOriginAd = YES; //必须
        slot1.position = BUAdSlotPositionTop;
        slot1.imgSize = [BUSize sizeBy:BUProposalSize_DrawFullScreen];
        slot1.isSupportDeepLink = YES;
        nad.adslot = slot1;
        nad.delegate = self;
        adVideoManager = nad;
        [nad loadAdDataWithCount:3];
    }
}

-(void)stopVideoNative{
        [adVideoCloseBtn removeFromSuperview];adVideoCloseBtn = nil;
        [adVideoTableView removeFromSuperview];adVideoTableView = nil;
        adVideoManager.delegate = nil;
        adVideoManager = nil;
        nativeVideoAdDataArray = nil;
}

- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray{
    nativeVideoAdDataArray = [[NSMutableArray alloc] initWithArray:nativeAdDataArray];
    if (!adVideoTableView) {
        adVideoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        adVideoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        adVideoTableView.pagingEnabled = YES;
         [adVideoTableView registerClass:[BUDDrawAdTableViewCell class] forCellReuseIdentifier:@"BUDDrawAdTableViewCell"];
        adVideoTableView.delegate = self;
        adVideoTableView.dataSource = self;
#if defined(__IPHONE_11_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        if ([adVideoTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            if (@available(iOS 11.0, *)) {
                adVideoTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
#else
#endif
        [self.player.currentPlayerManager pause];
         adVideoCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [adVideoCloseBtn addTarget:self action:@selector(closeAdVideoNative:) forControlEvents:UIControlEventTouchUpInside];
        [adVideoCloseBtn setImage:[UIImage imageNamed:@"AppMain.bundle/close_ad.png"] forState:UIControlStateNormal];
        float offsetFixY = GetAppDelegate.appStatusBarH-20;
        adVideoCloseBtn.frame = CGRectMake(20, 20+offsetFixY, 40, 40);
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:adVideoTableView];
        [[UIApplication sharedApplication].keyWindow addSubview:adVideoCloseBtn];
        NSDate *nextDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];//后一天
        [[BUDAdManager getInstance] updateTime:nextDay];
    }
}

-(void)closeAdVideoNative:(UIButton*)sender{
    [self stopVideoNative];
    [[BUDAdManager getInstance] updateTime:[NSDate date]];
    [self.player.currentPlayerManager play];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return nativeVideoAdDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    id model = nativeVideoAdDataArray[index];
    if ([model isKindOfClass:[BUNativeAd class]]) {
        BUNativeAd *nativeAd = (BUNativeAd *)model;
        nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        BUDDrawAdTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"BUDDrawAdTableViewCell" forIndexPath:indexPath];
        nativeAd.delegate = self;
        cell.nativeAdRelatedView.videoAdView.delegate = self;
        [cell refreshUIWithModel:nativeAd];
        [model registerContainer:cell withClickableViews:@[cell.creativeButton]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BUDDrawBaseTableViewCell cellHeight];
}


@end
