//
//  BeatifyWebPicsView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/31.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyWebPicsView.h"
#import "BeatifyWebView.h"
#import "BeatifyBridgeNode.h"
//#import "WKWebView+LongPress.h"
#import "BeatifyFavoriteListView.h"
#import "WebBrigdgeNode.h"
#import "AXPracticalHUD.h"
#import "GCDWebServer.h"
#import <Photos/Photos.h>
#import "NSObject+UISegment.h"
#import "WKWebView+LVShot.h"
#import "UIView+BlocksKit.h"
#import "YYCache.h"
//#import "UIImage+BeatfiyImageTools.h"
//#import "VideoAdManager.h"
//#import "BeatifyAssetManager.h"
#import "BuDNativeAdManager.h"
#import "BeatifySlideView.h"
#import "helpFuntion.h"
#import "MKNetworkKit.h"
#import "VideoPlayerManager.h"
#import "AppDelegate.h"
#import "VipPayPlus.h"
#import "UIImage+CWAdditions.h"
#import "YSCHUDManager.h"
#define PicsTypeKey @"picTypsKey"
#define PicsUUIDKey @"picUUIDKey"
#define TypeNameKey @"name"
#define TypeUrlKey @"url"

#define  ShowgGetImageError   UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"error" message:@"获取图片错误" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil]; \
[v show];

static YYCache *picsCache = nil;
@interface BeatifyWebPicsView()<BeatifyFavoriteListViewDelegate,BeatifyWebViewDelegate,BeatifyWebViewExternDelegate>{
    MKNetworkEngine*  imageNetWorkEngine;
    BOOL isFirstLoadFinish;
}
@property (nonatomic,assign) NSInteger saveIndex;
@property (nonatomic,strong) NSMutableArray *picFiles;
@property (nonatomic,strong)  BeatifySlideView *sildeView;
@property (nonatomic,assign)  NSInteger total;
@property (nonatomic,assign)  BOOL isFinish;
@property (nonatomic,strong)  UILabel *topDesLabel;
@property (nonatomic,strong)  NSString *tmpWebUrl;
@property (nonatomic,strong)  NSString *tmpTitle;
@property (nonatomic,strong)  GCDWebServer *webSever;
@property (nonatomic,strong)  NSMutableArray *arrayPics;
@property(assign,nonatomic)CGRect webRect;
@property(strong,nonatomic)BeatifyWebView *webView;
@property(strong,nonatomic)UIButton *btnBack;
@property(strong,nonatomic)UIButton *btnAdd;
@property(strong,nonatomic)UIView *topToolsView;
@property(strong,nonatomic)UIView *bottomToolsView;
@property(assign,nonatomic)BOOL isHd;
@property(strong,nonatomic)BeatifyWebView *webViewPics;
@property(strong,nonatomic)BeatifyBridgeNode *birdgeNode;
@property(strong,nonatomic)BeatifyFavoriteListView *favoriteListView;
@property(strong,nonatomic)void (^closeBlock)(void);
@property(strong,nonatomic)void (^imageBlock)(UIImage*image);
@property(strong,nonatomic)void (^clickBlock)(NSString*url);
@property(strong,nonatomic)void (^firstLoadBlock)(void);
@end

@implementation BeatifyWebPicsView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    if ([self.webSever isRunning]) {
            [self.webSever stop];
    }
   // [[BuDNativeAdManager getInstance] stopNative];
    self.arrayPics = nil;
    self.webSever = nil;
    [self.birdgeNode stop];self.birdgeNode = nil;
   // [self.webViewPics unInitLongPressEvent];
   // [self.webView unInitLongPressEvent];
    [self.webViewPics removeFromSuperview];
    [self.webView removeFromSuperview];
    [super removeFromSuperview];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self.webSever startWithPort:WebSeverPort bonjourName:nil];
    if([[helpFuntion gethelpFuntion] isValideOneDay:@"20191125175843_key" nCount:1 isUseYYCache:NO time:nil]){
        //[MobClick event:@"girl_btn"];
    }
    if([[VipPayPlus getInstance]isCanShowFullVideo]){
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
        [[VipPayPlus getInstance] tryShowFullVideo:^{
          [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
            [[VipPayPlus getInstance] tryPlayVideoFinish];
        }];
        [[UIApplication sharedApplication].keyWindow makeToast:@"图片加载完后,可以点图片保存,此广告2秒后可跳过" duration:2 position:@"center"];
    }
    else{
        [[UIApplication sharedApplication].keyWindow makeToast:@"图片加载完后,可以点图片保存" duration:2 position:@"center"];
    }
    return self;
}

- (GCDWebServer *)webSever{
    if (!_webSever) {
        NSString *root = BeatifyWebPicsViewWebRoot;
        _webSever = [[GCDWebServer alloc]init];
        [_webSever addGETHandlerForBasePath:@"/" directoryPath:root indexFilename:nil cacheAge:3600 allowRangeRequests:YES];// 此处设置本地服务器根目录
    }
    return _webSever;
}

-(void)initCommonUI:(void(^)(void))backBlock imageBlock:(void(^)(UIImage*image))imageBlock{
    if (!picsCache) {
        picsCache = [YYCache cacheWithName:@"BeatifyPicWebs"];
    }
    self.arrayPics = [NSMutableArray arrayWithCapacity:10];
    self.closeBlock = backBlock;
    self.imageBlock = imageBlock;
    self.backgroundColor = [UIColor blackColor];
    
    UIView *vvv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, GetAppDelegate.appStatusBarH)];
    [self addSubview:vvv];vvv.backgroundColor = [UIColor whiteColor];

    
    float toolsH = 50;
    self.topToolsView = [[UIView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, toolsH)];self.topToolsView.backgroundColor = RGBCOLOR(0, 0, 0);
    [self addSubview:self.topToolsView];
    
    self.topDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, toolsH*0.1, MY_SCREEN_WIDTH, toolsH*0.8)];
    self.topDesLabel.textColor = [UIColor whiteColor];
    self.topDesLabel.textAlignment = NSTextAlignmentCenter;
    self.topDesLabel.text = @"";
    [self.topToolsView addSubview:self.topDesLabel];
  
    
    self.btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnBack.frame = CGRectMake(0, toolsH*0.1, 80, toolsH*0.8);
    [self.btnBack setTitle:@"返回" forState:UIControlStateNormal];
    [self.topToolsView addSubview:self.btnBack];
    [self.btnBack addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAdd.frame = CGRectMake(MY_SCREEN_WIDTH-80, toolsH*0.1, 80, toolsH*0.8);
    [self.btnAdd setTitle:@"添加" forState:UIControlStateNormal];
    [self.topToolsView addSubview:self.btnAdd];
    [self.btnAdd addTarget:self action:@selector(clickAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomToolsView = [[UIView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-toolsH, MY_SCREEN_WIDTH, toolsH)];self.bottomToolsView.backgroundColor = RGBCOLOR(0, 0, 0);
    [self addSubview:self.bottomToolsView];
    {
        CGSize btnSize = CGSizeMake(90, 80);
        UIButton *btnShow = [UIButton buttonWithType:UIButtonTypeCustom];
         [btnShow setTitle:@"幻灯片" forState:UIControlStateNormal];
        [self.bottomToolsView addSubview:btnShow];
        [btnShow addTarget:self action:@selector(testHd) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnSc = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSc setTitle:@"专辑收藏" forState:UIControlStateNormal];
        [self.bottomToolsView addSubview:btnSc];
        [btnSc addTarget:self action:@selector(clickShow:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnDc = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDc setTitle:@"导出长图" forState:UIControlStateNormal];
        [self.bottomToolsView addSubview:btnDc];
        [btnDc addTarget:self action:@selector(testGetImage) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnAll = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAll setTitle:@"保存所有" forState:UIControlStateNormal];
        [self.bottomToolsView addSubview:btnAll];
        [btnAll addTarget:self action:@selector(exportAll) forControlEvents:UIControlEventTouchUpInside];
        [NSObject initii:self.bottomToolsView contenSize:self.bottomToolsView.bounds.size vi:btnShow viSize:btnSize vi2:nil index:0 count:4];
        [NSObject initii:self.bottomToolsView contenSize:self.bottomToolsView.bounds.size vi:btnSc  viSize:btnSize vi2:btnShow index:1 count:4];
        [NSObject initii:self.bottomToolsView contenSize:self.bottomToolsView.bounds.size vi:btnDc viSize:btnSize vi2:btnSc index:2 count:4];
        [NSObject initii:self.bottomToolsView contenSize:self.bottomToolsView.bounds.size vi:btnAll viSize:btnSize vi2:btnDc index:3 count:4];

    }
    isFirstLoadFinish = false;
    self.webRect = CGRectMake(0,self.topToolsView.frame.origin.y+self.topToolsView.frame.size.height , self.bounds.size.width, self.bottomToolsView.frame.origin.y-(self.topToolsView.frame.origin.y+self.topToolsView.frame.size.height));
    
    self.webViewPics =  [[BeatifyWebView alloc] initWithFrame:self.webRect ];
    [self.webViewPics loadWebView];
    [self.webViewPics loadAllJs:YES];
   // [self.webViewPics initLongPressEvent];
    self.webViewPics.clipsToBounds = YES;
    self.webViewPics.progressView.hidden = YES;
    self.webViewPics.delegate = self;
    [self addSubview:self.webViewPics];
    [self reloadWebsPic];
    
   // [[BuDNativeAdManager getInstance] startNative:self pos:BuDNativeAdManagerAdPos_ParentView_LeftBottom];
}

- (void)webViewDidFinishLoad:(BeatifyWebView *)webView{
    if (!isFirstLoadFinish && self.firstLoadBlock) {
        self.firstLoadBlock();
    }
    isFirstLoadFinish = true;
}

-(void)exportAll{
    if (!self.isFinish) {
        [self makeToast:@"请等待图片加载完~才能导出图片" duration:2 position:@"center"];
        return ;
    }
    self.saveIndex = 0;
    [YSCHUDManager showHUDOnView:self message:@"图片导出中..."];
    if ([VipPayPlus getInstance].systemConfig.vip!=Recharge_User && [[VipPayPlus getInstance] isCanPlayVideoAd2]) {
        [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
            
        } isShowAlter:NO isForce:NO];
    }
    [self gotoSaveAll];
}

-(void)gotoSaveAll{
    if (self.saveIndex>=self.picFiles.count) {
        [YSCHUDManager hideHUDOnView:self animated:NO];
        return;
    }
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:[self.picFiles objectAtIndex:self.saveIndex]], self, @selector(exportAll:didFinishSavingWithError:contextInfo:), nil);
}

- (void)exportAll:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    self.saveIndex++;
    [self performSelector:@selector(gotoSaveAll) withObject:nil afterDelay:0.25];
}

-(void)gogo{
    __weak BeatifyWebPicsView *weakSelf = self;
            [self.webViewPics.webView shotScreenContentScrollCapture:^(UIImage *screenShotImage) {
                if (weakSelf.total>30) {
                       screenShotImage =  [screenShotImage scaleImage:0.5];
                }
                  UIImageWriteToSavedPhotosAlbum(screenShotImage, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
              }];
}

-(void)testHd{
    if (self.isFinish) {
        self.isHd = !self.isHd;
        if (self.isHd) {
            self.sildeView = [[BeatifySlideView alloc] initWithFrame:self.webViewPics.frame arrayPics:self.arrayPics];
            [self addSubview:self.sildeView];
        }
        else{
            [self.sildeView removeFromSuperview];self.sildeView = nil;
        }
    }
    else{
        [self makeToast:@"请等待图片加载完~才能自动播放" duration:2 position:@"center"];
    }
}

-(void)testGetImage{
    if (self.isFinish) {
        if (self.isHd) {
            [self makeToast:@"幻灯片模式无法导出,请切换成普通模式" duration:2 position:@"center"];
            return;
        }
        if (false && [[VipPayPlus getInstance]isCanPlayVideoAd2]) {
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
            [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                [self gogo];
                } isShowAlter:YES isForce:false];
        }
        else{
            [self gogo];
        }
    }
    else{
        [self makeToast:@"请等待图片加载完~才能导出图片" duration:2 position:@"center"];
    }
}

-(void)initUI2:(void(^)(void))backBlock imageBlock:(void(^)(UIImage*image))imageBlock clickBlock:(void(^)(NSString*url))clickBlock title:(NSString*)title webUrl:(NSString*)webUrl firstLoadFinish:(void(^)(void))firstLoadBlock{
    [self initCommonUI:backBlock imageBlock:imageBlock];
    self.clickBlock = clickBlock;
    self.firstLoadBlock = firstLoadBlock;
    self.webViewPics.hidden = NO;
    self.tmpTitle = title;self.tmpWebUrl = webUrl;
}

/*
-(void)initUI:(void(^)(void))backBlock imageBlock:(void(^)(UIImage*image))imageBlock{
    [self initCommonUI:backBlock imageBlock:imageBlock];
    self.webView = [[BeatifyWebView alloc] initWithFrame:self.webRect];
    self.webView.clipsToBounds = YES;
    [self.webView loadWebView];
    [self addSubview:self.webView];
    self.webView.delegate = self;
    self.webView.externDelegate = self;
    [self.webView loadAllJs:YES];
    [self.webView initLongPressEvent];
    [self.webView loadURL:[NSURL URLWithString:@"https://www.mzitu.com/"]];
    self.webViewPics.hidden = YES;
}*/

-(void)reloadWebsPic{
    NSString *basePath = [[NSBundle mainBundle]pathForResource:@"zymywww" ofType:nil];
    NSURL *baseUrl =  [NSURL fileURLWithPath:basePath isDirectory:YES];
    NSString *path = [NSString stringWithFormat:@"%@/index.html",basePath];
    NSString *urt= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webViewPics.webView loadHTMLString:urt baseURL:baseUrl];
}

-(void)clickAssetListView:(NSString*)url{
    if (self.clickBlock) {
        self.clickBlock(url);
        return;
    }
    [self.arrayPics removeAllObjects];
    [self.birdgeNode stop];self.birdgeNode = nil;
    [self reloadWebsPic];
    self.webViewPics.hidden = YES;
    self.webView.hidden = NO;
    [self.webView loadURL:[NSURL URLWithString:url]];
}

-(void)clickAssetRemove:(NSInteger)pos{
    NSMutableArray *array = [self getPicCacheArray];
    if (array.count>pos) {
       NSDictionary *info =  [array objectAtIndex:pos];
        NSString *md5 = [[info objectForKey:@"name"] md5];
        NSDictionary *md5Info =  (NSDictionary*)[picsCache objectForKey:PicsUUIDKey];
        NSMutableDictionary *saveMd5 = [NSMutableDictionary dictionaryWithCapacity:1];
        if (md5Info) {
            [saveMd5 setDictionary:md5Info];
            [saveMd5 removeObjectForKey:md5];
            [picsCache setObject:saveMd5 forKey:PicsUUIDKey];
        }
        [array removeObjectAtIndex:pos];
        [picsCache setObject:array forKey:PicsTypeKey];
    }
}

-(void)removeAssetListView{
    [self.favoriteListView removeFromSuperview];self.self.favoriteListView = nil;
}

-(void)clickShow:(id)sender{
    if (!self.favoriteListView) {
        self.favoriteListView = [[BeatifyFavoriteListView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width , self.frame.size.height) array:[self getPicCacheArray]];
        [self addSubview:self.favoriteListView];
        self.favoriteListView.delegate = self;
    }
}

-(void)clickAdd:(id)sender{
    NSString *title = self.webView.webView.title;
    if (!title) {
        title = self.tmpTitle;
    }
    NSString *md5 = [title md5];
    NSDictionary *md5Info =  (NSDictionary*)[picsCache objectForKey:PicsUUIDKey];
    NSMutableDictionary *saveMd5 = [NSMutableDictionary dictionaryWithCapacity:1];
    if (md5Info) {
        [saveMd5 setDictionary:md5Info];
    }
    if (![saveMd5 objectForKey:md5]) {
        NSMutableArray *array = [self getPicCacheArray];
        NSString *url = [self.webView.webView.URL absoluteString];
        if(!url){
            url = self.tmpWebUrl;
        }
        if ([title length]>0&&[url length]>0) {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
            [info setObject:title forKey:TypeNameKey];
            [info setObject:url forKey:TypeUrlKey];
            [array addObject:info];
            [picsCache  setObject:array forKey:PicsTypeKey];
            [saveMd5 setObject:@"0" forKey:md5];
            [picsCache setObject:saveMd5 forKey:PicsUUIDKey];
            [self makeToast:@"收藏成功" duration:2 position:@"center"];
        }
        else{
            [self makeToast:@"收藏失败" duration:2 position:@"center"];
        }
    }
    else{
        [self makeToast:@"收藏成功" duration:2 position:@"center"];
    }
}

-(void)clickBack:(id)sender{
    [self.arrayPics removeAllObjects];
    [self.birdgeNode stop];self.birdgeNode = nil;
    if ((!self.webView) || (self.webViewPics.hidden && self.closeBlock)) {
        [self removeFromSuperview];
        self.closeBlock();
    }
    else{
        [self reloadWebsPic];
        self.webViewPics.hidden = YES;
        self.webView.hidden = NO;
    }
}

-(NSMutableArray*)getPicCacheArray{
    NSArray *array = (NSArray*)[picsCache objectForKey:PicsTypeKey];
    if (array.count>0) {
        return [NSMutableArray arrayWithArray:array];
    }
    return [NSMutableArray arrayWithCapacity:1];
}

- (void)webViewSaveImage:(NSString*)imageUrl{
    [self operationImage:imageUrl isSaveOrEdit:false];
}

- (void)webViewGetImage:(NSString*)imageUrl{
    [self operationImage:imageUrl isSaveOrEdit:true];
}

- (void)operationImage:(NSString*)imageUrl isSaveOrEdit:(BOOL)isSaveOrEdit{
    if ([imageUrl rangeOfString:@"http"].location!=NSNotFound && [imageUrl rangeOfString:@"http://localhost"].location==NSNotFound) {
        NSString *url = [self.webView.webView.URL absoluteString];
        NSString *file = [WebBrigdgeNode isPicFileExit:[url md5]];
        NSLog(@"file = %@",file);
        if (!file) {//下载
            [AXPracticalHUD showHUDInView:self animated:YES];
            [self reqeustImage:imageUrl referer:url isSaveOrEdit:isSaveOrEdit];
        }
        else{
            [self loadLocalFile:file isSaveOrEdit:isSaveOrEdit];
        }
    }
    else{
        NSString *name = [imageUrl substringFromIndex:[imageUrl rangeOfString:@"/pics/"].location+6];
        [self loadLocalFile:[[BeatifyWebPicsViewWebRoot stringByAppendingPathComponent:BeatifyWebPicsViewPicDirName] stringByAppendingPathComponent:name]isSaveOrEdit:isSaveOrEdit];
    }
}

- (void)reqeustImage:(NSString*)url referer:(NSString*)referer isSaveOrEdit:(BOOL)isSaveOrEdit{
    imageNetWorkEngine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:@{@"Referer":referer}];
    MKNetworkOperation *op = [imageNetWorkEngine operationWithURLString:url  timeOut:3];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        [self parseIamgeResult:completedOperation error:nil isSaveOrEdit:isSaveOrEdit];
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self parseIamgeResult:completedOperation error:error isSaveOrEdit:isSaveOrEdit];
    }];
    [imageNetWorkEngine enqueueOperation:op];
}

-(void)parseIamgeResult:(MKNetworkOperation*)op error:(NSError*)error isSaveOrEdit:(BOOL)isSaveOrEdit{
    [AXPracticalHUD  hideHUDInView:self animated:YES];
    if (!error) {
        UIImage *image = [UIImage imageWithData:op.responseData];
        if (!image) {
            ShowgGetImageError
            imageNetWorkEngine = nil;
            return;
        }
        imageNetWorkEngine = nil;
        [self finisImage:image isSaveOrEdit:isSaveOrEdit];
    }
    else{
        imageNetWorkEngine = nil;
        ShowgGetImageError
    }
}

-(void)finisImage:(UIImage*)image isSaveOrEdit:(BOOL)isSaveOrEdit{
    if (isSaveOrEdit) {
        if (self.imageBlock) {
            self.imageBlock(image);
        }
    }
    else{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                         if (status == PHAuthorizationStatusNotDetermined) {
                             [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                 if (status == PHAuthorizationStatusAuthorized) {
                                     UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
                                 }
                                 else{
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self makeToast:@"在设置中打开访问照片权限" duration:1.5 position:@"center"];
                                     });
                                 }
                             }];
                         } else if (status == PHAuthorizationStatusAuthorized) {
                             UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
                         }
                         else{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [self makeToast:@"在设置中打开访问照片权限" duration:1.5 position:@"center"];
                                                                });
                         }
    }
}

-(void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        [self makeToast:@"保存到相册失败" duration:2 position:@"center"];
        //NSLog(@"%@", error.localizedDescription);
    }
    else {
        [self makeToast:@"保存到相册成功" duration:2 position:@"center"];
    }
}


-(void)loadLocalFile:(NSString*)filePath  isSaveOrEdit:(BOOL)isSaveOrEdit{
  NSData *data =  [NSData dataWithContentsOfFile:filePath];
  UIImage *image =  [UIImage imageWithData:data];
    [self finisImage:image isSaveOrEdit:isSaveOrEdit];
}

-(void)webViewLoadingPogress:(float)progress uuid:(NSString *)uuid{
    if (progress>0.3) {//尝试检查是否有合适的url
        [self.webView evaluateJavaScript:@"tryToGetWebsFromAsset()" completionHandler:^(id _Nullable v, NSError * _Nullable error) {
            NSLog(@"tryToGetPicFromWeb = %@",error);
        }];
    }
}

-(void)webViewClickWebsFromImage:(NSString*)url{
   NSString *file = [WebBrigdgeNode getPicFileFromUrl:url];
    if (file) {
         UIAlertView *alertView = [[UIAlertView alloc]
                                     initWithTitle:@"是否保存到相册"
                                     message:nil
                                     delegate:nil
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@"保存", nil];
           [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
               switch (buttonIndex) {
                   case 1: {
                       UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:file], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                        break;
                   }
                   case 0:{
                       NSLog(@"webCore_webViewOpenInAppStore = 0");
                        break;
                   }
                   
               }
           }];
    }
}

- (void)image:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [self makeToast:[error description] duration:1.5 position:@"center"];
     }
    else {
        [self makeToast:@"保存成功" duration:1.5 position:@"center"];
     }
}

-(void)webViewGetPicsFromPagWebCallBack:(BOOL)isSuccess uuid:(NSString *)uuid ret:(NSDictionary *)retInfo{
    [self loadPicFromWebs:retInfo];
}


-(void)loadPicFromWebs:(NSDictionary*)retInfo{
    if (self.birdgeNode) {
        return;
    }
    self.webViewPics.hidden = NO;
    self.webView.hidden = YES;
    __weak BeatifyWebPicsView *weakSelf = self;
    if (!self.birdgeNode) {
        self.birdgeNode = [[BeatifyBridgeNode alloc] init];
    }
    [self.birdgeNode stop];
    self.picFiles = [NSMutableArray arrayWithCapacity:100];
    [self.birdgeNode startWithUrl:[retInfo objectForKey:@"array"] type:1 useRerfer:[[retInfo objectForKey:@"isRerfer"]boolValue] totalBlock:^(NSInteger totalNo) {
        
    } imageBlock:^(NSString * _Nonnull imageDom, NSInteger index,NSInteger total) {
        NSString *st = [NSString stringWithFormat:@"addPicIntoWeb('%@',%ld,%ld)",imageDom,index,total];
        NSLog(@"index = %ld total = %ld",index,total);
        weakSelf.topDesLabel.text = [NSString stringWithFormat:@"当前已加载(%ld/%ld)",index+1,total];
        weakSelf.isFinish = (index+1==total)?true:false;
        weakSelf.total = total;
       // NSInteger startPos = [imageDom rangeOfString:@"http://localhost"].location;
       // NSInteger endPos = [imageDom rangeOfString:@"style=\""].location;
       // NSString *file = [imageDom substringWithRange:NSMakeRange(startPos, endPos-startPos-1)];
        NSRange range1 =  [st rangeOfString:@"pics/"];
        NSRange range2 =  [st rangeOfString:@"\"style="];
        NSString *files = [WebBrigdgeNode isPicFileExit:[st substringWithRange:NSMakeRange(range1.length+range1.location, range2.location-(range1.length+range1.location))]];
        if (files) {
            [self.picFiles addObject:files];
        }
        [weakSelf.webViewPics evaluateJavaScript:st completionHandler:^(id ret , NSError * _Nullable error) {
            NSLog(@"addPicIntoWeb %@",error);
        }];
        if(weakSelf.isFinish){
            [weakSelf.webViewPics evaluateJavaScript:@"addClickWebsEvent()" completionHandler:^(id _Nullable r, NSError * _Nullable error) {
                NSLog(@"addClickWebsEvent");
            }];
        }
    }addImageBlock:^(NSString * _Nonnull filePath) {
        NSLog(@"addPicIntoWeb filePath = %@",filePath);
        [weakSelf.arrayPics addObject:filePath];
    }];
}
@end
