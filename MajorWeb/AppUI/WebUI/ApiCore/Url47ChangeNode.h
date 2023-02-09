//
//  Url47ChangeNode.h
//  WatchApp
//
//  Created by zengbiwang on 2017/4/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^Url47ChangeNodeFaild)();
typedef void (^Url47ChangeNodeSuccess)(id url);

@interface Url47ChangeNode : NSObject
-(void)start:(NSString*)url faildBlock:(Url47ChangeNodeFaild)fail Success:(Url47ChangeNodeSuccess)success;
@end
