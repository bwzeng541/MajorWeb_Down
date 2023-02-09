//
//  MajorGoldManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/21.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MajorGoldManager:NSObject
+(MajorGoldManager*)getInstance;
@property(nonatomic,readonly)NSInteger goldNumber;
-(void)initWithDate:(NSDate*)dateTime;
-(void)unInitWithDate;
-(BOOL)spendGold:(NSInteger)gold uuid:(NSString*)uuid;
-(void)showPyq;
-(void)showQQ;
-(void)showVideo;
-(void)showFullVideo:(BOOL)isEveryXz;
-(void)showNole;

@end

NS_ASSUME_NONNULL_END
