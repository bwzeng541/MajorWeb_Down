//
//  AppAdManager.h
//  grayWolf
//
//  Created by zengbiwang on 2018/11/1.
//

#import <Foundation/Foundation.h>

@interface AppAdManager : NSObject
+(AppAdManager*)getInstance;
-(void)startConfigUrl:(NSString*)url isDebugMode:(BOOL)isDebugMode;
@end
