//
//  SGWiFiUploadManager.m
//  SGWiFiUpload
//
//  Created by soulghost on 29/6/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGWiFiUploadManager.h"
 #import "SGHTTPConnection.h"
#import "SGWiFiUploadManager.h"
#import "SVProgressHUD.h"
@interface SGWiFiUploadManager () {
    NSString *_tmpFileName;
    NSString *_tmpFilePath;
    BOOL _isStartServer;
}

/*
 *  Callback Blocks
 */
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadStartBlock startBlock;
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadProgressBlock progressBlock;
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadFinishBlock finishBlock;
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadIpUpdateBlock ipBlock;
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadFinishBlock finishOutBlock;
@end

@implementation SGWiFiUploadManager

+ (instancetype)sharedManager {
    static SGWiFiUploadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

+ (NSString *)ip {
    return [[UIDevice currentDevice] ipAddressWIFI];
}

- (NSString *)ip {
    return [[UIDevice currentDevice] ipAddressWIFI];
}

- (UInt16)port {
    return self.httpServer.port;
}

- (instancetype)init {
    if (self = [super init]) {
        

        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *wifiDirectory = [documentsDirectory stringByAppendingPathComponent:@"upload_wifi"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:wifiDirectory]) {
            [fileManager createDirectoryAtPath:wifiDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"index" ofType:@"html"]] writeToFile:[NSString stringWithFormat:@"%@/index.html",wifiDirectory] atomically:YES];
        [[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"upload" ofType:@"html"]] writeToFile:[NSString stringWithFormat:@"%@/upload.html",wifiDirectory] atomically:YES];
        self.webPath = wifiDirectory;
        self.savePath = wifiDirectory;
    }
    return self;
}

- (BOOL)startHTTPServerAtPort:(UInt16)port {
    if(!self.httpServer){
        HTTPServer *server = [HTTPServer new];
        server.port = port;
        self.httpServer = server;
        [self.httpServer setDocumentRoot:self.webPath];
        [self.httpServer setConnectionClass:[SGHTTPConnection class]];
        NSError *error = nil;
        [self.httpServer start:&error];
        if (error == nil) {
            [self setupStart];
            self.isWiFiUploadService = true;
        }
        return error == nil;
    }
    return self.httpServer.isRunning;
}

- (BOOL)startHTTPServerAtPort:(UInt16)port start:(SGWiFiUploadManagerFileUploadStartBlock)start progress:(SGWiFiUploadManagerFileUploadProgressBlock)progress finish:(SGWiFiUploadManagerFileUploadFinishBlock)finish {
    self.startBlock = start;
    self.progressBlock = progress;
    self.finishBlock = finish;
    return [self startHTTPServerAtPort:port];
}

- (BOOL)isServerRunning {
    return self.httpServer.isRunning;
}

- (void)stopHTTPServer {
    [self.httpServer stop];
    [self setupStop];
    self.httpServer = nil;
}

- (void)showWiFiPageFrontViewController:(UIViewController *)viewController dismiss:(void (^)(void))dismiss {
 
}

#pragma mark - Setup
- (void)setupStart {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadStart:) name:SGFileUploadDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinish:) name:SGFileUploadDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadProgress:) name:SGFileUploadProgressNotification object:nil];
}

- (void)setupStop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.startBlock = nil;
    self.progressBlock = nil;
    self.finishBlock = nil;
}

#pragma mark - Notification Callback
- (void)fileUploadStart:(NSNotification *)nof {
    NSString *fileName = nof.object[@"fileName"];
    NSString *filePath = [self.savePath stringByAppendingPathComponent:fileName];
    _tmpFileName = fileName;
    _tmpFilePath = filePath;
    if (self.startBlock) {
        self.startBlock(fileName, filePath);
    }
}

- (void)fileUploadFinish:(NSNotification *)nof {
    if (self.finishBlock) {
        self.finishBlock(_tmpFileName, _tmpFilePath);
    }
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    if (self.progressBlock) {
        self.progressBlock(_tmpFileName, _tmpFilePath, progress);
    }
}

#pragma mark - Block Setter
- (void)setFileUploadStartCallback:(SGWiFiUploadManagerFileUploadStartBlock)callback {
    self.startBlock = callback;
}

- (void)setFileUploadProgressCallback:(SGWiFiUploadManagerFileUploadProgressBlock)callback {
    self.progressBlock = callback;
}

- (void)setFileUploadFinishCallback:(SGWiFiUploadManagerFileUploadFinishBlock)callback {
    self.finishBlock = callback;
}

- (void)dealloc {
    [self setupStop];
}


-(void)startUpLoadServer:(NSInteger)port callBack:(SGWiFiUploadManagerFileUploadIpUpdateBlock)callBack finshBlock:(SGWiFiUploadManagerFileUploadFinishBlock)finshCallBack{
    self.finishOutBlock = finshCallBack;
    self.ipBlock = callBack;
    if(!_isStartServer){
    SGWiFiUploadManager *mgr = self;
    _isStartServer = [self startHTTPServerAtPort:port];
    if (_isStartServer) {
        [self setCallBack];
    }
    mgr = [SGWiFiUploadManager sharedManager];
    HTTPServer *server = mgr.httpServer;
    if (server.isRunning) {
        if ([[UIDevice currentDevice] ipAddressWIFI] == nil) {
            
            return;
        }
        NSString *ip_port = [NSString stringWithFormat:@"http://%@:%@",mgr.ip,@(mgr.port)];
        if (self.ipBlock) {
            self.ipBlock(ip_port);
        }
    } else {
    }
        
      [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkServer) userInfo:nil repeats:YES];
    }
    else{
        NSString *ip_port = [NSString stringWithFormat:@"http://%@:%@",self.ip,@(self.port)];
        if (self.ipBlock) {
            self.ipBlock(ip_port);
        }
        [self setCallBack];
    }
}

-(void)setCallBack{
    [self setFileUploadStartCallback:^(NSString *fileName, NSString *savePath) {
        NSLog(@"File %@ Upload Start", fileName);
    }];
    [self setFileUploadProgressCallback:^(NSString *fileName, NSString *savePath, CGFloat progress) {
        [SVProgressHUD showProgress:progress status:@"正在传输" maskType:(SVProgressHUDMaskTypeBlack)];
        
        NSLog(@"File %@ on progress %f", fileName, progress);
    }];
    [self setFileUploadFinishCallback:^(NSString *fileName, NSString *savePath) {
        NSLog(@"File Upload Finish %@ at %@", fileName, savePath);
        [SVProgressHUD dismiss];
        if (self.finishOutBlock) {
            self.finishOutBlock(fileName, savePath);
        }
    }];
}

-(void)checkServer{
    SGWiFiUploadManager *mgr = self;
    if (![mgr isServerRunning]) {
        HTTPServer *server = mgr.httpServer;
        NSError *err = nil;
        [server start:&err];
    }
    else{
        NSString *ip_port = [NSString stringWithFormat:@"http://%@:%@",mgr.ip,@(mgr.port)];
        if (self.ipBlock) {
            self.ipBlock(ip_port);
        }
    }
}
@end
