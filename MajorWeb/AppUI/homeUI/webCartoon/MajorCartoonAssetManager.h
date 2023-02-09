//
//  MajorCartoonAssetManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/1.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WebCartoonItem;
NS_ASSUME_NONNULL_BEGIN

@protocol MajorCartoonAssetManagerDelegate <NSObject>
-(void)beginCartoonAsset:(WebCartoonItem*)object;
@end
@interface MajorCartoonAssetManager : NSObject
+(MajorCartoonAssetManager*)getInstance;
@property(nonatomic,weak)id<MajorCartoonAssetManagerDelegate>delegate;
-(void)clearAllAsset;
-(BOOL)addAssetInfo:(WebCartoonItem*)item;
-(void)removeAssetInfo:(WebCartoonItem*)item;
@end

NS_ASSUME_NONNULL_END
