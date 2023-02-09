//
//  ClickManager.m
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2018/5/9.
//

#import "ClickManager.h"
#import "JSON.h"
#import "FTWCache.h"
#import "helpFuntion.h"
#import "MajorSystemConfig.h"
#define ClickSaveKey @"201805091637"

#define click_zb_manager_20180604 @"click_zb_manager_20180604"

//0 不跑广告 1 正常点击 2自动点击
#define click_type_key_20180602 @"click_type_key_20180602"
@interface ClickManager()
@property(retain)NSMutableDictionary *clickInfo;
@end
@implementation ClickManager
+(ClickManager*)getInstance{
    static ClickManager *g = nil;
    if (!g) {
        g = [[ClickManager alloc] init];
    }
    return g;
}

-(id)init{
    self =[super init];
    self.clickInfo = [NSMutableDictionary dictionaryWithCapacity:1];
     NSData *data =[FTWCache objectForKey:ClickSaveKey useKey:YES];
    if (data) {
      self.clickInfo = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] JSONValue];
    }
    return self;
}

-(void)updateClickKey:(NSString*)key{
    [self.clickInfo setObject:@"1" forKey:key];
    [self syncLocal];
}

-(void)deleleClickKey:(NSString*)key{
    [self.clickInfo removeObjectForKey:key];
    [self syncLocal];
}

-(BOOL)isClickReady:(NSString*)key{
    if(![self.clickInfo objectForKey:key]){
        return false;
    }
    return true;
}

-(void)syncLocal{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [[self.clickInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [FTWCache setObject:data forKey:ClickSaveKey useKey:YES];
    });
}

-(void)clearAllClickInfo{//一天只清除一次
    if([[helpFuntion gethelpFuntion] isValideOneDay:@"cl2018earl07ck17Info" nCount:1 isUseYYCache:false time:nil]){
        self.clickInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        [FTWCache removeObject:ClickSaveKey];
    }
}

//0 不跑广告 1 正常点击 2自动点击
-(int)isAllInfoClick:(NSArray*)array{
    int ret = 1;
    NSArray *arrayTmp = [NSArray arrayWithArray:array];
    for (int i = 0; i < arrayTmp.count; i++) {
        id v = [[arrayTmp objectAtIndex:i] objectForKey:@"pkgname"];
        if (v &&  ![self.clickInfo objectForKey:v]) {
            ret = 2;
            break;
        }
    }
    if (ret==1) {//自动点击完成以后，执行用户点击操作
      //  ret = [self getClickTypeInOneDay];
    }
    return ret;
}

-(int)getClickTypeInOneDay{
    [MajorSystemConfig getInstance].fix_qq_Apl = false;
    int ret = 2;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:click_type_key_20180602]) {
        [defaults setObject:[NSNumber numberWithInteger:2] forKey:click_type_key_20180602];
        [defaults synchronize];
    }
    else {
        if(false && [[helpFuntion gethelpFuntion] isValideOneDay:click_zb_manager_20180604 nCount:1 isUseYYCache:false time:nil])
        {
            [defaults setObject:[NSNumber numberWithInteger:2] forKey:click_type_key_20180602];
            [defaults synchronize];
        }
        else{
            int type = [[defaults objectForKey:click_type_key_20180602] intValue];
            if (type==2) {
                type=1;
                ret = 2;
                [MajorSystemConfig getInstance].fix_qq_Apl = true;
            }
            else if(type==1){
                type=0;
                ret =0;
            }
            else if(type==0){
                type=2;
                ret = type;
            }
            [defaults setObject:[NSNumber numberWithInteger:type] forKey:click_type_key_20180602];
            [defaults synchronize];
        }
    }
    return ret;
}
@end
