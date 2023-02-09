//
//  AdvertGdtManager.m
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2017/11/10.
//

#import "AdvertGdtManager.h"
#import "AdvertGdtInterstitialManager.h"
#import "MajorSystemConfig.h"
#import "CSPausibleTimer.h"
#import "AppDevice.h"
#import "fishhook.h"
#import "GLLogging.h"
#import "ClickManager.h"

id my_ns_calss(NSString *msg);

static id  (*orig_ns_calss)(NSString *msg);

id my_ns_calss(NSString *msg)
{
    if((_clickState !=GDT_CLICK_unVaild && [msg compare:@"SFSafariViewController"] == NSOrderedSame) ||
       (_click_banner_State !=GDT_CLICK_unVaild && [msg compare:@"SFSafariViewController"] == NSOrderedSame) ||
       (_click_Interstitial_State !=GDT_CLICK_unVaild && [msg compare:@"SFSafariViewController"] == NSOrderedSame)){
        return NULL;
    }
    id v =  orig_ns_calss( msg);
    return v;
}

void test_GDTCp(){
    // rebind_symbols((struct rebinding[1]){"CC_MD5", (void *)&my_ccmd5, (void **)&orig_ccmd5}, 1);
    rebind_symbols((struct rebinding[1]){"NSClassFromString", (void *)&my_ns_calss, (void **)&orig_ns_calss}, 1);
}



@interface AdvertGdtManager()
@property(retain)NSMutableDictionary *_dInfo;
@property(copy)NSArray *idArray;
@property(assign)UIViewController *rootCtrl;
@property(retain)CSPausibleTimer *changeTimer;
@property(assign)NSInteger total;
@property(assign)NSInteger index;
@end

@implementation AdvertGdtManager
+(AdvertGdtManager*)getInstance{
    if(IF_IPAD){
     //   return NULL;
    }
    static AdvertGdtManager *g = NULL;
    if (!g) {
        g = [[AdvertGdtManager alloc]init];
    }
    return g;
}

-(void)initAdvertArray:(NSArray*)array
{
   xxxn(self.idArray, array)
}

-(void)isPasuseTimer:(BOOL)isPause{
    if (isPause) {
        [self.changeTimer pauseTimer];
    }
    else{
        [self.changeTimer resumeTimer];
    }
}

-(void)initUseId
{
    int gdtIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gdt_info_param"] intValue];
    if (self.idArray.count > 0 &&  gdtIndex>=self.idArray.count)
    {
        gdtIndex = 0;
    }
    if ( gdtIndex < self.idArray.count) {
        [MajorSystemConfig getInstance].gdtAdInfo = [self.idArray objectAtIndex:gdtIndex];
        gdtIndex = (gdtIndex+1) % self.idArray.count;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gdtIndex] forKey:@"gdt_info_param"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.index++;
}

-(BOOL)startRun:(UIViewController*)rootCtrl
{
    if ([MajorSystemConfig getInstance].isDelGdtCreateDir) {//删除目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"tencent_gdtmob"] error:NULL] ;
    }
    if([MajorSystemConfig getInstance].isParallelClick){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkAdvertGdtManagerChangeID) name:@"CheckAdvertGdtManagerChangeID" object:nil];
    }
    test_GDTCp();
    self._dInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSInteger v1 = self.idArray.count;
    NSInteger v2 = [[AdvertGdtBannerManager getInstance] getIdArrayCount];
    self.total = v1>v2?v1:v2;
    self.index = 0;
    self.rootCtrl = rootCtrl;
    [[AppDevice getInstance] initReSetDeviceInfo];
    if(!self.changeTimer){
        self.changeTimer = [CSPausibleTimer scheduledTimerWithTimeInterval:[MajorSystemConfig getInstance].changeAdvertIdTime target:self selector:@selector(isCanChangeAndShowCp) userInfo:nil repeats:YES];
    }
    return [self isCanChangeAndShowCp];
}

-(void)checkAdvertGdtManagerChangeID{
    [self isPasuseTimer:false];
}

-(void)changeAllUseID{
    [self initUseId];
    NSInteger ret = [[AdvertGdtBannerManager getInstance] initUseId];
    [[AdvertGdtInterstitialManager getInstance] initUseId:ret];
}

-(void)destoryAllAd{
    [GDTCpNativeManager destoryInstance];
    [GDTCpBannerManager destoryInstance];
    [GDTInterstitialManager destoryInstance];
}

-(BOOL)showAllAd{
    if([MajorSystemConfig getInstance].isParallelClick){
        [self isPasuseTimer:true];
        [self.changeTimer reSetPausedTimeInterval:40];
    }
    printf("showAllAd \n");
    //初始化init
    [GDTCpBannerManager getInstance];
    [GDTInterstitialManager getInstance];
    [self reSetAppInfo];
    //end
    [self showGDTCp:nil rootCtrl:self.rootCtrl];
    [[GDTCpBannerManager getInstance]showGDTCp:nil rootCtrl:self.rootCtrl];
    [[GDTInterstitialManager getInstance]showGDTCp:nil rootCtrl:self.rootCtrl];//插屏
    return true;
}

-(void)reSetAppInfo{
    NSString *pkgname = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"pkgname"];
    NSString *appn = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"_appn"];
    NSString *appnversion = [[MajorSystemConfig getInstance].gdtBannerAdInfo objectForKey:@"_app_version_code"];
    [[GetStatsMgrPro getInstance] setNewValue:self.gdtStatsMgr key:@"_an" value:pkgname];
    [[GetStatsMgrPro getInstance] setNewValue:self.gdtStatsMgr key:@"_appn" value:appn];
    [[GetStatsMgrPro getInstance] setNewValue:self.gdtStatsMgr key:@"_app_version_code" value:appnversion];
    if (![[ClickManager getInstance] isClickReady:pkgname]) {
        [MajorSystemConfig getInstance].is_qq_Apl = true;//没有点击过，强制点击，
    }
    else{//否则点击过，走20%的点击流程
        [MajorSystemConfig getInstance].is_qq_Apl = [MajorSystemConfig getInstance].is_save_old_qq_Apl;//
    }
}

//停止所有请求，不恢复
-(void)stopAllReqeust{
    [self.changeTimer invalidate];
    self.changeTimer = nil;
    [self destoryAllAd];
    _clickState = GDT_CLICK_unVaild;
    _click_banner_State = GDT_CLICK_unVaild;
    _click_Interstitial_State = GDT_CLICK_unVaild;
}//end

-(BOOL)isCanChangeAndShowCp
{
    return false;
    if (true || self.index<self.total) {
        [self changeAllUseID];
        [self destoryAllAd];
        if (self.index>=self.total) {//这里需要切换设备信息
            self.index = 0;
            [[AppDevice getInstance] initReSetDeviceInfo];
        }
        return  [self showAllAd];
    }
    return NO;
}

//循环跑量需要次api
-(BOOL)isCanAutoShow{
    BOOL ret = false;
    if(![self._dInfo objectForKey:[NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID]]){
        ret = true;
    }
    return ret;
}

-(void)initClickInfo{
    [self._dInfo setObject:@"1" forKey:[NSString stringWithFormat:@"%@%@",[[MajorSystemConfig getInstance].gdtAdInfo objectForKey:@"placementId"],[AppDevice getInstance].deviceUID]];
}

-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl{
    return [[GDTCpNativeManager getInstance]showGDTCp:outView rootCtrl:rootCtrl];
}

-(_GDTCpManagerState)getCpState{
    return [GDTCpNativeManager getInstance].cpState;
}
 

 
@end
