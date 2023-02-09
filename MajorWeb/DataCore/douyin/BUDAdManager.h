//
//  BUDAdManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/21.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUDAdManager : NSObject
@property(nonatomic,readonly)BOOL isAdRemove;
@property(nonatomic,readonly)int IsGotoUserModel;
+ (NSString *)appKey;
+(BUDAdManager*)getInstance;
-(void)initBudParam;
-(void)updateTime:(NSDate*)date;
-(void)setIsGotoUserModel:(int)saveState;
-(void)start;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
