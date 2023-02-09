//
//  WebUrlHandleNode.h
//  WatchApp
//
//  Created by zengbiwang on 2017/11/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^WebUrlHandleNodeFinish)(id url);
@interface WebUrlHandleNode : NSObject
-(void)startJs:(NSString*)strJs url:(NSString*)url parseApi:(NSString*)paresApi htmlBody:(NSString*)htmlBody finishBlock:(WebUrlHandleNodeFinish)block;
-(void)clearJs;
@end
