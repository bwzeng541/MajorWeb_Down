#import "SqliteInterface.h"
@implementation SqliteInterface
@synthesize dbRealPath, dbo;
static SqliteInterface *sharedSqliteInterface;
+ (SqliteInterface *)sharedSqliteInterface
{
    if (!sharedSqliteInterface) 
    {
        sharedSqliteInterface = [[SqliteInterface alloc] init];
        
    }
    return sharedSqliteInterface;
}

- (void) connectDB
{
    if (dbo == nil)
    {
        dbo = [[FMDatabase alloc] initWithPath:dbRealPath];
        if (! [dbo open]) 
        {
            NSLog(@"Could not open database.");
        }
    }
    else 
    {
        NSLog(@"Database has already opened.");
    }
}

- (void) closeDB
{
    [dbo close];
//    BR_RELEASE(dbo);
    self.dbo =nil;
}

+ (BOOL)dbFileIsExist {
    NSString *documentsPath = AppSynchronizationDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"MAIN.sqlite"];
    return [fileManager fileExistsAtPath:dbPath];
    
}

- (void) setupDB:(NSString *)dbFileName
{
    if (dbFileName == nil) 
    {
        return;
    }
    
    NSString *documentsPath = AppSynchronizationDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    
    dbRealPath = [documentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@",dbFileName]];
    
    if (![fileManager fileExistsAtPath:dbRealPath]) 
    {
        NSString *dbSrcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbFileName];
        BOOL copySuccess = [fileManager copyItemAtPath:dbSrcPath toPath:dbRealPath error:&err];
        
        if (!copySuccess) 
        {
            NSLog(@"Failed to copy database '%@'.", [err localizedDescription]);
        }
    }

}
@end
