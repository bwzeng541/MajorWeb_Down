//
//  BeatifyAliOssManager.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeatifyAliOssManager : NSObject
+(BeatifyAliOssManager*)getInstance;
-(void)initAssetOssClient;
-(NSString*)updateAsset2:(NSString*)asset;
-(void)uploadAsset:(NSString *)asset;
@end

NS_ASSUME_NONNULL_END
