//
//  M3u8ArStateManager.h
//  babeKingdom
//
//  Created by zengbiwang on 13-9-22.
//
//

#import <Foundation/Foundation.h>
#import "FileDonwPlus.h"
//管理每个m3u8的进度等相关信息
@interface M3u8ArStateManager : NSObject
+(M3u8ArStateManager*)getInstance;
-(void)addM3u8Item:(NSString*)m3u8ID;
-(void)delM3u8Item:(NSString*)m3u8ID;
-(NSInteger)getCurrentDownNumber;
-(NSArray*)getAllDownM3u8UUID;
 -(m3u8DownSate)getM3u8State:(NSString*)m3u8ID;
-(NSNumber*)getM3u8Progress:(NSString *)m3u8ID;
@end
