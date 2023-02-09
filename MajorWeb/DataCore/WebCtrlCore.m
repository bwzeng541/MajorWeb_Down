//
//  WebCtrlCore.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebCtrlCore.h"
#import "AppDelegate.h"
#import "FileCache.h"

#define WebMaxCountMark 99
@interface WebCtrlCore()
@property(strong,nonatomic)NSMutableArray *webArray;
@property(strong,nonatomic)NSMutableDictionary *syncMarkInfo;

@property(copy,nonatomic)NSString *syncDir;
@property(copy,nonatomic)NSString *syncConfigFile;
@end

@implementation WebCtrlCore
-(id)init{
    self = [super init];
        self.webArray = [NSMutableArray arrayWithCapacity:10];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncWebToLocal) name:SyncMarkWebNotifi object:nil];
    [self initData];
    return self;
}

-(void)initData{
    self.syncDir = [NSString stringWithFormat:@"%@/%@",AppSynchronizationDir,SyncMarkWebDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.syncDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.syncDir withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    self.syncConfigFile = [NSString stringWithFormat:@"%@%@",self.syncDir,@"markConfig"];
    self.syncMarkInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [[NSFileManager defaultManager] removeItemAtPath:self.syncConfigFile error:nil];
    NSDictionary *tmpInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:self.syncConfigFile];
    if (tmpInfo.count>0) {
        [self.syncMarkInfo setDictionary:tmpInfo];
    }
}

-(NSArray*)getAlllLocalMarkWeb{
    NSArray *arrayKey = [self.syncMarkInfo allKeys];
    [self.webArray removeAllObjects];
    GetAppDelegate.totalWebOpen = 0;
    __weak __typeof(self)weakSelf = self;
    NSArray *testArr = [arrayKey sortedArrayWithOptions:NSSortStable usingComparator:
                        ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                            NSInteger value1 = [[[weakSelf.syncMarkInfo objectForKey:obj1] objectForKey:@"WebTime"] integerValue];
                            NSInteger value2 = [[[weakSelf.syncMarkInfo objectForKey:obj2] objectForKey:@"WebTime"] integerValue];
                            if (value1 < value2) {
                                return NSOrderedDescending;
                            }else if (value1 == value2){
                                return NSOrderedSame;
                            }else{
                                return NSOrderedAscending;
                            }
                        }];
    NSMutableArray *delUUIDArray = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < testArr.count; i++) {
        NSString *webUUID  = [testArr objectAtIndex:i];
         NSDictionary*info = [self.syncMarkInfo objectForKey:webUUID];
        WebConfigItem *config = [info objectForKey:@"webUserConfig"];
        NSArray *webTopArray = [info objectForKey:@"webTopArray"];
        NSString *lastUrl = [info objectForKey:@"WebUrl"];
        NSURL *url = [NSURL URLWithString:lastUrl];
        if (url) {
            ContentWebView *v = [[ContentWebView alloc] initWithSnapshotFrame:[[UIScreen mainScreen] bounds] config:config webUUID:webUUID imageData:[info objectForKey:@"WebImageData"]webTopArray:webTopArray lastUrl:lastUrl];
            [self.webArray addObject:v];
            GetAppDelegate.totalWebOpen++;
        }
        else{
            [delUUIDArray addObject:webUUID];
            NSLog(@"error url loaclMarkWeb");
        }
    }
    for (int i =0; i < delUUIDArray.count; i++) {
        [self remveWebToLocal:[delUUIDArray objectAtIndex:i]];
    }
    return [NSArray arrayWithArray:self.webArray];
}

//同步标签数据
-(void)didEnterBackground:(NSNotification*)object{
    //[self syncWebToLocal];,不同步标签
}

-(void)syncWebToLocal{
    for (int i = 0; i < self.webArray.count; i++) {
        ContentWebView *webView =  (ContentWebView*)[self.webArray objectAtIndex:i];
        if (true) {
            NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [mutableDic setObject:[webView getSnapshotSmallImageData] forKey:@"WebImageData"];
            [mutableDic setObject:[FileCache getNowDate] forKey:@"WebTime"];
            [mutableDic setObject:webView.webTopArray forKey:@"webTopArray"];
            [mutableDic setObject:webView.webUserConfig forKey:@"webUserConfig"];
            if (![NSURL URLWithString:webView.requestUrl]) {
                [mutableDic setObject:@"https://softhome.oss-cn-hangzhou.aliyuncs.com/max/help/360.html" forKey:@"WebUrl"];
            }
            else{
                [mutableDic setObject:webView.requestUrl forKey:@"WebUrl"];
            }
            [self.syncMarkInfo setObject:mutableDic forKey:webView.webUUID];
        }
    }
    [NSKeyedArchiver archiveRootObject:self.syncMarkInfo toFile:self.syncConfigFile];
}

-(void)remveWebToLocal:(NSString*)uuid{
    if ([self.syncMarkInfo objectForKey:uuid]) {
        [self.syncMarkInfo removeObjectForKey:uuid];
        [NSKeyedArchiver archiveRootObject:self.syncMarkInfo toFile:self.syncConfigFile];
    }
}

-(void)clearAllWeb{
    while (self.webArray.count>0) {
        ContentWebView *web = [self.webArray objectAtIndex:0];
        [web removeFromSuperviewAndDesotryWeb];
        [self.webArray removeObject:web];
        GetAppDelegate.totalWebOpen--;
    }
    [self.syncMarkInfo removeAllObjects];
    [NSKeyedArchiver archiveRootObject:self.syncMarkInfo toFile:self.syncConfigFile];
}

-(ContentWebView*)createNewWebView:(WebConfigItem*)webConfig arrayBack:(NSArray**)array{
    if (self.webArray.count>=WebMaxCountMark) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoRemoveWeb" object:nil];
    }
    ContentWebView *v = [[ContentWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds] config:webConfig];
    if (self.webArray.count>0) {//把正在使用的放到WebBoradView上
        *array = [NSArray arrayWithArray:self.webArray];
    }
    [self.webArray addObject:v];
    GetAppDelegate.totalWebOpen++;
    return v;
}

-(void)removeContentWebView:(ContentWebView*)v{
    [v removeFromSuperviewAndDesotryWeb];
    [self remveWebToLocal:v.webUUID];
    [self.webArray removeObject:v];
    GetAppDelegate.totalWebOpen--;
}

-(void)updateFrontWebView:(ContentWebView*)v{
    for(int i = 0;i<self.webArray.count;i++){
        ContentWebView *web = [self.webArray objectAtIndex:i];
        if (web!=v) {
            [web updateShowState:false];
            [web createSnapshotViewOfView:true];
        }
        else{
            [v updateShowState:true];
        }
    }
}

-(void)updateBackWebView:(ContentWebView*)v{
    [v updateShowState:false];
}

@end
