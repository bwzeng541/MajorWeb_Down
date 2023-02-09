

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZyBrigdgeNodeDelegate <NSObject>
-(void)updateListArray:(NSArray*)array;
-(void)updateDomContent:(NSString*)domConent url:(NSString*)url imageUrl:(NSString*)imageUrl isLocal:(BOOL)isLocal picName:(NSString*)picName;
-(void)revicePic:(NSString*)filePath;
@end
@interface WebBrigdgeNode : NSObject
@property(nonatomic,weak)id<ZyBrigdgeNodeDelegate>delegate;
@property(readonly,nonatomic)NSString *picName;
//0列表1dom
+(NSString*)isPicFileExit:(NSString*)name;
+(NSString*)getPicFileFromUrl:(NSString*)url;
-(void)stop;
-(void)stopLoading;
-(void)startUrl:(NSString*)url type:(NSInteger)type;
@end

NS_ASSUME_NONNULL_END
