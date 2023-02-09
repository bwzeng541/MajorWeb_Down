//
//  VideoPlayerSetView.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayerController.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerSetView : UIView
+(void)showVideoPlayerView:(ZFPlayerController*)player;
+(void)hiddeVideoPlayerView;
@end

NS_ASSUME_NONNULL_END
