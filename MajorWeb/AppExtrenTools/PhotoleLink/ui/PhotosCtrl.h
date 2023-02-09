//
//  PhotosCtrl.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PhotosCtrlDelegate <NSObject>
-(void)willRemoveThrowLoad:(id)ctrl;
@end
@interface PhotosCtrl : UIViewController
-(void)initUI;
@property(weak,nonatomic)id<PhotosCtrlDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
