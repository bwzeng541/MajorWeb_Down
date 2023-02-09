//
//  MajorZyCookie.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/9.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MajorZyCookie : NSObject
+(void)delCookie;
+(NSHTTPCookie*)getReadModeCookie;
@end

NS_ASSUME_NONNULL_END
