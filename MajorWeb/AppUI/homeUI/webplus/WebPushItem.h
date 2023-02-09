//
//  WebPushItem.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WebPushItemDelegate <NSObject>
-(void)updateWebPushSuccess:(id)object;
@end
@interface WebPushItem : NSObject
@property(nonatomic,readonly)NSString *title;
@property(nonatomic,readonly)NSString *iconUrl;
@property(nonatomic,readonly)NSString *referer;
@property(nonatomic,readonly)NSString *playUrl;
@property(nonatomic,readonly)NSString *uuid;
@property(nonatomic,assign)BOOL isVertical;
@property(nonatomic,weak)id<WebPushItemDelegate>delegate;
-(id)initWithUrl:(NSString*)url iconUrl:(NSString*)iconUrl referer:(NSString*)referer title:(NSString*)title;
-(void)delayStart:(float)time;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
