//
//  MajorICloudCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/20.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorICloudView.h"
#import "MarjorWebConfig.h"
#import "MajorICloudSync.h"
#import "YSCHUDManager.h"
#import "AppDelegate.h"
@interface MajorICloudView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,assign)BOOL isShowAlter;
@end

@implementation MajorICloudView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.isUsePopGesture = YES;
    self.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(5, GetAppDelegate.appStatusBarH, 50, 50);
    [btnBack setTitle:@"< 设置" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:btnBack];
    
    UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, 50)];
    labelDes.text =@"iCloud同步";
    labelDes.textColor = [UIColor blackColor];
    labelDes.textAlignment = NSTextAlignmentCenter;
    [self insertSubview:labelDes belowSubview:btnBack];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH+52, MY_SCREEN_WIDTH, 1)];
    [self addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [btnBack addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH+55, MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT-75 ) style:UITableViewStylePlain];
    _myTableView.dataSource = self;
    _myTableView.rowHeight = 45;
    _myTableView.delaysContentTouches = NO;
    _myTableView.delegate = self;
    [self addSubview:_myTableView];
    @weakify(self)
    [RACObserve([MarjorWebConfig getInstance],isSyncICloud) subscribeNext:^(id x) {
        @strongify(self)
        [self.myTableView reloadData];
    }];
    return self;
}

-(void)updateAlter{
        [YSCHUDManager showHUDOnKeyWindowWithMesage:@"数据同步中..."];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MajorICloudSync getInstance] syncNetToLoalInMainThread:nil failure:nil];
            [YSCHUDManager hideHUDOnKeyWindow];
            UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据同步成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [v show];
        });
}

- (void)pressBack:(UIButton*)sender{
    [self removeFromSuperview];
 }

 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[MajorICloudSync getInstance] cloudIsAvailable]?3:2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MajorIClund";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.row==0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row==0){
       // UISwitch * switchBtn = [[UISwitch alloc]init];
       // switchBtn.on = [[MajorICloudSync getInstance] cloudIsAvailable];
        cell.textLabel.text = @"数据同步";
        cell.detailTextLabel.text = [MajorICloudSync getInstance].iclondSyncDes;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        
        /*if (switchBtn) {
            [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            switchBtn.tag = indexPath.row;
            [cell.contentView addSubview:switchBtn];
            [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.right.equalTo(cell.contentView);
            }];
        }*/
    }
    else {
    if ([[MajorICloudSync getInstance] cloudIsAvailable]) {
        if (indexPath.row==1) {
            cell.textLabel.text = @"立即同步";
        }
        else if (indexPath.row==2){
            cell.textLabel.text = @"关于iCloud同步";
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else{
        if (indexPath.row==1) {
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = @"关于iCloud同步";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    return cell;
}

-(void)switchAction:(UISwitch*)btnSwitch
{
    /*
    if (btnSwitch.on) {
        if ([[iCloud sharedCloud]checkCloudAvailability]) {
            [[iCloud sharedCloud]updateFiles];
            [MarjorWebConfig getInstance].isSyncICloud = btnSwitch.on;
            [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateAlter];
            });
        }
        else{
            btnSwitch.on = NO;
            [MarjorWebConfig getInstance].isSyncICloud = NO;
            UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置中打开iCloud备份" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [v show];
        }
    }
    else{
        [MarjorWebConfig getInstance].isSyncICloud = NO;
        [MarjorWebConfig getInstance].updateConfig = ![MarjorWebConfig getInstance].updateConfig;
    }*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[MajorICloudSync getInstance] cloudIsAvailable]) {
        if (indexPath.row==2) {
            [self showMsgAlter];
        }
        else if (indexPath.row==1){//[[MajorICloudSync getInstance] syncNetToLoalInMainThread]
            [self updateAlter];
        }
    }
    else if(indexPath.row==1){
        [self showMsgAlter];
    }
}


-(void)showMsgAlter{
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"说明" message:@"iCloud将App配置、用户标签、收藏、历史记录存储在苹果服务器(Cookie以及账号密码不会同步)，防止数据丢失。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [v show];
}

@end
