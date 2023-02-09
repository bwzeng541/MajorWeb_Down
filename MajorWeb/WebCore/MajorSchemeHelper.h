
#import <Foundation/Foundation.h>

@interface MajorSchemeHelper : NSObject

+ (MajorSchemeHelper*)sharedHelper;

-(NSString*)getLocalMask;
- (void)addPrefixes:(NSArray*)array;
- (void)addPrefixexFromUser:(NSString*)preStr;
- (NSString*)getAppId:(NSString*)searchedString;



-(NSString*)findSchemeUrl:(NSURL*)url;
/*!
 
 判断该链接是否可以在AppStore中打开.
 
 */
- (BOOL)isAppStoreLink:(NSURL*)url;

/*!
 
 如果是一键安装链接
 
 */
//- (BOOL)isJBInstallLink:(NSURL*)url;

+ (BOOL)validateUrl:(NSString*)candidate;

@end
