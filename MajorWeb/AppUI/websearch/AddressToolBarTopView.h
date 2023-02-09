//
//  GGToolBarTopView.h
//  GGBrower
//
//  Created by zengbiwang on 2019/12/16.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^AddressToolBarTopViewCopy)(void);
typedef void (^AddressToolBarTopViewEdit)(void);

@interface AddressToolBarTopView : UIView
@property(copy)AddressToolBarTopViewCopy copyWeb;
@property(copy)AddressToolBarTopViewEdit editWeb;
@end

NS_ASSUME_NONNULL_END
