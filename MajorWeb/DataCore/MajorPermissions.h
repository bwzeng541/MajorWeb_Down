//
//  MajorPermissions.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/5/14.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MajorPermissions : NSObject
+(void)playClickPerMissions:(NSString*)key pressmission:(void(^)(BOOL))pressmission;
@end

NS_ASSUME_NONNULL_END
