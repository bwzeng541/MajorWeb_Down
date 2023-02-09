//
//  AppVipBuyCtrl.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/12/24.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AppVipBuyCtrlDelegate <NSObject>
-(void)willRemove;
@end
@interface AppVipBuyCtrl : UIViewController
@property(weak)id<AppVipBuyCtrlDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
