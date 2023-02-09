//
//  Z_Node_1.h
//  WatchApp
//
//  Created by zengbiwang on 2018/5/3.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewBase.h"
#ifdef __cplusplus
#define Z_Node_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define Z_Node_EXTERN extern __attribute__((visibility ("default")))
#endif
Z_Node_EXTERN NSString* const ForceExitDownZ_Node_Flag;
typedef void (^Z_Node_1Block)(NSString *pamar0,NSString *pamar1,NSString *pamar2,NSString*title);
@interface Z_Node_1 : NSObject
-(instancetype)initWithParam0:(NSString*)pamar0  pamar1:(NSString*)pamar1 pamar2:(NSString*)pamar2;
@property(copy)Z_Node_1Block block;
-(void)z_node_1_clearAndKill;
-(void)start;
-(void)stop;
@end
