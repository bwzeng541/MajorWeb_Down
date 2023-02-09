//
//  FileArInfo.m
//  WatchApp
//
//  Created by zengbiwang on 2017/12/21.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileArInfo.h"
#import "NSData+AES256.h"
#import "NSData+Base64.h"
#import "EMAES128.h"
@interface FileArInfo(){
      dispatch_queue_t  readQueue;
}

@property(copy)NSString *url;
@property(copy)NSString *localfile;
@property(strong)NSTimer *syncTimer;
@property(assign)BOOL isCanResumable;
@property(assign)BOOL iForceDealTmpData;
@property(strong)NSData* vi;
@property(strong)NSData* key;
@property(strong)NSNumber* type;
@property(copy)NSString* refer;
@end

@implementation FileArInfo
- (id)initWithFile:(NSString *)url local:(NSString*)local isCanResumable:(BOOL)isCanResumable forceDelTmpData:(BOOL)forceDelTmpData vi:(NSData*)vi key:(NSData*)keyData type:(NSNumber *)type refer:(NSString*)refer{
    self = [super init];
    if (self) {
        self.url = url;
        self.localfile = local;
        readQueue = nil;
        self.isCanResumable=isCanResumable;
        self.iForceDealTmpData = forceDelTmpData;
        self.vi = vi;
        self.key = keyData;
        self.refer = refer;
        self.type = type;
     }
    return self;
}

-(void)stop{
    [self.syncTimer invalidate];
    self.syncTimer  = nil;
    [super stop];
}

-(void)start{
    [super start];
}

-(void)dealloc{
   // NSLog(@"%s",__FUNCTION__);
}

- (NSString *)requestUrl {
    return self.url;
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary{
    if ([self.refer length]>3) {
        return @{@"Referer":self.refer};
    }
    return nil;
}

- (BOOL)useCDN {
    return YES;
}

/*
KEY_NONE = 0,
KEY_AES_128 = 1,
KEY_SAMPLE_AES = 2*/
- (void)didSuccessedWillDatafilter{
    if ([self.type intValue]==1) {
        NSData *data = [NSData dataWithContentsOfFile:self.localfile];
        //不解密，走http服务器合成
        NSData *newData = [[EMAES128 shared] decryptCBC128Mode:data withKey:self.key vectorKey:self.vi];
       [newData writeToFile:self.localfile atomically:YES];
    }
    else if([[self type] intValue]==2){
    }
}

- (NSString *)resumableDownloadPath {
    return self.isCanResumable?self.localfile:nil;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeHTTP;
}

-(BOOL)isDelResumableDownloadPath{
    return self.iForceDealTmpData;
}
@end
