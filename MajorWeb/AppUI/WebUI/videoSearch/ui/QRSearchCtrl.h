//
//  QRSearchCtrl.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRSearchCtrl : UIViewController
-(void)initClickBlock:(void (^)(NSString *url))clickBlock;
@end

NS_ASSUME_NONNULL_END
