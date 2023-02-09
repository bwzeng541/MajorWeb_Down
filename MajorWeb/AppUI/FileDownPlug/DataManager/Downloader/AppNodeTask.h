
#if DoNotKMPLayerCanShareVideo
#else
#import <Foundation/Foundation.h>

@protocol PlayVideoTaskDelegate<NSObject>
@optional
-(void)speedSlow:(NSString*)uuid;
@end
@interface AppNodeTask : NSObject

@property(copy)NSString *uuid;
@property(assign)id<PlayVideoTaskDelegate>delegate;
-(void)jisuan:(float)count;
-(void)jisuan2:(NSProgress*)progress;
-(void)startCheckToSlow;
-(void)stopCheckToSlow;
@end
#endif
