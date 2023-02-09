//
//  VideoPlayerSetView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "VideoPlayerSetView.h"
#import "VideoPlayerSetCtrl.h"
#import "VipPayPlus.h"
static VideoPlayerSetView *videoSetView = nil;
static VideoPlayerSetCtrl *videoSetCtrl = nil;

@interface VideoPlayerSetView ()<VideoPlayerSetCtrlDelagate>
@end

@implementation VideoPlayerSetView

-(void)removeFromSuperview{
    videoSetView = nil;
    videoSetCtrl = nil;
    [super removeFromSuperview];
}

+(void)showVideoPlayerView:(ZFPlayerController*)player{
    if (!videoSetView) {
        videoSetView = [[VideoPlayerSetView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_HEIGHT, MY_SCREEN_WIDTH) player:player];
        [player.currentPlayerManager.view addSubview:videoSetView];
    }
}

+(void)hiddeVideoPlayerView{
    RemoveViewAndSetNil(videoSetView);
}

-(BOOL)isClickValid{
    BOOL ret = [[VipPayPlus getInstance] isVaildOperation:false plugKey:NSStringFromClass([self class])];
    if (!ret) {
        videoSetCtrl.player.smallFloatView.frame = CGRectMake(0, 0, MY_SCREEN_HEIGHT, MY_SCREEN_WIDTH);
        [videoSetCtrl.player addPlayerViewToKeyWindow];
        return false;
    }
    return true;
}

-(id)initWithFrame:(CGRect)frame player:(ZFPlayerController*)player{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [btn addTarget:self action:@selector(closeSetView:) forControlEvents:UIControlEventTouchUpInside];
    videoSetCtrl = [[VideoPlayerSetCtrl alloc] initWithNibName:@"VideoPlayerSetCtrl" bundle:NULL player:player.currentPlayerManager];
    videoSetCtrl.delegate = self;
    videoSetCtrl.player = player;
    [self addSubview:videoSetCtrl.view];
    [videoSetCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(videoSetCtrl.view.bounds.size.width);
        make.height.mas_equalTo(videoSetCtrl.view.bounds.size.height);
    }];
    return self;
}

-(void)closeSetView:(UIButton*)sender{
    [VideoPlayerSetView hiddeVideoPlayerView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
