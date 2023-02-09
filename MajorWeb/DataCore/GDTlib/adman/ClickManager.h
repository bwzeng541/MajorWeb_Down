//
//  ClickManager.h
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2018/5/9.
//

#import <Foundation/Foundation.h>

@interface ClickManager : NSObject
+(ClickManager*)getInstance;
-(void)updateClickKey:(NSString*)key;
-(void)deleleClickKey:(NSString*)key;
-(BOOL)isClickReady:(NSString*)key;
-(void)clearAllClickInfo;
//更具banner判断是否点击完成
-(int)isAllInfoClick:(NSArray*)array;

@end
