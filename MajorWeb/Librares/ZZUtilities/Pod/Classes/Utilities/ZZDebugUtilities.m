//
//  ZZDebugUtilities.m
//  Five
//
//  Created by gluttony on 4/24/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "ZZDebugUtilities.h"

NSString *ZZReadableReachabilityNetworkStatus(NetworkStatus status)
{
    NSString *friendlyStatus = nil;
    switch (status) {
    case NotReachable:
        friendlyStatus = @"NotReachable";
        break;
    case ReachableViaWWAN:
        friendlyStatus = @"ReachableViaWWAN";
        break;
    case ReachableViaWiFi:
        friendlyStatus = @"ReachableViaWiFi";
        break;
    default:
        break;
    }
    return friendlyStatus;
}

NSString *ZZReadableBOOL(BOOL boolValue)
{
    return (boolValue ? @"YES" : @"NO");
}
