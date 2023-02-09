//
//  ZZAppUtilities.m
//  DailyNews
//
//  Created by gluttony on 10/8/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "ZZAppUtilities.h"

BOOL ZZWeiXinInstalled()
{
    if ([UIApplication class]) {
        UIApplication *app = [UIApplication sharedApplication];
        return [app canOpenURL:[NSURL URLWithString:@"weixin://"]] || [app canOpenURL:[NSURL URLWithString:@"wechat://"]];
    }
    else {
        return NO;
    }
}
