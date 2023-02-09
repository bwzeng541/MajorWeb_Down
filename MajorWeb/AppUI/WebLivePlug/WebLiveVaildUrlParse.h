//
//  WebLiveVaildUrlParse.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebLiveVaildUrlParse : NSObject
+(WebLiveVaildUrlParse*)getInstance;
-(void)initVaildPlug;
-(void)stopVaildParse;

-(void)startWebChannel:(NSString*)webUrl title:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
