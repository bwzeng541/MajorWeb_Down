//
//  QRDataManager.m
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/16.
//  Copyright © 2020 cxh. All rights reserved.
//

#import "QRDataManager.h"

static QRDataManager *__qrDataManager;

#define QRDataReamlFileDir [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"ReamlDir"]

#define QRRRecordEdit

NSString *QRRRecordCreateKey = @"QRRRecordCreateKey";
NSString *QRRRecordScanKey = @"QRRRecordScanKey";
NSString *QRWebFavRecordScanKey = @"QRWebFavRecordScanKey";
NSString *QRWebHistoryRecordScanKey = @"QRWebHistoryRecordScanKey";
NSString *QRFileCacheRecordKey = @"QRFileCacheRecordKey";
NSString *QRMediaRecordKey = @"QRMediaRecordKey";
NSString *QRMediaFarivteKey = @"QRMediaFarivteKey";
NSString *QRSearchWordRecordKey = @"QRSearchWordRecordKey";
NSString *QRWatchRecordKey = @"QRWatchRecordKey";

@interface QRDataManager()
@property(nonatomic,strong)NSMutableDictionary *rRDataRealmInfo;
@end
@implementation QRDataManager
+(QRDataManager*)shareInstance{
     static dispatch_once_t oneToken;
        dispatch_once(&oneToken, ^{
            __qrDataManager = [[QRDataManager alloc]init];
        });
        return __qrDataManager;
}

+ (instancetype)alloc {
    NSCAssert(!__qrDataManager, @"QRDataManager类只能初始化一次");
  return [super alloc];
}

-(id)init{
    self = [super init];
    self.rRDataRealmInfo = [NSMutableDictionary dictionary];
    if (![[NSFileManager defaultManager]fileExistsAtPath:QRDataReamlFileDir]) {
          [[NSFileManager defaultManager] createDirectoryAtPath:QRDataReamlFileDir withIntermediateDirectories:NO attributes:nil error:nil];
      }
    if (![[NSFileManager defaultManager]fileExistsAtPath:QRFileCacheDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:QRFileCacheDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return self;
}

 

 
-(void)delAllQRRecord:(NSString*)realmKey
{
    RLMRealm *realm = [self getRealmFromKey:realmKey];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

-(RLMRealm*)getRealmFromKey:(NSString*)key{
    RLMRealm *realm = [self.rRDataRealmInfo objectForKey:key];
    if (!realm) {
        realm = [self creatDataBaseWithName:key];
        [self.rRDataRealmInfo setObject:realm forKey:key];
    }
    return realm;
}


- (RLMRealm*)creatDataBaseWithName:(NSString *)databaseName
{
    NSString *path = QRDataReamlFileDir;
    NSString *filePath = [path stringByAppendingPathComponent:databaseName];
    NSLog(@"数据库目录 = %@",filePath);
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [NSURL URLWithString:filePath];
    config.readOnly = NO;
    int currentVersion = 1.0;
    config.schemaVersion = currentVersion;
    config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {
        // 这里是设置数据迁移的block
        if (oldSchemaVersion < currentVersion) {
        }
    };
    return [RLMRealm realmWithConfiguration:config
                                      error:nil];
}


-(RLMResults*)getSearchWordRecord{
    RLMRealm *realm = [self getRealmFromKey:QRSearchWordRecordKey];
     [realm beginWriteTransaction];
    RLMResults *array = [QRSearhWord allObjectsInRealm:realm];
    array = [array sortedResultsUsingKeyPath:@"serialNumber" ascending:NO];
    [realm commitWriteTransaction];
    return array;
}

-(NSArray*)getSearchRecord:(NSString*)word{
    NSArray *ret = nil;
    RLMRealm *realm = [self getRealmFromKey:QRSearchWordRecordKey];
    NSString *where = [NSString stringWithFormat:@"uuid='%@'",[QRCommon md5From:word]];
    [realm beginWriteTransaction];
    RLMResults *ss = [QRSearhWord objectsInRealm:realm where:where];
    if (ss.count>0) {
        QRSearhWord *t = ss[0];
        NSMutableArray *aa = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i<t.array.count; i++) {
           QRWordItem *item = t.array[i];
            [aa addObject:@{@"url":item.url,@"bgUrl":item.bgUrl,@"name":item.name?item.name:@""}];
        }
        ret=[NSArray arrayWithArray:aa];
    }
    [realm commitWriteTransaction];
    return ret;
}

-(void)delSearchRecord:(NSString*)word{
    RLMRealm *realm = [self getRealmFromKey:QRSearchWordRecordKey];
    NSString *where = [NSString stringWithFormat:@"uuid='%@'",[QRCommon md5From:word]];
    [realm beginWriteTransaction];
    [realm deleteObjects:[QRSearhWord objectsInRealm:realm where:where]];
    [realm commitWriteTransaction];
}

-(void)addSearchRecord:(NSString*)word array:(NSArray*)array{
    RLMRealm *realm=[self getRealmFromKey:QRSearchWordRecordKey];
       NSString *where = [NSString stringWithFormat:@"uuid='%@'",[QRCommon md5From:word]];
       [realm transactionWithBlock:^{
           RLMResults *results = [QRSearhWord objectsInRealm:realm where:where];
           QRSearhWord *v = nil;
           if(results.count>0){
               v = results[0];
           }
           else{
               v = [QRSearhWord buildQRSearhWord:word];
               [v.array removeAllObjects];
           }
           for (int i = 0; i < array.count; i++) {
                             QRWordItem *itme = [[QRWordItem alloc] init];
                             itme.bgUrl = [array[i] objectForKey:@"bgUrl"];
                             itme.url = [array[i] objectForKey:@"url"];
                             itme.name = [array[i] objectForKey:@"name"];
                             [v.array addObject:itme];
                         }
           [realm addOrUpdateObject:v];
       }];
}

 

 
@end
