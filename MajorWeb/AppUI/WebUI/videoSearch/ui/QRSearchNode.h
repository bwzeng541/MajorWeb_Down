//
//  QRSearchNode.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QRSearch_Type_Key @"searchParam1Key"
#define QRSearch_Url_Key @"searchParam2Key"
#define QRSearch_Word_Key @"searchParam3Key"

NS_ASSUME_NONNULL_BEGIN
@class UIView;
@protocol QRSearchNodeDelegate <NSObject>
-(void)qrSearchRevice:(NSArray*)array object:(id)object;
@end
@interface QRSearchNode : NSObject
@property(weak)id<QRSearchNodeDelegate>delegate;
-(id)initWithParam:(NSDictionary*)info parentView:(UIView*)parentView;
-(void)start;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
