//
//  AppWtManager.h
//  WatchApp
//
//  Created by zengbiwang on 2018/6/11.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppWtManager : NSObject
+(AppWtManager*)getInstanceAndInit;
-(id)getWtCallBack:(NSDictionary*)info;
@end
