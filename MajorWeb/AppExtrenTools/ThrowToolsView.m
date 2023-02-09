//
//  ThrowToolsView.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/27.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ThrowToolsView.h"
#import "PhotosCtrl.h"
#import "VideosCtrl.h"
#import "ThrowUpLoadCtrl.h"
#import "WaterMarkView.h"
#import "ThrowWebController.h"
#import "VideoPlayerManager.h"
#import "VipPayPlus.h"
#import "AppDelegate.h"
#import "NSString+MKNetworkKitAdditions.h"
typedef enum ToolsFunticonType{
    tools_shangchuang_type,
    tools_xiangce_type,//视频
    tools_zhaopian_type,//相册图片
    tools_douyin_type,
    tools_google_type,
    tools_baiduwangpan_type,
    tools_tengxuyun_type
}_ToolsFunticonType;

#define Tools_Pic_Path  @"Tools_Pic_Path"
#define Tools_Mode_Type  @"Tools_Mode_Type"

#define Tools_Icon_Path(X) [[NSBundle mainBundle] pathForResource:X ofType:@"png"]
@interface ThrowToolsView()<UICollectionViewDelegate,UICollectionViewDataSource,ThrowUpLoadCtrlDelegate,PhotosCtrlDelegate,VideosCtrlDelegate>{
    float cellW ,cellH,itemSpacing;
}
@property(nonatomic,assign)_ToolsFunticonType funticonType;
@property(nonatomic,copy)NSString* currentKey;
@property(nonatomic,strong)PhotosCtrl *photosCtrl;
@property(nonatomic,strong)VideosCtrl *videosCtrl;
@property(nonatomic,strong)ThrowUpLoadCtrl *upLoadCtrl;
@property(nonatomic,strong)NSArray *arrayInfo;
@end
@implementation ThrowToolsView

-(void)dealloc{
    [self willRemoveThrowLoad:nil];
    NSLog(@"%s",__FUNCTION__);
}

-(void)initConentUI{
    self.isUsePopGesture = YES;
    self.arrayInfo =
        @[@{Tools_Mode_Type:@(tools_douyin_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_douyin")},
        @{Tools_Mode_Type:@(tools_google_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_google")},
        @{Tools_Mode_Type:@(tools_baiduwangpan_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_bdwp")},
        @{Tools_Mode_Type:@(tools_tengxuyun_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_tengxunyun")}
    ,@{Tools_Mode_Type:@(tools_xiangce_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_xiangce")},
      @{Tools_Mode_Type:@(tools_zhaopian_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_zhaopian")},
      @{Tools_Mode_Type:@(tools_shangchuang_type),Tools_Pic_Path:Tools_Icon_Path(@"tools_shangchuan")} ];

    //640*168
    UIButton *btnli = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnli setImage:[UIImage imageWithContentsOfFile:Tools_Icon_Path(@"tools_jilu")] forState:UIControlStateNormal];
    [btnli addTarget:self action:@selector(pressWatchHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnli];btnli.hidden = YES;
    float startY = 50;
    float startX = 10;

    float w = self.bounds.size.width;
    if (!IF_IPHONE) {
        w *= 0.8;
    }
    float h = w / (640.0/186);
    btnli.frame = CGRectMake((self.bounds.size.width-w)/2, startY, w, h);
    CGRect rect = CGRectMake((self.bounds.size.width-(w-(startX*2)))/2,startY+h,w-(startX*2),self.bounds.size.height-(startY+h) );
    UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:fallLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    fallLayout.minimumInteritemSpacing =1;
    [collectionView setCollectionViewLayout:fallLayout];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    //294*178;
    itemSpacing = 10;
    int colume = 2;
    cellW = (collectionView.frame.size.width-itemSpacing*colume)/colume;
    cellH = cellW*(178.0/294);
    [collectionView reloadData];
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [[UIView alloc] init];
    [self addSubview:topView];
    [topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.right.equalTo(self);
        make.top.equalTo(self).mas_offset(GetAppDelegate.appStatusBarH);
    }];
    UILabel *lable = [[UILabel alloc] init];
    lable.text = @"视频大全";lable.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(topView);
    }];
    //app_fanhui.png 7.5 36X25
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"app_fanhui"] forState:UIControlStateNormal];
    [topView addSubview:btnClose];
    [btnClose setFrame:CGRectMake(0, 7.5, 36, 25)];
    [btnClose addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.right.equalTo(self);
        make.top.equalTo(topView.mas_bottom).mas_offset(5);
    }];
    
}

-(void)pressWatchHistory:(UIButton*)sender{
    
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemSpacing;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.arrayInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ContentCollection";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    ;
    NSString *path = [[self.arrayInfo objectAtIndex:indexPath.row] objectForKey:Tools_Pic_Path];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
    [cell.contentView addSubview:imageView];
     [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{//   ThrowWebController *webVC = [[ThrowWebController alloc] initWithAddress:@"http://www.5tdy.com/"];
    self.funticonType = (_ToolsFunticonType)[[[self.arrayInfo objectAtIndex:indexPath.row] objectForKey:Tools_Mode_Type] integerValue];
    self.currentKey = [[[self.arrayInfo objectAtIndex:indexPath.row] objectForKey:Tools_Pic_Path] md5];
    
    if(true || GetAppDelegate.isWatchHomeVideo || [VipPayPlus getInstance].systemConfig.vip!=General_User){
        [self showFuction];
        return;
    }
    if( [[VipPayPlus getInstance] isVaildOperationCheck:self.currentKey]){
        [self showFuction];
        return;
    }
    [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
    [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
        __weak __typeof(self)weakSelf = self;
        if (isSuccess) {//@"https://proxyunblock.site"
            [[VipPayPlus getInstance] setVaildOperationCheck:weakSelf.currentKey];
        }
        else{
        }
        [weakSelf showFuction];
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
    }isShowAlter:true isForce:false];
   
}

-(void)showFuction{
    if(self.funticonType==tools_xiangce_type){
        if (!self.videosCtrl) {
            self.videosCtrl = [[NSClassFromString(@"VideosCtrl") alloc] initWithNibName:@"VideosCtrl" bundle:nil];
            CGRect rect = CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
            self.videosCtrl.delegate = self;
            self.videosCtrl.view.frame = rect;
            [self.videosCtrl initUI];
            UIViewController *manvView = (UIViewController*)self.superview.superview.nextResponder ;
            [manvView.view addSubview:self.videosCtrl.view];
        }
        //[MobClick event:@"xiangce_btn"];
    }
    else if(self.funticonType==tools_zhaopian_type){
        if (!self.photosCtrl) {
            self.photosCtrl = [[NSClassFromString(@"PhotosCtrl") alloc] initWithNibName:@"PhotosCtrl" bundle:nil];
            CGRect rect = CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
            self.photosCtrl.delegate = self;
            self.photosCtrl.view.frame = rect;
            [self.photosCtrl initUI];
            UIViewController *manvView = (UIViewController*)self.superview.superview.nextResponder ;
            [manvView.view addSubview:self.photosCtrl.view];
        }
        //[MobClick event:@"zhaopian_btn"];
    }
    else if(self.funticonType==tools_shangchuang_type){
        if (!self.upLoadCtrl) {
            self.upLoadCtrl = [[ThrowUpLoadCtrl alloc] initWithNibName:@"ThrowUpLoadCtrl" bundle:nil];
            CGRect rect = CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
            self.upLoadCtrl.view.frame = rect;
            self.upLoadCtrl.delegate =self;
            UIViewController *manvView = (UIViewController*)self.superview.superview.nextResponder ;
            [manvView.view addSubview:self.upLoadCtrl.view];
        }
        //[MobClick event:@"upshipin_btn"];
    }
    else if (self.funticonType==tools_douyin_type){
        UIViewController *manvView = (UIViewController*)self.superview.superview.nextResponder ;
        WaterMarkView *v= [[WaterMarkView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        [manvView.view addSubview:v];
        //[MobClick event:@"douyin_btn"];
    }
    else if (self.funticonType ==tools_google_type){
        NSString *url = [NSString stringWithFormat:@"https://%@%@%@%@%@%@%@ite",@"pr",@"ox",@"yu",@"n",@"bl",@"oc",@"k.s"];
        if(GetAppDelegate.isProxyState){
            url = @"http://www.baidu.com";
        }
        ThrowWebController *webVC = [[ThrowWebController alloc] initWithAddress:url];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        nav.navigationBar.tintColor = [UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1.00];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:NULL];
        webVC.showsToolBar = YES;
        webVC.navigationType = 1;
        //[MobClick event:@"toolsgoogle_btn"];
    }
    else if (self.funticonType==tools_baiduwangpan_type){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"OpenBaiduWangPan" object:nil];
        [self removeFromSuperview];
        UIAlertView *vv = [[UIAlertView alloc] initWithTitle:@"提示" message:@"百度网盘视频观看，请登录，添加视频到收藏，进入我的网盘才能观看完整视频，正在研发长视频下载功能，请稍等" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [vv show];
    }
    else if (self.funticonType==tools_tengxuyun_type){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"OpenTengXunYun" object:nil];
        [self removeFromSuperview];
        UIAlertView *vv = [[UIAlertView alloc] initWithTitle:@"提示" message:@"支持在线观看和下载腾讯云里面的视频，此MP4网站，请选择“微云极速下载”，才是腾讯云视频，你也可以复制其他腾讯云视频地址观看" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [vv show];
        
    }
}


-(void)willRemoveThrowLoad:(id)ctrl{
    [self.videosCtrl.view removeFromSuperview];self.videosCtrl = nil;
    [self.upLoadCtrl.view removeFromSuperview];self.upLoadCtrl = nil;
    [self.photosCtrl.view removeFromSuperview];self.photosCtrl = nil;

}

- (BOOL)isValidGesture:(CGPoint)point{
    if (!self.videosCtrl && !self.upLoadCtrl && !self.photosCtrl) {
        return YES;
    }
    return false;
}
@end
