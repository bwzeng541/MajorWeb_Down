//
//  MajorSetCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/9.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorSetCtrl.h"
#import "MarjorWebConfig.h"
#import "SDWebImageDownloader.h"
#import "FileCache.h"
#import "AppDelegate.h"
#import "YSCHUDManager.h"
#import "MajorICloudSync.h"
#import "ClearCachesTool.h"
#import "MajorSystemConfig.h"
#import "ReactiveCocoa.h"
#import "MajorICloudCtrl.h"
#import "ShareSdkManager.h"
#import "MajorFeedbackKit.h"
#import "MajorPrivacyCtrl.h"
#import "MajorPopGestureView.h"
@interface MajorSetCtrl ()<UITableViewDelegate,UITableViewDataSource>{
    int _step;//分享好友和朋友圈
}
@property(nonatomic,copy)NSString *sizeMsg;
@property(nonatomic,strong)UITableView *myTableView;
@end

@implementation MajorSetCtrl

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sizeMsg = @"计算中...";
    // Do any additional setup after loading the view.
    self.view = [[MajorPopGestureView alloc]initWithFrame:self.view.bounds];
    ((MajorPopGestureView*)self.view).isUsePopGesture = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(5, 20, 50, 50);
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnBack];
    _step = 0;
    if(![MajorSystemConfig getInstance].isOpen){
        _step = 3;
    }
#ifdef DEBUG
    _step = 3;
#endif
    UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, MY_SCREEN_WIDTH, 50)];
    labelDes.text =@"设置";
    labelDes.textColor = [UIColor blackColor];
    labelDes.textAlignment = NSTextAlignmentCenter;
    [self.view insertSubview:labelDes belowSubview:btnBack];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 72, MY_SCREEN_WIDTH, 1)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [btnBack addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 75, MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT-75 ) style:UITableViewStyleGrouped];
    _myTableView.dataSource = self;
    _myTableView.rowHeight = 45;
    _myTableView.delaysContentTouches = NO;
    _myTableView.delegate = self;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    _myTableView.tableHeaderView = headerView;
    [self.view addSubview:_myTableView];
    @weakify(self)
    
    [RACObserve([MarjorWebConfig getInstance],isSyncICloud) subscribeNext:^(id x) {
        @strongify(self)
        [self.myTableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section==0) {
        return 0.01;
    }
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_step==0)return 2;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_step==0) {
        return section==0?3:10;
    }
    else {
        if (section==0) {
            return 3;
        }
        else if (section==1){
            return 3;
        }
        return 10;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SetListCell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if(indexPath.row==0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UISwitch *switchBtn = nil;
    NSInteger section = indexPath.section;
    NSInteger row =  indexPath.row;
    if ((_step == 0 && section==1 && row==0) || (_step > 0 && section==2 && row==0) ){
        cell.textLabel.text = @"iCloud同步";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ([[MajorICloudSync getInstance] cloudIsAvailable]) {
            cell.detailTextLabel.text = @"打开";
        }
        else{
            cell.detailTextLabel.text = @"关";
        }
    }
    else if (  (_step == 0 && section==1 && row==1) || (_step > 0 &&section==2 && row==1)) {
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
    else if ((_step == 0&&section==1 && row==2) || (_step > 0&&section==2 && row==2)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isCanReadMode;
        cell.textLabel.text = @"阅读模式";
    }
    else if ((_step == 0&&section==1 && row==8) || (_step > 0&&section==2 && row==8)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isOpenLocaNotifi;
        cell.textLabel.text = @"本地推送";
    }
    else if ((_step == 0&&section==1 && row==9) || (_step > 0&&section==2 && row==9)){
          cell.textLabel.text = @"网络设置";
    }
    else if ((_step == 0 && section==1 && row==3) || (_step > 0&&section==2 && row==3)){
        switchBtn = [[UISwitch alloc]init];
        switchBtn.on = [MarjorWebConfig getInstance].isAllowsBackForwardNavigationGestures;
        cell.textLabel.text = @"手势返回";
    }
    else if ((_step == 0&&section==1 && row==4) || (_step > 0&&section==2 && row==4)){
        cell.textLabel.text = @"清除播放记录";
    }
    else if ((_step == 0&&section==1 && row==5) || (_step > 0&&section==2 && row==5)){
        cell.textLabel.text = @"清除历史记录";
    }
    else if ((_step == 0&&section==1 && row==6) || (_step > 0&&section==2 && row==6)){
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
    else if ((_step == 0&&section==1 && row==7) || (_step > 0&&section==2 && row==7)){
        cell.textLabel.text = @"隐私声明";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ((_step == 0&&section==0 && row==0) || (_step > 0&&section==1 && row==0)){
        cell.textLabel.text = @"反馈意见";
    }
    else if ((_step == 0&&section==0 && row==1) || (_step >0&&section==1 && row==1)){
        cell.textLabel.text = @"提交需要屏蔽广告的网站";
    }
    else if ((_step == 0&&section==0 && row==2) || (_step > 0&&section==1 && row==2)){
        cell.textLabel.text = @"我要推荐网站";
    }
    else if ((section==0 && row==0) || (section==0 && row==0)) {
        cell.textLabel.text = @"写评价--送会员功能";
    }
    else if ((section==0 && row==1) || (section==0 && row==1)) {
        cell.textLabel.text = @"分享app给好友";
    }
    else if ((section==0 && row==2) || (section==0 && row==2)) {
        cell.textLabel.text = @"分享app到朋友圈";
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (indexPath.row!=0) {
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    if (switchBtn) {
        [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        switchBtn.tag = indexPath.row;
        [cell.contentView addSubview:switchBtn];
        [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.right.equalTo(cell.contentView);
        }];
    }
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
    else if (btnSwitch.tag==8){
        [MarjorWebConfig getInstance].isOpenLocaNotifi = btnSwitch.on;
    }
    [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(_step>0&&indexPath.row==0 && section ==0)
    {
        NSString *strUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",PRODUCTID];
        NSURL *url = [NSURL URLWithString:strUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else if(_step>0&&indexPath.row==1&&section ==0){
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
    else if(_step>0&&indexPath.row==2&&section ==0){
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
    else if ((_step == 0 && section==1 && row==0) || (_step > 0 && section==2 && row==0) ){
        MajorICloudCtrl *v= [[MajorICloudCtrl alloc] init];
        [self presentViewController:v animated:NO completion:nil];
    }
    else if ((_step == 0&&section==1 && row==6) || (_step > 0&&section==2 && row==6)) {
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
    else if ((_step == 0&&section==1 && row==9) || (_step > 0&&section==2 && row==9)) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    else if ((_step == 0&&section==1 && row==7) || (_step > 0&&section==2 && row==7)){
        MajorPrivacyCtrl *v= [[MajorPrivacyCtrl alloc] init];
        [self presentViewController:v animated:NO completion:nil];
    }
    else if((_step == 0&&section==1 && row==4) || (_step > 0&&section==2 && row==4)){
        [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
        GetAppDelegate.isVideoHistoryUpdate = !GetAppDelegate.isVideoHistoryUpdate;
        [YSCHUDManager showHUDThenHideOnView:self.view message:@"删除完成" afterDelay:1];
    }
    else if((_step == 0&&section==1 && row==5) || (_step > 0&&section==2 && row==5)){
        [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABLE_HISRECORD];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
        [YSCHUDManager showHUDThenHideOnView:self.view message:@"删除完成" afterDelay:1];
    }
    else if((section==1&&_step>0) || (section==0&&_step==0)){
        [self openFeedbackViewController];
    }
}

-(void)pressBack:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)openFeedbackViewController {
    [[MajorFeedbackKit getInstance] openFeedbackViewController:self];
}

@end
