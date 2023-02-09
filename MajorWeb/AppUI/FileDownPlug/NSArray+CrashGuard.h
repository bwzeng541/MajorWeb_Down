//
//  NSArray_CrashGuard.h
//  WatchApp
//
//  Created by zengbiwang on 2017/4/20.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CrashGuard)
+(void)load ;
- (id)objectAtIndexWithCheck:(NSUInteger)index;
@end


@interface NSMutableArray (CrashGuard)
+(void)load ;
- (id)objectAtIndexWithCheck:(NSUInteger)index;
@end
