//
//  WebPushManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebPushItem.h"
NS_ASSUME_NONNULL_BEGIN
//typedef BOOL (^WebPushManagerItemUpdate)(NSArray<WebPushItem*>*array);
@interface WebPushManager : NSObject
+(WebPushManager*)getInstance;
@property(readonly,assign)BOOL isReqeustSuccess;
@property(readonly,strong)NSMutableArray* parseData;
-(void)startWithUrl:(NSString*)url updateBlock:(void(^)(WebPushItem*item,BOOL isRemoveOldAll))updateBlock falidBlock:(void(^)(void))falidBlock;
-(void)startWithUrlUsrOldBlock:(NSString*)url;
-(void)showDateBlock:(void(^)(NSArray*))showBlock updateBlock:(void(^)(WebPushItem*item,BOOL isRemoveOldAll))updateBlock startHomeBlock:(void(^)(void))startHomeBlock falidBlock:(void(^)(void))falidBlock;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
