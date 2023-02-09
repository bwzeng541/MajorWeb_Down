#import "MajorContactCtrl.h"
#import "MarjorWebConfig.h"
#import "SDWebImageDownloader.h"
#import "FileCache.h"
#import "AppDelegate.h"
#import "YSCHUDManager.h"
#import "MajorICloudSync.h"
#import "ClearCachesTool.h"
#import "MajorSystemConfig.h"
#import "ReactiveCocoa.h"
#import "MajorModeDefine.h"
#import "ShareSdkManager.h"
#import "MajorFeedbackKit.h"
@interface MajorContactCtrl ()<UITableViewDelegate,UITableViewDataSource>{
    int _step;//分享好友和朋友圈
}
@property(nonatomic,strong)UITableView *myTableView;
@end

@implementation MajorContactCtrl

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(5, 20, 50, 50);
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnBack];
    UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, MY_SCREEN_WIDTH, 50)];
    labelDes.text =@"联系我们";
    labelDes.textColor = [UIColor blackColor];
    labelDes.textAlignment = NSTextAlignmentCenter;
    [self.view insertSubview:labelDes belowSubview:btnBack];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 72, MY_SCREEN_WIDTH, 1)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [btnBack addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 75, MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT-75 ) style:UITableViewStylePlain];
    _myTableView.dataSource = self;
    _myTableView.rowHeight = 45;
    _myTableView.delaysContentTouches = NO;
    _myTableView.delegate = self;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    _myTableView.tableHeaderView = headerView;
    [self.view addSubview:_myTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [MajorSystemConfig getInstance].isOpen?4:6;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ContactListCell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
 
    if (indexPath.row==0){
        cell.textLabel.text = @"反馈意见";
    }
    else if (indexPath.row==1){
        cell.textLabel.text = @"提交需要屏蔽广告的网站";
    }
    else if (indexPath.row==2){
        cell.textLabel.text = @"我要推荐网站";
    }
    else if (indexPath.row==3) {
        cell.textLabel.text = @"论坛";
    }
    else if (indexPath.row==4) {
        cell.textLabel.text = @"分享好友";
    }
    else if (indexPath.row==5) {
        cell.textLabel.text = @"分享朋友圈";
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(row<=2){
        [self openFeedbackViewController];
    }
    else {
        if (row==3) {//http://47.96.26.202:16916/forum.php
            [self dismissViewControllerAnimated:YES completion:^{
                WebConfigItem *item = [[WebConfigItem alloc] init];
                [MarjorWebConfig getInstance].webItemArray = nil;
                item.url = @"http://47.96.26.202:16916/forum.php";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
            }];

        }
        else if (row==4){
            [[ShareSdkManager getInstance] shareHome:(SSDKPlatformSubTypeWechatSession)];
        }
        else if (row==5){
            [[ShareSdkManager getInstance] shareHome:(SSDKPlatformSubTypeWechatTimeline)];
        }
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
