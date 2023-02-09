 
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface FullVideoPreloadAd : NSObject
@property(readonly,nonatomic)BOOL isVaild;
@property(readonly,nonatomic)BOOL isShowState;
-(void)start:(void(^)(void))closeAdBlock;
-(void)show;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
