//
//  ZZDeviceUtilities.h
//  Five
//
//  Created by gluttony on 5/5/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZZDeviceScreenType) {
    kZZDeviceScreenUnknown,
    kZZDeviceScreeniPhone4,
    kZZDeviceScreeniPhone5,
    kZZDeviceScreeniPhone6,
    kZZDeviceScreeniPhone6p,
    kZZDeviceScreeniPad,
    kZZDeviceScreeniPadPro
};

#if defined __cplusplus
extern "C" {
#endif

BOOL ZZOSVersionIsAtLeastiOS8();

BOOL ZZOSVersionIsBelowiOS8();

BOOL ZZOSVersionIsAtLeastiOS7();

BOOL ZZOSVersionIsBelowiOS7();

BOOL ZZOSVersionIsAtLeastiOS6();

BOOL ZZOSVersionIsBelowiOS6();

BOOL ZZScreenIsRetina();

BOOL ZZIsiPhone4Screen();

BOOL ZZIsiPhone5Screen();

BOOL ZZIsiPhone6Screen();

BOOL ZZIsiPhone6pScreen();

BOOL ZZIsiPadScreen();

BOOL ZZIsiPadProScreen();

ZZDeviceScreenType ZZDetectDeviceScreenType();

void ZZDisableInteraction();

void ZZEnableInteraction();

NSString *ZZAfdi();

NSString *ZZAfdiWithoutDash();

#if defined __cplusplus
};
#endif