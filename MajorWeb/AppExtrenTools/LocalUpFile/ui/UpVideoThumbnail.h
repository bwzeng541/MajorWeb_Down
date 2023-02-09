//
//  VideoThumbnail.h
//  WatchApp
//
//  Created by zengbiwang on 2017/9/26.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VideoThumbnailShareBlock)(NSString *uuid, BOOL shareState);

@interface UpVideoThumbnail : UIView
-(void)showThumbanil:(NSString*)videoPath;
-(void)showThumbanilUrl:(NSURL*)url;
-(void)setThumbani:(UIImage*)image;
@property(copy)VideoThumbnailShareBlock shareBlock;
@end
