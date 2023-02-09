//
//  MajorSetCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/9.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorSetView.h"
#import "MarjorWebConfig.h"
#import "SDWebImageDownloader.h"
#import "FileCache.h"
#import "AppDelegate.h"
#import "YSCHUDManager.h"
#import "MajorICloudSync.h"
#import "ClearCachesTool.h"
#import "MajorSystemConfig.h"
#import "ReactiveCocoa.h"
#import "MajorICloudView.h"
#import "ShareSdkManager.h"
#import "MajorFeedbackKit.h"
#import "MajorPrivacyView.h"
#import "MajorPopGestureView.h"
#import "GetGoldView.h"
#import "VipPayPlus.h"
#import "TmpSetView.h"
#import "VideoPlayerManager.h"
#import <AdSupport/AdSupport.h>
#define Swtich4GTag 100
@interface MajorSetView ()<UITableViewDelegate,UITableViewDataSource,GetGoldViewDelegate>{
    int _step;//分享好友和朋友圈
}
@property(nonatomic,copy)NSString *sizeMsg;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UIViewController *hcCtrl;
@property(nonatomic,strong)GetGoldView *goldCtrl;
@end

@implementation MajorSetView

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"checkVipStatus" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self hc_back_Event];
    [self back_from_gold];
}

-(void)back_from_gold{
    [self.goldCtrl.view removeFromSuperview];
    self.goldCtrl = nil;
}

-(void)hc_back_Event{
    [self.hcCtrl.view removeFromSuperview];
    self.hcCtrl = nil;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.sizeMsg = @"计算中...";
    // Do any additional setup after loading the view.
    self.isUsePopGesture = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hc_back_Event) name:DOWNAPICONFIG.msgapp3Notifi object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update_ui) name:@"updateMajorSetView"  object:nil];

    self.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(5, 20, 50, 50);
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:btnBack];
    _step = 0;
    if(![MajorSystemConfig getInstance].isOpen){
        _step = 3;
    }
#ifdef DEBUG
    _step = 3;
#endif
    _step = 3;
     UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, MY_SCREEN_WIDTH, 50)];
    labelDes.text =@"设置";
    labelDes.textColor = [UIColor blackColor];
    labelDes.textAlignment = NSTextAlignmentCenter;
    [self insertSubview:labelDes belowSubview:btnBack];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 72, MY_SCREEN_WIDTH, 1)];
    [self addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [btnBack addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 75, MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT-75 ) style:UITableViewStyleGrouped];
    _myTableView.dataSource = self;
    _myTableView.rowHeight = 45;
    _myTableView.delaysContentTouches = NO;
    _myTableView.delegate = self;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    _myTableView.tableHeaderView = headerView;
    [self addSubview:_myTableView];
     @weakify(self)
    
    [RACObserve([MarjorWebConfig getInstance],isSyncICloud) subscribeNext:^(id x) {
        @strongify(self)
        [self.myTableView reloadData];
    }];
    [RACObserve([VipPayPlus getInstance],isLogin) subscribeNext:^(id x) {
        @strongify(self)
        [self.myTableView reloadData];
    }];
    [TmpSetView hidenTmpSetView];
    return self;
}

-(void)update_ui{
    [self.myTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section==0) {
        return 0.01;
    }
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_step==0)return 3;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 0;//([VipPayPlus getInstance].systemConfig.vip!=General_User)?2:7;
    }
    if (_step==0) {
        return section==1?3:11;
    }
    else {
        if (section==1) {
            return 8;
        }
        else if (section==2){
            return 3;
        }
        return 11;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (((_step == 0&&indexPath.section==1 && indexPath.row==1) || (_step >0&&indexPath.section==2 && indexPath.row==1)) || ((indexPath.section==1 && indexPath.row==1) || (indexPath.section==1 && indexPath.row==1)) || (indexPath.section==1 && indexPath.row==2)) {
        return 0;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SetListCell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if(indexPath.row==0 && indexPath.section!=0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    cell.detailTextLabel.text = nil;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UISwitch *switchBtn = nil;
    NSInteger section = indexPath.section;
    NSInteger row =  indexPath.row;
    float fontS = 1;
     if ((_step == 0 && section==2 && row==0) || (_step > 0 && section==3 && row==0) ){
         cell.textLabel.text = @"更新收藏，下载记录等数据";
        if ([[MajorICloudSync getInstance] cloudIsAvailable]) {
            cell.detailTextLabel.text = @" ";
        }
        else{
            cell.detailTextLabel.text = @" ";
        }
    }
    else if (  (_step == 0 && section==2 && row==1) || (_step > 0 &&section==3 && row==1)) {
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isRemoveAd;
        cell.textLabel.text = @"过滤广告";
        if (@available(iOS 11.0, *)) {

        }
        else{
            cell.detailTextLabel.text = @"需要ios11(包含)以上系统";
            switchBtn.enabled = false;
        }
    }
    else if ((_step == 0&&section==2 && row==2) || (_step > 0&&section==3 && row==2)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isCanReadMode;
        cell.textLabel.text = @"阅读模式";
    }
    else if ((_step == 0&&section==2 && row==9) || (_step > 0&&section==3 && row==9)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isOpenLocaNotifi;
        cell.textLabel.text = @"本地推送";
    }
    else if ((_step == 0&&section==2 && row==10) || (_step > 0&&section==3 && row==10)){
          cell.textLabel.text = @"(网络/照片/通知)设置";
    }
    else if ((_step == 0 && section==2 && row==3) || (_step > 0&&section==3 && row==3)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isAllowsBackForwardNavigationGestures;
        cell.textLabel.text = @"手势返回";
    }
    else if ((_step == 0 && section==2 && row==7) || (_step > 0&&section==3 && row==7)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isCleanMode;
        cell.textLabel.text = @"不再记录历史记录（无痕模式）";
    }
    else if ((_step == 0&&section==2 && row==4) || (_step > 0&&section==3 && row==4)){
        cell.textLabel.text = @"清除播放记录";
    }
    else if ((_step == 0&&section==2 && row==5) || (_step > 0&&section==3 && row==5)){
        cell.textLabel.text = @"清除历史记录";
    }
    else if ((_step == 0&&section==2 && row==6) || (_step > 0&&section==3 && row==6)){
        cell.textLabel.text = @"清除缓存";
        cell.detailTextLabel.text = self.sizeMsg;
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            weakSelf.sizeMsg = [ClearCachesTool getCacheSize];
            dispatch_async(dispatch_get_main_queue(),^{
               UITableViewCell *cell=  [weakSelf.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                cell.detailTextLabel.text = self.sizeMsg;
            });
        });
    }
    else if ((_step == 0&&section==2 && row==8) || (_step > 0&&section==3 && row==8)){
        cell.textLabel.text = @"隐私声明";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ((_step == 0&&section==1 && row==0) || (_step > 0&&section==2 && row==0)){
        cell.textLabel.text = @"反馈意见";
    }
    else if ((_step == 0&&section==1 && row==1) || (_step >0&&section==2 && row==1)){
        cell.textLabel.text = @"";//@"提交需要屏蔽广告的网站";
    }
    else if ((_step == 0&&section==1 && row==2) || (_step > 0&&section==2 && row==2)){
        cell.textLabel.text = @"我要推荐网站";
    }
    else if ((section==1 && row==0)  ) {
        cell.textLabel.text = @"下载管理";
        cell.textLabel.textColor = [UIColor blueColor];
        fontS = 2;
    }
    else if ((section==1 && row==1)  ) {
        cell.textLabel.text = @"";//捐赠
    }
    else if ((section==1 && row==2)  ) {
        cell.textLabel.text = @"";//@"写评价--送会员功能";
    }
    else if ((section==1 && row==3)  ) {
        cell.textLabel.text = @"分享app给好友";
    }
    else if ((section==1 && row==4)  ) {
        cell.textLabel.text = @"分享app到朋友圈";
    }
    else if ((section==1 && row==5)  ) {
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay;
        cell.textLabel.text = @"自动下载视频";
    }
    else if ((section==1 && row==6)  ) {
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isAllowsBackGroundDownMode;
        cell.textLabel.text = @"后台自动下载视频";
    }
    else if ((section==1 && row==7)  ) {
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isAllows4GDownMode;
        cell.textLabel.text = @"允许4G网络下载时";
    }
    if (indexPath.row!=0) {
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    if (switchBtn) {
        [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        if ((section==1 && row==7)) {
            switchBtn.tag = Swtich4GTag;
        }
        else{
            switchBtn.tag = indexPath.row;
        }
        [cell.contentView addSubview:switchBtn];
        [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.right.equalTo(cell.contentView);
        }];
    }
    if (section==0 )
    {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14*fontS];
        if (row==0) {
            NSString *tel = [VipPayPlus getInstance].systemConfig.tel;
            BOOL isLogin = [VipPayPlus getInstance].isLogin;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
            cell.textLabel.text = tel?[NSString stringWithFormat:@"会员账号:%@        (修改密码)",tel]:[NSString stringWithFormat:@"登录/注册"];
            //cell.detailTextLabel.text = isLogin?@"已登录":@"未登录";
            cell.textLabel.textColor = [UIColor redColor];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [cell.contentView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell.contentView);
            }];
            [btn bk_addEventHandler:^(id sender) {
                [[VipPayPlus getInstance] showLoginWeb];
            } forControlEvents:UIControlEventTouchUpInside];
        }
        else if (row==1){
            BOOL vip = (([VipPayPlus getInstance].systemConfig.vip!=General_User)?true:false);
            BOOL isLogin = [VipPayPlus getInstance].isLogin;
            if (isLogin) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [cell.contentView addSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(cell.contentView);
                }];
                [btn bk_addEventHandler:^(id sender) {
                    [[VipPayPlus getInstance] showBuyWeb];
                } forControlEvents:UIControlEventTouchUpInside];
                if(vip){
                    NSString *endTime = [VipPayPlus getInstance].systemConfig.endTime;
                    endTime = endTime?endTime:@"";
                    if(endTime.length>10){
                        endTime = [endTime substringToIndex:10];
                    }
                    cell.textLabel.text = [NSString stringWithFormat:@"已经是会员,到期时间%@     (点击续费)",endTime];
                }
                else {
                    cell.textLabel.text = @"点击购买会员";
                }
            }
            else{
                cell.textLabel.text = @"请登录后开通会员";
            }
            cell.textLabel.textColor = [UIColor redColor];
        }
        else {
            cell.textLabel.textColor = RGBCOLOR(21, 152, 0);
            if(row==2){
                cell.textLabel.text = @"会员--拥有完美--下载视频--功能";
            }
            else if(row==3){
                cell.textLabel.text = @"会员--拥有更强播放器功能";
            }
            else if(row==4){
                cell.textLabel.text = @"会员--拥有更丰富的满足感内容";
            }
            else if(row==5){
                cell.textLabel.text = @"会员--拥有大福利";
            }
            else if(row==6){
                cell.textLabel.text = @"会员--取消所有广告";
            }
        }
        return cell;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14*fontS];
    return cell;
}

-(void)switchAction:(UISwitch*)btnSwitch
{
    if (btnSwitch.tag == 1 ) {
        [MarjorWebConfig getInstance].isRemoveAd = btnSwitch.on;
    }
    else if (btnSwitch.tag==2){
        [MarjorWebConfig getInstance].isCanReadMode = btnSwitch.on;
    }
    else if (btnSwitch.tag==3){
        [MarjorWebConfig getInstance].isAllowsBackForwardNavigationGestures = btnSwitch.on;
    }
    else if (btnSwitch.tag==5){
        [MarjorWebConfig getInstance].isAllowsAutoCachesVideoWhenPlay = btnSwitch.on;
    }
    else if (btnSwitch.tag==6){
        [MarjorWebConfig getInstance].isAllowsBackGroundDownMode = btnSwitch.on;
        GetAppDelegate.backGroundDownMode = btnSwitch.on;
    }
    else if (btnSwitch.tag==7){
        [MarjorWebConfig getInstance].isCleanMode = btnSwitch.on;
    }
    else if (btnSwitch.tag==9){
        [MarjorWebConfig getInstance].isOpenLocaNotifi = btnSwitch.on;
    }
    else if (btnSwitch.tag == Swtich4GTag){
        [MarjorWebConfig getInstance].isAllows4GDownMode = btnSwitch.on;
    }
    [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(_step>0&&indexPath.row==0 && section ==1)
    {
        [TmpSetView showTmpSetView:self];
//        if (!self.hcCtrl) {
//            self.hcCtrl = [[NSClassFromString(DOWNAPICONFIG.msgapp3) alloc] initWithNibName:DOWNAPICONFIG.msgapp3 bundle:nil];
//            [self addSubview:self.hcCtrl.view];
//            [self.hcCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self);
//            }];
//        }
    }
    else if(_step>0&&indexPath.row==1 && section ==1)
    {//金币获取列表
       /* if (!self.goldCtrl) {
            self.goldCtrl = [[GetGoldView alloc] initWithNibName:@"GetGoldView" bundle:nil];
            [self addSubview:self.goldCtrl.view];
            self.goldCtrl.delegate = self;
            [self.goldCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }*/
    }
    else if(_step>0&&indexPath.row==2 && section ==1)
    {
        NSString *strUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",PRODUCTID];
        NSURL *url = [NSURL URLWithString:strUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else if(_step>0&&indexPath.row==3&&section ==1){
        [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
            return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeQQFriend)];
        } value:^NSString *{
            return nil;
        } titleBlock:^NSString *{
            return nil;
        } imageBlock:^UIImage *{
            return nil;
        }urlBlock:^NSString  *{
            return nil;
        }shareViewTileBlock:^NSString *{
            return @"分享app给好友";
        }];
    }
    else if(_step>0&&indexPath.row==4&&section ==1){
        [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
            return @[@(SSDKPlatformSubTypeQZone),@(SSDKPlatformSubTypeWechatTimeline)];
        } value:^NSString *{
            return nil;
        } titleBlock:^NSString *{
            return nil;
        } imageBlock:^UIImage *{
            return nil;
        }urlBlock:^NSString  *{
            return nil;
        }shareViewTileBlock:^NSString *{
            return @"分享app到朋友圈";
        }];
    }
    else if ((_step == 0 && section==2 && row==0) || (_step > 0 && section==3 && row==0) ){
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            
            __weak __typeof(self)weakSelf = self;
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"更新收藏历史记录" message:nil];
            alertView.buttonFont = [UIFont systemFontOfSize:14];
            TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                         style:TYAlertActionStyleCancel
                                                       handler:^(TYAlertAction *action) {
                                                           
                                                       }];
            [alertView addAction:v];
            v  = [TYAlertAction actionWithTitle:@"看视频更新数据"
                                          style:TYAlertActionStyleDefault
                                        handler:^(TYAlertAction *action) {
                                            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
                                            [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                [weakSelf upldateAssetFromServer];
                                                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                                            } isShowAlter:YES isForce:false];
                                        }];
            [alertView addAction:v];
            [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
         }
    }
    else if ((_step == 0&&section==2 && row==6) || (_step > 0&&section==3 && row==6)) {
        [YSCHUDManager showHUDOnKeyWindowWithMesage:@"清除缓存中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MarjorWebConfig  clearAllCache];
            [ClearCachesTool clearCache];
            [ClearCachesTool clearWKWebKitCache];
            [ClearCachesTool clearSDImageDefaultCache];
            GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
            [YSCHUDManager hideHUDOnKeyWindow];
            [tableView reloadData];
        });
    }
    else if ((_step == 0&&section==2 && row==10) || (_step > 0&&section==3 && row==10)) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    else if ((_step == 0&&section==2 && row==8) || (_step > 0&&section==3 && row==8)){
        [self addSubview:[[MajorPrivacyView alloc] initWithFrame:self.bounds]] ;
    }
    else if((_step == 0&&section==2 && row==4) || (_step > 0&&section==3 && row==4)){
        [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
        GetAppDelegate.isVideoHistoryUpdate = !GetAppDelegate.isVideoHistoryUpdate;
        [YSCHUDManager showHUDThenHideOnView:self message:@"删除完成" afterDelay:1];
    }
    else if((_step == 0&&section==2 && row==5) || (_step > 0&&section==3 && row==5)){
        [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABLE_HISRECORD];
        [[MarjorWebConfig getInstance] removeSearchHots];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
        [YSCHUDManager showHUDThenHideOnView:self message:@"删除完成" afterDelay:1];
    }
    else if((section==2&&_step>0) || (section==1&&_step==0)){
        [self openFeedbackViewController];
    }
}

-(void)pressBack:(UIButton*)sender
{
    [self removeFromSuperview];
    //[self dismissViewControllerAnimated:YES completion:nil];
}



- (void)openFeedbackViewController {
    [[MajorFeedbackKit getInstance] openFeedbackViewController:GetAppDelegate.getRootCtrlView.nextResponder];
}

- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer {
     NSArray *subView = [super subviews];
    for (int i =0; i<subView.count; i++) {
        UIView *view = [subView objectAtIndex:i];
        BOOL t1 =[view isKindOfClass:[MajorICloudView class]];
        BOOL t2 =[view isKindOfClass:[MajorPrivacyView class]];
        BOOL t3 =[TmpSetView isShowState];
        BOOL t4 =self.goldCtrl?true:false;
        if (t1||t2||t3||t4) {
            return;
        }
    }
    [super doMoveAction:recognizer];
}


-(void)upldateAssetFromServer{
                [YSCHUDManager showHUDOnKeyWindowWithMesage:@"数据同步中"];
                BOOL ret =  [[MajorICloudSync getInstance] foceUpdateAsset:^(id _Nullable ret) {
                    [YSCHUDManager  hideHUDOnKeyWindow];
                    [YSCHUDManager  showHUDThenHideOnView:self message:@"同步数据成功" afterDelay:2];//:
                } failure:^(NSError * _Nonnull ret) {
                    [YSCHUDManager  hideHUDOnKeyWindow];
                    [YSCHUDManager  showHUDThenHideOnView:self message:@"未知错误或服务器没有最新数据" afterDelay:2];//:
                }];
                if (!ret) {
                    [YSCHUDManager hideHUDOnKeyWindow];
                    [YSCHUDManager  showHUDThenHideOnView:self message:@"已经是最新数据" afterDelay:2];//:
                }
}
@end
