//
//  GdtUserManager.h
//  grayWolf
//
//  Created by zengbiwang on 2018/6/4.
//

#import <Foundation/Foundation.h>
#import "GDTMobBannerView.h"

@interface GdtUserManager : NSObject
+(GdtUserManager*)getInstance;
@property(nonatomic,assign)id gdtStatsMgr;
-(void)updateInterstitialRoot:(UIViewController*)ctrl showPartView:(UIView*)showPartView;
-(void)initWithRootCtrl:(UIViewController*)rootCtrl;
-(NSDictionary*)getBannerInfo;
-(NSDictionary*)getExpressInfo;
-(NSDictionary*)getKaiPinInfo;
-(NSDictionary*)getInterstitialInfo;
-(void)showit;
-(BOOL)initAdInfo;

-(BOOL)checkStateShowInterstitial;
-(BOOL)isRootCtrlVaild;
@end
