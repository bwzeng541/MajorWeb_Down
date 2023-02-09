//
//  MajorZyParseNode.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/10.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MajorZyParseNodeDelegate <NSObject>
-(void)praseResultSuccess:(NSDictionary*)info;
-(void)praseResultFalid:(NSDictionary*)info;
@end
@interface MajorZyParseNode : NSObject
@property(weak,nonatomic)id<MajorZyParseNodeDelegate>delegate;
-(void)start:(NSString*)url;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
