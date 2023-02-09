//
//  ThrowUpLoadCtrl.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ThrowUpLoadCtrl.h"
#import "SGWiFiUploadManager.h"
#import "SVProgressHUD.h"
#import "ThrowUpdateFileManager.h"
#import "UpVideoThumbnail.h"
#import "VideoPlayerManager.h"
#import "FileDonwPlus.h"
#import "VipPayPlus.h"
#import "AppDelegate.h"
@interface ThrowUpLoadCtrl ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _isStartServer;
    NSTimer *_timerCheck;
    float cellH;
}
@property(nonatomic,strong)UIView *maskVipView;
@property(nonatomic,strong)NSMutableArray *arraylist;
@property(weak,nonatomic)IBOutlet UIView *topView;
@property(weak,nonatomic)IBOutlet UIButton *btnBack;
@property(weak,nonatomic)IBOutlet UILabel *ipDesLabel;
@property(weak,nonatomic)IBOutlet UIButton *btnDel;
@property(weak,nonatomic)IBOutlet UIButton *btnHelp;
@property(weak,nonatomic)IBOutlet UITableView *tableView;

@end

@implementation ThrowUpLoadCtrl

-(void)dealloc{ 
    NSLog(@"%s",__FUNCTION__);
}

-(void)startService{
    ThrowUpLoadCtrl * __weak weakSelf = self;
    [[SGWiFiUploadManager sharedManager]  startUpLoadServer:ThrowUpLoadHttpServerPort callBack:^(NSString *ip) {
         [weakSelf updateIpLabel:ip];
    } finshBlock:^(NSString *fileName, NSString *savePath) {
       [weakSelf reloadLocalData];
    }];
}

-(void)initUI{
    
}


-(void)updateIpLabel:(NSString*)des{
    self.ipDesLabel.text = [NSString stringWithFormat:@"%@",des ];
}

-(void)reloadLocalData{
    cellH = 140;
    if (IF_IPAD) {
        cellH = 280;
    }
    self.arraylist = [NSMutableArray arrayWithArray:[[ThrowUpdateFileManager getInstance] getAllVideoFile]];
    [self.tableView reloadData];
}

-(void)checkServer{
//    SGWiFiUploadManager *mgr = [SGWiFiUploadManager sharedManager];
//    if (![mgr isServerRunning]) {
//        HTTPServer *server = mgr.httpServer;
//        NSError *err = nil;
//        [server start:&err];
//    }
//    else{
//        NSString *ip_port = [NSString stringWithFormat:@"http://%@:%@",mgr.ip,@(mgr.port)];
//        [self updateIpLabel:ip_port];
//    }
}

-(void)stopService{
    [_timerCheck invalidate];
    _timerCheck = nil;
    [[SGWiFiUploadManager sharedManager] startHTTPServerAtPort:0 start:nil progress:nil finish:nil];
    //[[SGWiFiUploadManager sharedManager] stopHTTPServer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startService];
    _timerCheck = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkServer) userInfo:nil repeats:YES];
    [self reloadLocalData];
    if(IF_IPHONE){
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).mas_offset(GetAppDelegate.appStatusBarH);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(159);
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.topView.mas_bottom).mas_offset(8);
            make.bottom.equalTo(self.view);
        }];
    }
}

-(IBAction)pressBack:(id)sender{
    [self stopService];
    [self.delegate willRemoveThrowLoad:self];
  //  [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)pressDel:(id)sender{
    [self.tableView setEditing:!self.tableView.isEditing];
}

-(IBAction)pressHelp:(id)sender{
    NSURL *url =  [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"共享帮助" ofType:@"mov"]] ;
    [[VideoPlayerManager getVideoPlayInstance] playWithUrl:[url absoluteString] title:@"共享帮助" referer:nil saveInfo:nil replayMode:NO rect:DefalutVideoRect throwUrl:[url absoluteString]isUseIjkPlayer:false];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellH;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicInfo = [self.arraylist objectAtIndex:indexPath.row];
    NSString *strDirPath = [dicInfo objectForKey:Local_DirPath];
    NSString *strFileName = [dicInfo objectForKey:Local_FileName];
    NSString *url = [[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",strDirPath,strFileName]] absoluteString];
    NSLog(@"ThrowUpLoadUrl");
    
    NSRange range = [url rangeOfString:@"/upload_wifi/"];
    NSString *name = [url substringFromIndex:range.location+13];
    SGWiFiUploadManager *bb =[SGWiFiUploadManager sharedManager];
    NSString *throwUrl = [NSString stringWithFormat:@"http://%@:%d/%@",bb.ip,bb.port,name];
 //   [[ThrowVideoManager getInstance] playWithUrl:url title:strFileName referer:nil saveInfo:nil replayMode:NO rect:DefalutVideoRect throwUrl:throwUrl];
    [[VideoPlayerManager getVideoPlayInstance] playWithUrl:url title:@"共享帮助" referer:nil saveInfo:nil replayMode:NO rect:DefalutVideoRect throwUrl:throwUrl isUseIjkPlayer:false];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{;
    return self.arraylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width,cellH);
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UpVideoThumbnail *   thumbanail = [[UpVideoThumbnail alloc]initWithFrame:CGRectMake(0, 5, cell.bounds.size.width, cell.bounds.size.height-5)];
    __weak typeof(self)weakSelf = self;
    thumbanail.shareBlock = ^(NSString *uuid, BOOL shareState) {
        [weakSelf showVideo:uuid isShareState:shareState];
    } ;
    [cell.contentView addSubview:thumbanail];
    NSDictionary *dicInfo = [self.arraylist objectAtIndex:indexPath.row];
    NSString *strDirPath = [dicInfo objectForKey:Local_DirPath];
    NSString *strFileName = [dicInfo objectForKey:Local_FileName];
    [thumbanail showThumbanil:[NSString stringWithFormat:@"%@/%@",strDirPath,strFileName]];
    return cell;
}

-(void)showVideo:(NSString*)uuid isShareState:(BOOL)shareState {

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.isEditing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ThrowUpdateFileManager getInstance] delVideoFromAllFile:indexPath.row];
        // Delete the row from the data source.
        [self.arraylist removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
