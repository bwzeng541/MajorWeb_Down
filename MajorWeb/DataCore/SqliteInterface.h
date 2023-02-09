
#import <Foundation/Foundation.h>
#import "FMDB.h"

@class FMDatabase;

@interface SqliteInterface : NSObject
{
    NSString *dbRealPath;
    FMDatabase *dbo;
}

@property (nonatomic, strong) NSString *dbRealPath;
@property (nonatomic, strong) FMDatabase *dbo;

+ (SqliteInterface *)sharedSqliteInterface;
- (void) connectDB;
- (void) closeDB;
- (void) setupDB : (NSString *)dbFileName;

+ (BOOL) dbFileIsExist; //用于验证，用户是否第一次启动

@end
