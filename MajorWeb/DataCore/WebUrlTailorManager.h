//
//  WebUrlTailor.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/31.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebUrlTailorManager : NSObject
+(BOOL)isWebUrlTailor:(NSString*)title url:(NSString*)url;
+(BOOL)insertWebUrlTailor:(NSString*)title url:(NSString*)url;
+(NSArray*)getWebUrlTailor;
+(void)delWebUrlTailor:(NSString*)title url:(NSString*)url;
@end
