//
//  DNLAController.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/19.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "DNLAController.h"
#import "HTTPServer.h"
#import "MajorSystemConfig.h"
#import "TYAlertAction+TagValue.h"
#import "MRDLNA.h"
#if DoNotKMPLayerCanShareVideo
#else
#import "FileDonwPlus.h"
#import "VipPayPlus.h"
#import "UIDevice+YSCKit.h"
#endif
#import "VideoPlayerManager.h"
#if (QRUserLBLelinkKit==1)

@interface DNLAController()<LBLelinkBrowserDelegate,LBLelinkConnectionDelegate,LBLelinkPlayerDelegate>{
#else
    @interface DNLAController()<DLNADelegate>{
#endif
#if DoNotKMPLayerCanShareVideo
#else
    BOOL _isStartHttpService;
#endif
}
#if DoNotKMPLayerCanShareVideo
#else
@property(strong,nonatomic)HTTPServer *httpServer;
#endif
#if (QRUserLBLelinkKit==1)
@property(strong,nonatomic)LBLelinkBrowser *lelinkBrowser;
@property(strong,nonatomic)LBLelinkConnection *lelinkConnection;
@property(strong,nonatomic)LBLelinkPlayer *player;
@property(nonatomic,assign)LBLelinkPlayStatus playStatus;
@property(nonatomic, assign) LBLelinkMediaType mediaType;
#else
@property(nonatomic,strong) MRDLNA *dlnaManager;
@property(nonatomic, copy) void (^searchBlock)(void);
#endif
@property(nonatomic,copy)NSDictionary* header;
@property(nonatomic,assign)float currentTime;
@property(nonatomic,assign)float darutTime;
@property(strong,nonatomic)NSArray *lelinkServices;
@property(copy,nonatomic)NSString *url;
@property(assign,nonatomic)float startTime;
@property(nonatomic,copy) void (^selectDevice)(NSInteger);
@end
@implementation DNLAController
+(DNLAController*)getInstance{
    static DNLAController*g = NULL;
    if (!g) {
        g = [[DNLAController alloc] init];
#if (QRUserLBLelinkKit==1)
        [LBLelinkKit enableLog:YES];
#endif
    }
    return g;
}

#if DoNotKMPLayerCanShareVideo
#else
-(void)startLocalServert{
    
    self.httpServer = [[HTTPServer alloc] init];
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [self.httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [self.httpServer setPort:DNLHttpServerPort];
    
    // Serve files from our embedded Web folder
    NSString *webPath =  VIDEOCACHESROOTPATH;
    //;[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];//
    //
    [self.httpServer setDocumentRoot:webPath];
    
    // Start the server (and check for problems)
    
    NSError *error;
    if(![self.httpServer start:&error])
    {
        _isStartHttpService = FALSE;
        NSLog(@"Error starting HTnonatomic, TP Server: %@", error);
    }
    else{
        _isStartHttpService = TRUE;
    }
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkHttpService) userInfo:nil repeats:YES];
}

-(void)checkHttpService{
    if (![self.httpServer isRunning]) {
        NSError *error;
        if(![self.httpServer start:&error])
        {
            _isStartHttpService = FALSE;
            NSLog(@"Error starting HTTP Server: %@", error);
        }
        else{
            _isStartHttpService = TRUE;
        }
    }
    else {
        NSLog(@"%s httpService = ok",__FUNCTION__);
    }
}
#endif

-(void)showSelectDevice:(void (^)(NSInteger index ))selectDevice{
    /*
    self.selectDevice= selectDevice;
    NSArray *deviceArray = [DNLAController getInstance].lelinkServices;
    TYAlertView *alertView = nil;
    alertView.buttonFont = [UIFont systemFontOfSize:14];
    DNLAController * __weak weakSelf = self;
    if (deviceArray.count>0) {
        alertView = [TYAlertView alertViewWithTitle:@"选择投屏设备" message:@""];
        
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
                                                            if(weakSelf.selectDevice){
                                                                weakSelf.selectDevice(action.tagValue);
                                                            }
                                                        }];
            [alertView addAction:tn];
            tn.tagValue = i;
        }
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
    }
    else{
        UIAlertView *l  = [[UIAlertView alloc] initWithTitle:@"投屏失败" message:@"1:手机和电视必须在同一个无线网络才能投屏播放\n2：选择列表显示出来的都可以投影出来播放\n3：你可以投屏到电视，同时在手机上看其他电影，支持后台投影播放\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [l show];
    }*/
}



-(void)sdkAuthRequest{
    #if (QRUserLBLelinkKit==1)

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError * error = nil;
      
#ifdef DEBUG
        BOOL result = [LBLelinkKit authWithAppid:@"14634" secretKey:@"e8c66ee733322499e8493edda3936e31" error:&error];
#else
        BOOL result = [LBLelinkKit authWithAppid:[MajorSystemConfig getInstance].lelinkAppId secretKey:[MajorSystemConfig getInstance].lelinkAppSecretKey error:&error];
#endif
        if (result) {
            printf("sdkAuthRequest 授权成功\n");
            dispatch_sync(dispatch_get_main_queue(), ^{
            [self startSearchDevice];
            });
#if DoNotKMPLayerCanShareVideo
#else
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self startLocalServert];
            });
#endif
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sdkAuthRequest];
            });
        }
    });
#else
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.delegate = self;
#endif
}

-(void)startSearchDevice:(void (^)(void))searchBlock{
    #if (QRUserLBLelinkKit==1)
    if (!self.lelinkBrowser) {
        [LBLelinkBrowser reportAPPTVButtonAction];
        self.lelinkBrowser = [[LBLelinkBrowser alloc] init];
        self.lelinkBrowser.delegate = self;
    }
    [self.lelinkBrowser searchForLelinkService];
#else
    self.searchBlock = searchBlock;
    [self.dlnaManager startSearch];
#endif
}

-(void)disConnect{
    #if (QRUserLBLelinkKit==1)
   // [self.lelinkBrowser reportServiceListDisappear];
    self.player.delegate = nil;
    [self.player stop];
    self.lelinkConnection.delegate = nil;
    [self.lelinkConnection disConnect];
#endif
}


-(void)playWithUrl:(NSString*)url time:(float)time header:(NSDictionary*)header  isLocal:(BOOL)isLocal deviceIndex:(NSInteger)deviceIndex{
    if (self.lelinkServices.count>deviceIndex) {
#if DoNotKMPLayerCanShareVideo
#else
        NSRange range =  [url rangeOfString:VIDEOCACHESROOTPATH];
        if (range.location!=NSNotFound) {
            url =  [url substringFromIndex:range.location+range.length];
            url = [NSString stringWithFormat:@"http://%@:%d%@",[[UIDevice currentDevice] ipAddressWIFI],DNLHttpServerPort,url] ;
            isLocal = true;
         }
#endif
        //  @{@"referer":self.urlReferer};  User-Agent
        //header = @{@"User-Agent":@"kiwi/15564 CFNetwork/1125.2 Drawin/19.4.0"};
        self.url = url;
        self.startTime = time;
        self.currentTime = time;
        self.header = header;
        self.darutTime = 0;
        #if (QRUserLBLelinkKit==1)
        self.mediaType = LBLelinkMediaTypeVideoOnline;
        self.player.delegate = nil;
        [self.player stop];//kiwi/15564 CFNetwork/1125.2 Drawin/19.4.0
        self.lelinkConnection = [[LBLelinkConnection alloc] init];
        self.lelinkConnection.delegate = self;
        self.lelinkConnection.lelinkService = self.lelinkServices[deviceIndex];
        [self.lelinkConnection connect];
        #endif
        if([[VipPayPlus getInstance] isCanPlayVideoAd:false]){//20200214取消广告
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
            [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
            } isShowAlter:YES isForce:false];
        }
    }
}

-(void)playWithPhotoUrl:(NSString*)url  isPic:(BOOL)isPic deviceIndex:(NSInteger)deviceIndex{
    #if (QRUserLBLelinkKit==1)
    if (self.lelinkServices.count>deviceIndex) {
        self.mediaType = isPic?LBLelinkMediaTypePhotoOnline:LBLelinkMediaTypeVideoLocal;
        self.url = url;
        self.player.delegate = nil;
        [self.player stop];self.startTime = 0;
        self.lelinkConnection = [[LBLelinkConnection alloc] init];
        self.lelinkConnection.delegate = self;
        self.lelinkConnection.lelinkService = self.lelinkServices[deviceIndex];
        [self.lelinkConnection connect];
    }
#endif
}

    #if (QRUserLBLelinkKit==1)

- (void)lelinkBrowser:(LBLelinkBrowser *)browser onError:(NSError *)error{
    self.lelinkServices = nil;
}

- (void)lelinkBrowser:(LBLelinkBrowser *)browser didFindLelinkServices:(NSArray <LBLelinkService *> *)services{
    self.lelinkServices = nil;
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < services.count; i++) {
       LBLelinkService *v = [services objectAtIndex:i];
        if (v.innerLelinkDevice || v.upnpDevice) {
            [arrayTmp addObject:v];
        }
        self.lelinkServices = arrayTmp;
    }
}

- (void)lelinkConnection:(LBLelinkConnection *)connection onError:(NSError *)error{
    
}
/**
 连接成功代理回调
 
 @param connection 当前连接
 @param service 当前连接的服务
 */
- (void)lelinkConnection:(LBLelinkConnection *)connection didConnectToService:(LBLelinkService *)service{
    self.player = [[LBLelinkPlayer alloc] init];
    self.player.delegate = self;
    self.player.lelinkConnection = self.lelinkConnection;
    LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
    // 设置媒体类型
    item.mediaType = self.mediaType ;
    // 设置媒体的URL
    item.mediaURLString = self.url;
    item.headerInfo = self.header;
    // 设置开始播放位置
    item.startPosition = self.startTime;
    // 推送
    [self.player playWithItem:item];
}
/**
 连接断开代理回调
 
 @param connection 当前连接
 @param service 当前服务
 */
- (void)lelinkConnection:(LBLelinkConnection *)connection disConnectToService:(LBLelinkService *)service{
    
}
/**
 收到互动广告信息
 
 @param connection 当前
 @param adInfo 广告信息
 */
- (void)lelinkConnection:(LBLelinkConnection *)connection didReceiveAdInfo:(LBADInfo *)adInfo{
    
}

/**
 播放错误代理回调
 
 @param player 当前播放器
 @param error 错误信息
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player onError:(NSError *)error{
    
}
/**
 播放状态代理回调
 
 @param player 当前播放器
 @param playStatus 播放状态
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player playStatus:(LBLelinkPlayStatus)playStatus{
    self.playStatus = playStatus;
    if (playStatus == LBLelinkPlayStatusPlaying ) {
        [player seekTo:self.startTime];
        if (self.darutTime>0) {
            [player setVolume:30];
        }
    }
}
/**
 播放进度信息代理回调
 
 @param player 当前播放器
 @param progressInfo 进度信息
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player progressInfo:(LBLelinkProgressInfo *)progressInfo{
    self.currentTime = progressInfo.currentTime;
    self.darutTime = progressInfo.duration;
 }
/**
 设置检测行为错误代理回调，注意此方法不是在调用“- (void)setMonitorActions:(NSArray <LBMonitorAction *> *)monitorActions;”后立即回调，
 而是在调用推送行为过程中才设置的，并且是设置错误才有回调，设置正确不回调。
 
 @param player 当前播放器
 @param error 错误信息
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player setMonitorActionError:(NSError *)error{
    
}
/**
 防骚扰信息代理回调
 
 @param player 当前播放器
 @param harassInfo 防骚扰信息
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player harassInfo:(LBLelinkHarassInfo)harassInfo{
    
}
/**
 乐播使用的透传数据
 
 @param player 当前播放器
 @param dataObj 从接收端透传过来数据对象
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player passthLeboInternalData:(id)dataObj{
    
}

/**
 外部使用的透传数据
 
 @param player 当前播放器
 @param dataObj 从接收端透传过来的数据对象
 */
- (void)lelinkPlayer:(LBLelinkPlayer *)player passthExternalData:(id)dataObj{
    
}
#else
    - (void)searchDLNAResult:(NSArray *)devicesArray{
        self.lelinkServices = [NSArray arrayWithArray:devicesArray];
    }

    -(void)searchDLNAend{
        if (self.searchBlock) {
            self.searchBlock();
        }
        self.searchBlock = nil;
    }

    - (void)dlnaStartPlay{
        
    }

#endif
@end
