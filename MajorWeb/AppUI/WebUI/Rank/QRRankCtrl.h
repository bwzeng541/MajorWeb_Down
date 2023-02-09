//
//  QRRankCtrl.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRRankCtrl : UIViewController
-(void)setBlock:(void(^)(NSString*url))clickBlock willRemoveBlock:(void(^)(void))willRemoveBlock;
@end

NS_ASSUME_NONNULL_END
