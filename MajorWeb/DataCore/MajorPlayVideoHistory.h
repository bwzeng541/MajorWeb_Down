//
//  MajorPlayVideoHistory.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/21.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

//记录播放信息
@interface MajorPlayVideoHistory : NSObject
+(MajorPlayVideoHistory*)getInstance;
-(void)initData;
-(BOOL)isVideoWatch:(NSString*)url;
-(void)addVideoInfo:(NSString*)url;
@end
