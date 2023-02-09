//
//  WebPushManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebCartoonItem.h"
NS_ASSUME_NONNULL_BEGIN
@interface WebCartoonManager : NSObject
+(WebCartoonManager*)getInstance;
@property(readonly,assign)BOOL isReqeustSuccess;
-(void)startWithUrl:(NSString*)key url:(NSString*)url parseInfo:(NSDictionary*)parseInfo updateBlock:(void(^)(WebCartoonItem*item,NSArray *array,BOOL isRemoveOldAll))updateBlock beginUrlRequestBlock:(void(^)(void))beginUrlBlock falidBlock:(void(^)(void))falidBlock;
-(void)startWithUrlUsrOldBlock:(NSString*)key url:(NSString*)url parseInfo:(NSDictionary*)parseInfo;
-(void)showDateBlock:(void(^)(NSArray*))showBlock updateBlock:(void(^)(WebCartoonItem*item,NSArray *array,BOOL isRemoveOldAll))updateBlock falidBlock:(void(^)(void))falidBlock;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
