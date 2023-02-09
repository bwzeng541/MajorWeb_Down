//
//  TmpSetView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/10.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorPopGestureView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TmpSetView : MajorPopGestureView
+(void)showTmpSetView:(UIView*)parentView;
+(void)hidenTmpSetView;
+(BOOL)isShowState;
@end

NS_ASSUME_NONNULL_END
