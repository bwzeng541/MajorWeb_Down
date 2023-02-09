//
//  QRDataManager.h
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/16.
//  Copyright © 2020 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRRecord.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *QRRRecordCreateKey ;
extern NSString *QRRRecordScanKey ;
extern NSString *QRWebFavRecordScanKey ;
extern NSString *QRWebHistoryRecordScanKey ;
extern NSString *QRFileCacheRecordKey;
extern NSString *QRMediaRecordKey;
extern NSString *QRMediaFarivteKey;
extern NSString *QRSearchWordRecordKey;
extern NSString *QRWatchRecordKey;
#define QRError404Html @"QRToolsHtml.bundle/404.html"
#define QRFileCacheDirName @"QRFileCache"
#define QRFileCacheDir [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0],QRFileCacheDirName]


@interface QRDataManager : NSObject
+(QRDataManager*)shareInstance;
//-(void)addQRRecord:(QRRecord*)record realmKey:(NSString*)realmKey;
//-(void)delQRRecord:(QRRecord*)record realmKey:(NSString*)realmKey;
//
 //网页相关
//-(void)addQRWebRecord:(QRWebRecord*)record realmKey:(NSString*)realmKey;
//-(void)delQRWebRecord:(QRWebRecord*)record realmKey:(NSString*)realmKey;

//文件下载相关
//-(void)updateFileRecord:(QRFileRecord*)record fileName:(NSString*)fileName suffix:(NSString*)suffix fileProgress:(NSString*)fileProgress fileState:(NSInteger)fileState netState:(NSInteger)netState;
//-(void)addQRFileRecord:(QRFileRecord*)record realmKey:(NSString*)realmKey;
//-(void)delQRFileRecord:(QRFileRecord*)record realmKey:(NSString*)realmKey;

//视频历史记录
//-(void)addQRMedia:(QRMedia*)record isHistory:(BOOL)isHistory ;
//-(void)delQRMedia:(QRMedia*)record isHistory:(BOOL)isHistory;

//host->jshe url
-(RLMResults*)getSearchWordRecord;
-(NSArray*)getSearchRecord:(NSString*)host;
-(void)delSearchRecord:(NSString*)host;
-(void)addSearchRecord:(NSString*)host array:(NSArray*)array;

 
 
@end

NS_ASSUME_NONNULL_END
