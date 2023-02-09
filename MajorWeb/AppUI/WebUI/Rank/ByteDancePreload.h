#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ByteDancePreload : NSObject
-(void)start:(void(^)(id adObject))successVideoAdBlock;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
