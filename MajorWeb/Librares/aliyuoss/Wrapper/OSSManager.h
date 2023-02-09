//
//  OSSManager.h
//  AliyunOSSSDK-iOS-Example
//
//  Created by huaixu on 2018/10/23.
//  Copyright © 2018 aliyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/AliyunOSSiOS.h>


#define OSS_ENDPOINT @"http://oss-cn-shenzhen.aliyuncs.com"
#define OSS_BUCKET_PRIVATE @"maxurl"
#define OSS_CALLBACK_URL @"http://oss-demo.aliyuncs.com:23450"
#define OSS_STSTOKEN_URL                @"http://*.*.*.*:****/sts/getsts"           // sts授权服务器的地址
#define OSS_ACCESSKEY_ID @"HSbNreZ6manJzK9k"
#define OSS_SECRETKEY_ID @"jkS7dWJsT2cetKNDrHNtzla10fjJhB"
NS_ASSUME_NONNULL_BEGIN

@interface OSSManager : NSObject

@property (nonatomic, strong) OSSClient *defaultClient;

@property (nonatomic, strong) OSSClient *imageClient;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
