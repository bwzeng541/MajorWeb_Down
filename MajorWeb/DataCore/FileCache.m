
#import "FileCache.h"
#import "SqliteInterface.h"


@implementation FileCache

+(NSString *)getFilePath:(NSString *)fileName
{
    if (fileName==nil)
    {
        return AppSynchronizationDir;
    }
    NSString *myFilePath = [AppSynchronizationDir stringByAppendingPathComponent:fileName];
    return myFilePath;
}
+(void)createFile:(NSString *)route FileName:(NSString *)fileName
{
    NSString *path=[route stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

+(void)createFolder:(NSString *)route FolderName:(NSString *)folderName
{	
    NSString *folerDir=[NSString stringWithFormat:@"%@/%@",route,folderName];
//    [[NSFileManager defaultManager] createDirectoryAtPath:folerDir attributes:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:folerDir withIntermediateDirectories:NO attributes:nil error:nil];
}

+(void)removeFile:(NSString *)route FileName:(NSString *)fileName
{
    
}

+(void)removeFolder:(NSString *)route FolderName:(NSString *)folderName
{
    
}

+(BOOL)is_file_exist:(NSString *)name
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:[FileCache getFilePath:name]];
}
//+(void) removeAllCache
//{
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    [fm removeItemAtPath:docDir error:NULL];
//}
//
//+ (BOOL) saveToCache:(NSString *)identity :(UIImage *)image :(NSInteger)dir{
//	
//	NSString *docDir = [self parseDir:dir];
//	
//	[[NSFileManager defaultManager] createDirectoryAtPath:docDir attributes:nil];
//    
//	NSString *filePath = [NSString stringWithFormat:@"%@/%@",docDir,identity];
//	
//	NSData *imgData = [NSData dataWithData:UIImageJPEGRepresentation(image,10.f)];
//	
//	return [imgData writeToFile:filePath atomically:YES];
//}
//

+ (int)getNotDBDataName:(NSString *)dbName 
             TableName:(NSString *)tbName 
             TitleName:(NSString *)titleName
              TitleUrl:(NSString *)titleUrl
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectStr = [NSString stringWithFormat:@"SELECT count(*) AS titleCount FROM %@ WHERE TitleName = ? ",tbName];
    FMResultSet *rsSet = [dbo executeQuery:selectStr,titleName];
    int count=0;
    while ([rsSet next])
    {
        count=[rsSet intForColumn:@"titleCount"];
    }
    [rsSet close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}

+ (int)getNotDBDataUrl:(NSString *)dbName 
             TableName:(NSString *)tbName 
             TitleName:(NSString *)titleName
              TitleUrl:(NSString *)titleUrl
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectStr = [NSString stringWithFormat:@"SELECT count(*) AS titleCount FROM %@ WHERE TitleUrl = ? ",tbName];
    FMResultSet *rsSet = [dbo executeQuery:selectStr,titleUrl];
    int count=0;
    while ([rsSet next])
    {
        count=[rsSet intForColumn:@"titleCount"];
    }
    [rsSet close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}

+ (NSInteger)getTableDataCount:(NSString*)dbName tbName:(NSString*)tableName maxCount:(NSInteger)maxCount isAutoDel:(BOOL)isAutoDel
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *str = [NSString stringWithFormat:@"SELECT count(*) FROM %@ ",tableName];
    FMResultSet *rs=[dbo executeQuery:str];
    NSInteger  totalCount = 0;
    if ([rs next]) {
        totalCount = [rs intForColumnIndex:0];
    }
    [rs close];
    if(isAutoDel && totalCount>=maxCount){//DELETE FROM UserMainHome where DateStr in (SELECT DateStr  FROM UserMainHome order by DateStr  LIMIT 1)
        str = [NSString stringWithFormat:@"DELETE FROM %@ where DateStr in(SELECT DateStr FROM %@ order by DateStr LIMIT 1)",tableName,tableName];
        [dbo executeUpdate:str];
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return totalCount;
}


//取数据库中不包含的索引
+ (int)getNotDBDataIndex:(NSString *)path 
                  DBName:(NSString *)dbName
               TableName:(NSString *)tbName
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    int titleNum=0;
    for (int i=1; ; i++) 
    {
        NSString *str = [NSString stringWithFormat:@"SELECT count(*) AS titNum FROM %@ WHERE TitleNum = ?",tbName];
        FMResultSet *rs=[dbo executeQuery:str,[NSNumber numberWithInt:i]];
        int count=0;
        while ([rs next])
        {
            count = [rs intForColumn:@"titNum"];
        }
        [rs close];
        if (count==0)
        {
            titleNum=i;
            break;
        }
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return titleNum;
}

//取系统时间
+ (NSString *)getNowDate
{
    NSDateFormatter *datef = [[NSDateFormatter alloc] init];
    [datef setDateFormat:@"yyyyMMddHHmmss"];
    NSString *str=[datef stringFromDate:[NSDate date]];
    //    NSLog(@"%@",[self getFolderName:str]);
    return str;
}

//向数据库中插入数据
+ (BOOL)insertDataToDB:(NSString *)dbName
             TableName:(NSString *)tbName
              TitleNum:(NSString *)titleNum
             TitleName:(NSString *)titleName
               IconStr:(NSString *)iconStr
              TitleUrl:(NSString *)titleUrl
               TypeStr:(NSString *)typeStr
               DateStr:(NSString *)dateStr
              SuperNum:(NSString *)superNum
                SubNum:(NSString *)subNum
             DataCount:(NSString *)dataCount;
{
    return [self insertBaseDataToDB:dbName TableName:tbName TitleNum:titleNum TitleName:titleName IconStr:iconStr TitleUrl:titleUrl WebUrl:@"" TypeStr:typeStr DateStr:dateStr SuperNum:superNum SubNum:subNum DataCount:dataCount];
}
+ (BOOL)insertBaseDataToDB:(NSString *)dbName
             TableName:(NSString *)tbName
              TitleNum:(NSString *)titleNum
             TitleName:(NSString *)titleName
               IconStr:(NSString *)iconStr
              TitleUrl:(NSString *)titleUrl
                WebUrl:(NSString *)WebUrl
               TypeStr:(NSString *)typeStr
               DateStr:(NSString *)dateStr
              SuperNum:(NSString *)superNum
                SubNum:(NSString *)subNum
             DataCount:(NSString *)dataCount{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
   
    FMResultSet *rs;
    if ([tbName isEqualToString:KEY_TABEL_VIDEOHISTORY] || [tbName isEqualToString:KEY_TABEL_USERMAINHOME]) {
        NSString *selectSql = [NSString stringWithFormat:@"SELECT count(*) AS titleCount FROM %@ WHERE TitleName = '%@' and TitleUrl like '%@%%' ",tbName,titleName,titleUrl];
        rs = [dbo executeQuery:selectSql];
    }else{
         NSString *selectSql = [NSString stringWithFormat:@"SELECT count(*) AS titleCount FROM %@ WHERE TitleName = ? AND TitleUrl = ?",tbName];
        rs = [dbo executeQuery:selectSql,titleName,titleUrl];
    }
    
    int count=0;
    while ([rs next])
    {
        count=[rs intForColumn:@"titleCount"];
    }
    [rs close];
    BOOL flag = NO;
    if (count==0)
    {
        
        if ([tbName isEqualToString:KEY_TABEL_VIDEOHISTORY] || [tbName isEqualToString:KEY_TABEL_USERMAINHOME]) {
            NSString *str =[NSString stringWithFormat:@"INSERT INTO %@ (TitleNum,TitleName,IconStr,TitleUrl,WebUrl,TypeStr,DateStr,SuperNum,SubNum,DataCount) VALUES (?,?,?,?,?,?,?,?,?,?)",tbName];
            flag=[dbo executeUpdate:str,[NSNumber numberWithInt:[titleNum intValue]],titleName,iconStr,titleUrl,WebUrl,[NSNumber numberWithInt:[typeStr intValue]],dateStr,[NSNumber numberWithInt:[superNum intValue]],[NSNumber numberWithInt:[subNum intValue]],[NSNumber numberWithInt:[dataCount intValue]]];
        }else{
            NSString *str = [NSString stringWithFormat:@"INSERT INTO %@ (TitleNum,TitleName,IconStr,TitleUrl,TypeStr,DateStr,SuperNum,SubNum,DataCount) VALUES (?,?,?,?,?,?,?,?,?)",tbName];
            flag=[dbo executeUpdate:str,[NSNumber numberWithInt:[titleNum intValue]],titleName,iconStr,titleUrl,[NSNumber numberWithInt:[typeStr intValue]],dateStr,[NSNumber numberWithInt:[superNum intValue]],[NSNumber numberWithInt:[subNum intValue]],[NSNumber numberWithInt:[dataCount intValue]]];
        }
        
        if (flag)
        {
            
        }
        else
        {
        }
    }
    if (count>0)
    {
        flag=YES;
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}

+ (BOOL)updateDBDataDate:(NSString *)dbName
                TableName:(NSString *)tbName
                TitleUrl:(NSString *)titleUrl
                 DateStr:(NSString *)dateStr
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *str = [NSString stringWithFormat:@"UPDATE %@ SET DateStr = ? WHERE TitleUrl = ? ",tbName];
    BOOL flag=[dbo executeUpdate:str,dateStr,titleUrl];
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}

+ (int)getDBDateCount:(NSString *)dbName
            TableName:(NSString *)tbName
             TitleUrl:(NSString *)titleUrl
              DateStr:(NSString *)dateStr
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectStr = [NSString stringWithFormat:@"SELECT DataCount FROM %@ WHERE TitleUrl = ? ",tbName];
    FMResultSet *rsSet = [dbo executeQuery:selectStr,titleUrl];
    int count=0;
    while ([rsSet next])
    {
        count=[[rsSet stringForColumn:@"DataCount"]intValue];
    }
    [rsSet close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}

+ (BOOL)updateDBDataDateCount:(NSString *)dbName
               TableName:(NSString *)tbName
                TitleUrl:(NSString *)titleUrl
                 DataCount:(NSString *)dateCount
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *str = [NSString stringWithFormat:@"UPDATE %@ SET DataCount = ? WHERE TitleUrl = ? ",tbName];
    BOOL flag=[dbo executeUpdate:str,dateCount,titleUrl];
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}

+ (BOOL)deleteAllDBDataByTbName:(NSString *)dbName
                      TableName:(NSString *)tbName
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *selectTitle = [NSString stringWithFormat:@"DELETE FROM %@ ",tbName];
    BOOL rsSetTitle = [dbo executeUpdate:selectTitle];

    [[SqliteInterface sharedSqliteInterface] closeDB];
    return rsSetTitle;
}

+ (BOOL)deleteAllDBDataByTitleNum:(NSString *)dbName
                        TableName:(NSString *)tbName
                         TitleNum:(NSString *)titleNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *str = [NSString stringWithFormat:@"DELETE FROM %@ WHERE titleNum = ? ",tbName];
    BOOL flag = [dbo executeUpdate:str,titleNum];  
    if (flag)
    {
    }
    else
    {
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}

//更新数据通过num
+ (BOOL)updateDBDataByTitleNum:(NSString *)dbName
                     TableName:(NSString *)tbName
                      TitleNum:(NSString *)titleNum
                     TitleName:(NSString *)titleName
                       IconStr:(NSString *)iconStr
                       DateStr:(NSString *)dateStr
                      TitleUrl:(NSString *)titleUrl
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *str = [NSString stringWithFormat:@"UPDATE %@ SET TitleName = ?,TitleUrl = ?,IconStr = ?,DateStr = ? WHERE TitleNum = ? ",tbName];
    BOOL flag=[dbo executeUpdate:str,titleName,titleUrl,iconStr,dateStr,titleNum];
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}





//格式化，取系统时间
+ (NSString *)getFolderName:(NSString *)name
{
    NSRange rangeOne = NSMakeRange(4,2);
    NSRange rangeTwo = NSMakeRange(6,2);
    NSString *str=[NSString stringWithFormat:@"%@年%@月%@日",[name substringToIndex:4],[name substringWithRange:rangeOne],[name substringWithRange:rangeTwo]];
    return str;
}
//取数据库中不包含的索引
+ (int)getNotQuickDataIndex:(NSString *)path 
                  DBName:(NSString *)dbName
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    int titleNum=0;
    for (int i=1; ; i++) 
    {
        FMResultSet *rs=[dbo executeQuery:@"SELECT count(*) AS titNum FROM Quick WHERE qImg = ? ",[NSString stringWithFormat:@"%i",i]];
        int count=0;
        while ([rs next])
        {
            count = [rs intForColumn:@"titNum"];
        }
        if (count==0)
        {
            titleNum=i;
            break;
        }
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return titleNum;
}



//向数据库中插入历史记录数据
+ (BOOL)insertDataToHistoryRecordDB:(NSString *)dbName
                           TitleNum:(NSString *)titleNum
                          TitleName:(NSString *)titleName
                            IconStr:(NSString *)iconStr
                           TitleUrl:(NSString *)titleUrl
                            TypeStr:(NSString *)typeStr
                            DateStr:(NSString *)dateStr
                           SuperNum:(NSString *)superNum
                             SubNum:(NSString *)subNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectSql = @"SELECT count(*) AS titleCount FROM Mainfirst WHERE TitleUrl = ? AND TypeStr = ? AND SuperNum = ? ";
    FMResultSet *rs = [dbo executeQuery:selectSql,titleUrl,typeStr,[NSNumber numberWithInt:1]];
    int count=0;
    while ([rs next]) 
    {
        count=[rs intForColumn:@"titleCount"];
    }
    BOOL flag = NO;
    if (count==0)
    {
        flag=[dbo executeUpdate:@"INSERT INTO Mainfirst (TitleNum,TitleName,IconStr,TitleUrl,TypeStr,DateStr,SuperNum,SubNum) VALUES (?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:[titleNum intValue]],titleName,iconStr,titleUrl,[NSNumber numberWithInt:[typeStr intValue]],dateStr,[NSNumber numberWithInt:[superNum intValue]],[NSNumber numberWithInt:[subNum intValue]]];
        if (flag)
        {
            NSLog(@"zsfzsfzsfzsfzsf");
        }
        else
        {
            NSLog(@"111zsfzsfzsfzsfzsf");
        }
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}

//取数据条数
+ (int)getDBDataNum:(NSString *)dbName
          TableName:(NSString *)tbName
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *selectSql = @"SELECT * FROM Mainfirst";
    FMResultSet *rs = [dbo executeQuery:selectSql];
    int count=0;
    while ([rs next])
    {
        count++;
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}

//更新父子关系
+ (BOOL)updateDBDataSuperNum:(NSString *)dbName
                   TitleNum:(NSString *)titleNum
                    SuperNum:(NSString *)superNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    BOOL flag=[dbo executeUpdate:@"UPDATE Mainfirst SET SuperNum = ? WHERE TitleNum = ? ",[NSNumber numberWithInt:[superNum intValue]],[NSNumber numberWithInt:[titleNum intValue]]];

    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}

//+ (BOOL)updateDBDataDate:(NSString *)dbName
//                TitleNum:(NSString *)titleNum
//                SuperNum:(NSString *)superNum
//                 DateStr:(NSString *)dateStr
//{
//    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
//    [[SqliteInterface sharedSqliteInterface] connectDB];
//    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
//    
//    BOOL flag=[dbo executeUpdate:@"UPDATE Mainfirst SET DateStr = ? WHERE TitleNum = ? AND SuperNum = ? ",dateStr,titleNum,superNum];
//    
//    [[SqliteInterface sharedSqliteInterface] closeDB];
//    return flag;
//}

//查询是否有历史记录文件夹
+ (int)selectDBHistoryFold:(NSString *)dbName
                  TitleNum:(NSString *)titleNum
                 TitleName:(NSString *)titleName
                   IconStr:(NSString *)iconStr
                  TitleUrl:(NSString *)titleUrl
                   TypeStr:(NSString *)typeStr
                   DateStr:(NSString *)dateStr
                  SuperNum:(NSString *)superNum
                    SubNum:(NSString *)subNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *selectStr = [NSString stringWithFormat:@"SELECT count(*) AS titleCount FROM %@ WHERE SuperNum = ? AND TypeStr = ? AND TitleName = ?",KEY_TABLE_HISRECORD];
    FMResultSet *rsSet = [dbo executeQuery:selectStr,[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],dateStr];
    int count=0;
    while ([rsSet next])
    {
        count = [rsSet intForColumn:@"titleCount"];
    }
    [rsSet close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}

+ (NSString *)selectDBHistoryFoldName:(NSString *)dbName
                             TitleNum:(NSString *)titleNum
                            TitleName:(NSString *)titleName
                              IconStr:(NSString *)iconStr
                             TitleUrl:(NSString *)titleUrl
                              TypeStr:(NSString *)typeStr
                              DateStr:(NSString *)dateStr
                             SuperNum:(NSString *)superNum
                               SubNum:(NSString *)subNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectTitle = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE SuperNum = ? AND TypeStr = ? AND TitleName = ?",KEY_TABLE_HISRECORD];
    FMResultSet *rsSetTitle = [dbo executeQuery:selectTitle,[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],dateStr];
    int str = 0;
    while ([rsSetTitle next])
    {
        str=[rsSetTitle intForColumn:@"TitleNum"];
    }
    NSString *strNSString = [NSString stringWithFormat:@"%i",str];
    [rsSetTitle close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return strNSString;
}

+ (BOOL)deleteAllDBHistoryFoldName:(NSString *)dbName
                                TitleNum:(NSString *)titleNum
                               TitleName:(NSString *)titleName
                                 IconStr:(NSString *)iconStr
                                TitleUrl:(NSString *)titleUrl
                                 TypeStr:(NSString *)typeStr
                                 DateStr:(NSString *)dateStr
                                SuperNum:(NSString *)superNum
                                  SubNum:(NSString *)subNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *selectTitle = [NSString stringWithFormat:@"DELETE FROM %@ WHERE SuperNum = ? ",KEY_TABLE_HISRECORD];
    BOOL rsSetTitle = [dbo executeUpdate:selectTitle,superNum];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return rsSetTitle;
}

+ (long) insertOrUpdateNavigation:(NSString *)urlString withTag:(NSUInteger)tag
{
    NSString *dbName = KEY_DATENAME;
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *selectStr = @"SELECT count FROM navigation WHERE tag = ? ";
    FMResultSet *rsSet = [dbo executeQuery:selectStr, [NSNumber numberWithInteger:tag]];
    long count=-1;
    while ([rsSet next])
    {
        count=[rsSet intForColumn:@"count"];
    }
    NSNumber *num = [NSNumber numberWithInteger:tag];
    if (count==-1) {
        selectStr = @"INSERT INTO navigation (url, date, tag) VALUES (?, ?, ?)";
        [dbo executeUpdate:selectStr, urlString, [NSDate date], num];
    } else {
        if (count<3) {
            count++;
            selectStr = @"UPDATE navigation SET count = count + 1, date = ? WHERE tag = ?";
            [dbo executeUpdate:selectStr, [NSDate date], num];
        }
    }
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}

+ (void) resetNavigationClickCount:(NSString *)urlString withTag:(NSUInteger)tag
{
    NSString *dbName = KEY_DATENAME;
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *selectStr = @"SELECT count FROM navigation WHERE tag = ? ";
    FMResultSet *rsSet = [dbo executeQuery:selectStr, [NSNumber numberWithInteger:tag]];
    long count=-1;
    while ([rsSet next])
    {
        count=[rsSet intForColumn:@"count"];
    }
    NSNumber *num = [NSNumber numberWithInteger:tag];
    if (count!=-1) {
        selectStr = @"UPDATE navigation SET count = 0, date = ? WHERE tag = ?";
        [dbo executeUpdate:selectStr, urlString, [NSDate date], num];
    }
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
}

+ (NSMutableArray *)topFive
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *dbName = KEY_DATENAME;
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    NSString *sqlStr = @"SELECT tag FROM navigation WHERE count >= 3 ORDER BY date DESC LIMIT 4";
    FMResultSet *rsSet = [dbo executeQuery:sqlStr];
    while ([rsSet next]) {
        int tag = [rsSet intForColumn:@"tag"];
        NSNumber *num = [NSNumber numberWithInt:tag];
        [array addObject:num];
    }
    [[SqliteInterface sharedSqliteInterface] closeDB];
    
    return array;
}

+(void)createDBUserMainHomeTable{
    NSString *dbName = KEY_DATENAME;
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    
    BOOL isCreateed = NO;
    while (!isCreateed) {
        NSString *createTableStr = @"CREATE TABLE IF Not Exists UserMainHome (TitleNum INTEGER PRIMARY KEY,TitleName TEXT,IconStr TEXT,TitleUrl TEXT,WebUrl TEXT,TypeStr INTEGER,DateStr TEXT,SuperNum INTEGER,SubNum INTEGER,DataCount INTEGER)";
        isCreateed = [dbo executeUpdate:createTableStr];
    }
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
}

+(void)createDBVideoHistoryTable{
    NSString *dbName = KEY_DATENAME;
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;

    BOOL isCreateed = NO;
    while (!isCreateed) {
        NSString *createTableStr = @"CREATE TABLE IF Not Exists VideoHistory (TitleNum INTEGER PRIMARY KEY,TitleName TEXT,IconStr TEXT,TitleUrl TEXT,WebUrl TEXT,TypeStr INTEGER,DateStr TEXT,SuperNum INTEGER,SubNum INTEGER,DataCount INTEGER)";
        isCreateed = [dbo executeUpdate:createTableStr];
    }
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
}

+ (BOOL)updateDBVideoDataDateCount:(NSString *)dbName
                    TableName:(NSString *)tbName
                     TitleUrl:(NSString *)titleUrl
                    SuperNum:(NSString *)superNum
                    SubNum:(NSString *)subNum
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *str = [NSString stringWithFormat:@"UPDATE %@ SET SuperNum = ?, SubNum = ? , DateStr = ? WHERE TitleUrl = ? ",tbName];
    BOOL flag=[dbo executeUpdate:str,superNum,subNum,[FileCache getNowDate],titleUrl];
    
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return flag;
}
+ (int)getNotDBVideoDataUrl:(NSString *)dbName
             TableName:(NSString *)tbName
             TitleName:(NSString *)titleName
              TitleUrl:(NSString *)titleUrl
{
    [[SqliteInterface sharedSqliteInterface] setupDB: dbName];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectStr = [NSString stringWithFormat:@"SELECT count(*) AS titleCount FROM %@ WHERE TitleName = '%@' and TitleUrl like '%@%%' ",tbName,titleName,titleUrl];
    FMResultSet *rsSet = [dbo executeQuery:selectStr];
    int count=0;
    while ([rsSet next])
    {
        count=[rsSet intForColumn:@"titleCount"];
    }
    [rsSet close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return count;
}
@end
