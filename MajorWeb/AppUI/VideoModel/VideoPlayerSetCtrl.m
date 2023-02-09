//
//  VideoPlayerSetCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VideoPlayerSetCtrl.h"
#import "NSObject+UISegment.h"
#import "ShareSdkManager.h"
#import "ZFPlayerControlView.h"
@interface VideoPlayerSetCtrl ()
@property(nonatomic,weak)IBOutlet UIView *fullSetView;
@property(nonatomic,weak)IBOutlet UIView *speedSetView;
@property(nonatomic,weak)IBOutlet UIButton *btnFullMain;
@property(nonatomic,weak)IBOutlet UIButton *btn100Main;
@property(nonatomic,weak)IBOutlet UIButton *btn75Main;
@property(nonatomic,weak)IBOutlet UIButton *btn50Main;
@property(nonatomic,weak)IBOutlet UIButton *btnSpeed0_75;
@property(nonatomic,weak)IBOutlet UIButton *btnSpeed1_0;
@property(nonatomic,weak)IBOutlet UIButton *btnSpeed1_25;
@property(nonatomic,weak)IBOutlet UIButton *btnSpeed1_5;
@property(nonatomic,weak)IBOutlet UIButton *btnSpeed2_0;
@property(nonatomic,weak)IBOutlet UIButton *btn1;

@property (nonatomic, weak) id<ZFPlayerMediaPlayback> currentPlayerManager;
@end

@implementation VideoPlayerSetCtrl

-(void)dealloc{
    
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil player:(id<ZFPlayerMediaPlayback>)player{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.currentPlayerManager = player;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize btnSize = CGSizeMake(50, 24);
    CGSize conentSize = self.fullSetView.bounds.size;
    [NSObject initii:self.fullSetView contenSize:conentSize vi:_btnFullMain viSize:btnSize vi2:nil index:0 count:4];
    [NSObject initii:self.fullSetView contenSize:conentSize vi:_btn100Main viSize:btnSize vi2:_btnFullMain index:1 count:4];
    [NSObject initii:self.fullSetView contenSize:conentSize vi:_btn75Main viSize:btnSize vi2:_btn100Main index:2 count:4];
    [NSObject initii:self.fullSetView contenSize:conentSize vi:_btn50Main viSize:btnSize vi2:_btn75Main index:3 count:4];

    [NSObject initii:self.speedSetView contenSize:conentSize vi:_btnSpeed0_75 viSize:btnSize vi2:nil index:0 count:5];
    [NSObject initii:self.speedSetView contenSize:conentSize vi:_btnSpeed1_0 viSize:btnSize vi2:_btnSpeed0_75 index:1 count:5];
    [NSObject initii:self.speedSetView contenSize:conentSize vi:_btnSpeed1_25 viSize:btnSize vi2:_btnSpeed1_0 index:2 count:5];
    [NSObject initii:self.speedSetView contenSize:conentSize vi:_btnSpeed1_5 viSize:btnSize vi2:_btnSpeed1_25 index:3 count:5];
    [NSObject initii:self.speedSetView contenSize:conentSize vi:_btnSpeed2_0 viSize:btnSize vi2:_btnSpeed1_5 index:4 count:5];
    [self updateSpeedBtnState];
    [self updateFullBtnState];
}

-(void)updateFullBtnState{
    [self.btn50Main setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btn75Main setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btn100Main setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnFullMain setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];

    if (self.currentPlayerManager.scalingMode == ZFPlayerScalingModeFill) {
        [self.btnFullMain setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if (self.currentPlayerManager.scalingMode == ZFPlayerScalingModeAspectFill) {
        [self.btn100Main setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if (self.currentPlayerManager.scalingMode == ZFPlayerScalingModeAspectFit) {
        [self.btn75Main setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if (self.currentPlayerManager.scalingMode == ZFPlayerScalingModeNone) {
        [self.btn50Main setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
 }

-(void)updateSpeedBtnState{
    [self.btnSpeed0_75 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnSpeed2_0 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnSpeed1_25 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnSpeed1_5 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnSpeed1_0 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    if ( fabs(self.currentPlayerManager.rate-0.75)<0.1) {
        [self.btnSpeed0_75 setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if ( fabs(self.currentPlayerManager.rate-1.0)<0.1) {
        [self.btnSpeed1_0 setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if ( fabs(self.currentPlayerManager.rate-1.5)<0.1) {
        [self.btnSpeed1_5 setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if ( fabs(self.currentPlayerManager.rate-1.25)<0.1) {
        [self.btnSpeed1_25 setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    else if ( fabs(self.currentPlayerManager.rate-2.0)<0.1) {
        [self.btnSpeed2_0 setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
}

-(IBAction)pressFullMain:(id)sender{
    if ([self.delegate isClickValid]) {
        [self.currentPlayerManager setScalingMode:(ZFPlayerScalingModeFill)];
        [self updateFullBtnState];
    }
}

-(IBAction)press100Main:(id)sender{
    if ([self.delegate isClickValid]) {
    [self.currentPlayerManager setScalingMode:(ZFPlayerScalingModeAspectFill)];
    [self updateFullBtnState];
    }
}

-(IBAction)press75Main:(id)sender{
    if ([self.delegate isClickValid]) {
    [self.currentPlayerManager setScalingMode:(ZFPlayerScalingModeAspectFit)];
    [self updateFullBtnState];
    }
}

-(IBAction)press50Main:(id)sender{
    if ([self.delegate isClickValid]) {
    [self.currentPlayerManager setScalingMode:(ZFPlayerScalingModeNone)];
    [self updateFullBtnState];
    }
}

-(IBAction)pressSpeen0_75:(id)sender{
    if ([self.delegate isClickValid]) {
    self.currentPlayerManager.rate = 0.75;
    [self updateSpeedBtnState];
    }
}

-(IBAction)pressSpeen1_0:(id)sender{
    if ([self.delegate isClickValid]) {
    self.currentPlayerManager.rate = 1.0;
    [self updateSpeedBtnState];
    }
}

-(IBAction)pressSpeen1_25:(id)sender{
    if ([self.delegate isClickValid]) {
    self.currentPlayerManager.rate = 1.25;
    [self updateSpeedBtnState];
    }
}

-(IBAction)pressSpeen1_5:(id)sender{
    if ([self.delegate isClickValid]) {
    self.currentPlayerManager.rate = 1.5;
    [self updateSpeedBtnState];
    }
}

-(IBAction)pressSpeen2_0:(id)sender{
    if ([self.delegate isClickValid]) {
    self.currentPlayerManager.rate = 2;
    [self updateSpeedBtnState];
    }
}

-(IBAction)press1:(id)sender{
   NSString *ss = ((ZFPlayerControlView*)self.player.controlView).landScapeControlView.titleLabel.text;
  UIView *v =  [[ShareSdkManager getInstance] showShareType:SSDKContentTypeApp typeArray:^NSArray *{
        return @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline)];
    } value:^NSString *{
        return nil;
    } titleBlock:^NSString *{
        return [BeatifyAssetVideoShareMsg stringByAppendingString:ss];
    } imageBlock:^UIImage *{
        return nil;
    }urlBlock:^NSString  *{
        return [self.currentPlayerManager.assetURL absoluteString];
    }shareViewTileBlock:^NSString *{
        return @"分享播放地址给好友";
    }];
    v.transform = CGAffineTransformMakeRotation(M_PI_2);
}
@end
