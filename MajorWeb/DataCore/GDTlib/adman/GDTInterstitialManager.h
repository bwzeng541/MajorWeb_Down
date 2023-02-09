//
//  GDTCpManager.h
//  grayWolf
//
//  Created by zengbiwang on 2017/6/27.
//
//

#import <Foundation/Foundation.h>
#import "GDTCpNativeManager.h"
#import "AdvertGdtInterstitialManager.h"
//透明点击逻辑处理
extern _GDTClickState _click_Interstitial_State ;

@interface GDTInterstitialManager : NSObject
@property(assign)_GDTCpManagerState cpState;
+(GDTInterstitialManager*)getInstance;
+(void)destoryInstance;
-(BOOL)showGDTCp:(UIView**)outView rootCtrl:(UIViewController*)rootCtrl;

-(void)stopGDTAndRemove;
-(void)stopIfisClick;
@end

