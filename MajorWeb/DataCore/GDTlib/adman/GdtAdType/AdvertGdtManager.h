//
//  AdvertGdtManager.h
//  PrincessGame-mobile
//
//  Created by zengbiwang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "GDTCpNativeManager.h"
#import "AdvertGdtBannerManager.h"

void test_GDTCp();
@interface GetStatsMgrPro :NSObject
+(GetStatsMgrPro*)getInstance;
-(NSString*)getAppid:(id)v;
-(void)setNewValue:(id)v key:(id)key value:(id)value;
@end

@interface AdvertGdtManager : NSObject
@property(nonatomic,assign)id gdtStatsMgr;
+(AdvertGdtManager*)getInstance;
-(_GDTCpManagerState)getCpState;
-(BOOL)startRun:(UIViewController*)rootCtrl;
-(void)initClickInfo;
-(void)initAdvertArray:(NSArray*)array;
-(BOOL)isCanAutoShow;
-(void)isPasuseTimer:(BOOL)isPause;

-(void)reSetAppInfo;

-(void)stopAllReqeust;
@end
