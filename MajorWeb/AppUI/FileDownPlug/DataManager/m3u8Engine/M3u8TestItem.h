//
//  M3u8TestItem.h
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@protocol M3u8TestItemDelgate<NSObject>
@optional

-(void)app_state_change_3:(NSString*)videoID;
-(void)itemStart:(int)index;
-(void)itemFinished:(int)index;

-(void)app_state_change_4:(NSString*)m3u8ID parma0:(float)parma0;
//所有文件下载完成
-(void)app_state_change_5:(NSString*)m3u8ID ;
-(void)app_state_change_1:(NSString*)m3u8ID;
-(void)app_state_change_7:(NSString*)m3u8ID;
-(void)app_state_change_6:(NSString *)m3u8ID;//下载失败
@end


@interface M3u8TestItem : NSObject<ASIHTTPRequestDelegate>

@property(assign)id<M3u8TestItemDelgate>delegate;
@property(retain)NSArray *allArrayDown;
@property(copy)NSString  *saveRootPath;
@property(copy)NSString  *m3u8ID;
@property(copy)NSString  *tempRootPath;
@property(copy)NSString  *m3u8Url;
@property(readonly,nonatomic)NSDate *createTime;
-(void)start;
-(void)stop;
@end
