//
//  ZZMetricsUtilities.h
//  DailyNews
//
//  Created by gluttony on 10/5/13.
//  Copyright (c) 2013 app111. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif

BOOL ZZInterfaceIsPortrait(void);
BOOL ZZInterfaceIsLandscape(void);

CGFloat ZZNavigationBarHeight(void);

CGSize ZZScreenSizeForPortrait(void);
CGSize ZZScreenSizeForLandscape(void);
CGSize ZZScreenSize(void);
CGSize ZZTopLayoutGuide(void);

#if defined __cplusplus
};
#endif
