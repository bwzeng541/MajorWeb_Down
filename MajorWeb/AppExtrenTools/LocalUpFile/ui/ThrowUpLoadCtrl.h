//
//  ThrowUpLoadCtrl.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ThrowUpLoadCtrlDelegate <NSObject>
-(void)willRemoveThrowLoad:(id)ctrl;
@end
@interface ThrowUpLoadCtrl : UIViewController
@property(weak,nonatomic)id<ThrowUpLoadCtrlDelegate>delegate;
-(void)initUI;
@end

NS_ASSUME_NONNULL_END
