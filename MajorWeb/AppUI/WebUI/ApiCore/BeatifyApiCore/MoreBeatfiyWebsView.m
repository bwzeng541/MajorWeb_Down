//
//  MoreBeatfiyWebsView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/7/31.
//  Copyright © 2019 cxh. All rights reserved.
//

#define UseSysVideoPlay 0
#define isclickBtnTest @"clickBtnTest"
#define MaxOpenUrlCount 60

#import "VideoPlayerManager.h"
#import "MoreBeatfiyWebsView.h"
#import "BlocksKit.h"
#import "UIControl+BlocksKit.h"
#import "GDTUnifiedBannerView.h"
#import "AppDelegate.h"
#import "WebsNodeView.h"
#import "BeatifyChangeToPc.h"
#import "MBProgressHUD.h"
#import "ZFPlayerController.h"
#import "ZFAVPlayerManager.h"
#import "BuDNativeAdManager.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "VipPayPlus.h"
#if (UseSysVideoPlay==1)
#import <AVKit/AVKit.h>
#else
#endif
static const char *externObjectKey = "externObjectKey";
static const char *contentValueKey = "contentVauleKey";
static const char *contentValueThrowKey = "contentValueThrowKey";


@interface UIButton(TagValue)
@property (nonatomic, copy) NSString* contentValue;
@end

@implementation UIButton(TagValue)
- (NSString* )contentValue {
    return objc_getAssociatedObject(self, contentValueKey);
}

-(void)setContentValue:(NSString *)contentValue
{
    objc_setAssociatedObject(self, contentValueKey, contentValue, OBJC_ASSOCIATION_COPY);
}
@end

#if (UseSysVideoPlay==1)

@interface AVPlayerViewController(ExternalObject)
@property (nonatomic, retain) id externObject;
@property (nonatomic, retain) id externObjectThrow;
@end

@implementation AVPlayerViewController(ExternalObject)
- (id )externObject {
    return objc_getAssociatedObject(self, externObjectKey);
}

-(void)setExternObject:(id )externObject
{
    objc_setAssociatedObject(self, externObjectKey, externObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id )externObjectThrow {
    return objc_getAssociatedObject(self, contentValueThrowKey);
}

-(void)setExternObjectThrow:(id)externObjectThrow
{
    objc_setAssociatedObject(self, contentValueThrowKey, externObjectThrow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
#endif

@interface MoreBeatfiyWebsView()<BeatifyWebViewExternDelegate,GDTUnifiedBannerViewDelegate,WebsNodeViewDelegate,BuDNativeAdManagerDelegate>{
    CGRect scorllViewRect;
}
@property(nonatomic,weak)UIView *adVideAdView;
@property (nonatomic,strong)NSMutableDictionary *assetKey;
@property (nonatomic,copy)NSString* requestUrl;
@property (nonatomic, weak) WKWebView *webNode;
@property(copy,nonatomic)void(^callBack)(void);
@property (nonatomic, strong) GDTUnifiedBannerView *bannerView;
@property(nonatomic,strong)NSMutableArray *websInfo;
@property(nonatomic,strong)UIScrollView *scorllView;
@property(nonatomic,assign)BOOL isPress;
@property(nonatomic,retain)id clickObject;
@property(nonatomic,retain)id tempObject;
@property(nonatomic,retain)id backObject;
@property(nonatomic,assign)CGSize viewSize;
@property(nonatomic,retain)UIView *bottomView;
@property(nonatomic,assign)int count;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *oldTitle;
@property(nonatomic,retain)UILabel *desLabel;
@property(nonatomic,assign)BOOL isDefautAsset;
@property(nonatomic,assign)BOOL isMute;
@property(nonatomic,assign)float isMuteValue;
@property(nonatomic,assign)BOOL isSeek;
@property(nonatomic,strong)BeatifyChangeToPc *beatifyChangeNode;
@property(nonatomic,strong)UIView *waitView;
@end
@implementation MoreBeatfiyWebsView
- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView{
    [self removeBanner];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeBanner{
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
    self.scorllView.frame = scorllViewRect;
 }

-(void)budnativeSuccessToLoad:(CGRect)videoAdRect videoAdView:(UIView*)videAdView{
    // videAdView.frame = CGRectMake(videAdView.frame.origin.x, scorllViewRect.origin.y, videAdView.frame.size.width, videAdView.frame.size.height);
    //   self.scorllView.frame  = CGRectMake(scorllViewRect.origin.x, scorllViewRect.origin.y+videoAdRect.size.height, scorllViewRect.size.width, scorllViewRect.size.height-videoAdRect.size.height);
    self.adVideAdView = videAdView;
    if (self.waitView) {
        self.waitView.frame = self.scorllView.frame;
    }
    [self.adVideAdView removeFromSuperview];
    [self.scorllView addSubview:self.adVideAdView];
    [self addAdjust];
}

-(void)budnativeClose{
    [self.adVideAdView removeFromSuperview];
    self.adVideAdView = nil;
    [self addAdjust];
}

-  (void)refreshCarouselBanner {
    [BuDNativeAdManager getInstance].delegate = self;
    [[BuDNativeAdManager getInstance] startNative:self pos:(BuDNativeAdManagerAdPos_ParentView_Top)];
    if (false && self.bannerView == nil ) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat bannerHeigh =60;
        CGRect rect = {CGPointMake((screenWidth-375)/2, scorllViewRect.origin.y), CGSizeMake(375, 60)};
        if (IF_IPAD) {
            bannerHeigh = screenWidth/375*60;
            rect = CGRectMake(0, scorllViewRect.origin.y, screenWidth, bannerHeigh);
        }
        self.bannerView = [[GDTUnifiedBannerView alloc]
                           initWithFrame:rect appId:@"1109675609"
                           placementId:@"8080589358776897"
                           viewController:GetAppDelegate.window.rootViewController];
        _bannerView.animated =  NO;
        _bannerView.autoSwitchInterval = 0;
        _bannerView.delegate = self;
        [self addSubview:self.bannerView];
        self.scorllView.frame  = CGRectMake(scorllViewRect.origin.x, scorllViewRect.origin.y+bannerHeigh, scorllViewRect.size.width, scorllViewRect.size.height-bannerHeigh);
    }
    [self.bannerView loadAdAndShow];
}

-(void)updateTitle:(NSString*)title{
    self.title = title;
    self.desLabel.text = title;
}

-(instancetype)initWithFrame:(CGRect)frame array:(NSArray*)array isDefautAsset:(BOOL)isDefautAsset  title:(NSString*)title url:(NSString*)url webNode:(id)webNode callBack:(void(^)(void))willCallBack isSeek:(BOOL)isSeek{
    self = [super initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
    [[VideoPlayerManager getVideoPlayInstance]stop];
    self.backgroundColor = [UIColor whiteColor];
    UIView *bvv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, GetAppDelegate.appStatusBarH)];
    bvv.backgroundColor = RGBCOLOR(0, 0, 0);
    [self addSubview:bvv];
    self.title = title;
    self.requestUrl  = url;
    self.isSeek = isSeek;
    self.callBack = willCallBack;
    self.isDefautAsset = isDefautAsset;
    self.oldTitle = title;
    self.webNode = webNode;
    self.assetKey = [NSMutableDictionary dictionary];
    self.websInfo = [NSMutableArray arrayWithCapacity:10];
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-45, MY_SCREEN_WIDTH, 45)];
    self.bottomView.backgroundColor = RGBCOLOR(0, 0, 0);
    self.scorllView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,(GetAppDelegate.appStatusBarH), MY_SCREEN_WIDTH,self.bottomView.frame.origin.y-GetAppDelegate.appStatusBarH-5 )];
    
    //修改bottomview 到顶部
    self.bottomView.frame = CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, self.bottomView.bounds.size.height);
    scorllViewRect = CGRectMake(0, self.bottomView.frame.origin.y+self.bottomView.bounds.size.height, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-self.bottomView.frame.origin.y-self.bottomView.bounds.size.height);
    self.scorllView.frame = scorllViewRect;
    //end
    [self addSubview:_scorllView];
    [self addSubview:_bottomView];
    [self refreshCarouselBanner];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/b_close") forState:UIControlStateNormal];
    btnClose.frame = CGRectMake(0,0, _bottomView.frame.size.height,  _bottomView.frame.size.height);
    [_bottomView addSubview:btnClose];
    
    UIButton *btnHelp = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHelp setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/b_share") forState:UIControlStateNormal];
    btnHelp.frame = CGRectMake(MY_SCREEN_WIDTH-_bottomView.frame.size.height*2,0, _bottomView.frame.size.height*2,  _bottomView.frame.size.height);
    [_bottomView addSubview:btnHelp];
    [btnHelp addTarget:self action:@selector(showApp) forControlEvents:UIControlEventTouchUpInside];btnHelp.hidden = YES;
    self.viewSize = CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
    [btnClose addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    self.desLabel = [[UILabel alloc] initWithFrame:CGRectMake(btnClose.frame.origin.x+btnClose.frame.size.width+5, 0, btnHelp.frame.origin.x-(btnClose.frame.origin.x+btnClose.frame.size.width+5), btnHelp.frame.size.height)];
    self.desLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    self.desLabel.textAlignment = NSTextAlignmentCenter;
    self.desLabel.textColor = RGBCOLOR(0, 255, 0);
    self.desLabel.text = self.title;
    [_bottomView addSubview:self.desLabel];
    
    self.waitView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomView.frame.origin.y+_bottomView.frame.size.height, _bottomView.bounds.size.width, MY_SCREEN_HEIGHT-(_bottomView.frame.origin.y+_bottomView.frame.size.height))];
    [self addSubview:self.waitView];
    MBProgressHUD *_progressHUD = [[MBProgressHUD alloc] initWithView:self.waitView];
    [self.waitView addSubview:_progressHUD];
    [_progressHUD showAnimated:YES];
    __weak __typeof(self)weakSelf = self;

    [self.webNode evaluateJavaScript:@"changeAsset()" completionHandler:^(id ret , NSError * _Nullable error) {
        weakSelf.beatifyChangeNode = [[BeatifyChangeToPc alloc]init];
        [self.beatifyChangeNode startWithAsset:error?url:ret callBack:^(NSString * _Nonnull realAsset) {
            [weakSelf initArray:array asset:realAsset];
           }];
    }];
    if ([[VipPayPlus getInstance] isCanShowFullVideo]) {
        [[VipPayPlus getInstance] tryShowFullVideo:^{
             [[VipPayPlus getInstance] tryPlayVideoFinish];
        }];
    }
    return self;
}

-(void)removeNodeFromID:(NSString*)uuid{
   // [self.websInfo addObject:@{@"object":beatifyWebView,@"key":beatifyWebView.uuid}];
    for (int i= 0; i < self.websInfo.count; i++) {
         NSDictionary *info =  [self.websInfo objectAtIndex:i];
        if([[info objectForKey:@"key"]compare:uuid ]==NSOrderedSame){
            id view=  [info objectForKey:@"object"];
            if ([view isKindOfClass:[UIView class]]) {
                [((UIView*)view) removeFromSuperview];
            }
            else{
#if (UseSysVideoPlay==1)
                AVPlayerViewController *boject = (AVPlayerViewController*)view;
#else
                WebsNodeView *boject = (WebsNodeView*)view;
#endif
                [boject.view removeFromSuperview];
            }
            [self.websInfo removeObjectAtIndex:i];
            [self addAdjust];
            return;
        }
    }
}

-(NSArray*)changeNewArray:(NSArray*)urlArray asset:(NSString*)newUrl{
    if([[urlArray objectAtIndex:0] rangeOfString:newUrl].location!=NSNotFound){
        return urlArray;
    }
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i < [urlArray count]; i++) {
        NSString *asset =  [urlArray objectAtIndex:i];
        if (self.isDefautAsset && i ==0) {
            [arrayRet addObject:asset];
            continue;
        }
        NSRange range =  [asset rangeOfString:@"="];
        if (range.location!=NSNotFound) {
           NSString *vv = [[asset substringToIndex:range.location+range.length] stringByAppendingString:newUrl];
            [arrayRet addObject:vv];
        }
        else{
            [arrayRet addObject:asset];
        }
    }
    return [NSArray arrayWithArray:arrayRet];
}

-(void)initArray:(NSArray*)urlArray asset:(NSString*)newUrl{
    [self.waitView removeFromSuperview];self.waitView = nil;
    urlArray = [self changeNewArray:urlArray asset:newUrl];
    [self.beatifyChangeNode unInitAsset];self.beatifyChangeNode = nil;
    int count=(int)urlArray.count;
    for (int i=0; i<count; i++) {
        BeatifyWebView *beatifyWebView = [[BeatifyWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)isShowOpUI:false];
        [beatifyWebView setWebViewType:webView_Test0];
        [beatifyWebView loadWebView];
        [beatifyWebView enableWebSrollview:false];
        [self.scorllView addSubview:beatifyWebView];
        [beatifyWebView loadAllJs:true];
        [beatifyWebView isOperationError:false];
        NSString* finnalStr=[urlArray[i*0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        beatifyWebView.externDelegate = self;
        [self.websInfo addObject:@{@"object":beatifyWebView,@"key":beatifyWebView.uuid}];
        float delayTime = i * 1;
        [beatifyWebView delayLoadURL:[NSURL URLWithString:finnalStr] time:delayTime isDefault:(self.isDefautAsset && i==0)?true:false];
    }
    self.scorllView.scrollEnabled = YES;
    [self addAdjust];
}

 
-(void)showApp{
     ;
}

-(void)showHelp{//640X1138
    UIButton *imageHelp = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageHelp setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/help_c") forState:UIControlStateNormal];
    imageHelp.frame = CGRectMake(0, 0, _viewSize.width, _viewSize.height);
    [self.superview addSubview:imageHelp];
    [imageHelp bk_addEventHandler:^(id sender) {
        [sender removeFromSuperview];
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)addAdjust{
    int totalloc=1;
    CGFloat appvieww=self.viewSize.width;
    CGFloat appviewh=appvieww*0.56;
    float w = self.viewSize.width;
    CGFloat margin=(w-totalloc*appvieww)/(totalloc+1);
    NSArray *urlArray = self.websInfo;
    int count=(int)urlArray.count;
    float offsetAdY = 0;
    if (self.adVideAdView) {
        self.adVideAdView.frame = CGRectMake(0, 0, self.adVideAdView.frame.size.width, self.adVideAdView.frame.size.height);
        offsetAdY = self.adVideAdView.frame.size.height;
    }
    if(self.clickObject){
#if (UseSysVideoPlay==1)
        AVPlayerViewController *boject = (AVPlayerViewController*)[self.clickObject objectForKey:@"object"];
#else
        WebsNodeView *boject = (WebsNodeView*)[self.clickObject objectForKey:@"object"];
#endif
        [boject.view removeFromSuperview];
        [self addSubview:boject.view];
        if (true) {
            [((UIView*)boject.externObject) removeFromSuperview];
            boject.view.frame = CGRectMake(0, self.bottomView.frame.origin.y+self.bottomView.bounds.size.height, appvieww, appviewh);
            //[self.scorllView setFrame:CGRectMake(0, GetAppDelegate.appStatusBarH+appviewh, MY_SCREEN_WIDTH, self.bottomView.frame.origin.y-(GetAppDelegate.appStatusBarH+appviewh)-5)];
            [self.scorllView setFrame:CGRectMake(0,self.bottomView.frame.origin.y+self.bottomView.bounds.size.height+appviewh, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-self.bottomView.frame.origin.y-self.bottomView.bounds.size.height-appviewh)];
        }
        else{
           // boject.view.frame = CGRectMake(0, 0, MY_SCREEN_HEIGHT, MY_SCREEN_WIDTH);
           // boject.view.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
           // boject.view.center = CGPointMake(MY_SCREEN_WIDTH /2, MY_SCREEN_HEIGHT/2);
        }
    }
    [self.scorllView setContentSize:CGSizeMake(appvieww, count*(appviewh+5)+offsetAdY)];
    
     for (int i=0; i<count; i++) {
      NSDictionary *info =  [self.websInfo objectAtIndex:i];
      id view=  [info objectForKey:@"object"];
        int row=i/totalloc;//行号
        //1/3=0,2/3=0,3/3=1;
        int loc=i%totalloc;//列号
         CGFloat appviewx=margin+(margin+appvieww)*loc;
        CGFloat appviewy=5+(5+appviewh)*row+offsetAdY;
         if ([view isKindOfClass:[UIView class]]) {
             ((UIView*)view).frame = CGRectMake(appviewx, appviewy, appvieww, appviewh);
         }
         else{
#if (UseSysVideoPlay==1)
             AVPlayerViewController *boject = (AVPlayerViewController*)view;
#else
             WebsNodeView *boject = (WebsNodeView*)view;
#endif
             [boject.view removeFromSuperview];
             boject.view.transform = CGAffineTransformMakeRotation(0);
             [((UIView*)boject.externObject) removeFromSuperview];
             [self.scorllView addSubview:boject.view];
             [self.scorllView addSubview:((UIView*)boject.externObject)];
             boject.view.frame = CGRectMake(appviewx, appviewy, appvieww, appviewh);
             ((UIView*)boject.externObject).frame = CGRectMake(appviewx, appviewy, appvieww,appviewh);
             [self addExternObjectThrow:(UIView*)boject.externObject];
         }
    }
}

-(void)removeFromSuperview{
    [[BuDNativeAdManager getInstance] stopNative];
    if (self.callBack) {
        self.callBack();
    }
    self.callBack = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.clickObject = nil;
    [self.beatifyChangeNode unInitAsset];self.beatifyChangeNode = nil;
    [self removeBanner];
    
    while (self.websInfo.count>0) {
        NSDictionary *info = [self.websInfo objectAtIndex:0];
        UIView *view =  [info objectForKey:@"object"];
        if([view respondsToSelector:@selector(removeFromSuperview)])
            [view removeFromSuperview];
        [self.websInfo removeObjectAtIndex:0];
    }
    
    [self.websInfo removeAllObjects];
    [super removeFromSuperview];
}

-(void)webViewExternCallBack:(BOOL)isSuccess uuid:(NSString*)uuid assetKey:(nonnull NSString *)assetKey{
    NSString *keyMd5 = [assetKey md5];
    NSLog(@"assetKey = %@",assetKey);
    if(assetKey && [self.assetKey objectForKey:keyMd5]){
        isSuccess = false;
    }
    else if(assetKey){
        [self.assetKey setObject:@"1" forKey:keyMd5];
    }
    for (int i = 0; i < self.websInfo.count; i++) {
            NSDictionary *info = [self.websInfo objectAtIndex:i];
            UIView *view =  [info objectForKey:@"object"];
            NSString *key =  [info objectForKey:@"key"];
            if ([key compare:uuid]==NSOrderedSame) {
                if(!isSuccess){
                    [view removeFromSuperview];
                    [self.websInfo removeObject:info];
                }
                else{//t替换成系统播放器
                    [self updateTitle:@"请选择一个流畅视频播放"];
                    NSString *url = ((BeatifyWebView*)view).externParam;
#if (UseSysVideoPlay==1)
                    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
                    playerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
                    playerVC.showsPlaybackControls = YES;
#else
                    WebsNodeView *playerVC = [[WebsNodeView alloc] init];
                    playerVC.delegate = self;
                    [playerVC initNodePlayer:url oldAsset:[((BeatifyWebView*)view).webView.URL absoluteString] isSeek:self.isSeek];
#endif
                    playerVC.view.frame = view.bounds;
#if (UseSysVideoPlay==1)
                    if (@available(iOS 11.0, *)) {
                        playerVC.entersFullScreenWhenPlaybackBegins = YES;
                    } else {
                        // Fallback on earlier versions
                    }//开启这个播放的时候支持（全屏）横竖屏哦
                    if (@available(iOS 11.0, *)) {
                        playerVC.exitsFullScreenWhenPlaybackEnds = YES;
                    } else {
                        // Fallback on earlier versions
                    }//开启这个所有 item 播放完毕可以退出全屏
#endif
                    [self.scorllView addSubview:playerVC.view];
                    if (!self.isPress) {
#if (UseSysVideoPlay==1)
                        [playerVC.player play];
#else
                        [playerVC play];
#endif
                    }
                    [view removeFromSuperview];
                    [self.websInfo removeObject:info];
                    NSString *newUUID = [key stringByAppendingString:@"vv"];
                    UIButton *btnTest = [UIButton buttonWithType:UIButtonTypeCustom];
                    btnTest.contentValue = newUUID;
                    [btnTest addTarget:self action:@selector(clickBtnTest:) forControlEvents:UIControlEventTouchUpInside];
                    if (self.isPress) {
                        btnTest.alpha=0.5;
                        btnTest.backgroundColor=RGBCOLOR(0, 0, 0);
                    }
                    else{
                        btnTest.backgroundColor = [UIColor clearColor];
                    }
#if (UseSysVideoPlay==0)
                    btnTest.hidden = YES;
#endif
                    playerVC.externObject = btnTest;
                    [self.scorllView addSubview:btnTest];
                     if(self.websInfo.count==0)
                         [self.websInfo addObject:@{@"object":playerVC,@"key":newUUID,@"url":url}];
                    else{
                        [self.websInfo insertObject:@{@"object":playerVC,@"key":newUUID,@"url":url} atIndex:self.count];
                    }
                    self.count++;
                }
                break;
            }
        }
    
    if (self.count>=(self.isDefautAsset?MaxOpenUrlCount+1:MaxOpenUrlCount)) {//u最多4个
        NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
        for (int i = 0; i < self.websInfo.count; i++) {
            id value =  [[self.websInfo objectAtIndex:i] objectForKey:@"object"];
            if ([value isKindOfClass:[UIView class]]) {
                [(UIView*)value removeFromSuperview];
                [indexSets addIndex:i];
            }
        }
        if (indexSets.count>0) {
            [self.websInfo removeObjectsAtIndexes:indexSets];
        }
        if (self.callBack) {
            self.callBack();
            self.callBack = nil;
        }
    }
    [self addAdjust];
}

-(void)addExternObjectThrow:(UIView*)parentView{
    //125X52;
    float w = 125;
    float h = 52;
    if (!IF_IPAD) {
        w/=2;h/=2;
    }
    [[parentView viewWithTag:1] removeFromSuperview];
    CGSize size =parentView.bounds.size;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image= [UIImage imageNamed:@"BeatifyWebView.bundle/more_list_tp"];
    [btn setImage:image forState:UIControlStateNormal];
    CGRect rect = CGRectMake(size.width-w, (size.height-h)/2, w, h);
    btn.frame = rect;btn.tag=1;
#if (UseSysVideoPlay==0)
    btn.hidden = YES;
#endif
    [btn addTarget:self action:@selector(clickThrow:) forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
}

-(void)linkIt:(NSString*)msg{
    /*
    NSArray *deviceArray = [DNLAController getInstance].lelinkServices;
    TYAlertView *alertView = nil;
    alertView.buttonFont = [UIFont systemFontOfSize:14];
    if ( deviceArray.count>0) {
        alertView = [TYAlertView alertViewWithTitle:@"选择投屏设备" message:@""];
        @weakify(self)
        
        TYAlertAction *v  = [TYAlertAction actionWithTitle:@"退出"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                   }];
        [alertView addAction:v];
        for (int i = 0; i < deviceArray.count; i++) {
            LBLelinkService *v = [deviceArray objectAtIndex:i];
            TYAlertAction *tn  = [TYAlertAction actionWithTitle:v.lelinkServiceName
                                                          style:TYAlertActionStyleDefault
                                                        handler:^(TYAlertAction *action) {
                                                            @strongify(self)
                                                            [self linkWithDevice:action.tagValue content:msg];
                                                        }];
            [alertView addAction:tn];
            tn.tagValue = i;
        }
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
    }
    else{
        alertView = [TYAlertView alertViewWithTitle:@"投屏失败" message:@"1:手机和电视必须在同一个无线网络才能投屏播放\n\n2：当搜索不到电视时，请重启电视机和APP再搜索\n\n3：视频投屏到电视时，手机上还可以看其他电影或者玩游戏，支持手机后台投影播放\n"];
        [alertView addAction:[TYAlertAction actionWithTitle:@"确定"
                                                      style:TYAlertActionStyleDefault
                                                    handler:^(TYAlertAction *action) {
                                                    }]];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
    }
     */
}

-(void)linkWithDevice:(NSInteger)pos content:(NSString*)msg{
    /*
    NSLog(@"linkWithDevice url= %@",msg);
    [[DNLAController getInstance] playWithUrl:msg time:0 header:nil isLocal:NO deviceIndex:pos];
     */
}


-(void)clickThrow:(UIButton*)sender{
      sender = (UIButton*)sender.superview;
    NSString *key = sender.contentValue;
    for (int i = 0; i < self.websInfo.count; i++) {
        NSDictionary *info = [self.websInfo objectAtIndex:i];
        id value =  [info objectForKey:@"object"];
        NSString *rkey =  [info objectForKey:@"key"];
        if (![value isKindOfClass:[UIView class]]) {
            if ([rkey compare:key]==NSOrderedSame) {
                [self linkIt:[info objectForKey:@"url"]];
                break;
            }
        }
    }
}

-(void)faildAsset:(WebsNodeView*)value{
    [((UIButton*)value.externObject) removeFromSuperview];
    [((UIButton*)value.externObjectThrow) removeFromSuperview];
    [self removeNodeFromID:((UIButton*)value.externObject).contentValue];
}

-(void)clickAsset:(WebsNodeView*)value{
    [self removeFromSuperview];
    ZFPlayerController* v =[value testFution];
   // value.player.currentPlayerManager.volume=self.isMuteValue;
    [value setInterfaceNil];
    NSDictionary *saveInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.requestUrl,@"requestUrl",self.title,@"theTitle", nil];
    [[VideoPlayerManager getVideoPlayInstance] playWithPlayerInterface:v title:self.oldTitle saveInfo:saveInfo isMustSeekBegin:self.isSeek];
}

-(BOOL)isMuteAsset:(WebsNodeView*)value{
    return false;
//    if (!self.isMute) {
//        self.isMute = true;
//        self.isMuteValue = value.player.volume;
//        return false;
//    }
//    return true;
}

-(void)clickBtnTest:(UIButton*)sender{
    NSString *key = sender.contentValue;
    int clickPos = -1;
    for (int i = 0; i < self.websInfo.count; i++) {
        NSDictionary *info = [self.websInfo objectAtIndex:i];
        id value =  [info objectForKey:@"object"];
        NSString *rkey =  [info objectForKey:@"key"];
        if (![value isKindOfClass:[UIView class]]) {
#if (UseSysVideoPlay==1)
            AVPlayerViewController *newValue = ((AVPlayerViewController*)value);
#else
            WebsNodeView *newValue = ((WebsNodeView*)value);
#endif
            if ([rkey compare:key]==NSOrderedSame) {
                
#if (UseSysVideoPlay==1)
                if (newValue.player.rate!=1.0  ) {
#else
                    if(newValue.player.currentPlayerManager.rate!=1.0){
#endif
                     self.tempObject = info;clickPos = i;
                     [self fireValue:newValue go:false];
                }
                else{
                    [self fireValue:newValue go:true];
                }
                if (!self.isPress) {
                    [self fireValue:newValue go:false];
                    self.tempObject = info;clickPos = i;
                    self.isPress=true;
                }
            }
            else{
                [self fireValue:newValue go:true];
            }
        }
    }
    
    
    if (self.backObject && self.tempObject) {
#if (UseSysVideoPlay==1)
        CMTime time = ((AVPlayerViewController*)[self.backObject objectForKey:@"object"]).player.currentTime;
        AVPlayerViewController* value =  [self.tempObject objectForKey:@"object"];
        [value.player seekToTime:time];
#else
        float time = ((WebsNodeView*)[self.backObject objectForKey:@"object"]).player.currentPlayerManager.currentTime;
        WebsNodeView * value = [self.tempObject objectForKey:@"object"];
        [value.player seekToTime:time completionHandler:nil];
#endif
        self.backObject = self.tempObject;
    }
    if (self.tempObject) {
#if (UseSysVideoPlay==1)
        AVPlayerViewController* value =  [self.tempObject objectForKey:@"object"];
        self.backObject = self.tempObject;
        if([value testFution]){
            self.tempObject = nil;
            [self testDevice];
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow makeToast:@"播放卡顿时，请切换其它线路播放" duration:1 position:@"center"];
            });
        }
#else
        WebsNodeView* value =  [self.tempObject objectForKey:@"object"];
        self.backObject = self.tempObject;
        self.tempObject = nil;
        id v =[value testFution];
        [value setInterfaceNil];
        NSDictionary *saveInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.requestUrl,@"requestUrl",self.title,@"theTitle", nil];
        [[VideoPlayerManager getVideoPlayInstance] playWithPlayerInterface:v title:self.oldTitle saveInfo:nil isMustSeekBegin:YES];
        [self removeFromSuperview];
        return;
#endif
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:@"播放卡顿时，请切换其它线路播放" duration:1 position:@"center"];
        });
    }
    if (self.tempObject) {
        if (self.clickObject && clickPos>=0) {
            id value =  [self.clickObject objectForKey:@"object"];
            [self fireValue:value go:true];
            [self.websInfo replaceObjectAtIndex:clickPos withObject:self.clickObject];
            self.clickObject = self.tempObject;
        }
        else{
            self.clickObject = self.tempObject;
            [self.websInfo removeObject:self.tempObject];
        }
        if(![[NSUserDefaults standardUserDefaults] objectForKey:isclickBtnTest]){
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:isclickBtnTest];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showHelp];
        }
    }
    [self addAdjust];
}

-(void)fireValue:(id)value go:(BOOL)go{
    if (go) {
#if (UseSysVideoPlay==1)
        [((AVPlayerViewController*)value).player pause];
#else
        [((WebsNodeView*)value) pause];
#endif
    }
    else{
#if (UseSysVideoPlay==1)
        [((AVPlayerViewController*)value).player play];
#else
        [((WebsNodeView*)value) play];

#endif
    }
}
@end
