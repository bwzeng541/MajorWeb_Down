//
//  HuanCunCtrl.h
//  WatchApp
//
//  Created by zengbiwang on 2018/4/27.
//  Copyright © 2018年 cxh. All rights reserved.
//
#if DoNotKMPLayerCanShareVideo
#else
#import <UIKit/UIKit.h>
@protocol HuanCunCtrlDelegate
-(void)hc_back_Event;
@end
@interface HuanCunCtrl : UIViewController
@property(assign)id<HuanCunCtrlDelegate>delegate;
+(void)sycnSortTable;
@end
#endif
