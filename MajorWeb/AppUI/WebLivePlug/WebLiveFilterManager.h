//
//  WebLiveFilterManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/18.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebLiveFilterManager : NSObject
+(WebLiveFilterManager*)getFilterManager;
-(void)startRun:(NSArray*)array;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
