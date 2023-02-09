//
//  VideoPreloadAd.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface VideoPreloadAd : NSObject
-(void)start:(void(^)(id adObject))successVideoAdBlock;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
