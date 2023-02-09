//
//  QRSearchManager.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UIView;
@interface QRSearchManager : NSObject
+(QRSearchManager*)shareInstance;
-(void)startSearch:(NSString*)context parentView:(UIView*)parentView retArray:(void (^)(NSArray *array,BOOL isAdd,BOOL isFinisd))reArrayBlock;
-(void)stopSearch;
@end

NS_ASSUME_NONNULL_END
