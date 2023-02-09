//
//  JsServiceManager.h
//  WatchApp
//
//  Created by zengbiwang on 2017/11/27.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsServiceManager : NSObject
@property(assign,nonatomic)BOOL isWebJsSuccess;
+(JsServiceManager*)getInstance;
-(NSString*)getJsContent:(NSString*)key;
@end
