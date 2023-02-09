//
//  WebLiveParseManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebLiveParseManager : NSObject
+(WebLiveParseManager*)getInstance;
-(void)startParse:(UIView*)webParentView;
-(void)stopParse;
-(void)stopCurrentParse;
-(void)addParseWeb:(NSArray*)webArray key:(NSString*)key;
-(void)deleteWeb:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
