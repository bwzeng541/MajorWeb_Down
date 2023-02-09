//
//  DebugModeCommond.h
//  WatchApp
//
//  Created by zengbiwang on 2018/1/9.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DebugModeCommond : NSObject
+(DebugModeCommond*)getInstance;
@property(nonatomic,readonly)NSArray*extb;
@property(nonatomic,readonly)NSArray*extn;
@end
