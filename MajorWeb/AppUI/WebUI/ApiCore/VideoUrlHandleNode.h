//
//  WebUrlHandleNode.h
//  WatchApp
//
//  Created by zengbiwang on 2017/11/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^VideoUrlHandleNodeFinish)(id url);
@interface VideoUrlHandleNode : NSObject
-(void)startJs:(NSString*)strJs videoUrl:(NSString*)videoUrl finishBlock:(VideoUrlHandleNodeFinish)block;
-(void)clearJs;
@end
