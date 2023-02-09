//
//  AdvertGdtManager.m
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2017/11/10.
//

#import "AdvertGdtInterstitialManager.h"
#import "MajorSystemConfig.h"
#import "AppDevice.h"

@interface AdvertGdtInterstitialManager()
@property(retain)NSMutableDictionary *_dInfo;
@property(copy)NSArray *idArray;
@property(assign)UIViewController *rootCtrl;
@end

@implementation AdvertGdtInterstitialManager
+(AdvertGdtInterstitialManager*)getInstance{
    //return NULL;
   
    static AdvertGdtInterstitialManager *g = NULL;
    if (!g) {
        g = [[AdvertGdtInterstitialManager alloc]init];
    }
    return g;
}

-(NSInteger)getIdArrayCount{
    return self.idArray.count;
}

-(void)initAdvertArray:(NSArray*)array
{
    xxxb(self.idArray, array)
    self._dInfo = [NSMutableDictionary dictionaryWithCapacity:1];
}

-(void)initUseId:(NSInteger)fromBanner
{
    int gdtIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gdt_interstitial_info_param"] intValue];
    if (self.idArray.count > 0 &&  gdtIndex>=self.idArray.count)
    {
        gdtIndex = 0;
    }
    if (fromBanner!=gdtIndex && fromBanner < self.idArray.count) {
        gdtIndex = fromBanner;
    }
    if ( gdtIndex < self.idArray.count) {
        [MajorSystemConfig getInstance].gdtInterstitialAdInfo = [self.idArray objectAtIndex:gdtIndex];
        gdtIndex = (gdtIndex+1) % self.idArray.count;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gdtIndex] forKey:@"gdt_interstitial_info_param"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(BOOL)startRun:(UIViewController*)rootCtrl
{
    return false;
}

-(BOOL)isCanChangeAndShowCp
{
    return false;
}

//循环跑量需要次api
-(BOOL)isCanAutoShow{
    BOOL ret = false;
    if(![self._dInfo objectForKey:[NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID]]){
        ret = true;
    }
    return ret;
}

-(void)initClickInfo{
    [self._dInfo setObject:@"1" forKey:[NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtInterstitialAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID]];
}

-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl{
    return [[GDTInterstitialManager getInstance]showGDTCp:outView rootCtrl:rootCtrl];
}

-(_GDTCpManagerState)getCpState{
    return [GDTInterstitialManager getInstance].cpState;
}
 

 
@end
