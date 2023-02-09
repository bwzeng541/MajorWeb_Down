//
//  AdvertGdtManager.m
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2017/11/10.
//

#import "AdvertGdtBannerManager.h"
#import "MajorSystemConfig.h"
#import "AppDevice.h"

@interface AdvertGdtBannerManager()
@property(retain)NSMutableDictionary *_dInfo;
@property(copy)NSArray *idArray;
@property(assign)UIViewController *rootCtrl;
@end

@implementation AdvertGdtBannerManager
+(AdvertGdtBannerManager*)getInstance{
    return NULL;
    if(IF_IPAD){
     //   return NULL;
    }
    static AdvertGdtBannerManager *g = NULL;
    if (!g) {
        g = [[AdvertGdtBannerManager alloc]init];
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

-(NSInteger)initUseId
{
    int gdtIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gdt_banner_info_param"] intValue];
    if (self.idArray.count > 0 &&  gdtIndex>=self.idArray.count)
    {
        gdtIndex = 0;
    }
    NSInteger ret = gdtIndex;
    if ( gdtIndex < self.idArray.count) {
        [MajorSystemConfig getInstance].gdtBannerAdInfo = [self.idArray objectAtIndex:gdtIndex];
        gdtIndex = (gdtIndex+1) % self.idArray.count;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gdtIndex] forKey:@"gdt_banner_info_param"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return ret;
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
    if(![self._dInfo objectForKey:[NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID]]){
        ret = true;
    }
    return ret;
}

-(void)initClickInfo{
    [self._dInfo setObject:@"1" forKey:[NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID]];
}

-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl{
    return [[GDTCpBannerManager getInstance]showGDTCp:outView rootCtrl:rootCtrl];
}

-(_GDTCpManagerState)getCpState{
    return [GDTCpBannerManager getInstance].cpState;
}
 

 
@end
