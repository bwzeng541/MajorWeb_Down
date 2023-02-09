//
//  QrByteVideoAd.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/14.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UIViewController;
@interface QrByteVideoAd : NSObject
-(id)initWithRootCtrl:(UIViewController*)ctrl;
-(void)stop;
-(BOOL)start:(void (^)(void))clickVideoAdBlock;
@end

NS_ASSUME_NONNULL_END
