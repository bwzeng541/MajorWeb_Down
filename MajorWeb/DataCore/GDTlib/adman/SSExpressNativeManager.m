//
//  SSExpressNativeManager.m
//  WatchApp
//
//  Created by zengbiwang on 2018/6/26.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "SSExpressNativeManager.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "GdtUserManager.h"
#import "AppDelegate.h"
#import "UIDevice+YSCKit.h"
#import "IQUIWindow+Hierarchy.h"
#import <SafariServices/SafariServices.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "BlocksKit+UIKit.h"
#import "JSON.h"
#import "helpFuntion.h"
#import "OnlineAdManager.h"
#import "SSDjsView.h"
#import "Toast+UIView.h"
#import "MajorSystemConfig.h"
#define ClickSaveKeySSExpressNativeManager @"20180629ESS"
#define ClickSSExpressNativeFlat @"20180629_ESSS"
#define ClickSSExpressNativeLastInfo @"201806329_last_info"

#define RemoveSxpressAdView [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { \
GDTNativeExpressAdView *adView = (GDTNativeExpressAdView *)obj; adView.alpha=1; \
[adView removeFromSuperview]; \
}];


@implementation SFSafariViewController(vv)

- (void)viewWillAppear:(BOOL)animated{//
    [super viewWillAppear:animated];
    if(false &&  [[SSExpressNativeManager getInstance] isCanAddCustomUI] && ![[UIApplication sharedApplication].keyWindow viewWithTag:100] && [MajorSystemConfig getInstance].msgappSaInfo){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [MajorSystemConfig getInstance].appSize.width*10, 55)];
        label.backgroundColor = RGBACOLOR(0, 0, 0, 1);
        label.tag =100;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:20];
        label.text = @"    关闭";
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [label bk_whenTapped:^{
            [weakSelf disCtrl];
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.centerX.equalTo([UIApplication sharedApplication].keyWindow );
            make.height.mas_equalTo(55);
            make.width.mas_equalTo([MajorSystemConfig getInstance].appSize.width*10);
        }];
        
        {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [MajorSystemConfig getInstance].appSize.width*10, 55)];
        label.backgroundColor = RGBACOLOR(0, 0, 0, 1);
        label.tag =101;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:20];
        label.text = @"推荐产品，感谢支持";
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [label bk_whenTapped:^{
            [weakSelf disCtrl];
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.centerX.equalTo([UIApplication sharedApplication].keyWindow );
            make.height.mas_equalTo(55);
            make.width.mas_equalTo([MajorSystemConfig getInstance].appSize.width*10);
        }];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:101] removeFromSuperview];
    [[[UIApplication sharedApplication].keyWindow viewWithTag:100] removeFromSuperview];
}


-(void)disCtrl{//私有api
    NSString *ma = [[MajorSystemConfig getInstance].msgappSaInfo objectForKey:@"param3"];
    Ivar iVar = class_getInstanceVariable([self class], [ma UTF8String]);
    id v = object_getIvar(self, iVar);//willDismissServiceViewController
    if (v) {
        SEL  selector = NSSelectorFromString([[MajorSystemConfig getInstance].msgappSaInfo objectForKey:@"param2"]);
        NSMethodSignature *signature = [NSClassFromString([[MajorSystemConfig getInstance].msgappSaInfo objectForKey:@"param1"]) instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = v;
        invocation.selector = selector;
        [invocation invoke];
    }
}
@end

@interface SSExpressNativeManager()<GDTNativeExpressAdDelegete>
@property(nonatomic,strong) GDTNativeExpressAd *nativeExpressAd;
@property(nonatomic,strong)NSArray *expressAdViews;
@property(nonatomic,strong)NSMutableArray *expressSuccessViews;
@property(nonatomic,strong)UIView *interstitialView;
@property(assign,nonatomic)BOOL isRenderSuccess;
@property(nonatomic,strong)NSArray *tmpArray;
@property(nonatomic,assign)UIInterfaceOrientationMask oldOrientationMask;
@property(nonatomic,assign)UIInterfaceOrientation oldOrientation;

@property(nonatomic,assign)BOOL isCanCheckWhenFront;
@property(nonatomic,strong)NSTimer *checkInterstitiiTImer;
@property(nonatomic,strong)NSTimer *updateLoadNativeTimer;

//
@property(nonatomic,assign)BOOL isVideoFullMode;//此字段通过电影全屏以及非全屏模式更新
//保存信息流点击数据,
@property(retain)NSMutableDictionary *clickInfo;
@property(copy)NSString *currentSSExpressKey;

@property(assign)NSInteger startIndex;
@end

@implementation SSExpressNativeManager
+(SSExpressNativeManager*)getInstance{
    return nil;
    static SSExpressNativeManager*g = nil;
    if (!g) {
        g = [[SSExpressNativeManager alloc]init];
    }
    return g;
}

//在全屏模式以及显示出广告的情况下，不切换id
-(BOOL)isCanChangeID{
    if(self.isVideoFullMode&&self.interstitialView){
        return false;
    }
    return true;
}

-(id)init{
    self = [super init];
    self.expressSuccessViews = [NSMutableArray arrayWithCapacity:1];
    self.isCanCheckWhenFront = true;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNativeExpressAd) name:@"GdtUserIDChange" object:NULL];
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
            selector:@selector(applicationDidEnterForeground:)
                name:UIApplicationDidBecomeActiveNotification
              object:[UIApplication sharedApplication]];
    [def addObserver:self
            selector:@selector(applicationDidEnterBackground:)
                name:UIApplicationDidEnterBackgroundNotification
              object:[UIApplication sharedApplication]];
    
    [def addObserver:self
            selector:@selector(onlineCtrlIntoEvent:)
                name:OnlineMovieIntoFullEvent
              object:nil];
    [def addObserver:self
            selector:@selector(onlineCtrlExitSmallEvent:)
                name:OnlineMovieExitSmallEvent
              object:nil];
    
    self.clickInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSData *data =[FTWCache objectForKey:ClickSaveKeySSExpressNativeManager useKey:YES];
    if (data) {
        self.clickInfo = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] JSONValue];
    }
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(changeAdID:) userInfo:nil repeats:YES];
    return self;
}

-(void)syncLocal{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [[self.clickInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [FTWCache setObject:data forKey:ClickSaveKeySSExpressNativeManager useKey:YES];
    });
}

-(void)updateClickKey:(NSString*)key{
    [self.clickInfo setObject:@"1" forKey:key];
    [self syncLocal];
}

-(void)deleleClickKey:(NSString*)key{
    [self.clickInfo removeObjectForKey:key];
    [self syncLocal];
}

-(BOOL)isCanAddCustomUI{
    if (self.isVideoFullMode) {
        return true;
    }
    if (self.interstitialView) {
        return true;
    }
    return false;
}

-(void)removeExpressFromArray:(NSArray*)array{
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GDTNativeExpressAdView *adView = (GDTNativeExpressAdView *)obj;
        adView.alpha=1;
        [adView removeFromSuperview];
    }];
}

-(BOOL)isShowExpressInterstitial:(UIViewController*)ctrl showPartView:(UIView*)shawPartView
{
    BOOL ret = false;
    NSInteger start = (self.startIndex+1) % self.expressSuccessViews.count;
    GDTNativeExpressAdView *adViewFind=nil;
    for (int i = 0; i < self.expressSuccessViews.count; i++) {
        GDTNativeExpressAdView *adView = [self.expressSuccessViews objectAtIndex:start];
        if (!adView.superview && !self.interstitialView) {//加载key
            adViewFind = adView;
            break;
        }
        else{
            start = (start+1)%self.expressSuccessViews.count;
        }
    }
    self.startIndex = start;
    if (adViewFind) {
        GDTNativeExpressAdView *adView = adViewFind;
        if (!adView.superview && !self.interstitialView) {//加载key
            if (!self.isVideoFullMode) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SSExpressNativeManagerShowStateNotifi object:[NSNumber numberWithBool:true]];
            }
            BOOL isCanTrans = false;
            UIViewController *fullCtrl = nil;
            UIViewController *vv =  [[[UIApplication sharedApplication] keyWindow] topMostController];
            if (![vv isKindOfClass:NSClassFromString(VideoCtrlSystem)]) {
                if (GetAppDelegate.supportRotationDirection==UIInterfaceOrientationMaskLandscape) {
                    isCanTrans = true;
                }
                if(!self.isVideoFullMode)//已经修改成在点击btn47api的时候有效，不用旋转,0.012无效，btn最好用不透明的
                {
                        self.oldOrientationMask = GetAppDelegate.supportRotationDirection;
                        self.oldOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                        GetAppDelegate.supportRotationDirection = UIInterfaceOrientationMaskPortrait;
                        [UIDevice forceToChangeInterfaceOrientation:UIInterfaceOrientationPortrait];
                }
                else{
                    isCanTrans = false;
                }
            }
            else{
                fullCtrl = vv;
            }
            
            self.interstitialView = [[UIView alloc] init];
            self.interstitialView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
            if (self.isVideoFullMode) {
                self.interstitialView.backgroundColor = [UIColor clearColor];
            }
            UIView *keyView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
            adView.controller = GetAppDelegate.window.rootViewController;
            if (fullCtrl) {
                keyView = fullCtrl.view;
                adView.controller = fullCtrl;
            }
            if (shawPartView) {
                keyView = shawPartView;
            }
            if (ctrl) {
                adView.controller = ctrl;
            }
            if (self.isVideoFullMode) {
                [keyView insertSubview:self.interstitialView atIndex:0];
            }
            else
            {
                [keyView addSubview:self.interstitialView];
            }
            [self.interstitialView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (self.isVideoFullMode) {
                    make.center.equalTo(keyView);
                    make.width.mas_equalTo(keyView);
                    make.height.mas_equalTo(keyView);
                }
                else{
                    make.center.equalTo(keyView);
                    make.height.mas_equalTo([MajorSystemConfig getInstance].appSize.height);
                    make.width.mas_equalTo([MajorSystemConfig getInstance].appSize.height);
                }
            }];
            [self.interstitialView addSubview:adView];
            CGSize size = adView.frame.size;
            [adView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (self.isVideoFullMode) {
                    make.edges.equalTo(self.interstitialView);
                 }
                else{
                    make.center.equalTo(self.interstitialView);
                    make.width.mas_equalTo(size.width);
                    make.height.mas_equalTo(size.height);
                }
            }];
            
            UIView *maskView = [[UIView alloc] init];
            maskView.backgroundColor = [UIColor blackColor];
            [self.interstitialView addSubview:maskView];
            [maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.interstitialView);
            }];
            maskView.userInteractionEnabled = NO;
            //640X529
            UIImageView *imageGoOn = [[UIImageView alloc] init];
            imageGoOn.userInteractionEnabled = NO;
            imageGoOn.image = UIImageFromNSBundlePngPath(@"ss_interstitial_go_on");
            [self.interstitialView addSubview:imageGoOn];
            [imageGoOn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.interstitialView);
                make.width.mas_equalTo(size.width);
                make.height.mas_equalTo(529.0/640*size.width);
            }];
            
            //kill btn
            UIButton *btnkill = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnkill setImage:UIImageFromNSBundlePngPath(@"ss_interstitial_kill") forState:UIControlStateNormal];
            [self.interstitialView addSubview:btnkill];
            [btnkill mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.interstitialView);
                make.top.equalTo(imageGoOn.mas_bottom);
                make.width.mas_equalTo(size.width);
                make.height.mas_equalTo(172.0/640*size.width);
            }];
            [btnkill addTarget:self action:@selector(killIt:) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.isVideoFullMode) {
                btnkill.alpha =0;
                imageGoOn.alpha =0;
                maskView.alpha = 0;
            }
            UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnClose addTarget:self action:@selector(closeInterstitial) forControlEvents:UIControlEventTouchUpInside];
            [self.interstitialView addSubview:btnClose];
            [btnClose setImage:UIImageFromNSBundlePngPath(@"ss_interstitial_close") forState:UIControlStateNormal];
            [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(40);
                make.top.equalTo(adView.mas_top).mas_offset(10);
                make.right.equalTo(adView.mas_right);
            }];
            btnClose.tag = 12345;
            btnClose.hidden = YES;
          
            if(isCanTrans){
             self.interstitialView.transform = CGAffineTransformRotate(self.interstitialView.transform, M_PI_2);
            }
            self.tmpArray = @[adView];
            if (self.intsertitialBlock) {
                self.intsertitialBlock(false);
            }
            if (self.filmPlayerIntsertitialBlock) {
                self.filmPlayerIntsertitialBlock(false);
            }
            if (self.isVideoFullMode) {
                adView.alpha=0.012;
            }
            else{
                adView.alpha=0.012;
            }
            if (self.isVideoFullMode) {
                SSDjsView *vv = [[SSDjsView alloc] init];
                [self.interstitialView addSubview:vv];
                vv.tag = 12346;
                [vv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.interstitialView).mas_offset(10);
                    make.right.equalTo(self.interstitialView).mas_offset(-10);
                    if (IF_IPHONE) {
                        make.width.mas_equalTo(132/2.0);
                        make.height.mas_equalTo(52/2.0);
                    }
                    else{
                        make.width.mas_equalTo(132);
                        make.height.mas_equalTo(52);
                    }
                }];
                __weak typeof(self) weakSelf = self;
                vv.autoRemove = ^{
                  //  [weakSelf closeInterstitial];
                };
            }
            ret = true;
        }
    }
    if (ret) {
        NSLog(@"stop updateLoadNativeTimer = nil");
        [self.updateLoadNativeTimer invalidate];
        self.updateLoadNativeTimer = nil;
    }
    return ret;
}

-(void)killIt:(UIButton*)sender{
    abort();
}

-(void)closeInterstitial{
    if (self.interstitialView) {
        self.isVideoFullMode = false;
        [[self.interstitialView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.interstitialView removeFromSuperview];
        self.interstitialView = nil;
        if (self.intsertitialBlock) {
            self.intsertitialBlock(true);
        }
        if (self.filmPlayerIntsertitialBlock) {
            self.filmPlayerIntsertitialBlock(true);
        }
        self.filmPlayerIntsertitialBlock =  nil;
        UIViewController *vv =  [[[UIApplication sharedApplication] keyWindow] topMostController];
        if (![vv isKindOfClass:NSClassFromString(VideoCtrlSystem)]){
            if (self.oldOrientationMask!=0) {
                GetAppDelegate.supportRotationDirection = self.oldOrientationMask;
            }
            if (GetAppDelegate.supportRotationDirection==UIInterfaceOrientationMaskLandscape) {
                [UIDevice forceToChangeInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
            }
            else{
                if (self.oldOrientation!=UIInterfaceOrientationUnknown) {
                    [UIDevice forceToChangeInterfaceOrientation:self.oldOrientation];
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SSExpressNativeManagerShowStateNotifi object:[NSNumber numberWithBool:false]];
        [self.updateLoadNativeTimer invalidate];self.updateLoadNativeTimer = nil;
        self.updateLoadNativeTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateLoadNative) userInfo:nil repeats:YES];
        self.isCanCheckWhenFront = true;
        NSLog(@"closeInterstitial add reStart updateLoadNativeTimer");
    }
}

-(NSArray*)getExpressNotSupreView:(NSInteger)maxCount
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: 1];
    if (maxCount>=self.expressSuccessViews.count) {
      //  maxCount--;
    }
    if(self.expressSuccessViews.count<=1){
        return array;
    }
    maxCount = maxCount/2;
    for (int i = 0; i < self.expressSuccessViews.count && i < maxCount; i++) {
         GDTNativeExpressAdView *adView = [self.expressSuccessViews objectAtIndex:i];
        adView.alpha=1;
        if (!adView.superview) {
            [array addObject:adView];
        }
    }
    return array;
}

-(void)stopLoadNativeExpressAd
{
    [self.updateLoadNativeTimer invalidate];self.updateLoadNativeTimer = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setRenderState) object:nil];
    self.isRenderSuccess = false;
    [self removeExpressFromArray:self.tmpArray];
    RemoveSxpressAdView
    [self.expressSuccessViews removeAllObjects];
}

-(void)loadNativeExpressAd{
    //重新拉取5条广告
    return;
    [self stopLoadNativeExpressAd];
    if([MajorSystemConfig getInstance].isGotoUserModel==1)
    {
        NSDictionary *info = [[GdtUserManager getInstance] getExpressInfo];
        NSString *appkey = [info objectForKey:@"appkey"];//@"1105344611";//
        NSString *placementId =  [info objectForKey:@"placementId"];//@"5030722621265924";//
        if (appkey && placementId) {
            self.currentSSExpressKey = [NSString stringWithFormat:@"%@%@",appkey,placementId];
            CGSize size = CGSizeMake([MajorSystemConfig getInstance].appSize.width,[MajorSystemConfig getInstance].appSize.width/(4/3.0));
            if (IF_IPHONE) {
                
            }
            self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:appkey placementId:placementId adSize:size];
            self.nativeExpressAd.delegate = self;
            [self.nativeExpressAd loadAd:10];
            
            self.updateLoadNativeTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateLoadNative) userInfo:nil repeats:YES];
        }
    }
}

//在isRenderSuccess==true的时候才停止
-(void)onlineCtrlIntoEvent:(NSNotification*)object{
    if (_isRenderSuccess) {
        self.isVideoFullMode = true;
        [self.updateLoadNativeTimer invalidate];
        self.updateLoadNativeTimer = nil;
        [[GdtUserManager getInstance] checkStateShowInterstitial];
    }
}

-(void)onlineCtrlExitSmallEvent:(NSNotification*)object{
    self.isVideoFullMode = false;
    [self.updateLoadNativeTimer invalidate];
    self.updateLoadNativeTimer = nil;
    self.updateLoadNativeTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateLoadNative) userInfo:nil repeats:YES];
}


-(void)updateLoadNative{
    [self loadNativeExpressAd];
}

-(void)setRenderState{
    self.isRenderSuccess = true;
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setRenderState) object:nil];
    [self performSelector:@selector(setRenderState) withObject:nil afterDelay:1];
    [self.expressSuccessViews addObject:nativeExpressAdView];
}

- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView{
 
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setRenderState) object:nil];
        self.isRenderSuccess = false;
        [self performSelector:@selector(loadNativeExpressAd) withObject:nil afterDelay:1];
    });
}

- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
    RemoveSxpressAdView
    self.expressAdViews = [NSArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            [expressView render];
        }];
    }    
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSString *msg = @"nativeExpressAdViewClicked";
    if (self.interstitialView)
    {//点击隐藏的插屏
        msg = @"nativeExpressAdViewClicked_1";
        [[OnlineAdManager getInstance] updateClickInfo];
        [[self.interstitialView viewWithTag:12346] removeFromSuperview];
        [self.interstitialView viewWithTag:12345].hidden = NO;
        if(!self.isVideoFullMode){
            [[helpFuntion gethelpFuntion] isValideOneDay:ClickSSExpressNativeFlat nCount:1 isUseYYCache:false time:nil];
            self.isCanCheckWhenFront = false;
            if (self.currentSSExpressKey) {
                [self updateClickKey:self.currentSSExpressKey];
                [FTWCache setObject:[self.currentSSExpressKey dataUsingEncoding:NSUTF8StringEncoding] forKey:ClickSSExpressNativeLastInfo useKey:YES];
            }
        }
        else{
            msg = @"nativeExpressAdViewClicked_2";
            self.isCanCheckWhenFront = false;
            //防止点击不消失，移开这个试图
            if(self.interstitialView && self.interstitialView.superview){
                UIView *view = self.interstitialView.superview;
                [self.interstitialView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.centerX.height.equalTo(view);
                    make.top.equalTo(view.mas_bottom);
                }];
            }
        }
        //[MobClick event:@"nativeExpressAdViewClicked"];
    }
    [GetAppDelegate.window makeToast:msg duration:2 position:@"center"];
}

- (void)nativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    [self closeInterstitial];
    self.isCanCheckWhenFront = true;
    if (self.intsertitialBlock) {
        self.intsertitialBlock(true);
    }
}

-(void)changeAdID:(NSTimer*)timer{
    [self delayLoad];
}

-(void)delayLoad{
    NSArray *array = [MajorSystemConfig getInstance].gdtUserExpressInfo;
    if([array count]>0 && [[GdtUserManager getInstance] initAdInfo] && self.isCanCheckWhenFront)
    {
#if DEBUG
        [GetAppDelegate.window makeToast:@"切换广告id成功" duration:2 position:@"center"];
#endif
        self.checkInterstitiiTImer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkState:) userInfo:nil repeats:YES];
    }
    self.isCanCheckWhenFront = true;
}

-(void)applicationDidEnterBackground:(NSNotification*)object{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayLoad) object:nil];
        [self.checkInterstitiiTImer invalidate];
        self.checkInterstitiiTImer = nil;
}
                                      
-(void)applicationDidEnterForeground:(NSNotification*)object{
    if (!self.isVideoFullMode) {
        [self.checkInterstitiiTImer invalidate];
        self.checkInterstitiiTImer = nil;
      //  [self performSelector:@selector(delayLoad) withObject:nil afterDelay:1];
    }
}

-(void)checkState:(NSTimer*)timer{
    //需要更具实际情况判断，是否弹出广告
    if ([self isCanShowItToDay]) {//不需要弹出广告
      //  if([[GdtUserManager getInstance] checkStateShowInterstitial]){
            [self.checkInterstitiiTImer invalidate];
            self.checkInterstitiiTImer = nil;
        //}
    }
    else{
        [self.checkInterstitiiTImer invalidate];
        self.checkInterstitiiTImer = nil;
    }
}

-(BOOL)isCanShowItToDay{
    //
    if (![[GdtUserManager getInstance] isRootCtrlVaild]) {
        return false;
    }
    if (!self.interstitialView && [[helpFuntion gethelpFuntion] isValideOneDayNotAutoAdd:ClickSSExpressNativeFlat nCount:1 isUseYYCache:false time:nil])
    {
        NSArray *array = [MajorSystemConfig getInstance].gdtUserExpressInfo;
        NSMutableDictionary *notClickKey = [NSMutableDictionary dictionaryWithCapacity:1];//找到所有未点击的项目
        for (int i = 0; i < array.count; i++) {
            NSDictionary *info = [array objectAtIndex:i];
            NSString *appkey = [info objectForKey:@"appkey"];//@"1105344611";//
            NSString *placementId =  [info objectForKey:@"placementId"];//@"5030722621265924";//
            NSString *key = [NSString stringWithFormat:@"%@%@",appkey,placementId];
            if (![self.clickInfo objectForKey:key]) {
                [notClickKey setObject:@"1" forKey:key];
            }
        }
        if(notClickKey.count==0){//表示所有项已经点击完成，按照流程点击即可
            //检查最后点击的一项是否是当前项，是就跳过,大于2的情况，防止同一id隔天就点击
            if(array.count==1)return true;
            NSData *data = [FTWCache objectForKey:ClickSSExpressNativeLastInfo useKey:YES];
            if (data) {
              NSString *lastKey =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                if(self.currentSSExpressKey && ([self.currentSSExpressKey compare:lastKey]==NSOrderedSame)){
                    return false;
                }
            }
            return true;
        }
        else{
            if (self.currentSSExpressKey && ![notClickKey objectForKey:self.currentSSExpressKey]) {
                return false;
            }
            return true;
        }
    }
    return false;
}
@end
