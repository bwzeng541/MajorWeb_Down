//
//  ZZDebugUtilities.h
//  Five
//
//  Created by gluttony on 4/24/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#if defined __cplusplus
extern "C" {
#endif

NSString *ZZReadableReachabilityNetworkStatus(NetworkStatus status);
NSString *ZZReadableBOOL(BOOL boolValue);

#if defined __cplusplus
};
#endif
