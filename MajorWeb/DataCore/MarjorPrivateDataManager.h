//
//  MarjorPrivateDataManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/8.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MarjorPrivateDataManagerDelegate <NSObject>
-(void)start_down_private_config;
-(void)finish_down_private_config:(BOOL)isSuccess;

-(void)start_upload_private_config;
-(void)finish_upload_private_config:(NSString*)key error:(NSError*)error;

-(void)start_update_pic_config;
-(void)finish_update_pic_config:(UIImage*)image;


-(void)update_local_private:(BOOL)isSuccess;
@end
@interface MarjorPrivateDataManager : NSObject
+(MarjorPrivateDataManager*)getInstance;
@property(weak,nonatomic)id<MarjorPrivateDataManagerDelegate>delegate;
-(void)reqeustNewImageData;
-(NSArray*)getCurrentConfigArray;
-(NSString*)getCurrentConfigName;
-(NSArray*)getPrivateConfigList;
-(void)initAllSortArray;
-(void)clearAllSortData;
-(void)upLoadMarjorPrivateData;
-(void)addNewSortItem:(NSString*)key object:(id)object;
-(BOOL)delSortItemIfCurrent:(NSString*)key;
-(void)downMarjorPrivateData:(NSString*)key;
-(void)updateLocalFormKey:(NSString*)key ;
-(void)updateCurrentConfig:(NSArray*)array showName:(NSString*)showName;
@end

NS_ASSUME_NONNULL_END
