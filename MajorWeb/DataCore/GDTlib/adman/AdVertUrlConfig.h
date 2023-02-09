//
//  AdVertUrlConfig.h
//  AdSdk
//
//  Created by zengbiwang on 2018/4/8.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AdVertUrlConfigUrlBlock)(NSString*configUrl);
@interface AdVertUrlConfig : NSObject
+(AdVertUrlConfig*)getInstance;
-(void)start:(AdVertUrlConfigUrlBlock)block serviceUrl:(NSString*)serviceUrl urlArray:(NSArray*)urlArray;
@end
