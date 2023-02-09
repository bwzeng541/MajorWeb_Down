//
//  M3u8FileAnalyze.h
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3u8FileAnalyze : NSObject
+(M3u8FileAnalyze*)getInstance;
-(NSDictionary*)getM3u8FileDownUrl:(NSString*)strPath m3u8ID:(NSString*)m3u8ID;
-(NSDictionary*)getM3u8FileDownUrlFromString:(NSString*)string m3u8ID:(NSString*)m3u8ID;

-(NSDictionary*)getM3u8FileDownUrlFromArray:(NSArray*)array originalText:(NSString*)originalText m3u8ID:(NSString*)m3u8ID;

@end
