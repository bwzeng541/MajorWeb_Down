//
//  AppWtManager.m
//  WatchApp
//
//  Created by zengbiwang on 2018/6/11.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "AppWtManager.h"
#import <objc/message.h>
#import "AppDelegate.h"
#import "FileDonwPlus.h"
#import "HTTPServer.h"
static HTTPServer * httpServer = nil;
static BOOL _isStartHttpService = false;

@implementation AppWtManager

+(AppWtManager*)getInstanceAndInit{
    static AppWtManager *g = nil;
    if (!g) {
        g = [[AppWtManager alloc]init];
    }
    return g;
}

- (void)initHttpService{
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self createNeedDir];

#if (TsFilesCanConCatMovFile==0)
    httpServer = [[HTTPServer alloc] init];
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:LOCAHOSET_SERVICE_PORT];
    
    // Serve files from our embedded Web folder
    NSString *webPath =  HTTPSERVICEROOTPATH;
    //;[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];//
    //
    [httpServer setDocumentRoot:webPath];
    
    // Start the server (and check for problems)
    
    NSError *error;
    if(![httpServer start:&error])
    {
        _isStartHttpService = FALSE;
        NSLog(@"Error starting HTnonatomic, TP Server: %@", error);
    }
    else{
        _isStartHttpService = TRUE;
    }
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkHttpService) userInfo:nil repeats:YES];
#endif
}

- (void)checkHttpService{
    if (![httpServer isRunning]) {
        NSError *error;
        if(![httpServer start:&error])
        {
            _isStartHttpService = FALSE;
            NSLog(@"Error starting HTTP Server: %@", error);
        }
        else{
            _isStartHttpService = TRUE;
        }
    }
    else {
        NSLog(@"%s httpService = ok",__FUNCTION__);
    }
}

-(id)init{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceWtNotifi:) name:@"PostWtNotifi" object:nil];
    [self initHttpService];
    return self;
}


-(void)reviceWtNotifi:(NSNotification*)object{
    NSDictionary *info = object.object;
    [self getWtCallBack:info];
}

-(id)getWtCallBack:(NSDictionary*)info{
    return nil;/*
    id result = nil;
//    NSLog(@"getWtCallBack info = %@",info);
    if (info) {
        [info retain];
        NSString *param1 =  [info objectForKey:@"param1"];//class name
        NSString *param2 =  [info objectForKey:@"param2"];//funtion name //单例函数必须getInstance字符串
        NSString *param3 =  [info objectForKey:@"param3"];//funtion name //函数名字
        NSArray  *param4 =  [info objectForKey:@"param4"];//参数数组
        SEL sel = NSSelectorFromString(param2);
        Class clazz = NSClassFromString(param1);
        if(!clazz)return nil;
        IMP imp = [clazz methodForSelector:sel];
        id resultob = imp(clazz,sel);
        if (!param3){    [info release];return nil;}        
        SEL  selector = NSSelectorFromString(param3);
        NSMethodSignature *signature = [clazz instanceMethodSignatureForSelector:selector];

        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = resultob;
        invocation.selector = selector;
        for (NSInteger i = 0; i < param4.count; i++) {
            id obj = param4[i];
            if ([obj isKindOfClass:[NSNull class]]) {
                continue;
            }
            [invocation setArgument:&obj atIndex:i+2];
        }
        [invocation invoke];
        if (signature.methodReturnLength != 0 && signature.methodReturnLength) {
            [invocation getReturnValue:&result];
        }
    }
    [info release];
    return result;*/
}



- (void)createNeedDir{
    if (![[NSFileManager defaultManager] fileExistsAtPath:VIDEOCACHESROOTPATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:VIDEOCACHESROOTPATH withIntermediateDirectories:NO
                                                   attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:HTTPSERVICEROOTPATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:HTTPSERVICEROOTPATH withIntermediateDirectories:NO
                                                   attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:M3U8DOWNROOTPATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:M3U8DOWNROOTPATH withIntermediateDirectories:NO
                                                   attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:ALONESERVICEROOTPATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ALONESERVICEROOTPATH withIntermediateDirectories:NO
                                                   attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:ALONEDOWNROOTPATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ALONEDOWNROOTPATH withIntermediateDirectories:NO
                                                   attributes:nil error:nil];
    }
}

@end
