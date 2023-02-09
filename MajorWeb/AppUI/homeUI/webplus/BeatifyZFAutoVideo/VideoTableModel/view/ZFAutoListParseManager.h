//
//  ZFAutoListParseManager.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/8/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ZfAutoListCacheItem : NSObject<NSCoding>
@property(copy,nonatomic)NSString *uuid;
@property(copy,nonatomic)NSString *url;
@property(copy,nonatomic)NSString *assetUrl;
@end

@interface ZFAutoListParseManager : NSObject
+(ZFAutoListParseManager*)getInstance;
@property(nonatomic,readonly)BOOL isReadyInit;
@property(nonatomic,assign)BOOL  isCanUpdate;
@property(readonly,nonatomic)BOOL listArrayChange;
@property(readonly,nonatomic)NSMutableArray *listArray;
-(void)initAssetArray:(NSArray*)array;
-(void)updateTypePos:(NSInteger)pos delayTime:(float)time;
-(NSArray*)getDefaultData;
-(void)startParse;
-(void)updatelistArray;
-(void)addFavite:(NSString*)uuid assetObject:(id)aasetObject;
-(void)updateFavite:(NSString*)uuid assetObject:(id)aasetObject;
-(NSArray*)getFavite;
-(void)removeFavite:(NSString*)uuid;
-(NSString*)getLastAsset;
-(void)saveLastAsset:(NSString*)uuid;
-(NSArray*)getDefaultArray;
-(void)stopParse;
@end

NS_ASSUME_NONNULL_END
