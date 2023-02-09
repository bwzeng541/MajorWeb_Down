//
//  MajorICloudSync.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/17.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MajorICloudSyncLastUpdatedTimeKey  @"MajorICloudSyncLastUpdatedTimeKey"
@interface MajorICloudSync : NSObject
+(MajorICloudSync*)getInstance;
@property(nonatomic,readonly)BOOL majorCloudIsAvailable;
@property(nonatomic,readonly)NSString *iclondSyncDes;//同步时间描述
@property(nonatomic,readonly)BOOL isSyncIng;
@property(nonatomic,readonly)BOOL isSyncToFinish;
-(BOOL)cloudIsAvailable;
-(BOOL)foceUpdateAsset:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure;
-(BOOL)syncNetToLoalInMainThread:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure;
@end
