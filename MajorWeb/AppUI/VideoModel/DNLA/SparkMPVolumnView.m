//
//  SparkMPVolumnView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "SparkMPVolumnView.h"
#define kTVMPVolumeViewTag 10
@implementation SparkMPVolumnView

-(instancetype)init{
    if(self = [self initWithFrame:CGRectZero]){
        self.backgroundColor = [UIColor clearColor];
        self.showsVolumeSlider = NO;
        self.tag = kTVMPVolumeViewTag;
        [self initMPButton];
    }
    return self;
}
//这个的目的是在AirPlay没有任何设备时也能呼出Picker使用
- (void)initMPButton{
    NSArray *subView = self.subviews;
    for (int i = 0; i < subView.count; i++) {
        UIButton *btnSender = [subView objectAtIndex:i];
        if ([btnSender isKindOfClass:[UIButton class]]) {
            self.MPButton = btnSender;
             [btnSender setImage:nil forState:UIControlStateNormal];
             [btnSender setImage:nil forState:UIControlStateHighlighted];
             [btnSender setImage:nil forState:UIControlStateSelected];
             [btnSender setBounds:CGRectZero];
            break;
        }

    }

}

@end
