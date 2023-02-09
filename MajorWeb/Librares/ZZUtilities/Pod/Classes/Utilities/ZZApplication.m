//
//  ZZApplication.m
//  FileVault
//
//  Created by gluttony on 11/12/14.
//  Copyright (c) 2014 gluttony. All rights reserved.
//

#import "ZZApplication.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "NimbusCore.h"
#import "ZZUtilities.h"

extern NSInteger NIMaxLogLevel;

@interface ZZApplication () {
    Reachability *_internetReachable;
}

@property (strong, readonly, nonatomic) ASINetworkQueue *networkQueue;

@end

@implementation ZZApplication

static ZZApplication *SINGLETON = nil;
static bool isFirstAccess = YES;
static NSTimeInterval kTimeout = 10.0f;

#pragma mark - Private Method

- (void)updateWithReachability:(Reachability *)curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus) {
    case NotReachable: {
        self.isNetworkReachable = NO;
        self.networkStatus = NotReachable;
        break;
    }
    case ReachableViaWWAN: {
        self.isNetworkReachable = YES;
        self.networkStatus = ReachableViaWWAN;
        break;
    }
    case ReachableViaWiFi: {
        self.isNetworkReachable = YES;
        self.networkStatus = ReachableViaWiFi;
        break;
    }
    }
    NIDINFO(@"NetworkStatus changed isNetworkReachable = %@ networkStatus = %@\n\n",
        ZZReadableBOOL(self.isNetworkReachable),
        ZZReadableReachabilityNetworkStatus(self.networkStatus));
}

- (void)setupNetworkObserver
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(reachabilityChangedHandler:)
               name:kReachabilityChangedNotification
             object:nil];

    _internetReachable = [Reachability reachabilityForInternetConnection];
    [_internetReachable startNotifier];
    [self updateWithReachability:_internetReachable];
}

- (void)setupNetworkQueue
{
    if (_requestTasks && _requestTasks.count > 0) {
        [_networkQueue reset];
        if (!_networkQueue) {
            _networkQueue = [[ASINetworkQueue alloc] init];
        }
        _networkQueue.delegate = self;
        [_networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [_networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [_networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];

        for (NSString *urlString in _requestTasks.allKeys) {
            NSURL *url = [NSURL URLWithString:urlString];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
            [request setTimeOutSeconds:kTimeout];
            [_networkQueue addOperation:request];
        }
        [_networkQueue go];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    NSString *urlString = request.originalURL.absoluteString;
    NIDINFO(@"Finished request = %@", urlString);
    ZZApplicationRequestCompletedBlock completedBlock = _requestTasks[urlString];
    if (completedBlock) {
        completedBlock(urlString, request.responseString, nil);
    }
    else {
        NIDWARNING(@"Cannot find completed block for %@", urlString);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *urlString = request.originalURL.absoluteString;
    NIDINFO(@"Failed request = %@\nerror=%@", request.originalURL, request.error);
    ZZApplicationRequestCompletedBlock completedBlock = _requestTasks[urlString];
    if (completedBlock) {
        completedBlock(urlString, nil, request.error);
    }
    else {
        NIDWARNING(@"Cannot find completed block for %@", urlString);
    }
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
    NIDINFO(@"Queue finished");
}

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
        NIDINFO(@"sharedInstance");
    });

    return SINGLETON;
}

- (void)registerClass:(Class)applicationClass
{
    _application = [[applicationClass alloc] init];
    if ([_application conformsToProtocol:@protocol(ZZApplicationDelegate)]) {
        [_application setZZApplication:self];
    }
}

#pragma mark - Notification Handlers

- (void)finishLaunchHandler
{
    NIDINFO(@"finishLaunchHandler");

    if (!_appID) {
        NSLog(@"\n-------------------------\n错误: [ZZApplication sharedInstance].appID 未赋值, becomeActive 前对 [ZZApplication sharedInstance].appID 赋值\n-------------------------\n");
        [NSException raise:@"[ZZApplication sharedInstance].appID 未赋值" format:@"becomeActive 前对 [ZZApplication sharedInstance].appID 赋值"];
    }
    if (!_umengKey) {
        NSLog(@"\n-------------------------\n错误: [ZZApplication sharedInstance].umengKey 未赋值, becomeActive 前对 [ZZApplication sharedInstance].umengKey 赋值\n-------------------------\n");
        [NSException raise:@"[ZZApplication sharedInstance].umengKey 未赋值" format:@"becomeActive 前对 [ZZApplication sharedInstance].umengKey 赋值"];
    }
    if (_apec == ZZApplicationAPECUnknown) {
        NSLog(@"\n-------------------------\n错误: [ZZApplication sharedInstance].apec 未赋值, becomeActive 前对 [ZZApplication sharedInstance].apec 赋值\n-------------------------\n");
        [NSException raise:@"[ZZApplication sharedInstance].apec 未赋值" format:@"becomeActive 前对 [ZZApplication sharedInstance].apec 赋值"];
    }
}

- (void)becomeActiveHandler
{
    NIDINFO(@"becomeActiveHandler");
    if (_apec == ZZApplicationAPECYES) {
        [self setupNetworkQueue];
    }
}

- (void)reachabilityChangedHandler:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateWithReachability:curReach];
}

#pragma mark - Life Cycle

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[ZZApplication alloc] init];
}

- (id)mutableCopy
{
    return [[ZZApplication alloc] init];
}

- (id)init
{
    if (SINGLETON) {
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    if (self) {
        //[self setupNetworkQueue];
        _requestTasks = [NSMutableDictionary dictionary];
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (void)load
{
    NIMaxLogLevel = NILOGLEVEL_INFO;
    [[self sharedInstance] setupNetworkObserver];
    NIDINFO(@"ZZApplication");
    [[NSNotificationCenter defaultCenter]
        addObserver:[self sharedInstance]
           selector:@selector(finishLaunchHandler)
               name:UIApplicationDidFinishLaunchingNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:[self sharedInstance]
           selector:@selector(becomeActiveHandler)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
}

@end
