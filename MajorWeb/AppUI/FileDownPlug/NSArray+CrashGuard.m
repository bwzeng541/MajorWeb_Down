//
//  NSArray_CrashGuard.cpp
//  WatchApp
//
//  Created by zengbiwang on 2017/4/20.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import  "NSArray+CrashGuard.h"
#import <objc/runtime.h>

@implementation NSArray (CrashGuard)
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method fromMethod = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
        Method toMethod = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(crashGuard_objectAtIndex:));
        method_exchangeImplementations(fromMethod, toMethod);
        
        Method fromMethod1 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
        Method toMethod1 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(crashGuard_objectAtIndex:));
        method_exchangeImplementations(fromMethod1, toMethod1);

    });
}

#pragma mark Swizzled Method

-(id)crashGuard_objectAtIndex:(NSUInteger)index {
    if(self.count-1 < index) {
        // 打印崩溃信息，栈信息 等
        NSLog(@"selector \"objectAtIndex\" crash for the index beyond  the boundary!");
        return nil;
    } else {
        return [self crashGuard_objectAtIndex:index];
    }
}

- (id)objectAtIndexWithCheck:(NSUInteger)index
{
    if (index < self.count) {
        id obj = [self objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}
@end


@implementation NSMutableArray (CrashGuard)
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method fromMethod = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
        Method toMethod = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(crashGuard_objectAtIndex:));
        method_exchangeImplementations(fromMethod, toMethod);
    });
}

#pragma mark Swizzled Method

-(id)crashGuard_objectAtIndex:(NSUInteger)index {
    if(self.count-1 < index) {
        // 打印崩溃信息，栈信息 等
        NSLog(@"selector \"objectAtIndex\" crash for the index beyond  the boundary!");
        return nil;
    } else {
        return [self crashGuard_objectAtIndex:index];
    }
}

- (id)objectAtIndexWithCheck:(NSUInteger)index
{
    if (index < self.count) {
        id obj = [self objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

@end
