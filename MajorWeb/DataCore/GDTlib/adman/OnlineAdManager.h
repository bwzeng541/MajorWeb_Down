//
//  OnlineAdManager.h
//  WatchApp
//
//  Created by zengbiwang on 2018/7/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlineAdManager : NSObject
+(OnlineAdManager*)getInstance;
-(BOOL)isCanShowAd;
-(void)updateClickInfo;
@end
