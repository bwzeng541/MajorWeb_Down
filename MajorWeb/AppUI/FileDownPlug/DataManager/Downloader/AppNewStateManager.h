
#import <Foundation/Foundation.h>

@interface AppNewStateManager : NSObject
+(AppNewStateManager*)getInstance;
-(void)updateValueFaild:(NSString*)uuid;
-(void)updateValueSuccess:(NSString*)uuid;
-(void)updateValueState2:(NSString*)uuid isStartTime:(BOOL)isStartTime;
-(void)updateValueState1:(NSString*)uuid value:(NSString*)value;
-(NSString*)getValueFaild:(NSString*)uuid;
-(NSString*)getDownProgress:(NSString*)uuid;
-(NSString*)getMaxCreateTime;
-(BOOL)isInCachesState:(NSString*)uuid;
-(NSNumber*)checkIsDown;//检查h是否后正在下载的项
@end
