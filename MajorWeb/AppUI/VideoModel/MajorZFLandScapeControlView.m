//
//  MajorZFLandScapeControlView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/10/16.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZFLandScapeControlView.h"
#import "VideoPlayerManager.h"
#import "VipPayPlus.h"
#import "BUPlayer.h"
@interface MajorZFLandScapeControlView()
@property(strong,nonatomic)UIButton *maskTopMask;
@end
@implementation MajorZFLandScapeControlView

- (void)backBtnClickAction:(UIButton *)sender {
    if (sender && [VipPayPlus getInstance].isPlayState) {
        [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
        [self.player.currentPlayerManager pause];//需要修改playe的l
        [BUPlayer reSetMute:false];
    }
    else if(sender){
        static BOOL isPlayExitFullVideo = true;
        if(!isPlayExitFullVideo && [[VipPayPlus getInstance]isCanPlayVideoAd:false]){
            [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
            [[VipPayPlus getInstance] tryPlayVideoAd:false  isUseTimeLimit:true block: ^(BOOL isSuccess) {
                if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlayStopped) {
                    [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                }
                [[VipPayPlus getInstance] tryPlayVideoFinish];
             }];
            isPlayExitFullVideo = true;
        }
    }
    [super backBtnClickAction:sender];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (!self.maskTopMask) {
        self.maskTopMask = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.maskTopMask addTarget:self action:@selector(pressFix) forControlEvents:UIControlEventTouchUpInside];
        [self.topToolView addSubview:self.maskTopMask];
    }
    [self.topToolView sendSubviewToBack:self.maskTopMask];
    self.maskTopMask.frame = self.topToolView.bounds;
}


-(void)pressFix{
    
}
@end
