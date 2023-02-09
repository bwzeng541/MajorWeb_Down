#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface BeatifyBridgeNode : NSObject
-(void)startWithUrl:(NSArray*)webUrls type:(NSInteger)type useRerfer:(BOOL)useRerfer totalBlock:(void(^)(NSInteger totalNo))totalBlock  imageBlock:(void(^)(NSString*imageDom,NSInteger index,NSInteger total))imageBlock addImageBlock:(void(^)(NSString* filePath))addImageBlock;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
