//
//  WebsNodeView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebsNodeView.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "MajorVideoControlView.h"
#import "ZFAVPlayerManager.h"
#import "AppDelegate.h"
#import "ZFUtilities.h"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define WebsNodeShowFaildInfo 0
@interface WebsNodeView(){
    CGSize videoSize;
    UILabel *sizelable;
}
@property(assign)float videoTime;
@property(copy)NSString *title;
@property(assign)BOOL isSeek;
@property (nonatomic, strong) UIView *view;
@property(nonatomic,strong)NSString *url;
@property(strong)UILabel *labelDes;
@property(copy)NSString* tmpVideoUrl;
@property(copy)NSString* videoUrl;
@property(copy)NSString*requestAsset;
@property (nonatomic, strong) MajorPlayerController *player;
@property (nonatomic, strong) MajorVideoControlView *controlView;
@end

@implementation WebsNodeView
@synthesize videoUrl;

-(void)dealloc{
    self.externObject = nil;
    self.externObjectThrow = nil;
    [self unInitAsset];
    NSLog(@"%s",__FUNCTION__);
}

-(ZFPlayerController*)testFution{
     return self.player;
}

-(void)setInterfaceNil{
    _player = nil;
}

-(void)unInit{
  [_player stop];
  self.controlView = nil;
  self.player = nil;
}

-(id)init{
    self = [super init];
    self.view = [[UIView alloc] init];
    return self;
}

#if (WebsNodeShowFaildInfo==1)
-(void)addFaildInfo:(BOOL)top{
    float lableH = 30;
    CGSize  size = self.view.bounds.size;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height-(top?lableH*2:lableH), size.width, lableH)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = RGBACOLOR(0, 0, 0, 255*0.8);
    [self.view addSubview:label];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = self.requestAsset;
}
#endif

-(void)initNodePlayer:(NSString*)url oldAsset:(NSString*)oldAsset isSeek:(BOOL)isSeek{
    self.url = url;
    self.requestAsset = oldAsset;
    self.isSeek = isSeek;
    self.title = IF_IPAD?@"选择时间长的播放":@"";
    NSLog(@"initNodePlayer videoUrl = %@ requestAsset  = %@",url,self.requestAsset);
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    /// player的tag值必须在cell里设置
    self.player = (MajorPlayerController*)[MajorPlayerController playerWithPlayerManager:playerManager containerView:self.view];
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
    @weakify(self)
    
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        @strongify(self)
        NSLog(@"playerPlayFailed %@ oldAsset = %@ url = %@",[self.player.currentPlayerManager.assetURL absoluteString],self.requestAsset,[error description]);
        if ([self.delegate respondsToSelector:@selector(faildAsset:)]) {
            [self.delegate faildAsset:self];
        }
#if (WebsNodeShowFaildInfo==1)
        [self addFaildInfo:false];
#endif
    };
    self.player.presentationSizeChanged = ^(CGSize presentSize) {
        @strongify(self)
        self->videoSize = presentSize;
        self->sizelable.text = [NSString stringWithFormat:@"分辨率:%0.0fX%0.0f",presentSize.width,presentSize.height];
        NSLog(@"majorThumbnail 86= %@  ",NSStringFromCGSize(presentSize))  ;
    };
    
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        [self updateSize];
    };
    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)
        [self updateTime:duration];
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(isMuteAsset:)] && [self.delegate isMuteAsset:self]){
            [self.player.currentPlayerManager setVolume:0];
        }
        else{
        }
    };
    self.player.assetURL = [NSURL URLWithString:url];
}

-(void)updateSize{

}

-(void)clickPlay:(id)sender{
    if ([self.delegate respondsToSelector:@selector(clickAsset:)]) {
        [self.delegate clickAsset:self];
    }
}

-(void)updateTime:(float)duration{
    if (![self.view viewWithTag:1000]) {
        
        RemoveViewAndSetNil(self.labelDes)
        RemoveViewAndSetNil(sizelable)
        //267 X62
        float btnW = 267,btnH = 62,lableH = 30;
        if (IF_IPHONE) {
            btnW/=2;
            btnH/=2;
            lableH = 23;
        }
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:playBtn];
        playBtn.frame = CGRectMake((self.view.bounds.size.width-btnW)/2, (self.view.bounds.size.height-btnH)/2, btnW, btnH);
        playBtn.tag = 1000;
        [playBtn setImage:UIImageFromNSBundlePngPath(@"tuijie_thumBnail") forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
        CGSize size = self.view.bounds.size;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height-lableH, size.width, lableH)];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = RGBACOLOR(0, 0, 0, 255*0.8);
        //左下角title
        UILabel *  labelText = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height-lableH, size.width, lableH)];
        labelText.textColor = [UIColor whiteColor];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.text = [NSString stringWithFormat:@"%@",self.title];
        labelText.font = [UIFont systemFontOfSize:10];
        
        int hh = (int)duration/3600;
        int mm = (((int)duration)-(hh)*3600)/60;
        int ss =  (int)(duration-hh*3600) % 60;
        label.textAlignment = IF_IPAD?NSTextAlignmentCenter:NSTextAlignmentRight;
        label.text = [NSString stringWithFormat:@"总时间%02d:%02d:%02d", hh, mm,ss];
        label.font = [UIFont boldSystemFontOfSize:IF_IPHONE?24:30];
        label.textColor = [UIColor redColor];
        [self.view addSubview:label];
        [self.view addSubview:labelText];
        
        sizelable  = [[UILabel alloc] initWithFrame:labelText.frame];
        sizelable.textAlignment = NSTextAlignmentLeft;
        sizelable.font = label.font;
        sizelable.textColor =  [UIColor greenColor];
        [self.view addSubview:sizelable];
        sizelable.text = [NSString stringWithFormat:@"分辨率:%0.0fX%0.0f",videoSize.width,videoSize.height];
        
        videoUrl = _tmpVideoUrl;//fix 判断duration是否为直播
        if ((isnan(duration) || duration > 600)) {
            NSLog(@"playOK videoUrl = %@",_tmpVideoUrl);
            self.videoTime = duration;
             if (self.videoTime>0 && self.isSeek) {
                [self.player seekToTime:self.videoTime*0.6 completionHandler:^(BOOL finished) {
             }];
            }
        }
#if (WebsNodeShowFaildInfo==1)
        [self addFaildInfo:true];
#endif
    }
}

-(void)unInitAsset{
    [self.player stop];
    self.player = nil;
}

-(void)pause{
    [self.player.currentPlayerManager pause];
}

-(void)play{
    [self.player.currentPlayerManager play];
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
