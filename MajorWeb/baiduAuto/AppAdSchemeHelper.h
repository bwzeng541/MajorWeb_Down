
#import <Foundation/Foundation.h>
#define AppTeShuPre [NSString stringWithFormat:@"%@%@%@",@"itm",@"s-serv",@"ices"]

@interface AppAdSchemeHelper : NSObject

+ (AppAdSchemeHelper*)sharedHelper;

 - (void)addPrefixes:(NSArray*)array;
 


-(NSString*)findSchemeUrl:(NSURL*)url;
/*!
 
 判断该链接是否可以在AppStore中打开.
 
 */
- (BOOL)isAppStoreLink:(NSURL*)url;

/*!
 
 如果是一键安装链接
 
 */
//- (BOOL)isJBInstallLink:(NSURL*)url;

 
@end
