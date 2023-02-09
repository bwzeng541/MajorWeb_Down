//
//  ZZMetricsUtilities.m
//  DailyNews
//
//  Created by gluttony on 10/5/13.
//  Copyright (c) 2013 app111. All rights reserved.
//

#import "ZZMetricsUtilities.h"
#import "NimbusCore.h"

BOOL ZZInterfaceIsPortrait(void)
{
    return (NIInterfaceOrientation() == UIInterfaceOrientationPortrait) || (NIInterfaceOrientation() == UIInterfaceOrientationPortraitUpsideDown);
}

BOOL ZZInterfaceIsLandscape(void)
{
    return (NIInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft) || (NIInterfaceOrientation() == UIInterfaceOrientationLandscapeRight);
}

CGFloat ZZNavigationBarHeight(void)
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return ZZInterfaceIsPortrait() ? 44.0f : 32.0f;
    }
    else {
        return 44.0f;
    }
}

CGSize ZZScreenSizeForPortrait(void)
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat width = fminf(size.width, size.height);
    CGFloat height = fmaxf(size.width, size.height);
    return CGSizeMake(width, height);
}

CGSize ZZScreenSizeForLandscape(void)
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat width = fmaxf(size.width, size.height);
    CGFloat height = fminf(size.width, size.height);
    return CGSizeMake(width, height);
}

CGSize ZZScreenSize(void)
{
    return (ZZInterfaceIsPortrait() ? ZZScreenSizeForPortrait()
                                    : ZZScreenSizeForLandscape());
}

CGSize ZZTopLayoutGuide(void)
{
    CGFloat height = NIStatusBarHeight() + ZZNavigationBarHeight();
    return CGSizeMake(ZZScreenSize().width, height);
}
