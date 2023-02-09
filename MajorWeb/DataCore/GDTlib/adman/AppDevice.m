//
//  AppDevice.m
//  WatchApp
//
//  Created by zengbiwang on 2018/1/19.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "AppDevice.h"
#import "helpFuntion.h"
#import "MajorSystemConfig.h"
#import "FTWCache.h"
#import <objc/message.h>
#import "Reachability.h"
#import <sys/mount.h>
//app留存处理
#define AppDeviceDataKey @"sfsdfessvdcddkey"
#define Device_Udid @"Udid"
#define Device_Name @"name"
#define Device_Disk @"disk"
#define Device_FreeDisk @"freedisk"
#define Device_MD6      @"md6"//网络标识
#define App_DeVice_index @"DevceIndex"

 NSString* deviceDefaultDisk;
 long long devicefreeDiskSpaceInBytes =-1;

void initDeviceDefalut(){//"attributesOfFileSystemForPath:error:
    NSDictionary *dicInfo = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    NSString *value = [[dicInfo objectForKey:NSFileSystemSize] stringValue];
    if (value) {
        deviceDefaultDisk = [[NSString alloc]initWithString:value];
    }
    if(devicefreeDiskSpaceInBytes<0){
        struct statfs buf;
        if (statfs("/var", &buf) >= 0)
        {
            devicefreeDiskSpaceInBytes = (unsigned long long)(buf.f_bsize * buf.f_bavail);
        }
    }
}

@interface AppDevice()
@property(nonatomic,assign)id gdtStatsMgr;
@property(nonatomic,assign)int deviceIndex;
@property(nonatomic,retain)NSMutableArray *arrayInfo;
@end
@implementation AppDevice
@synthesize deviceUID,deviceName,deviceDisk,deviceMd6,freeDiskSpaceInBytes;
+(AppDevice*)getInstance{
    static AppDevice *g = NULL;
    if (!g && [MajorSystemConfig getInstance].initDeviceIDCount>0) {
        g = [[AppDevice alloc]init];
        [g initData];
    }
    if(!deviceDefaultDisk){
        initDeviceDefalut();
    }
    return g;
}

-(id)init{
    self = [super init];
    return self;
}

-(void)setGDTStatsMgr:(id)g{
    self.gdtStatsMgr = g;
}

//初始化
-(void)initData{
    if (!self.arrayInfo) {
        self.arrayInfo = [[NSMutableArray alloc]initWithCapacity:100];
    }
    [self readFromLocal];
}

-(void)delAllDevice_Key:(NSString*)key{//_ext
    return;
    NSDictionary *allValue = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for(int i = 0;i<allValue.allKeys.count;i++) {
        NSString *keyValue = [allValue.allKeys objectAtIndex:i];
        if ([keyValue rangeOfString:[NSString stringWithFormat:@"%@_ext",key]].location != NSNotFound) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyValue];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)readFromLocal{
    NSData *data = [FTWCache objectForKey:AppDeviceDataKey useKey:YES];
    if (data)
    {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.arrayInfo addObjectsFromArray:array];
    }
    NSInteger ll = self.arrayInfo.count-[MajorSystemConfig getInstance].initDeviceIDCount;
    if (ll<0 && self.arrayInfo.count>0)
    {
        ll *=-1;
        for (int i = 0;i<ll && self.arrayInfo.count>0;i++){
            NSDictionary *info = [self.arrayInfo objectAtIndex: arc4random()%self.arrayInfo.count];
            [self delAllDevice_Key:[info objectForKey:Device_Udid]];
            [self.arrayInfo removeObject:info];
        }
    }
    BOOL ret = [[helpFuntion gethelpFuntion] isValideOneDay:AppDeviceDataKey nCount:1 isUseYYCache:false time:nil];
    if (ret) {//这些需要删除
        for (int i = 0;i<[MajorSystemConfig getInstance].deviceRetention && self.arrayInfo.count>0;i++){
            NSDictionary *info = [self.arrayInfo objectAtIndex: arc4random()%self.arrayInfo.count];
            [self delAllDevice_Key:[info objectForKey:Device_Udid]];
            [self.arrayInfo removeObject:info];
        }
    }
    NSInteger addCount = [MajorSystemConfig getInstance].initDeviceIDCount - self.arrayInfo.count;
    NSArray *levaArray = [NSArray arrayWithArray:self.arrayInfo];
    NSMutableArray *arrayNew = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0;i<addCount; i++) {
        [arrayNew addObject:[self createInfo]];
    }
    //合并数据穿插
    NSMutableArray *arrResult = [NSMutableArray arrayWithCapacity:10];
    int intRstIdx = 0;
    NSArray *arrData = @[levaArray,arrayNew];
    NSInteger intMaxLength = (levaArray.count > arrayNew.count) ? levaArray.count
    : arrayNew.count;
    for (NSInteger i = 0; i < intMaxLength; i++) {
        // 按照需要交错合并的两个数组循环
        for (NSInteger j = 0; j < arrData.count; j++) {
            //如果这个数组还有值，就交错合并
            NSArray *v = arrData[j];
            if (v.count > i) {
                [arrResult addObject:[v objectAtIndex:i]];
                intRstIdx++; // 这句话是新手程序员最容易忘记的一行代码
            }
        }
    }
    //end
    self.arrayInfo = arrResult;
    self.deviceIndex = [[[NSUserDefaults standardUserDefaults]objectForKey:App_DeVice_index] intValue];
    [self saveToLoacl];
    [self isSetMd6];
}


-(void)isSetMd6{//区域网才设置md6
    //    NSLog(@"%d",( != NotReachable));
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi)
    {//创建每个设备的md5
        self.isWiFi = true;
    }
    else{
        self.isWiFi = false;
    }
}

-(NSDictionary*)createInfo{
    CFUUIDRef cfuuid =CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString =(NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    NSString *deviceName = [NSString stringWithFormat:@"%d%d%d",arc4random()%100,arc4random()%100,arc4random()%100];
    //3G->27560554496  128G->127989493760  64G-59417452544
    NSArray *array =@[@"27560554496",@"127989493760",@"59417452544"];
    NSString *deviceDisk = [array objectAtIndex:arc4random()%array.count];
    long long totoal =  [deviceDisk longLongValue];
    NSNumber *freeDiskSpaceInBytes = [NSNumber numberWithLongLong:arc4random()%(totoal/3)+totoal/10];
    return @{Device_Udid:cfuuidString,Device_Disk:deviceDisk,Device_FreeDisk:freeDiskSpaceInBytes,Device_Name:deviceName,Device_MD6:[self createMd6]};
}

-(NSString*)createMd6{
    CFUUIDRef cfuuid =CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString =(NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    cfuuidString = [cfuuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [cfuuidString lowercaseString];
}

-(void)saveToLoacl{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.arrayInfo];
    [FTWCache setObject:data forKey:AppDeviceDataKey useKey:YES];
}

-(void)initReSetDeviceInfo
{
    self.deviceIndex = (self.deviceIndex+1)%self.arrayInfo.count;
    if (self.deviceIndex<self.arrayInfo.count) {
        NSDictionary *info = [self.arrayInfo objectAtIndex:self.deviceIndex];
        deviceUID = [[NSString alloc]initWithString:[info objectForKey: Device_Udid]];
        deviceName = [[NSString alloc]initWithString:[info objectForKey: Device_Name]];
        deviceDisk = [[NSString alloc]initWithString:[info objectForKey: Device_Disk]];
        deviceMd6 = [[NSString alloc]initWithString:[info objectForKey: Device_MD6]];
        freeDiskSpaceInBytes = [[info objectForKey:Device_FreeDisk] longLongValue];
        printf("deviceUID = %s\n",[deviceUID UTF8String]);
    }
    else{
        deviceUID = nil;;
        deviceName = nil;
        deviceDisk = 0;
        freeDiskSpaceInBytes = 0;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.deviceIndex] forKey:App_DeVice_index];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.gdtStatsMgr) {
        NSMethodSignature *sig=[NSClassFromString(@"GDTStatsMgr") instanceMethodSignatureForSelector:@selector(initializeData)];
        NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:self.gdtStatsMgr];
        [invocation setSelector:@selector(initializeData)];
        [invocation invoke];//强制更新一次
    }
}
@end
