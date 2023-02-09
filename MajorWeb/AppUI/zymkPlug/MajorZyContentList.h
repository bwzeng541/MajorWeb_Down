//
//  MajorZyContentList.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/10.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorPopGestureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MajorZyContentList : MajorPopGestureView
-(instancetype)initWithFrame:(CGRect)frame typeDes:(NSString*)typeDes selectBlock:(void(^)(NSArray*array ,NSString*showName,NSString*historUrl))selectBlock closeBlcok:(void(^)(void))closeBlock;

-(instancetype)initWithFrame:(CGRect)frame  array:(NSArray*)array selectBlock:(void(^)(NSString*sortUrl))selectBlock closeBlcok:(void(^)(void))closeBlock;
@end

NS_ASSUME_NONNULL_END
