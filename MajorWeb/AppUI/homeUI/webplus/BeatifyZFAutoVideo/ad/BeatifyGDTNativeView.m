//
//  BeatifyGDTNativeView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyGDTNativeView.h"
#import "AppDelegate.h"
#import "helpFuntion.h"
#import "UIView+BlocksKit.h"
#import "BeatifyNativeAdManager.h"
#import "MajorSystemConfig.h"
#import "VipPayPlus.h"
static NSString *nativeexpresscell = @"nativeexpresscell";
static BeatifyGDTNativeView *beatifyGdtView = NULL;
@interface BeatifyGDTNativeView()<BeatifyNativeAdManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign)CGSize adSize;
@property (nonatomic, strong) NSMutableArray *expressAdViews;
@property (nonatomic, strong) UIImageView *maskBtnView;
@property(copy,nonatomic)void(^willShow)(void);
@property(copy,nonatomic)void(^willRemove)(void);

@end


@implementation BeatifyGDTNativeView

+(void)stopGdtNatiview{
    [beatifyGdtView removeFromSuperview];beatifyGdtView = nil;
}

+(void)startBeatifyView:(void(^)(void))willShow willRemove:(void(^)(void))willRemove{
    if(beatifyGdtView==NULL && [VipPayPlus getInstance].systemConfig.vip!=General_User && GetAppDelegate.isGdtNativewShow &&  [[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:BeatifyAppCloseNativeKey nCount:1 intervalDay:3 isUseYYCache:false time:nil]){
        if(true)
        {
            beatifyGdtView = [[BeatifyGDTNativeView alloc] initWithFrame:CGRectMake(0, [MajorSystemConfig getInstance].appSize.height*1.5, [MajorSystemConfig getInstance].appSize.width, [MajorSystemConfig getInstance].appSize.height)];
            beatifyGdtView.willRemove =  willRemove;
            beatifyGdtView.willShow = willShow;
            [beatifyGdtView startAd];
            GetAppDelegate.isGdtNativewShow = false;
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:beatifyGdtView];
        }
    }
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    self.willShow = nil;
    self.willRemove = nil;
    GetAppDelegate.isGdtNativewShow = true;
    [BeatifyNativeAdManager getInstance].delegate = nil;
    [self.tableView removeFromSuperview];self.tableView = nil;
    [super removeFromSuperview];
}

-(void)closeBtn{
    [BeatifyNativeAdManager getInstance].delegate = nil;
    if (self.willRemove) {
        self.willRemove();
    }
    [beatifyGdtView removeFromSuperview];beatifyGdtView = nil;
}

-(void)initEvent{
    _maskBtnView.userInteractionEnabled = YES;
    __weak __typeof(self)weakSelf = self;
    [_maskBtnView bk_whenTapped:^{
        [weakSelf closeBtn];
    }];
}

-(void)addCloseBtn{
    _maskBtnView = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x+self.tableView.frame.size.width-50, self.tableView.frame.origin.y<GetAppDelegate.appStatusBarH?GetAppDelegate.appStatusBarH+10:self.tableView.frame.origin.y, 25, 25)];
    [self addSubview:_maskBtnView];
    _maskBtnView.image = [UIImage imageNamed:@"x_b_ad.png"];
    
    if([[helpFuntion gethelpFuntion] isValideCommonDay:BeatifyAppCloseNativeKey nCount:1 intervalDay:3 isUseYYCache:false time:nil])
    {
        _maskBtnView.userInteractionEnabled = NO;
    }
    else{
        [self initEvent];
    }

    UIImageView *backView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [MajorSystemConfig getInstance].appSize.width, [MajorSystemConfig getInstance].appSize.height)];
    backView.backgroundColor = RGBCOLOR(0, 0, 0);
    [self addSubview:backView];//640*960
    UIImageView *imageti = [[UIImageView alloc] initWithFrame:CGRectMake(0, [MajorSystemConfig getInstance].appSize.height-[MajorSystemConfig getInstance].appSize.width*1.5, [MajorSystemConfig getInstance].appSize.width, [MajorSystemConfig getInstance].appSize.width*1.5)];
    imageti.image = [UIImage imageNamed:@"beatify_app_tj.png"];
    [self addSubview:imageti];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBCOLOR(0, 0, 0);
    
    return self;
}

-(void)startAd{
    [BeatifyNativeAdManager getInstance].delegate = self;
    [[BeatifyNativeAdManager getInstance] startReqeust:true];
}

- (UITableView *)tableView {
    if (!_tableView) {
        float ww = self.adSize.width;
        float totalH = self.expressAdViews.count*self.adSize.height;
        float originY = ([MajorSystemConfig getInstance].appSize.height-totalH)/2;
        if (totalH>[MajorSystemConfig getInstance].appSize.height) {
            originY = GetAppDelegate.appStatusBarH;
            totalH = [MajorSystemConfig getInstance].appSize.height-(GetAppDelegate.appStatusBarH);
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,originY,ww,totalH) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:nativeexpresscell];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
         }
        _tableView.backgroundColor = RGBCOLOR(0, 0, 0);
        _tableView.estimatedRowHeight = 0;
        _tableView.scrollEnabled = NO;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    return _tableView;
}


-(void)beatifyNativeExpressAdSuccessToLoad:(NSArray*)adArray{
    NSLog(@"%s",__FUNCTION__);
    //随机交换
    self.expressAdViews = [NSMutableArray arrayWithArray:adArray];
    [self.expressAdViews shuffle];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = GetAppDelegate.window.rootViewController;
            [expressView render];
            NSLog(@"eCPM:%ld eCPMLevel:%@", [expressView eCPM], [expressView eCPMLevel]);
        }];
    }
}

-(void)beatifyNativeRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"%s",__FUNCTION__);
    self.frame = CGRectMake(0, 0, [MajorSystemConfig getInstance].appSize.width, [MajorSystemConfig getInstance].appSize.height);
    if (self.willShow) {
        self.willShow();
    }
    UIView *view = nativeExpressAdView;
    if (!_tableView) {
        self.adSize = view.frame.size;
        [self addSubview:self.tableView];

        [self addCloseBtn];
    }
    [self.tableView reloadData];
}

-(void)beatifyNativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView{
    [self initEvent];
    [self performSelector:@selector(closeBtn) withObject:nil afterDelay:1];
}

-(void)beatifyNativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView{
    [self.expressAdViews removeObject:nativeExpressAdView];
    [self.tableView reloadData];
}

-(void)beatifyNativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = [self.expressAdViews objectAtIndex:indexPath.row ];
    return view.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.expressAdViews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
    if ([subView superview]) {
        [subView removeFromSuperview];
    }
    UIView *view = [self.expressAdViews objectAtIndex:indexPath.row];
    view.tag = 1000;
    [cell.contentView addSubview:view];
    cell.accessibilityIdentifier = @"nativeTemp_ad";
    return cell;
}
@end
