//
//  MajorWebConfig.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/27.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MarjorWebConfig.h"
#import "FileCache.h"
#import "FMDatabase.h"
#import "SqliteInterface.h"
#import "AppDelegate.h"
#import "Record.h"
#import "MajorICloudSync.h"
#define T_OSVersion ([[UIDevice currentDevice].systemVersion floatValue])
#define T_IS_ABOVE_IOS(v) (T_OSVersion >= v)

#define MaxSearchCount 20
@interface MarjorWebConfig()
@property(nonatomic,strong)NSMutableDictionary *disOpenAppStoreInfo;
@property(nonatomic,strong)NSMutableArray *searchHotsArray;
@property(nonatomic,strong)NSMutableDictionary *appConfigInfo;
@end
@implementation MarjorWebConfig
+(MarjorWebConfig*)getInstance{
    static MarjorWebConfig *g = nil;
    if (!g) {
        g = [[MarjorWebConfig alloc] init];
    }
    return g;
}

-(NSArray*)getSearchHotsArray{
    return  [NSArray arrayWithArray:self.searchHotsArray];
}

-(void)addSearchHots:(NSString*)key{
    NSURL *url = [NSURL URLWithString:key];
    if (url) {
        return;
    }
    if (self.searchHotsArray.count>MaxSearchCount) {
        [self.searchHotsArray removeLastObject];
    }
    for (int i = 0; i < self.searchHotsArray.count; i++) {
        Record *record = [self.searchHotsArray objectAtIndex:i];
        if ([record.titleName compare:key]==NSOrderedSame) {
            return;
        }
    }
    Record *record = [[Record alloc] init];
    record.titleName = key;
    record.iconStr = @"dzltb3.png";
    record.titleUrl= @"";
    record.typeStr = @"";
    if (self.searchHotsArray.count==0) {
        [self.searchHotsArray addObject:record];
    }
    else{
        [self.searchHotsArray insertObject:record atIndex:0];
    }
    [NSKeyedArchiver archiveRootObject:self.searchHotsArray toFile:WebHotsHistory];
}

-(id)init{
    self = [super init];
    [self initConfig];
    @weakify(self)
    [RACObserve(self,updateConfig) subscribeNext:^(id x) {
        @strongify(self)
        [self updateConfigLocal];
     }];
    [RACObserve(self,isOpenLocaNotifi) subscribeNext:^(id x) {
        if (self.isOpenLocaNotifi) {
         [GetAppDelegate setEveryDataLocadNotifi:@"21:05:00" textArray:[NSArray arrayWithObjects:@"电影更新了~快来",@"电视剧有新片哟",@"今天撸一撸",@"视频下载完成",@"电影已经下载完成", nil]];
        }
        else{
            [GetAppDelegate cancelAllLocadNotifi];
        }
    }];
    return self;
}

-(void)initConfig{
    NSDictionary *defaluts = [NSDictionary dictionaryWithContentsOfFile:AppConfigFilePath];
    self.appConfigInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    if (defaluts) {
        [self.appConfigInfo setDictionary:defaluts];
    }
    id value1 = [self.appConfigInfo objectForKey:@"app_autoplay_key"];
    id value2 = [self.appConfigInfo objectForKey:@"app_isSuspensionMode_key"];
    if (value1&&value2) {
        self.isAutoPlay = [value1 boolValue];
        self.isSuspensionMode = [value2 boolValue];
    }
    else{
       self.isSuspensionMode = self.isAutoPlay = true;
    }
    self.isSuspensionMode = self.isAutoPlay = true;
   // printf("self.isSuspensionMode = %ld\n",self.isSuspensionMode);
    id vaule3 = [self.appConfigInfo objectForKey:@"app_isRemoveAd_key"];
    if (vaule3) {
        self.isRemoveAd = [vaule3 boolValue];
    }
    else{
        self.isRemoveAd = YES;
    }
    vaule3 = [self.appConfigInfo objectForKey:@"app_isSyncICloud_key"];
    if (vaule3) {
        self.isSyncICloud = [vaule3 boolValue];
    }
    else{
        self.isSyncICloud = NO;
    }
    
    if (@available(iOS 11.0, *)) {
    }
    else{
        self.isRemoveAd = false;
    }
    
    vaule3 = [self.appConfigInfo objectForKey:@"app_isPlayVideoAutoRotate_key"];
    if (vaule3) {
        self.isPlayVideoAutoRotate = [vaule3 boolValue];
    }
    else{
        self.isPlayVideoAutoRotate = true;
    }
    self.isAllowsBackForwardNavigationGestures = [[self.appConfigInfo objectForKey:@"app_isAllowsBackForwardNavigationGestures_key"] boolValue];
    
    vaule3 = [self.appConfigInfo objectForKey:@"app_isAllowsAutoCachesVideoWhenPlay_key"];
    if (vaule3) {
        self.isAllowsAutoCachesVideoWhenPlay = [vaule3 boolValue];
    }
    else{
        self.isAllowsAutoCachesVideoWhenPlay = true;
    }
    
    vaule3 = [self.appConfigInfo objectForKey:@"app_isAllowsBackGroundDownMode_key"];
    if (vaule3) {
        self.isAllowsBackGroundDownMode = [vaule3 boolValue];
    }
    else{
        self.isAllowsBackGroundDownMode = true;
    }
    
    vaule3 = [self.appConfigInfo objectForKey:@"app_isAllows4GDownMode_key"];
    if (vaule3) {
        self.isAllows4GDownMode = [vaule3 boolValue];
    }
    else{
        self.isAllows4GDownMode = false;
    }
    
    id vaule4 = [self.appConfigInfo objectForKey:@"app_isCanReadMode_key"];
    if (vaule4) {
        self.isCanReadMode = [ vaule4 boolValue];
    }
    self.isNightMode = [[self.appConfigInfo objectForKey:@"app_isNightMode_key"] boolValue];
#if DEBUG
    self.isBackClear = true;
#else
    self.isBackClear = true;
#endif
    NSNumber *number =  [self.appConfigInfo objectForKey:@"app_isShowPicMode_key"];
    if(number){
        self.isShowPicMode = [number boolValue];
    }
    else{
        self.isShowPicMode = true;
    }
    self.isScaleWeb = [[self.appConfigInfo objectForKey:@"app_isScaleWeb_key"] boolValue];
    
    self.disOpenAppStoreInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    id value =  [self.appConfigInfo objectForKey:@"disOpenAppStoreInfo"];
    if (value) {
        [self.disOpenAppStoreInfo setDictionary:value];
    }
    BOOL boolValue = true;
    value = [self.appConfigInfo objectForKey:@"app_isOpenLocaNotifi_key"];
    if (value) {
        boolValue = [ value boolValue];
    }
    value = [self.appConfigInfo objectForKey:@"app_webFontSize_key"];
    if (value) {
        _webFontSize = [ value integerValue];
    }
    else{
        _webFontSize = 100;
    }
    
    value = [self.appConfigInfo objectForKey:@"app_isCleanMode_key"];
    if (value) {
        _isCleanMode = [ value boolValue];
    }
    else{
        _isCleanMode = false;
    }
    
    self.isOpenLocaNotifi = boolValue;
    self.overHeadKey = [self.appConfigInfo objectForKey:@"app_OverHeadKey_key"];
    self.searchHotsArray = [NSMutableArray arrayWithCapacity:10];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:WebHotsHistory];
    if (array.count>0) {
        [self.searchHotsArray addObjectsFromArray:array];
    }
}

-(void)updateConfigLocal{
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isAutoPlay] forKey:@"app_autoplay_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isRemoveAd] forKey:@"app_isRemoveAd_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isNightMode] forKey:@"app_isNightMode_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isSuspensionMode] forKey:@"app_isSuspensionMode_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isShowPicMode] forKey:@"app_isShowPicMode_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isScaleWeb] forKey:@"app_isScaleWeb_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isCanReadMode] forKey:@"app_isCanReadMode_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isPlayVideoAutoRotate] forKey:@"app_isPlayVideoAutoRotate_key"];
    [self.appConfigInfo setObject:[NSNumber numberWithBool:_isAllowsAutoCachesVideoWhenPlay] forKey:@"app_isAllowsAutoCachesVideoWhenPlay_key"];
    [self.appConfigInfo setObject:[NSNumber numberWithBool:_isAllowsBackGroundDownMode] forKey:@"app_isAllowsBackGroundDownMode_key"];
    [self.appConfigInfo setObject:[NSNumber numberWithBool:_isAllowsBackForwardNavigationGestures] forKey:@"app_isAllowsBackForwardNavigationGestures_key"];
    [self.appConfigInfo setObject:[NSNumber numberWithBool:_isAllows4GDownMode] forKey:@"app_isAllows4GDownMode_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isSyncICloud] forKey:@"app_isSyncICloud_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithBool:_isOpenLocaNotifi] forKey:@"app_isOpenLocaNotifi_key"];
   [self.appConfigInfo setObject:[NSNumber numberWithInteger:_webFontSize] forKey:@"app_webFontSize_key"];
    [self.appConfigInfo setObject:[NSNumber numberWithBool:_isCleanMode] forKey:@"app_isCleanMode_key"];
    
    if (self.overHeadKey) {
        [self.appConfigInfo setObject:self.overHeadKey forKey:@"app_OverHeadKey_key"];
    }
   [self.appConfigInfo writeToFile:AppConfigFilePath atomically:YES];
}

+(void)isUrlValid:(NSString*)urlString callBack:(void(^)(BOOL validValue, NSString *result))callBack
{
    NSString *tempUrl = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *regex = [NSString
                       stringWithFormat:
                       @"%@%@%@%@%@%@%@%@%@%@", @"^((https|http|ftp|rtsp|mms)?://)",
                       @"?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?",
                       @"(([0-9]{1,3}\\.){3}[0-9]{1,3}", @"|", @"([0-9a-zA-Z_!~*'()-]+\\.)*",
                       @"([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\.", @"[a-zA-Z]{2,6})",
                       @"(:[0-9]{1,4})?", @"((/?)|",
                       @"(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"];
    if ([tempUrl hasPrefix:@"http://"] || [tempUrl hasPrefix:@"https://"])
    {
        if ([tempUrl isMatchedByRegex:regex]) {
            callBack(YES,tempUrl);
        }
        else
        {
            callBack(NO,tempUrl);
        }
    }
    else
    {
        NSString *result = [NSString stringWithFormat:@"http://%@",tempUrl];
        if ([result isMatchedByRegex:regex]) {
            callBack(YES, result);
        }
        else
        {
            callBack(NO, tempUrl);
        }
    }
}

+(void)addFavorite:(NSString*)_title iconUrl:(NSString*)iconUrl  requestUrl:(NSString*)_requestUrl{
    NSString *title= _title;
    NSString *url = _requestUrl;
    int urlCount = [FileCache getNotDBDataUrl:KEY_DATENAME TableName:KEY_TABLE_LOCAL TitleName:title TitleUrl:url];
    int nameCount = [FileCache getNotDBDataName:KEY_DATENAME TableName:KEY_TABLE_LOCAL TitleName:title TitleUrl:url];
    if (nameCount == 0 || urlCount == 0) {
        int titleNum = [FileCache getNotDBDataIndex:nil DBName:KEY_DATENAME TableName:KEY_TABLE_LOCAL];
        NSString *titleStr = [NSString stringWithFormat:@"%i", titleNum];
        NSString *dateStr = [FileCache getNowDate];
        BOOL flag = [FileCache insertDataToDB:KEY_DATENAME TableName:KEY_TABLE_LOCAL TitleNum:titleStr TitleName:title IconStr:iconUrl TitleUrl:url TypeStr:@"" DateStr:dateStr SuperNum:@"0" SubNum:@"0" DataCount:@"0"];
        if (flag) {
            GetAppDelegate.isFavoriteUpdate = !GetAppDelegate.isFavoriteUpdate;
        }
        else {
            
        }
    } else {
        if (nameCount != 0 && urlCount == 0) {
            [[UIApplication sharedApplication].keyWindow makeToast:@"该网页已添加" duration:1.5 position:@"center"];
        }
        else {
            [[UIApplication sharedApplication].keyWindow makeToast:@"该网页已添加" duration:1.5 position:@"center"];
        }
    }
}

+ (void)updateDB:(NSString *)theTitle withFavicon:(NSString *)ico withUrl:(NSString *)strUrl {//无痕模式这里是
    if ([MarjorWebConfig getInstance].isCleanMode) {
        return;
    }
    if ([strUrl rangeOfString:@".apk"].location != NSNotFound || [strUrl rangeOfString:@".ipa"].location != NSNotFound) {
        NSLog(@"%s-> %@",__FUNCTION__,strUrl);
        return;
    }
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (theTitle == nil || theTitle.length == 0 || strUrl == nil || strUrl.length == 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:strUrl forKey:@"lastUrl20191226"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    int count = [FileCache getNotDBDataUrl:KEY_DATENAME TableName:KEY_TABLE_HISRECORD TitleName:nil TitleUrl:strUrl];
    if (count == 0) {
        int num = [FileCache getNotDBDataIndex:nil DBName:KEY_DATENAME TableName:KEY_TABLE_HISRECORD];
        NSString *titleStr = [NSString stringWithFormat:@"%i", num];
        NSString *dateStr = [FileCache getNowDate];
        [FileCache insertDataToDB:KEY_DATENAME TableName:KEY_TABLE_HISRECORD TitleNum:titleStr TitleName:theTitle IconStr:ico TitleUrl:strUrl TypeStr:@"" DateStr:dateStr SuperNum:@"0" SubNum:@"0" DataCount:@"0"];
        
    } else {
        NSString *strDate = [FileCache getNowDate];
        [FileCache updateDBDataDate:KEY_DATENAME TableName:KEY_TABLE_HISRECORD TitleUrl:strUrl DateStr:strDate];
    }
    count = [FileCache getNotDBDataUrl:KEY_DATENAME TableName:KEY_TABLE_REVISIT TitleName:nil TitleUrl:strUrl];
    if (count == 0) {
        int num = [FileCache getNotDBDataIndex:nil DBName:KEY_DATENAME TableName:KEY_TABLE_REVISIT];
        NSString *titleStr = [NSString stringWithFormat:@"%i", num];
        NSString *dateStr = [FileCache getNowDate];
        [FileCache insertDataToDB:KEY_DATENAME TableName:KEY_TABLE_REVISIT TitleNum:titleStr TitleName:theTitle IconStr:ico TitleUrl:strUrl TypeStr:@"" DateStr:dateStr SuperNum:@"0" SubNum:@"0" DataCount:@"1"];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
    } else {
        count = [FileCache getDBDateCount:KEY_DATENAME TableName:KEY_TABLE_REVISIT TitleUrl:strUrl DateStr:nil];
        count++;
        NSString *strCount = [NSString stringWithFormat:@"%i", count];
        [FileCache updateDBDataDateCount:KEY_DATENAME TableName:KEY_TABLE_REVISIT TitleUrl:strUrl DataCount:strCount];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
    }
}

+ (NSString*)getLastHistoryUrl{

    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *strSql = [NSString stringWithFormat:@"%@%@%@%@%@", @"SELECT * FROM ", KEY_TABLE_HISRECORD, @" WHERE TitleUrl like '%", @"", [NSString stringWithFormat:@"%%' order by dateStr desc limit 0,%i ",1]];
    FMResultSet *rs = [dbo executeQuery:strSql, strSql];
    //NSLog(@"%@  cccccccc",strSql);
    NSString *retuUrl = nil;
    while ([rs next]) {
        retuUrl = [rs stringForColumn:@"titleUrl"];
    }
    [rs close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return retuUrl;
}

+ (NSArray*)getVideoHistoryAndUserTableData:(NSString*)tableName
{
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:1];
    [[SqliteInterface sharedSqliteInterface] setupDB:KEY_DATENAME];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@ order by DateStr DESC ", tableName];
    FMResultSet *rs = [dbo executeQuery:selectSql];
    while ([rs next]) {
        Record *record = [[Record alloc] init];
        record.titleNum = [NSString stringWithFormat:@"%i", [rs intForColumn:@"titleNum"]];
        record.titleName = [rs stringForColumn:@"titleName"];
        record.iconStr = [rs stringForColumn:@"iconStr"];
        record.titleUrl = [rs stringForColumn:@"titleUrl"];
        record.typeStr = [NSString stringWithFormat:@"%i", [rs intForColumn:@"typeStr"]];
        record.dateStr = [rs stringForColumn:@"dateStr"];
        record.superNum = [NSString stringWithFormat:@"%i", [rs intForColumn:@"superNum"]];
        record.subNum = [NSString stringWithFormat:@"%i", [rs intForColumn:@"subNum"]];
        record.dataCount = [NSString stringWithFormat:@"%i", [rs intForColumn:@"DataCount"]];
        record.webUrl = [rs stringForColumn:@"webUrl"];
        [arrayRet addObject:record];
    }
    [rs close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return arrayRet;
}

+ (NSArray*)getFavoriteOrHistroyData:(BOOL)isHistory{
    NSString *tableName = KEY_TABLE_HISRECORD;
    if (!isHistory) {
        tableName = KEY_TABLE_LOCAL;
    }
    [[SqliteInterface sharedSqliteInterface] setupDB:KEY_DATENAME];
    [[SqliteInterface sharedSqliteInterface] connectDB];
    FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@ order by DateStr DESC ", tableName];
    FMResultSet *rs = [dbo executeQuery:selectSql];
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:1];
    while ([rs next]) {
        Record *record = [[Record alloc] init];
        record.titleNum = [NSString stringWithFormat:@"%i", [rs intForColumn:@"titleNum"]];
        record.titleName = [rs stringForColumn:@"titleName"];
        record.iconStr = [rs stringForColumn:@"iconStr"];
        record.titleUrl = [rs stringForColumn:@"titleUrl"];
        record.typeStr = [NSString stringWithFormat:@"%i", [rs intForColumn:@"typeStr"]];
        record.dateStr = [rs stringForColumn:@"dateStr"];
        record.superNum = [NSString stringWithFormat:@"%i", [rs intForColumn:@"superNum"]];
        record.subNum = [NSString stringWithFormat:@"%i", [rs intForColumn:@"subNum"]];
        record.dataCount = [NSString stringWithFormat:@"%i", [rs intForColumn:@"DataCount"]];
        [arrayRet addObject:record];
    }
    [rs close];
    [[SqliteInterface sharedSqliteInterface] closeDB];
    return [NSArray arrayWithArray:arrayRet];
}

-(void)removeSearchHots{
    [self.searchHotsArray removeAllObjects];
    [NSKeyedArchiver archiveRootObject:self.searchHotsArray toFile:WebHotsHistory];
}

+(void)clearAllCache{
        NSString *iosVer;
        __block NSString *ms = @"清除列表:\n";
        if (T_IS_ABOVE_IOS(9)) {
            iosVer = @"iOS 9+";
            WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
            [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                             completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                                 for (WKWebsiteDataRecord *record  in records) {
                                     //取消备注，可以针对某域名清除，否则是全清
                                     //if (![record.displayName containsString:@"baidu"]) {
                                     //    continue;
                                     //}
                                     ms = [ms stringByAppendingString:[NSString stringWithFormat:@"%@\n", record.displayName]];
                                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                               forDataRecords:@[record]
                                                                            completionHandler:^{
                                                                                NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                            }];
                                 }
                              }];
        } else if (T_IS_ABOVE_IOS(8)){
            iosVer = @"iOS 8";
            NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath
                                                       error:&error];
            if (error != nil) {
                NSLog(@"%@", error);
            }
        
        } else {
            // ios 7
            iosVer = @"iOS 7";
            ms = [ms stringByAppendingString:[NSString stringWithFormat:@"[[NSURLCache sharedURLCache] removeAllCachedResponses]\ncookies:\n"]];
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [storage cookies]) {
                ms = [ms stringByAppendingString:[NSString stringWithFormat:@"%@\n", cookie.name]];
                [storage deleteCookie:cookie];
            }
            [[NSURLCache sharedURLCache] removeAllCachedResponses];//清除缓存
        }
}

-(BOOL)isCanOpenInAppStore:(NSString*)host{
    if ([self.disOpenAppStoreInfo objectForKey:host])
    {
        return true;
    }
    return false;
}

-(void)addOpenInAppStoreDisable:(NSString*)host{
    [self.disOpenAppStoreInfo setObject:@"1" forKey:host];
    [self.appConfigInfo setObject:self.disOpenAppStoreInfo forKey:@"disOpenAppStoreInfo"];
    [self.appConfigInfo writeToFile:AppConfigFilePath atomically:YES];
}

-(void)removeOpenInAppStoreDisable:(NSString*)host{
    [self.disOpenAppStoreInfo removeObjectForKey:host];
    [self.appConfigInfo setObject:self.disOpenAppStoreInfo forKey:@"disOpenAppStoreInfo"];
    [self.appConfigInfo writeToFile:AppConfigFilePath atomically:YES];
}

+(void)saveUserHomeMain:(NSString *)strUrl theTitle:(NSString*)theTitle  webUrl:(NSString *)webUrl{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FileCache createDBUserMainHomeTable];
    });
    int count = [FileCache getNotDBVideoDataUrl:KEY_DATENAME TableName:KEY_TABEL_USERMAINHOME TitleName:theTitle TitleUrl:[[strUrl componentsSeparatedByString:@"?"] firstObject]];
    if (count == 0) {
        NSInteger count = [FileCache getTableDataCount:KEY_DATENAME tbName:KEY_TABEL_USERMAINHOME maxCount:12 isAutoDel:true];
        int num = [FileCache getNotDBDataIndex:nil DBName:KEY_DATENAME TableName:KEY_TABEL_USERMAINHOME];
        NSString *titleStr = [NSString stringWithFormat:@"%i", num];
        NSString *dateStr = [FileCache getNowDate];
        
        [FileCache insertBaseDataToDB:KEY_DATENAME TableName:KEY_TABEL_USERMAINHOME TitleNum:titleStr TitleName:theTitle IconStr:@"" TitleUrl:strUrl WebUrl:webUrl TypeStr:@"" DateStr:dateStr SuperNum:@"0" SubNum:@"0" DataCount:@"0"];
        GetAppDelegate.isUserMainHomeUpdate = !GetAppDelegate.isUserMainHomeUpdate;
        
    } else {
        //[FileCache updateDBVideoDataDateCount:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY TitleUrl:strUrl SuperNum:@"0" SubNum:@"0"];
    }
}

#pragma mark video
+(void)saveVideoHistory:(NSString *)strUrl theTitle:(NSString*)theTitle videoImg:(NSString*)videoImg webUrl:(NSString *)webUrl{
    if ([MarjorWebConfig getInstance].isCleanMode) {
        return;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FileCache createDBVideoHistoryTable];
    });
    int count = [FileCache getNotDBVideoDataUrl:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY TitleName:theTitle TitleUrl:[[strUrl componentsSeparatedByString:@"?"] firstObject]];
    if (count == 0) {
        int num = [FileCache getNotDBDataIndex:nil DBName:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY];
        NSString *titleStr = [NSString stringWithFormat:@"%i", num];
        NSString *dateStr = [FileCache getNowDate];
        
        [FileCache insertBaseDataToDB:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY TitleNum:titleStr TitleName:theTitle IconStr:videoImg TitleUrl:strUrl WebUrl:webUrl TypeStr:@"" DateStr:dateStr SuperNum:@"0" SubNum:@"0" DataCount:@"0"];
        GetAppDelegate.isVideoHistoryUpdate = !GetAppDelegate.isVideoHistoryUpdate;
        
    } else {
        //[FileCache updateDBVideoDataDateCount:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY TitleUrl:strUrl SuperNum:@"0" SubNum:@"0"];
    }
}


+(id)convertIdFromNSString:(NSString*)msg type:(NSInteger)type
{
    NSString*file = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"tmp"];
    [msg writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if(type==0){
        NSArray *tmpe = [NSArray arrayWithContentsOfFile:file];
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        return tmpe;
    }
    
#if 1
    NSDictionary *tmpe = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ggtmpdel" ofType:@"plist"]];
    return tmpe;
#else
    NSDictionary *tmpe = [NSDictionary dictionaryWithContentsOfFile:file];
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    return tmpe;
#endif
    return nil;
}

+(BOOL)isValid:(NSString*)a1 a2:(NSString*)a2{
    if (!a1 || !a2) {
        return false;
    }
    NSInteger currentTime =  [[NSDate new] hour];
    NSInteger begTime = [a1 integerValue];
    NSInteger endTime = [a2 integerValue];
    
    BOOL isVaild = false;
    if (begTime>endTime) {//是晚上这里到凌晨
        if (currentTime>=begTime || currentTime<endTime) {
            isVaild =  true;
        }
    }
    else {//早上到晚上
        if(currentTime>=begTime && currentTime<endTime){
            isVaild = true;
        }
    }
    return isVaild;
}
@end
