//
//  ZFDouYinControlView.h
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/6/4.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayerControlView.h"

@interface MajorVideoControlView : ZFPlayerControlView <ZFPlayerMediaControl>
@property(copy,nonatomic)NSString *downVideoHtml;
@property(copy,nonatomic)NSString *downTitle;
@property(copy,nonatomic)NSString *downVideoUrl;
@property (nonatomic, copy, nullable) NSArray *(^updateVidesArray)(void);
@property (nonatomic, copy, nullable) void (^updateVideoUrl)(NSString *videoUrl);

- (void)videoCachesDown;

- (void)cancelAllPerformSelector;

- (void)sharePlay;

- (void)marjorHiddenCallBack:(BOOL)withAnimated;

- (void)reSetTopCtrlView;

- (void)resetControlView;

- (void)hideFixCtrl;

- (void)showCoverViewWithUrl:(NSString *)coverUrl;

- (void)addShareBtn;

- (void)updateDynamic:(NSArray*)videoArray;

- (void)updatePlayTime:(float)playTime;
@end
