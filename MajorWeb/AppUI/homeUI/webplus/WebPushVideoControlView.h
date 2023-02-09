//
//  ZFDouYinControlView.h
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/6/4.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayerControlView.h"
typedef enum WebPushPlayMode{
    WebPush_DouYin_Mode,
    WebPush_Defualt_Mode,
    WebPush_Small_Mode
}WebPushPlayMode;
@interface WebPushVideoControlView : ZFPlayerControlView <ZFPlayerMediaControl>
@property (nonatomic, assign)WebPushPlayMode webPlayMode;
-(void)updatePlayMode:(WebPushPlayMode)webPlayMode;
-(void)updateWebMode;
-(void)intoFull:(BOOL)isFull title:(NSString*)title;
@end
