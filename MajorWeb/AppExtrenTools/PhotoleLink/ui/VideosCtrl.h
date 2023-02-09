//
//  VideosCtrl.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/25.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideosCtrlDelegate <NSObject>
-(void)willRemoveThrowLoad:(id)ctrl;
@end
NS_ASSUME_NONNULL_BEGIN

@interface VideosCtrl : UIViewController
-(void)initUI;
@property(weak,nonatomic)id<VideosCtrlDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
