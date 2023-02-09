//
//  ZZApplication.h
//  FileVault
//
//  Created by gluttony on 11/12/14.
//  Copyright (c) 2014 gluttony. All rights reserved.
//

#import "Reachability.h"

@class ZZApplication;

typedef void (^ZZApplicationRequestCompletedBlock)(NSString *urlString, NSString *responseString, NSError *error);

typedef NS_ENUM(NSInteger, ZZApplicationAPEC) {
    ZZApplicationAPECUnknown = 0,
    ZZApplicationAPECYES,
    ZZApplicationAPECNO
};

@protocol ZZApplicationDelegate <NSObject>

- (void)setZZApplication:(ZZApplication *)application;

@end

@interface ZZApplication : NSObject

@property (strong, readonly, nonatomic) id<ZZApplicationDelegate> application;
@property (strong, readonly, nonatomic) NSMutableDictionary *requestTasks;
@property (strong, readonly, nonatomic) NSMutableDictionary *data;
@property (assign, nonatomic) BOOL isNetworkReachable;
@property (assign, nonatomic) NetworkStatus networkStatus;

@property (assign, nonatomic) ZZApplicationAPEC apec;
@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *umengKey;


// 广点通 所属应用id
@property (strong, nonatomic) NSString *guangDianTongAppKey;
// 广点通 广告位ID
@property (strong, nonatomic) NSString *guangDianTongPlacementID;

// 广点通 原生广告key
@property (strong, nonatomic) NSString *guangDianTongNativeAppKey;
// 广点通 原生广告位ID
@property (strong, nonatomic) NSString *guangDianTongNativePlacementID;

// AdMob 广告ID
@property (strong, nonatomic) NSString *adUnitID;

// City ID
@property (strong, nonatomic) NSString *cityID;

+ (ZZApplication *)sharedInstance;
- (void)registerClass:(Class)applicationClass;

@end
