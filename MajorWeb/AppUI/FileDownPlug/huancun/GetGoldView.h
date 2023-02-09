//
//  GetGoldView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/21.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol GetGoldViewDelegate <NSObject>
-(void)back_from_gold;
@end
@interface GetGoldView : UIViewController
@property(weak)id<GetGoldViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
