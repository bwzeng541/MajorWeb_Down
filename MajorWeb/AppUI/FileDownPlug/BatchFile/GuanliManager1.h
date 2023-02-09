
#if DoNotKMPLayerCanShareVideo
#else
#import <Foundation/Foundation.h>
#import "YTKNetworkPrivate.h"


@interface GuanliNSDictionary :NSObject
-(NSDictionary*)getInfo;
@end
//批量的地方走这里
@interface GuanliManager1 : NSObject
+(GuanliManager1*)getInstance;
-(NSNumber*)isNodeInArray:(NSString*)uuid;
-(NSArray*)getNodeArray;
-(NSArray*)getNodeKeyArray;
-(void)addZNode:(NSString*)parma0 parma1:(NSString*)parma1;
-(void)startZNode:(NSString*)uuid;
-(void)stopZNode:(NSString*)uuid;
-(void)reDownAlter:(NSString*)uuid msg:(NSString*)msg;
-(void)deletZNodeUUID:(NSString*)uuid;
-(void)fixbugSetUUIDNIL;
-(NSNumber*)isZNodeInQueque:(NSString*)uuid;
@end
#endif
