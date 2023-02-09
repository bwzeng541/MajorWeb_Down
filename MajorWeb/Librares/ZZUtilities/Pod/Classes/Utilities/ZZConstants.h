//
//  ZZConstants.h
//  FileVault
//
//  Created by gluttony on 11/17/14.
//  Copyright (c) 2014 gluttony. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Macros

#ifndef ZZ_Constants_h
#define ZZ_Constants_h

#define FILE_MANAGER [NSFileManager defaultManager]
#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define GA_TRACKER [[GAI sharedInstance] defaultTracker]
#define UMENG_PARAMETER(cKey) \
    [NSString stringWithFormat:@"%@_%@", cKey, APP_VERSION]

#define GA_SCREEN(screen_)                                                    \
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:screen_]; \
    [[[GAI sharedInstance] defaultTracker]                                    \
        send:[[GAIDictionaryBuilder createScreenView] build]]

#define GA_EVENT(category_, action_, label_, value_)                  \
    [[[GAI sharedInstance] defaultTracker]                            \
        send:[[GAIDictionaryBuilder createEventWithCategory:category_ \
                                                     action:action_   \
                                                      label:label_    \
                                                      value:value_] build]]

#define APP_VERSION                         \
    [[[NSBundle mainBundle] infoDictionary] \
        objectForKey:@"CFBundleShortVersionString"]

#define BUILD_VERSION \
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define DISPLAY_NAME \
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

// 1 - (Default) The app runs on iPhone and iPod touch devices.
// 2 - The app runs on iPad devices.
#define SUPPORTED_DEVICE \
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIDeviceFamily"]

#define dispatch_main_sync_safe(block)                   \
    if ([NSThread isMainThread]) {                       \
        block();                                         \
    }                                                    \
    else {                                               \
        dispatch_sync(dispatch_get_main_queue(), block); \
    }

#define dispatch_main_async(block) \
    dispatch_async(dispatch_get_main_queue(), block)

#define dispatch_default_async(block) \
    dispatch_async(                   \
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)

#define dispatch_after_delay(delayInSeconds, block)               \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,               \
                       (int64_t)(delayInSeconds * NSEC_PER_SEC)), \
        dispatch_get_main_queue(), block)

#define ENSURE_NO_ERROR_OR_RETURN           \
    do {                                    \
        if (error) {                        \
            NIDERROR(@"error = %@", error); \
            return;                         \
        }                                   \
    } while (0)

#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self

#define ZZ_RELEASE_VIEW(view)       \
    do {                            \
        [view removeFromSuperview]; \
        view = nil;                 \
    } while (NO)

#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
