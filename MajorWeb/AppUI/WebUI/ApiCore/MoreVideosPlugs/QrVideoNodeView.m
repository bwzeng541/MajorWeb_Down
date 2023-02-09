//
//  QrVideoNodeView.m
//  QRTools
//
//  Created by bxing zeng on 2020/5/7.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QrVideoNodeView.h"
#import "QRWKWebview.h"
#import "ZFPlayer.h"
#import "ZFPlayerControlView.h"
#import "ZFAVPlayerManager.h"
//#import "QRDeviceAssetManager.h"
//#import "HMScannerController.h"
//#import "QRSystemConfig.h"
#import "VideoPlayerManager.h"
#import "MajorPlayerController.h"
#import "MajorVideoControlView.h"
#import "ZFUtilities.h"
@interface QrVideoNodeView()<QRWKWebviewDelegate>
@property(copy,nonatomic)NSString *uuid;
@property(strong,nonatomic)MajorVideoControlView *controlView;
@property(strong,nonatomic)QRWKWebview *webView;
@property(strong,nonatomic)UILabel *maskSearchLabel;
@property(nonatomic, strong)MajorPlayerController *player;
@property(nonatomic,copy)NSString *mediaTitle;
@property(assign)BOOL isGetState;
@property(strong)NSTimer *delayTimer;
@property(strong)NSTimer *delayFrieTimer;
@property(copy)NSString *urlAdderss;
@property(copy)NSString *urlAdderssTitle;
#ifdef DEBUG
@property(copy)NSString *reqeutUrl;
@property(strong)NSTimer *showTimer;
@property(strong)UIButton *assetLabel;
#endif
@end
@implementation QrVideoNodeView

- (void)dealloc{
    #ifdef DEBUG
    NSLog(@"%s",__FUNCTION__);
    #endif
}

-(void)removeFromSuperview{
    [self clearNodeAsset];
    [super removeFromSuperview];
}

-(void)removeNotClear{
    [super removeFromSuperview];
}

-(void)clearNodeAsset{
    #ifdef DEBUG
    [self.showTimer invalidate];self.showTimer = nil;
    #endif
    [self.delayTimer invalidate];self.delayTimer = nil;
    [self.delayFrieTimer invalidate];self.delayFrieTimer=nil;
    self.describeView.hidden = YES;
    self.btnQrScan.hidden = YES;
    self.btnBigQrScan.hidden = NO;
    [self.maskSearchLabel removeFromSuperview];
    self.maskSearchLabel = nil;
    [self.player.smallFloatView removeFromSuperview];
    [self.player.controlView removeFromSuperview];
    [self.player.currentPlayerManager.view removeFromSuperview];
    [self.player stop];
    self.player = nil;
    [self.webView removeFromSuperview];
    self.webView = nil;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        [self awakeFromNib];
    }
    CFUUIDRef   uuidObj = CFUUIDCreate(nil);
    NSString    *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    self.uuid = uuidString;
    CFRelease(uuidObj);
    self.btnQrScan.hidden = YES;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
  {
      if (self = [super initWithCoder:aDecoder])
      {
          [self awakeFromNib];
      }
      return self;
}

- (void)awakeFromNib {
     [[NSBundle mainBundle] loadNibNamed:@"QrVideoNodeView" owner:self options:nil];
    self.contentView.frame = self.bounds;
    self.contentView.backgroundColor = [UIColor orangeColor];
    [self addSubview:self.contentView];
    [super awakeFromNib];
}
 
 

-(IBAction)pressPlay:(id)sender{
   // [[VideoPlayerManager getVideoPlayInstance] playWithInterface:self.player url:[self.player.currentPlayerManager.assetURL absoluteString] title:self.mediaTitle];
    
    NSString *url = nil;
    NSRange range = [self.urlAdderss rangeOfString:@"=http"];
    if (range.location!=NSNotFound) {
        url = [self.urlAdderss substringFromIndex:range.location+1];
    }
    NSDictionary *saveInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self.player.currentPlayerManager.assetURL absoluteString],@"requestUrl",self.mediaTitle,@"theTitle", nil];
    [[VideoPlayerManager getVideoPlayInstance] playWithPlayerInterface:self.player title:self.mediaTitle saveInfo:saveInfo isMustSeekBegin:false];
    self.player = nil;
    [self.delegate selectQrVideoNode];
}

-(IBAction)pressScan:(id)sender{
//    self.btnBigQrScan.hidden = YES;
//    __weak typeof(self) weakSelf = self;
//      [[QRDeviceAssetManager shareInstance] checkVideoAuthority:^(BOOL ret) {
//          if (ret ) {
//              HMScannerController * v = [[HMScannerController alloc]  initWithNibName:@"HMScannerController" bundle:nil];
//              v.view.frame = CGRectMake(0, 0, [QRSystemConfig shareInstance].deviceSize.width, [QRSystemConfig shareInstance].deviceSize.height);
//              v.modalPresentationStyle = UIModalPresentationFullScreen;
//              [GetAppDelegate.window.rootViewController presentViewController:v animated:YES completion:nil];
//                v.callBackBlock = ^(HMScannerController * _Nonnull vc, NSString * _Nonnull content) {
//                    [vc clearAllAsset];
//                    [vc dismissViewControllerAnimated:YES completion:^{
//                        [weakSelf gotoSearch:content];
//                    }];
//                    #ifdef DEBUG
//                    NSLog(@"content = %@",content);
//                    #endif
//                };
//          }
//      } ipadView:sender parentCtrl:GetAppDelegate.window.rootViewController];
}

-(void)delayTimeOut:(NSTimer*)timer{
    if ([self.delegate recviceCheckNumber:self]) {
        [self.delayTimer invalidate];self.delayTimer = nil;
        [self.delegate reviceAndCheckIsVaild:@"" object:self isFaild:true];
    }
}

-(void)delayFrieTimerFutin:(NSTimer*)timer{
    if (!self.webView) {
        NSString *url = [timer.userInfo objectForKey:@"v1"];
        NSString *title = [timer.userInfo objectForKey:@"v2"];
                   #ifdef DEBUG
                   self.reqeutUrl=[timer.userInfo objectForKey:@"v1"];
                   #endif
        self.webView = [[QRWKWebview alloc] initWithFrame:self.contentView.bounds uuid:self.uuid userAgent:nil isExcutJs:true];
        self.webView.isUseChallenge = false;
        [self.contentView addSubview:self.webView];
        self.mediaTitle = title;
        [self.webView setWebViewType:webView_Simple];
                       self.webView.webView.scrollView.scrollEnabled = false;
        if (@available(iOS 11.0, *)) {
            self.webView.webView.scrollView.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
                       self.webView.webView.userInteractionEnabled = NO;
                       [self.webView loadUrl:url];
                   self.webView.qrWkdelegate = self;
                   self.maskSearchLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
           #ifdef DEBUG
                   self.maskSearchLabel.backgroundColor = [UIColor clearColor];
        self.webView.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;

           #else
                   self.maskSearchLabel.backgroundColor = [UIColor blackColor];
           #endif
                   self.maskSearchLabel.text = @"资源查找中";
                   self.maskSearchLabel.textColor = [UIColor whiteColor];
                   [self.contentView addSubview:self.maskSearchLabel];
                   self.maskSearchLabel.textAlignment = NSTextAlignmentCenter;
                   
                   if (!self.delayTimer) {
                       self.delayTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:15] interval:3 target:self selector:@selector(delayTimeOut:) userInfo:nil repeats:YES];
                       [[NSRunLoop currentRunLoop] addTimer:self.delayTimer forMode:NSDefaultRunLoopMode];
                   }
           #ifdef DEBUG
                   NSLog(@"QrVideoNode url %@",url);
                   if (!self.showTimer) {
                       self.showTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showAssetLabel) userInfo:nil repeats:YES];
                       self.assetLabel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
                       [self addSubview:self.assetLabel];
                        self.assetLabel.titleLabel.font = [UIFont systemFontOfSize:13];
                       [self.assetLabel setTitle:self.reqeutUrl forState:UIControlStateNormal];
                       [self.assetLabel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                       self.assetLabel.titleLabel.adjustsFontSizeToFitWidth =NO;
                       [self.assetLabel addTarget:self action:@selector(copyUrl:) forControlEvents:UIControlEventTouchUpInside];
                   }
           #else
           #endif
               }
    [self.delayFrieTimer invalidate];
      self.delayFrieTimer = nil;
}

#ifdef DEBUG
-(void)copyUrl:(id)sender{
    if (self.reqeutUrl) {
        [UIPasteboard generalPasteboard].string = self.reqeutUrl;
        //[[QRSystemConfig shareInstance] showAlterMsg:@"复制成功"];
    }
}
#endif

-(void)loadUrl:(NSString*)url title:(NSString*)title delay:(float)delay{
    if (!self.delayFrieTimer) {
        self.urlAdderss = url;
        self.urlAdderssTitle = title;
        self.delayFrieTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:delay] interval:1 target:self selector:@selector(delayFrieTimerFutin:) userInfo:@{@"v1":url,@"v2":title} repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.delayFrieTimer forMode:NSDefaultRunLoopMode];
    }
}

#ifdef DEBUG
-(void)showAssetLabel{
    [self bringSubviewToFront:self.assetLabel];
}
#endif
-(void)qrExternCallBack:(BOOL)isSuccess uuid:(NSString*)uuid assetKey:(NSString*)assetKey title:(NSString*)title {
    [self.webView removeFromSuperview];
    self.webView = nil;
    [self.delayTimer invalidate];self.delayTimer=nil;
    [self.delayFrieTimer invalidate];self.delayFrieTimer=nil;
    NSLog(@"%s %@ %@",__FUNCTION__,uuid,assetKey);
    if (!isSuccess) {
        self.btnBigQrScan.hidden = NO;
    }
    [self.maskSearchLabel removeFromSuperview];self.maskSearchLabel = nil;
    if (isSuccess) {
       isSuccess = [self.delegate reviceAndCheckIsVaild:assetKey object:self isFaild:false];
    }
    if (!self.player && isSuccess) {
        self.btnQrScan.hidden = NO;
        if ([self.mediaTitle length]<=2 && [title length]>2) {
            self.mediaTitle = title;
        }
        id<ZFPlayerMediaPlayback> playerManager = [[ZFAVPlayerManager alloc] init];
        self.player = (MajorPlayerController*)[MajorPlayerController playerWithPlayerManager:playerManager containerView:self.webOrVideoView];
           /// player的tag值必须在cell里设置
           self.player.controlView = self.controlView;
           /// 0.8是消失80%时候，默认0.5
           self.player.playerDisapperaPercent = 0.8;
           self.player.allowOrentitaionRotation = NO;
           /// 移动网络依然自动播放
           self.player.WWANAutoPlay = YES;
           self.player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
           self.player.currentPlayerManager.view.userInteractionEnabled = NO;
          ZFPlayerControlView *vv = (ZFPlayerControlView*) (self.player.controlView);
           vv.portraitControlView.hidden = YES;
            __weak __typeof(self)weakSelf = self;
            self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
                [weakSelf.delegate recviceQrVideoStateFaild:[asset.assetURL absoluteString]object:weakSelf];
            };
           
            self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
              
             };
            self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
               [weakSelf updateDuration:duration currentTime:currentTime];
            };
            
            self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
             };
            self.player.presentationSizeChanged = ^(CGSize presentSize) {
                if(presentSize.width<10){
                    [weakSelf.delegate recviceQrVideoStateFaild:[weakSelf.player.currentPlayerManager.assetURL absoluteString]object:weakSelf];
                }
                else{
                    [weakSelf updateSize:presentSize];
                }
            };
            self.player.assetURL = [NSURL URLWithString:assetKey];
         //  [self.controlView showTitle:self.mediaTitle coverURLString:@""  placeholderImage:nil fullScreenMode:ZFFullScreenModeAutomatic];
        [self.controlView showTitle:self.mediaTitle coverURLString:@"" fullScreenMode:ZFFullScreenModeAutomatic];
           self.webOrVideoView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    }
    self.clipsToBounds = YES;
}

-(void)updateDuration:(float)duration currentTime:(NSTimeInterval)currentTime{
    int hh = (int)duration/3600;
    int mm = (((int)duration)-(hh)*3600)/60;
    int ss =  (int)(duration-hh*3600) % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"总时间%02d:%02d:%02d", hh, mm,ss];
    self.timeLabel.textColor = [UIColor redColor];
    self.describeView.hidden = NO;
    if (!self.isGetState) {
        #ifdef DEBUG
                printf("updateDuration url = %s\n",[self.reqeutUrl UTF8String]);
        #endif
          [self.delegate recviceQrVideoState:self];
          self.isGetState =true;
        if (![self.delegate recviceAndCheckIsMutilFront]) {
           // [self pressPlay:nil];
        }
      }
}

-(void)updateSize:(CGSize)size{
    NSString *msg = size.width>=1000?[NSString stringWithFormat:@"%@%@%@%@",@"高",@"清",@"视",@"频--"]:[NSString stringWithFormat:@"%@%@%@%@",@"标",@"清",@"视",@"频--"];
    self.resolvLabel.text = [NSString stringWithFormat:@"%@分辨率:%0.0fX%0.0f",msg,size.width,size.height];
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [MajorVideoControlView new];
        UIImage *image = ZFPlayer_Image(@"loading_1");
        _controlView.placeholderImage = image;
    }
    return _controlView;
}

@end
