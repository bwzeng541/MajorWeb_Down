
#import <Foundation/Foundation.h>

@interface FileCache : NSObject
{
    
}

+ (int)getNotDBDataName:(NSString *)dbName 
              TableName:(NSString *)tbName 
              TitleName:(NSString *)titleName
               TitleUrl:(NSString *)titleUrl;
+ (int)getNotDBDataUrl:(NSString *)dbName 
             TableName:(NSString *)tbName 
             TitleName:(NSString *)titleName
              TitleUrl:(NSString *)titleUrl;
+ (int)getNotDBDataIndex:(NSString *)path 
                  DBName:(NSString *)dbName
               TableName:(NSString *)tbName;
+ (NSString *)getNowDate;
+ (NSString *)getFolderName:(NSString *)name;
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


+ (BOOL)updateDBDataDate:(NSString *)dbName
               TableName:(NSString *)tbName
                TitleUrl:(NSString *)titleUrl
                 DateStr:(NSString *)dateStr;
+ (int)getDBDateCount:(NSString *)dbName
            TableName:(NSString *)tbName
             TitleUrl:(NSString *)titleUrl
              DateStr:(NSString *)dateStr;
+ (BOOL)updateDBDataDateCount:(NSString *)dbName
                    TableName:(NSString *)tbName
                     TitleUrl:(NSString *)titleUrl
                    DataCount:(NSString *)dateCount;
+ (BOOL)deleteAllDBDataByTbName:(NSString *)dbName
                      TableName:(NSString *)tbName;
+ (BOOL)deleteAllDBDataByTitleNum:(NSString *)dbName
                        TableName:(NSString *)tbName
                         TitleNum:(NSString *)titleNum;
+ (BOOL)updateDBDataByTitleNum:(NSString *)dbName
                     TableName:(NSString *)tbName
                      TitleNum:(NSString *)titleNum
                     TitleName:(NSString *)titleName
                       IconStr:(NSString *)iconStr
                       DateStr:(NSString *)dateStr
                      TitleUrl:(NSString *)titleUrl;


+(NSString *)getFilePath:(NSString *)fileName;
+(void)createFile:(NSString *)route FileName:(NSString *)fileName;
+(void)createFolder:(NSString *)route FolderName:(NSString *)folderName;
+(void)removeFile:(NSString *)route FileName:(NSString *)fileName;
+(void)removeFolder:(NSString *)route FolderName:(NSString *)folderName;
+(BOOL)is_file_exist:(NSString *)name;



+ (int)getDBDataNum:(NSString *)dbName
          TableName:(NSString *)tbName;
+ (BOOL)updateDBDataSuperNum:(NSString *)dbName
                    TitleNum:(NSString *)titleNum
                    SuperNum:(NSString *)superNum;
//+ (BOOL)updateDBDataDate:(NSString *)dbName
//                    TitleNum:(NSString *)titleNum
//                    SuperNum:(NSString *)superNum
//                     DateStr:(NSString *)dateStr;
+ (BOOL)insertDataToHistoryRecordDB:(NSString *)dbName
              TitleNum:(NSString *)titleNum
             TitleName:(NSString *)titleName
               IconStr:(NSString *)iconStr
              TitleUrl:(NSString *)titleUrl
               TypeStr:(NSString *)typeStr
               DateStr:(NSString *)dateStr
              SuperNum:(NSString *)superNum
                SubNum:(NSString *)subNum;
+ (int)selectDBHistoryFold:(NSString *)dbName
                           TitleNum:(NSString *)titleNum
                          TitleName:(NSString *)titleName
                            IconStr:(NSString *)iconStr
                           TitleUrl:(NSString *)titleUrl
                            TypeStr:(NSString *)typeStr
                            DateStr:(NSString *)dateStr
                           SuperNum:(NSString *)superNum
                             SubNum:(NSString *)subNum;
+ (NSString *)selectDBHistoryFoldName:(NSString *)dbName
                  TitleNum:(NSString *)titleNum
                 TitleName:(NSString *)titleName
                   IconStr:(NSString *)iconStr
                  TitleUrl:(NSString *)titleUrl
                   TypeStr:(NSString *)typeStr
                   DateStr:(NSString *)dateStr
                  SuperNum:(NSString *)superNum
                    SubNum:(NSString *)subNum;
+ (BOOL)deleteAllDBHistoryFoldName:(NSString *)dbName
                             TitleNum:(NSString *)titleNum
                            TitleName:(NSString *)titleName
                              IconStr:(NSString *)iconStr
                             TitleUrl:(NSString *)titleUrl
                              TypeStr:(NSString *)typeStr
                              DateStr:(NSString *)dateStr
                             SuperNum:(NSString *)superNum
                               SubNum:(NSString *)subNum;
+ (int)getNotQuickDataIndex:(NSString *)path 
                     DBName:(NSString *)dbName;

+ (long) insertOrUpdateNavigation:(NSString *)urlString withTag:(NSUInteger)tag;
+ (void) resetNavigationClickCount:(NSString *)urlString withTag:(NSUInteger)tag;
+ (NSMutableArray *)topFive;
+ (void) createDBVideoHistoryTable;
+ (BOOL)updateDBVideoDataDateCount:(NSString *)dbName
                         TableName:(NSString *)tbName
                          TitleUrl:(NSString *)titleUrl
                          SuperNum:(NSString *)superNum
                            SubNum:(NSString *)subNum;
+ (void) createDBUserMainHomeTable;//用户添加到首页的数据


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
                 DataCount:(NSString *)dataCount;
+ (int)getNotDBVideoDataUrl:(NSString *)dbName
                  TableName:(NSString *)tbName
                  TitleName:(NSString *)titleName
                   TitleUrl:(NSString *)titleUrl;
//自动删除
+ (NSInteger)getTableDataCount:(NSString*)dbName tbName:(NSString*)tableName maxCount:(NSInteger)maxCount isAutoDel:(BOOL)isAutoDel;
@end
