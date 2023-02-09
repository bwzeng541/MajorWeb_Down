//
//  RecordUrlToUUID.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordUrlToUUID : NSObject
+(RecordUrlToUUID*)getInstance;
-(NSString*)urlFromKey:(NSString*)uuid;
-(NSString*)titleFromKey:(NSString*)uuid;

-(void)addUrl:(NSString*)url uuid:(NSString*)uuid title:(NSString*)title;
-(void)updateVideoTime:(NSString*)uuid playTime:(NSDictionary*)playInfo;
-(NSDictionary*)playTimeFromKey:(NSString*)uuid;
-(void)removeKey:(NSString*)uuid;
@end

NS_ASSUME_NONNULL_END
