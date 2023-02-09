//
//  ZyBrigdgenode.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/23.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZyBrigdgeNodeDelegate <NSObject>
-(void)updateListArray:(NSArray*)array;
-(void)updateDomContent:(NSString*)domConent url:(NSString*)url;
@end
@interface ZyBrigdgeNode : NSObject
@property(nonatomic,weak)id<ZyBrigdgeNodeDelegate>delegate;
//0列表1dom
-(void)stop;
-(void)stopLoading;
-(void)startUrl:(NSString*)url type:(NSInteger)type;
@end

NS_ASSUME_NONNULL_END
