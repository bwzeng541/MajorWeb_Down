//
//  WebLiveNodeInfo.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebLiveNodeInfo : NSObject
@property(nonatomic,readonly)BOOL isDataChange;
@property(nonatomic,readonly)NSMutableArray *dataNodeArray;
-(id)initWithWebsArray:(NSArray*)websArray title:(NSString*)title;
-(void)startParse;
-(void)stopParse;
@end

NS_ASSUME_NONNULL_END
