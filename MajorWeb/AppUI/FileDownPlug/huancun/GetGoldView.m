//
//  GetGoldView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/21.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "GetGoldView.h"
#import "MajorPopGestureView.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "MajorGoldManager.h"
#import "AppDelegate.h"
@interface GetGoldView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MKNetworkEngine *engine;
@property(nonatomic,strong)MKNetworkOperation *timeOperation;
@property(nonatomic,strong)MBProgressHUD *progressHud;
@property(nonatomic,copy)NSString *cellID;
@property(nonatomic,strong)IBOutlet UIButton *btnBack;
@property(nonatomic,strong)IBOutlet UITableView *tableView;
@property(nonatomic,strong)IBOutlet UILabel *toplabelDes;
@property(nonatomic,strong)IBOutlet UILabel *goldlabelDes;

@property(nonatomic,assign)NSInteger number;
@property(nonatomic,strong)UIButton *shuaxinBtn;
@property(nonatomic,strong)NSDate *dateTime;
@end

@implementation GetGoldView

-(IBAction)pressBack:(id)sender{
    [self stop];
    [[MajorGoldManager getInstance] unInitWithDate];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.delegate back_from_gold];
 }

-(void)stop{
    [self.timeOperation cancel];
    self.timeOperation =nil;
    self.engine = nil;
    [self.progressHud hideAnimated:NO];
    self.progressHud = nil;
}

-(void)start{
    if (!self.engine) {
        RemoveViewAndSetNil(self.shuaxinBtn);
        self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.progressHud];
        self.progressHud.removeFromSuperViewOnHide = YES;
        [self.progressHud showAnimated:YES];
        self.number = 0;
        self.engine = [[MKNetworkEngine alloc] init];
        self.timeOperation = [self.engine operationWithURLString:@"http://quan.suning.com/getSysTime.do" timeOut:3];
        
        [self.timeOperation onCompletion:^(MKNetworkOperation *completedOperation) {
            NSInteger code= completedOperation.HTTPStatusCode;
            if (code>=200&& code<300) {
                id value = [completedOperation.responseString JSONValue];
                if ([value isKindOfClass:[NSDictionary class]]) {
                   NSString *v = [value objectForKey:@"sysTime2"];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    //设定时间格式,这里可以设置成自己需要的格式
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                  self.dateTime =  [dateFormatter dateFromString:v];
                    if (!self.dateTime) {
                        [self showFaild];
                    }
                    else{
                        [self.progressHud hideAnimated:NO];
                        self.progressHud = nil;
                        self.number = 5;
                        [[MajorGoldManager getInstance] initWithDate:self.dateTime];
                        [self.tableView reloadData];
                    }
                }
            }
            else{
                [self showFaild];
            }
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
            [self showFaild];
        }];
        [self.engine enqueueOperation:self.timeOperation];
    }
}

-(void)showFaild{
    [self stop];
    if (!self.shuaxinBtn) {
        self.shuaxinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shuaxinBtn setTitle:@"刷新重试" forState:UIControlStateNormal];
        [self.view addSubview:self.shuaxinBtn ];
        self.shuaxinBtn.frame = self.tableView.frame;
        [self.shuaxinBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)viewDidLoad{
    MajorPopGestureView *view =  (MajorPopGestureView*)self.view;
    __weak __typeof(self)weakSelf = self;
    view.isUsePopGesture = true;
    view.backBlock = ^{
        [weakSelf pressBack:nil];
    };
    float offsetFixY = GetAppDelegate.appStatusBarH-20;
    self.cellID = @"sfsf";
    self.toplabelDes.text = @"捐赠";
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
    
    rect = self.tableView.frame;
    self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.view.bounds.size.height-rect.origin.y- self.btnBack.bounds.size.height-offsetFixY);
    
    [self start];
    
    @weakify(self)
    [RACObserve([MajorGoldManager getInstance],goldNumber) subscribeNext:^(id x) {
        @strongify(self)
        self.goldlabelDes.text = @"";//[NSString stringWithFormat:@"拥有%ld金币",[MajorGoldManager getInstance].goldNumber];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        [[MajorGoldManager getInstance] showVideo];
    }
    else if (indexPath.row==1){
        [[MajorGoldManager getInstance] showFullVideo:true];
    }
    else if (indexPath.row==2) {
        [[MajorGoldManager getInstance] showPyq];
    }
    else if(indexPath.row==3){
        [[MajorGoldManager getInstance] showQQ];
    }
    else if(indexPath.row==4){
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{;
    return self.number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellID];
    }
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *leftLable = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    UILabel *rightLable = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    NSString *leftStr = @"";
    NSString *rightStr = @"我要捐赠";
    if (indexPath.row==0) {
        leftStr = @"观看视频";
    }
    else if(indexPath.row==1){
        leftStr = @"全屏视频";
    }
    else if(indexPath.row==2){
        leftStr = @"分享到朋友圈";

    }
    else if(indexPath.row==3){
        leftStr = @"分享到QQ空间";

    }
    else if(indexPath.row==4){
        leftStr = @"访问小说";
    }
    leftLable.text = leftStr;
    rightLable.text = rightStr;
    rightLable.textAlignment = NSTextAlignmentRight;
    leftLable.textAlignment = NSTextAlignmentLeft;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.contentView addSubview:leftLable];
    [cell.contentView addSubview:rightLable];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
@end
