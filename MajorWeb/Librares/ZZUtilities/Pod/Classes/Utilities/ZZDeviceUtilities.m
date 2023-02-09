//
//  ZZDeviceUtilities.m
//  Five
//
//  Created by gluttony on 5/5/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "ZZDeviceUtilities.h"
#import "Base64.h"
#import "ZZMetricsUtilities.h"

BOOL ZZOSVersionIsAtLeastiOS8()
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1);
}

BOOL ZZOSVersionIsBelowiOS8()
{
    return (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1);
}

BOOL ZZOSVersionIsAtLeastiOS7()
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1);
}

BOOL ZZOSVersionIsBelowiOS7()
{
    return (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1);
}

BOOL ZZOSVersionIsAtLeastiOS6()
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_5_1);
}

BOOL ZZOSVersionIsBelowiOS6()
{
    return (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1);
}

BOOL ZZScreenIsRetina()
{
    return ([[UIScreen mainScreen]
                respondsToSelector:@selector(displayLinkWithTarget:selector:)]
        && ([UIScreen mainScreen].scale >= 2.0f));
}

BOOL ZZIsiPhone4Screen()
{
    return ZZScreenSizeForPortrait().height == 480.0f;
}

BOOL ZZIsiPhone5Screen()
{
    return ZZScreenSizeForPortrait().height == 568.0f;
}

BOOL ZZIsiPhone6Screen()
{
    return ZZScreenSizeForPortrait().height == 667.0f;
}

BOOL ZZIsiPhone6pScreen()
{
    return ZZScreenSizeForPortrait().height == 736.0f;
}

BOOL ZZIsiPadScreen()
{
    return ZZScreenSizeForPortrait().height == 1024.0f;
}

BOOL ZZIsiPadProScreen()
{
    return ZZScreenSizeForPortrait().height == 2732.0f;
}

ZZDeviceScreenType ZZDetectDeviceScreenType()
{
    CGFloat height = ZZScreenSizeForPortrait().height;
    ZZDeviceScreenType deviceScreenType;
    if (height == 480.0f) {
        deviceScreenType = kZZDeviceScreeniPhone4;
    } else if (height == 568.0f) {
        deviceScreenType = kZZDeviceScreeniPhone5;
    } else if (height == 667.0f) {
        deviceScreenType = kZZDeviceScreeniPhone6;
    } else if (height == 736.0f) {
        deviceScreenType = kZZDeviceScreeniPhone6p;
    } else if (height == 1024.0f) {
        deviceScreenType = kZZDeviceScreeniPad;
    } else if (height == 2732.0f) {
        deviceScreenType = kZZDeviceScreeniPadPro;
    } else {
        deviceScreenType = kZZDeviceScreenUnknown;
    }
    return deviceScreenType;
}

void ZZDisableInteraction()
{
    if (![UIApplication sharedApplication].isIgnoringInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
}

void ZZEnableInteraction()
{
    if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

NSString *ZZAfdi()
{
    static NSString *afdi = nil;
    if (afdi == nil) {
        NSString *cn = [@"QVNJZGVudGlmaWVyTWFuYWdlcg==" base64DecodedString];
        Class afdiClass = NSClassFromString(cn);
        if (afdiClass == nil) {
            afdi = @"";
        }
        else {
            id afdiInstance = [[afdiClass alloc] init];
            if (afdiInstance == nil) {
                afdi = @"";
            }
            else {
                //advertisingIdentifier
                NSString *identifier = [@"YWR2ZXJ0aXNpbmdJZGVudGlmaWVy" base64DecodedString];
                NSUUID *uuid = [afdiInstance valueForKey:identifier];
                afdi = [uuid UUIDString];
            }
        }
    }
    return afdi;
}

NSString *ZZAfdiWithoutDash()
{
    static NSString *afdiWithoutDash = nil;
    if (afdiWithoutDash == nil) {
        NSString *afdi = ZZAfdi();
        if (afdi == nil) {
            afdiWithoutDash = @"";
        }
        else {
            afdiWithoutDash = [afdi stringByReplacingOccurrencesOfString:@"-"
                                                              withString:@""];
        }
    }
    return afdiWithoutDash;
}
