//
//  PhotoLinkPlug.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/21.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYCache.h"
#define PhotoLinkPlugDir [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"PhotoLinkPlugDir"]
NS_ASSUME_NONNULL_BEGIN

@interface PhotoLinkPlug : NSObject
@property(nonatomic,readonly)NSString *photoLinkUrl;
@property(nonatomic,readonly)YYCache *photoCache;
+(PhotoLinkPlug*)PhotoLinkPlug;

-(void)startPhotoServer;
-(void)stopPhotoServer;

//导出的时候把资源拷贝到这个目录
-(void)addAssetToLocal:(NSData*)data iconImage:(UIImage*)iconImage assetKey:(NSString*)assetKey extName:(NSString*)extName dirName:(NSString*)dirName;
-(void)removeAssetToLocal:(NSString*)assetKey fileName:(NSString*)fileName dirName:(NSString*)dirName;
-(NSString*)getAssetToLocal:(NSString*)fileName  dirName:(NSString*)dirName;

 -(NSString*)getAssetIcon:(NSString*)dirName;
-(void)removeAssetFromDirName:(NSString*)dirName;

-(NSString*)addVideThrow:(NSData*)data  fileName:(NSString*)fileName;
-(void)startLinkPhotoVideo;

-(void)startLinkDir:(NSString*)dirName;
-(void)stopLinkDir:(NSString*)dirName;
-(void)changePlaySpeed:(NSInteger)playSpeed;
@end

NS_ASSUME_NONNULL_END
