//
//  helpFuntion.h
//  zhenhuanzhuang
//
//  Created by zengbiwang on 13-5-10.
//  Copyright (c) 2013年 stone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface helpFuntion : NSObject
+(helpFuntion*)gethelpFuntion;
-(BOOL)isValideOneDayNotAutoAdd:(NSString*)strTag nCount:(int)time isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date;
-(NSInteger)isVaildOneDayNotAutoAddExcTimes:(NSString*)strTag nCount:(int)time  intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date;

-(NSInteger)isVaildOneDayNotAutoAddExcTimesfixBug:(NSString*)strTag nCount:(int)time  intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date;


-(BOOL)isValideOneDay:(NSString*)strTag nCount:(int)time isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date;

-(BOOL)isValideNotAutoAddCommonDay:(NSString*)strTag nCount:(int)time intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date;
-(BOOL)isValideCommonDay:(NSString*)strTag nCount:(int)time intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date;

 @end
