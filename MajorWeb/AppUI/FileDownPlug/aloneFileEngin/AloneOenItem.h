//
//  AloneOenItem.h
//  WatchApp
//
//  Created by zengbiwang on 2017/6/23.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AloneOenItemDelegate <NSObject>
-(void)app_state_change_3:(NSString*)_uuid_;
-(void)app_state_change_4:(NSString*)_uuid_ parma0:(float)parma0;
-(void)app_state_change_5:(NSString*)_uuid_ ;
-(void)app_state_change_1:(NSString*)_uuid_ ;
-(void)app_state_change_2:(NSString*)_uuid_ ;
-(void)app_state_change_6:(NSString *)_uuid_;
@end

@interface AloneOenItem : NSObject
@property(copy)NSString  *saveRootPath;
@property(copy)NSString  *tmpRootPath;
@property(copy)NSString  *uuid;
@property(copy)NSString  *fileUrl;
@property(readonly,nonatomic)NSDate  *createTime;
@property(assign)id<AloneOenItemDelegate>delegate;
-(void)start;
-(void)stop;
@end
