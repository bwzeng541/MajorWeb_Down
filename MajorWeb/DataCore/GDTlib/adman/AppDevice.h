//
//  AppDevice.h
//  WatchApp
//
//  Created by zengbiwang on 2018/1/19.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* deviceDefaultDisk;
extern long long devicefreeDiskSpaceInBytes;

@interface AppDevice : NSObject
+(AppDevice*)getInstance;
-(void)initReSetDeviceInfo;
-(void)setGDTStatsMgr:(id)g;
@property(nonatomic,assign)BOOL isWiFi;
@property(nonatomic,strong,readonly)NSString *deviceMd6;
@property(nonatomic,strong,readonly)NSString *deviceUID;
@property(nonatomic,strong,readonly)NSString *deviceName;
@property(nonatomic,strong,readonly)NSString *deviceDisk;
@property(nonatomic,readonly)long long freeDiskSpaceInBytes;
@end
