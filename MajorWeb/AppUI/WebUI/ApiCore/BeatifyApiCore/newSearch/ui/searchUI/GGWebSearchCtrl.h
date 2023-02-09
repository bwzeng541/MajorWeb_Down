//
//  GGWebSearchCtrl.h
//  GGBrower
//
//  Created by zengbiwang on 2019/12/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol GGWebSearchCtrlDelegate <NSObject>
-(void)ggWebSearch:(NSArray*)urls titles:(NSArray*)titlesArray word:(NSString*)word isSearch:(BOOL)isSearch ;
@end
@interface GGWebSearchCtrl : UIViewController
@property(weak)id<GGWebSearchCtrlDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
