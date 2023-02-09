//
//  helpFuntion.m
//  zhenhuanzhuang
//
//  Created by zengbiwang on 13-5-10.
//  Copyright (c) 2013年 stone. All rights reserved.
//

#import "helpFuntion.h"
#import "FTWCache.h"
#import "MKNetworkEngine.h"
#import "YYCache.h"

#define HelpFuntionCaches [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/helpCaches",AppSynchronizationDir ]]
#define LOCALTIMEINFO @"132ssfkashfkjafgasdjkfsd"
@implementation helpFuntion
+(helpFuntion*)gethelpFuntion{
    static helpFuntion *g = nil;
    if (g==nil) {
        g = [[helpFuntion alloc]init];
    }
    
    return g;
}

-(id)init{
    self = [super init];
    
    
    return self;
}

-(NSDate*)getDataFromString:(NSString *)str{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *strTime = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00",
                         [str substringWithRange:NSMakeRange(0, 4)],
                         [str substringWithRange:NSMakeRange(4, 2)],
                         [str substringWithRange:NSMakeRange(6, 2)]
                         /*,
                         [str substringWithRange:NSMakeRange(8, 2)],
                         [str substringWithRange:NSMakeRange(10, 2)],
                         [str substringWithRange:NSMakeRange(12, 2)]*/
                         ];
    
    NSDate *date =[dateFormat dateFromString:strTime];
    return date;
}

-(BOOL)isAddGold:(NSString *)newTime{
    BOOL ret = TRUE;
    
    id t = [FTWCache objectForKey:LOCALTIMEINFO useKey:true];
    if (t==nil) {
        [FTWCache setObject:[newTime dataUsingEncoding:NSUTF8StringEncoding] forKey:LOCALTIMEINFO useKey:true];
        return TRUE;
    }
    NSString *oldTime = [[[NSString alloc]initWithData:[FTWCache objectForKey:LOCALTIMEINFO useKey:true] encoding:NSUTF8StringEncoding] autorelease];
    if ([oldTime length]==14 && [newTime length]==14) {
        NSDate *oldDate = [self getDataFromString:oldTime];
        NSDate *newDate = [self getDataFromString:newTime];
        NSTimeInterval t = [newDate timeIntervalSinceDate:oldDate];
        if (t >60*60*23) {
            [FTWCache setObject:[newTime dataUsingEncoding:NSUTF8StringEncoding] forKey:LOCALTIMEINFO useKey:true];
            ret = TRUE;
        }
        else
        {
            ret = FALSE;
        }
    }
    else {
        ret = FALSE;
    }
    return ret ;
}

-(NSDate*)getDataFromStringLocal:(NSString *)str{
    NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *strTime = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00",
                         [str substringWithRange:NSMakeRange(0, 4)],
                         [str substringWithRange:NSMakeRange(5, 2)],
                         [str substringWithRange:NSMakeRange(8, 2)]
                         ];
    
    NSDate *date =[dateFormat dateFromString:strTime];
    return date;
}

-(BOOL)isOneDayFromOldTime:(NSString*)strTag oldTime:(NSString*)oldTime AutoSet:(BOOL)isSet isUseYYCache:(BOOL)isUseYYCache{
    BOOL ret = FALSE;
    //关闭当天广告请求
    NSString *currentDateStr = oldTime;
    NSString *strTime = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (isUseYYCache) {
        strTime = (NSString*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        strTime = [userDefaults objectForKey:strTag];
    }
    if (!strTime) {//第一次点击
        ret = FALSE;
        if (isSet) {
            if(isUseYYCache){
                [HelpFuntionCaches setObject:currentDateStr forKey:strTag];
            }
            else{
                [userDefaults setObject:currentDateStr forKey:strTag];
            }
        }
    }
    else {
        NSDate *oldDate = [self getDataFromStringLocal:strTime];
        NSDate *newTime = [self getDataFromStringLocal:currentDateStr];
        
        NSTimeInterval t = [newTime timeIntervalSinceDate:oldDate];
        if (t != 0) {
            if (isSet) {
                if(isUseYYCache){
                    [HelpFuntionCaches setObject:currentDateStr forKey:strTag];
                }
                else{
                    [userDefaults setObject:currentDateStr forKey:strTag];
                }
            }
        }
        else{
            
            ret = TRUE;
        }
    }
    
    [userDefaults synchronize];
    return ret;

}

-(BOOL)isOneDay:(NSString*)strTag isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date{
    //BOOL ret = FALSE;
    //关闭当天广告请求
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    if (!date) {
        date = [NSDate date];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return [self isOneDayFromOldTime:strTag oldTime:currentDateStr AutoSet:true isUseYYCache:isUseYYCache];
}

-(NSInteger)isVaildOneDayNotAutoAddExcTimesfixBug:(NSString*)strTag nCount:(int)time  intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   NSNumber  *number = nil;
     if (isUseYYCache) {
         number = (NSNumber*)[HelpFuntionCaches objectForKey:strTag];
     }
     else{
         number = [userDefaults objectForKey:strTag];
     }
    return [number integerValue];
}

-(NSInteger)isVaildOneDayNotAutoAddExcTimes:(NSString*)strTag nCount:(int)time  intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [self isValideNotAutoAddCommonDay:strTag nCount:time intervalDay:intervalDay isUseYYCache:isUseYYCache time:date];
    printf("isValideOneDayNotAutoAdd1 flag = %d time = %d isUseYYCache = %d\n",flag,time,isUseYYCache);
    if (!flag) {
        if (isUseYYCache) {
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
    }
    else{
        
    }
    NSNumber  *number = nil;
    if (isUseYYCache) {
        number = (NSNumber*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        number = [userDefaults objectForKey:strTag];
    }
    [userDefaults synchronize];
    return [number integerValue];
}

-(BOOL)isValideOneDayNotAutoAdd:(NSString*)strTag nCount:(int)time isUseYYCache:(BOOL)isUseYYCache time:(NSDate *)date
{
    BOOL ret = TRUE;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [self isOneDay:[NSString stringWithFormat:@"%@_ext",strTag] isUseYYCache:isUseYYCache time:date];
    printf("isValideOneDayNotAutoAdd1 flag = %d time = %d isUseYYCache = %d\n",flag,time,isUseYYCache);
    if (!flag) {
        if (isUseYYCache) {
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
    }
    else{
        
    }
    NSNumber  *number = nil;
    if (isUseYYCache) {
        number = (NSNumber*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        number = [userDefaults objectForKey:strTag];
    }
    if ([number intValue]<=0) {
        ret = FALSE;
    }
    else {
    }
    [userDefaults synchronize];
    printf("isValideOneDayNotAutoAdd2 flag = %d time = %d isUseYYCache = %d = number = %d\n",flag,time,isUseYYCache,[number intValue]);
    return ret;
}


-(BOOL)isValideOneDay:(NSString*)strTag nCount:(int)time isUseYYCache:(BOOL)isUseYYCache time:(NSDate *)date{
    BOOL ret = TRUE;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [self isOneDay:[NSString stringWithFormat:@"%@_ext",strTag] isUseYYCache:isUseYYCache time:date];
    if (!flag) {
        if (isUseYYCache) {
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
    }
    else{
        
    }
    
    NSNumber  *number = nil;
    
    if (isUseYYCache) {
        number =  (NSNumber*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        number = [userDefaults objectForKey:strTag];
    }
    int leave = [number integerValue]-1;
    if (leave<0) {
        ret = FALSE;
    }
    else {
        if (isUseYYCache) {
            NSLog(@"levae = %d strTag = %@",leave,strTag);
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:leave] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:leave] forKey:strTag];
        }
    }
    [userDefaults synchronize];
    
    return ret;
}


-(BOOL)isIntervalDayFromOldTime:(NSString*)strTag oldTime:(NSString*)oldTime AutoSet:(BOOL)isSet  intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache{
    BOOL ret = FALSE;
    //关闭当天广告请求
    NSString *currentDateStr = oldTime;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strTime = nil;
    if (isUseYYCache) {
        strTime = (NSString*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        strTime = [userDefaults objectForKey:strTag];
    }
    if (!strTime) {//第一次点击
        ret = FALSE;
        if (isSet) {
            if (isUseYYCache) {
                [HelpFuntionCaches setObject:currentDateStr forKey:strTag];
            }
            else {
                [userDefaults setObject:currentDateStr forKey:strTag];
            }
        }
    }
    else {
        NSDate *oldDate = [self getDataFromStringLocal:strTime];
        NSDate *newTime = [self getDataFromStringLocal:currentDateStr];
        
        NSTimeInterval t = [newTime timeIntervalSinceDate:oldDate];
        if (fabs(t) >= intervalDay * 3600*24) {
            if (isSet) {
                if (isUseYYCache) {
                    [HelpFuntionCaches setObject:currentDateStr forKey:strTag];
                }
                else{
                    [userDefaults setObject:currentDateStr forKey:strTag];
                }
            }
        }
        else{
            
            ret = TRUE;
        }
    }
    
    [userDefaults synchronize];
    return ret;
    
}


-(BOOL)isIntervalDay:(NSString*)strTag intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //用[NSDate date]可以获取系统当前时间
    if (!date) {
        date = [NSDate date];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return [self isIntervalDayFromOldTime:strTag oldTime:currentDateStr AutoSet:true intervalDay:intervalDay isUseYYCache:isUseYYCache];
}

-(BOOL)isValideNotAutoAddCommonDay:(NSString*)strTag nCount:(int)time intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date{
    BOOL ret = TRUE;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [self isIntervalDay:[NSString stringWithFormat:@"%@_ext",strTag] intervalDay:intervalDay isUseYYCache:isUseYYCache time:date];
    if (!flag) {
        if (isUseYYCache) {
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
    }
    else{
        
    }
    NSNumber  *number = nil;
    if (isUseYYCache) {
        number = (NSNumber*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        number = [userDefaults objectForKey:strTag];
    }
    if ([number intValue]<=0) {
        ret = FALSE;
    }
    else {
    }
    [userDefaults synchronize];
    return ret;
}

-(BOOL)isValideCommonDay:(NSString*)strTag nCount:(int)time intervalDay:(int)intervalDay isUseYYCache:(BOOL)isUseYYCache time:(NSDate*)date{
    BOOL ret = TRUE;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [self isIntervalDay:[NSString stringWithFormat:@"%@_ext",strTag] intervalDay:intervalDay isUseYYCache:isUseYYCache time:date];
    if (!flag) {
        if (isUseYYCache) {
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:time] forKey:strTag];
        }
    }
    else{
        
    }
    
    NSNumber  *number = nil;
    if (isUseYYCache) {
        number = (NSNumber*)[HelpFuntionCaches objectForKey:strTag];
    }
    else{
        number = [userDefaults objectForKey:strTag];
    }
    int leave = [number integerValue]-1;
    if (leave<0) {
        ret = FALSE;
    }
    else {
        if (isUseYYCache) {
            NSLog(@"levae = %d strTag = %@",leave,strTag);
            [HelpFuntionCaches setObject:[NSNumber numberWithInt:leave] forKey:strTag];
        }
        else{
            [userDefaults setObject:[NSNumber numberWithInt:leave] forKey:strTag];
        }
    }
    [userDefaults synchronize];
    
    return ret;
}

@end
