//
//  GDTCpManager.h
//  grayWolf
//
//  Created by zengbiwang on 2017/6/27.
//
//

#import <Foundation/Foundation.h>
typedef enum GDTClickState{
    GDT_CLICK_unVaild,
    GDT_CLICK_Vaild,
}_GDTClickState;

extern _GDTClickState _clickState ;

#define NotitifiBannerState [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckBannerState" object:nil];
#define NotitifiInterstitialState [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckInterstitialState" object:nil];
#define NotitifiAdvertGdtManagerChangeID [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckAdvertGdtManagerChangeID" object:nil];

typedef enum GDTCpManagerState{
    GDT_CpManager_FirstRequest,//第一次请求的状态
    GDT_CpManager_AutoClickSuccess,//成功自动点击
    GDT_CpManager_AutoClickFaild,//没有自动点击，超时处理
    GDT_CpManager_AutoUpdate,//刷新状态
}_GDTCpManagerState;

//透明点击逻辑处理
@interface GDTCpNativeManager : NSObject
@property(assign)_GDTCpManagerState cpState;
+(GDTCpNativeManager*)getInstance;
+(void)destoryInstance;
-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl;

-(void)stopGDTAndRemove;
-(void)stopIfisClick;
@end

