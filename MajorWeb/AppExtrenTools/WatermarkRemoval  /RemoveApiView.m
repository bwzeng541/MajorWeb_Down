//
//  RemoveApiManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "RemoveApiView.h"
#import "RemoveMarkWeb.h"
#import "VideoPlayerManager.h"
@interface RemoveApiView()
@property(strong,nonatomic)RemoveMarkWeb *removeMarkWeb;
@property(strong,nonatomic)NSString *videoUrl;
@property(strong,nonatomic)NSString *referrer;
@property(strong,nonatomic)UILabel *uilabelUrl;
@end
@implementation RemoveApiView

-(void)dealloc{
    [self stop];
    NSLog(@"%s",__FUNCTION__);
}

-(id)init{
    self = [super init];
    return self;
}

-(id)initWithApi:(NSString*)searchApi searchVideoUrl:(NSString*)searchVideoUrl{
    self  = [super init];
    self.removeMarkWeb = [[RemoveMarkWeb alloc] initWithUrl:searchApi searchUrl:searchVideoUrl waitView:self];
    __weak __typeof(self)weakSelf = self;
    self.removeMarkWeb.removeMarkMsgBlock = ^(NSString * _Nonnull videoUrl, NSString * _Nonnull referrer) {
        [weakSelf updateVideoInfo:videoUrl referrer:referrer];
    };
    self.uilabelUrl = [[UILabel alloc] init];
    self.uilabelUrl.textAlignment = NSTextAlignmentCenter;
    self.uilabelUrl.textColor = [UIColor blackColor];
    self.uilabelUrl.text = @"查找中...";
    [self addSubview:self.uilabelUrl];
    [self.uilabelUrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    return self;
}

-(void)start {
    [self.removeMarkWeb start];
}

-(void)updateVideoInfo:(NSString*)videoUrl referrer:(NSString*)referrer{
    self.referrer = referrer;
    self.videoUrl = videoUrl;
    self.uilabelUrl.text = videoUrl;
    self.uilabelUrl.userInteractionEnabled = YES;
    [self.uilabelUrl bk_whenTapped:^{
        [[VideoPlayerManager getVideoPlayInstance] playWithUrl:videoUrl title:videoUrl referer:referrer saveInfo:@{@"requestUrl":videoUrl,@"theTitle":videoUrl} replayMode:NO rect:CGRectZero throwUrl:nil isUseIjkPlayer:false];
    }];
    [self stop];
}

-(void)stop{
    [self.removeMarkWeb stop];
    self.removeMarkWeb = nil;
}
@end
