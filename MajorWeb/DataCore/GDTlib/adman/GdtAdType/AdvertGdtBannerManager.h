//
//  AdvertGdtManager.h
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "GDTCpBannerManager.h"
@interface AdvertGdtBannerManager : NSObject
+(AdvertGdtBannerManager*)getInstance;
-(NSInteger)getIdArrayCount;
-(_GDTCpManagerState)getCpState;
-(BOOL)startRun:(UIViewController*)rootCtrl;
-(void)initClickInfo;
-(void)initAdvertArray:(NSArray*)array;
-(BOOL)isCanAutoShow;
-(NSInteger)initUseId;

 @end
