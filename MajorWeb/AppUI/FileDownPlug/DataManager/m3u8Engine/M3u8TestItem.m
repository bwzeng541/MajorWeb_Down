
//
//  M3u8TestItem.m
//  m3u8DownDemo
//
//  Created by zengbiwang on 13-9-18.
//  Copyright (c) 2013年 zengbiwang. All rights reserved.
//

#import "M3u8TestItem.h"
#import "MKNetworkEngine.h"
#import "FileDonwPlus.h"
#import "VideoPlaylistModel.h"
#import "FileArInfo.h"
#import "FTWCache.h"
#import "AppNodeTask.h"
#import "NSStringNSOpertation.h"
#import "RecordUrlToUUID.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#define TsContCatStrarPogress 0.98
#if DoNotKMPLayerCanShareVideo
@interface M3u8TestItem (){
#else
@interface M3u8TestItem ()<PlayVideoTaskDelegate,FFmpegCmdConcatDelegate,FFmpegCmdHlsDelegate>{
#endif
    NSInteger currentDownFinishesCount;//已经下载完成个数
    NSInteger leaveFileCount;//剩余文件个数
    NSInteger totatFileCount;//文件总个数
    NSInteger currentDownCount;//当前下载个数,
    NSString *strM3u8Info;
    
    NSOperationQueue *queueThread  ;

    MKNetworkEngine *mkNetEngine;
    MKNetworkOperation *op;
    NSMutableArray *downArrayASI;
    BOOL  isCanPlay;
    float videoDuration;
    BOOL  isUserRefer;
    int   tryTimes;
}
@property (nonatomic, strong)NSData *keyData;
@property (nonatomic, strong)NSData *viData;
@property (nonatomic, strong)NSString *lastFilePath;
@property (nonatomic, strong)NSMutableString *localM3u8Text;
@property (nonatomic, strong) dispatch_block_t afterStartBlock;
@property (nonatomic, strong) dispatch_block_t afterBlock;
@property (nonatomic, strong) dispatch_block_t concatBlock;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, assign)   BOOL isStart;

#if DoNotKMPLayerCanShareVideo
#else
@property(strong)    AppNodeTask *AppNodeTask;
#endif
@end

@implementation M3u8TestItem

-(id)init{
    self = [super init];
    self.isStart = FALSE;currentDownFinishesCount=0;currentDownCount=0;
    downArrayASI = [[NSMutableArray arrayWithCapacity:10] retain];
#if DoNotKMPLayerCanShareVideo
#else
    self.AppNodeTask = [[AppNodeTask alloc]init];
    self.AppNodeTask.delegate = self;
#endif
    isUserRefer = true;
    tryTimes=0;
    queueThread = [[NSOperationQueue alloc]init];
    self.createTime = [NSDate date];
    return self;
}

-(void)dealloc{
#if DoNotKMPLayerCanShareVideo
#else
    self.AppNodeTask = nil;
#endif
    [self canelBlock];
    [self stop];self.m3u8ID=nil;self.m3u8Url=nil;
    self.allArrayDown=nil;self.saveRootPath=nil;self.tempRootPath=nil;
    [downArrayASI release];[queueThread release];
    NSLog(@"%s",__FUNCTION__);
    [super dealloc];
}

-(void)canelBlock{
    if (self.afterBlock) {
            dispatch_block_cancel(self.afterBlock);
            self.afterBlock = nil;
    }
    if(self.afterStartBlock){
        dispatch_block_cancel(self.afterStartBlock);
        self.afterStartBlock = nil;
    }
    if(self.concatBlock){
        dispatch_block_cancel(self.concatBlock);
        self.concatBlock = nil;
    }
}
    
-(void)stop{
    if(!self.isStart)return;
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask stopCheckToSlow];
#endif
    [self canelBlock];
    [queueThread cancelAllOperations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(segmentListParse:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(downInfoCheckAndStart) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(m3u8Thread:) object:nil];
    [op cancel];op=nil;[mkNetEngine release];mkNetEngine=nil;//?手动调用暂停的时候，op！=nil
    [self stopAllReqeust];
    [[FFmpegCmd getInstace] exitffmpeg:self.m3u8ID];
    self.isStart = FALSE;
    NSLog(@"%s",__FUNCTION__);
}

-(void)stopAllReqeust{
    for (int i = 0; i<[downArrayASI count]; i++) {
        [(FileArInfo*)[downArrayASI objectAtIndex:i] clearCompletionBlock];
        [(FileArInfo*)[downArrayASI objectAtIndex:i] stop];
    }
    [downArrayASI removeAllObjects];
}

-(void)start{
    if (!self.isStart) {
        videoDuration = -1;
        [self canelBlock];
        self.isStart = TRUE;
        isCanPlay = false;
#if DoNotKMPLayerCanShareVideo
#else
        self.AppNodeTask.uuid = self.m3u8ID;
#endif
        currentDownFinishesCount=0;currentDownCount=0;
        [[NSNotificationCenter defaultCenter]postNotificationName:DOWNPREINGM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID", nil]];
        NSString*url = [[RecordUrlToUUID getInstance] urlFromKey:self.m3u8ID];
        if(!isUserRefer){
            url = @"";
        }
        [[FFmpegCmd getInstace] addHlsUrlGetInfo:self.m3u8ID url:self.m3u8Url referUrl:url  hlsgetDelegate:self];
        if ([self.delegate respondsToSelector:@selector(app_state_change_1:)]) {
            [self.delegate app_state_change_1:self.m3u8ID];
        }
    }
}


-(void)requestM3u8Faild{
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask stopCheckToSlow];
#endif
    self.localM3u8Text = nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:DOWNFAILDM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID" ,nil]];
    if ([self.delegate respondsToSelector:@selector(app_state_change_7:)]) {
        [self.delegate app_state_change_7:self.m3u8ID];//文件失效，必须重新解析数据下载
    }
}

//调用失败
-(void)speedSlow:(NSString *)uuid{
    [self stop];
    [self reqeustFailInvalid:nil];
}

    -(FileArInfo*)createReqeustApi:(NSString*)url local:(NSString*)local vi:(NSData*)vi key:(NSData*)key type:(NSNumber*)type{
        NSString *refer = [[RecordUrlToUUID getInstance]urlFromKey:self.m3u8ID];
        FileArInfo *api = [[[FileArInfo alloc]initWithFile:url local:local isCanResumable:true forceDelTmpData:true vi:vi key:key type:type refer:isUserRefer?refer:@""] autorelease];
    [api setFailureCompletionBlock:^(__kindof YTKBaseRequest * _Nonnull request) {//失败走的回调
        NSInteger statusCode =  request.responseStatusCode;//检查错误码已经上一个文件是否存储
        if(statusCode==404 && [[NSFileManager defaultManager] fileExistsAtPath:self.lastFilePath]){
            //拷贝数据给失败的这个文件，然后走下载成功流程，每次下载成功后，更新lastFilePath文件，以及在初始化的时候初始化lastFilePath文件
            [[NSFileManager defaultManager] copyItemAtPath:self.lastFilePath toPath:((FileArInfo*)request).localfile error:nil];
            [self requestOK:request];
        }
        else
        {
            [self reqeustFail:request];
        }
    }];
    [api setResumableDownloadProgressBlock:^(NSProgress * progress) {
        [self dispOneFileProgress:progress.fractionCompleted];
#if DoNotKMPLayerCanShareVideo
#else
        [self.AppNodeTask jisuan2:progress];
#endif
    }];
    [api setSuccessCompletionBlock:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (request.responseStatusCode>=200 && request.responseStatusCode<300) {
            self.lastFilePath = ((FileArInfo*)request).localfile;
            [self requestOK:request];
        }
        else{
            [self reqeustFailInvalid:request];
        }
    }];
    return api;
}

-(void)dispOneFileProgress:(float)progress{
    NSInteger v = currentDownCount;
    if (v<0) {
        v = 0;
    }
    float t = (float)(v+currentDownFinishesCount)/(totatFileCount) + progress/totatFileCount;
    [self.delegate app_state_change_4:self.m3u8ID parma0:t];
}

-(void)downInfoCheckAndStart{
    [self stopAllReqeust];
#if DoNotKMPLayerCanShareVideo
#else
    [self.AppNodeTask startCheckToSlow];
#endif
//    if ([self.delegate respondsToSelector:@selector(app_state_change_1:)]) {
//        [self.delegate app_state_change_1:self.m3u8ID];
//    }
    NSFileManager *filemangaer = [NSFileManager defaultManager];
    if (![filemangaer fileExistsAtPath:self.saveRootPath]) {
        [filemangaer createDirectoryAtPath:self.saveRootPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![filemangaer fileExistsAtPath:self.tempRootPath]) {
        [filemangaer createDirectoryAtPath:self.tempRootPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    currentDownFinishesCount= 0;
   totatFileCount = [self.allArrayDown count];
    for (int i = 0 ; i < totatFileCount; i++) {
        NSDictionary *info = [self.allArrayDown objectAtIndex:i];
        NSString *strLocal =  [info objectForKey:M3U8_Local_Key];
        NSString *strURI =  [info objectForKey:M3U8_Url_Key];
        if (strURI&&strLocal) {//必须为2类型
            NSString  *strUrl = strURI;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:strLocal]) {
                [downArrayASI addObject:[self createReqeustApi:strUrl local:strLocal vi:self.viData key:self.keyData type:[info objectForKey:M3U8_Encryption_type_Key]]];
            }
            else {//
                self.lastFilePath = strLocal;
                currentDownFinishesCount++;
            }
            leaveFileCount = totatFileCount-currentDownFinishesCount;
        }
    }
    if ([downArrayASI count]>0) {
        [self dispProgrogress];
        __weak typeof(self) weakSelf = self;
        self.afterStartBlock = dispatch_block_create(0, ^{
            [weakSelf gogogo];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterStartBlock);
        
    }
    else{
        NSLog(@"%s ,%d",__FUNCTION__,__LINE__);
        if(![self checkMovAndStart]){
    #if DoNotKMPLayerCanShareVideo
    #else
            [self.AppNodeTask stopCheckToSlow];
    #endif
#if (TsFilesCanConCatMovFile==0)
            [self catFinish:nil];
#endif
        }
    }
}

-(BOOL)checkMovAndStart{
#if (TsFilesCanConCatMovFile==0)
    return false;
#endif
    NSString *save = [NSString stringWithFormat:@"%@/%@.mov",self.saveRootPath,self.m3u8ID];
    NSString *fixts = [NSString stringWithFormat:@"%@/1.ts",self.saveRootPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:save] && ![fileManager fileExistsAtPath:fixts]){
        return false;
    }
    __weak typeof(self) weakSelf = self;
    self.concatBlock = dispatch_block_create(0, ^{
        [weakSelf startToConvertMp4];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        if (weakSelf.concatBlock) {
            weakSelf.concatBlock();
        }
    });
    return true;
}
    
-(void)gogogo{
        [(FileArInfo*) [downArrayASI objectAtIndex:0] start];
        NSLog(@"%s ,%d",__FUNCTION__,__LINE__);
        [[NSNotificationCenter defaultCenter]postNotificationName:DOWNSTARTM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID",nil]];
}

-(BOOL)isSaveFileExsit:(NSString*)name{
    NSFileManager *filemangaer = [NSFileManager defaultManager];
    if ([filemangaer fileExistsAtPath:[self getSaveFilePath:name]]) {
        return TRUE;
    }
    return FALSE;
}

-(NSString*)getSaveFilePath:(NSString*)name{
    NSString *strSaveFile = [NSString stringWithFormat:@"%@/%@",self.saveRootPath,name];
    return strSaveFile;
}

-(NSString*)getTmpFilePath:(NSString*)name{
    NSString *strSaveFile = [NSString stringWithFormat:@"%@/%@.tmp",self.tempRootPath,name];
    return strSaveFile;
}

-(ASIHTTPRequest*)ceateDownObject:(NSString *)strUrl fileName:(NSString*)fileName{
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *url = [NSURL URLWithString:strUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:[self getSaveFilePath:fileName]];
    [request setTemporaryFileDownloadPath:[self getTmpFilePath:fileName]];
    [request setTimeOutSeconds:10];
    [request setDelegate:self];
    return request;
}
#pragma mark-- ASIHttpDelagte

-(void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"%s",__FUNCTION__);
}


-(void)requestFinished:(ASIHTTPRequest *)request{
    if (self.isStart) {
        //判断responseStatusCode
        if (request.responseStatusCode>=200 && request.responseStatusCode<300) {
            [self requestOK:request];
        }
        else {
            [self reqeustFailInvalid:request];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    [self reqeustFail:request];
}


#pragma mark --

-(void)reqeustFailInvalid:(id)request{
    NSString *savePath = [NSString stringWithFormat:@"%@/%@.mp4",self.saveRootPath,self.m3u8ID];
    [[NSFileManager defaultManager]removeItemAtPath:savePath error:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:DOWNFAILDM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID" ,nil]];
    if ([self.delegate respondsToSelector:@selector(app_state_change_7:)]) {
        [self.delegate app_state_change_7:self.m3u8ID];//文件失效，必须重新解析数据下载
    }
}

-(float)dispProgrogress{
    float t = (float)(currentDownCount+currentDownFinishesCount)/(totatFileCount);
    [[NSNotificationCenter defaultCenter]postNotificationName:UPPROGROESSM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID",[NSNumber numberWithFloat:t],@"PROGRESS",nil]];
    [self.delegate app_state_change_4:self.m3u8ID parma0:t];
    return t;
}

-(void)requestOK:(id)request{
    currentDownCount++;
    float t = [self dispProgrogress];
    [downArrayASI removeObject:request];
    if ([downArrayASI count]>0) {
        [(FileArInfo*) [downArrayASI objectAtIndex:0] start];
    }
    if([self.delegate respondsToSelector:@selector(app_state_change_4:parma0:)]){
        [self.delegate app_state_change_4:self.m3u8ID parma0:t];
        if (t>0.001 && !isCanPlay) {
            isCanPlay = true;
            [self.delegate app_state_change_3:self.m3u8ID];
        }
    }
    if (t>=1) {
#if DoNotKMPLayerCanShareVideo
#else
        [self.AppNodeTask stopCheckToSlow];
#endif
        
#if (TsFilesCanConCatMovFile==1)
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self startToConvertMp4];
        });
#else
        [self catFinish:nil];
#endif
    }
}
    
-(void)ffmpegCmdHlsFinish:(NSString*)_uuid_  urlfiles:(NSArray*)array keyData:(NSData *)keyData viData:(NSData *)viData error:(int)errror{
    if([_uuid_ isEqualToString:self.m3u8ID]){
        [[FFmpegCmd getInstace]removeHlsObject:self];
    }
    if([_uuid_ isEqualToString:self.m3u8ID]&&self.isStart && errror!=ForceExitFFMpegCode){//解析放在线程中
        [self stopAllReqeust];
        __weak M3u8TestItem* weakSelf = self;
        if(array.count==0 && tryTimes<1){
            isUserRefer = false;
            tryTimes++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                [[FFmpegCmd getInstace] addHlsUrlGetInfo:weakSelf.m3u8ID url:self.m3u8Url referUrl:@""  hlsgetDelegate:self];
            });
            return;
        }
        self.viData = viData;self.keyData = keyData;
        self.afterBlock = dispatch_block_create(0, ^{
            [weakSelf parseffmpegHls:array error:errror];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            if (weakSelf.afterBlock) {
                weakSelf.afterBlock();
            }
        });
     }
}

-(void)ffmpegCmdConCatProgress:(NSString*)_uuid_  currentTime:(float)currentTime{
    if([_uuid_ isEqualToString:self.m3u8ID] ){
        float pp = currentTime/videoDuration;
        float p = (float)(TsContCatStrarPogress) + pp*(1-TsContCatStrarPogress);
        if(p>=0&&p<=1){
            [[NSNotificationCenter defaultCenter]postNotificationName:UPPROGROESSM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID",[NSNumber numberWithFloat:p],@"PROGRESS",nil]];
            [self.delegate app_state_change_4:self.m3u8ID parma0:p];
        }
    }
}
    
-(void)ffmpegCmdConCatFinish:(NSString*)_uuid_  files:(NSArray*)array error:(int)errror{
    if([_uuid_ isEqualToString:self.m3u8ID] ){
        [[FFmpegCmd getInstace]removeConcateObject:self];
        if(errror!=0){
//            NSString *savePath = [NSString stringWithFormat:@"%@/%@.mp4",self.saveRootPath,self.m3u8ID];
//            NSURL *url = [NSURL fileURLWithPath:savePath];
//            if(url){
//                AVAsset *v = [AVURLAsset URLAssetWithURL:url options:nil];
//                NSArray *array = v.metadata;
//                if(array.count>0){
//                    [self catFinish:array];
//                    return;
//                }
//            }
            [self reqeustFailInvalid:nil];
        }
        else
        {
            [self catFinish:array];
        }
  }
}

-(void)catFinish:(NSArray *)array{
    for(int i = 0;i<array.count;i++){
        [[NSFileManager defaultManager]removeItemAtPath:[array objectAtIndex:i] error:nil];
    }
    {
        [self dispProgrogress];
        if([self.delegate respondsToSelector:@selector(app_state_change_5:)]){
            [self.delegate app_state_change_5:self.m3u8ID];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:DOWNFINISHESM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID" ,nil]];
    }
}
    
-(void)parseffmpegHls:(NSArray*)array error:(int)error{
    NSDictionary *info=nil;
    @autoreleasepool {
        NSData *oldData = [FTWCache objectForKey:self.m3u8ID useKey:YES];
        NSString *strOld = nil;
        if (oldData) {
            strOld = [[[NSString alloc]initWithData:oldData encoding:NSUTF8StringEncoding]autorelease];
        }
        if(error==0&&array.count>0){
            NSError *error = nil;
            NSString *jsonString = [array JSONString];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                               options:kNilOptions
                                                                 error:&error];
            jsonString = [[NSString alloc] initWithData:jsonData
                                                         encoding:NSUTF8StringEncoding];
            if ([strOld compare:jsonString]!=NSOrderedSame) {//更新数据，线路改变了，删除原来的数据
                [[NSFileManager defaultManager]removeItemAtPath:self.saveRootPath error:nil];
                [[NSFileManager defaultManager]removeItemAtPath:self.tempRootPath error:nil];
                [FTWCache setObject:[jsonString dataUsingEncoding:NSUTF8StringEncoding] forKey:self.m3u8ID useKey:YES];
            }
            
            info = [self getCacheDownInfo:array md5LocalText:[jsonString md5]];
        }
        else{
            if(strOld){
                info = [self getCacheDownInfo:[strOld JSONValue] md5LocalText:[strOld md5]];
            }
        }
        if(!info){
            self.isStart = FALSE;
            [self performSelectorOnMainThread:@selector(requestM3u8Faild) withObject:nil waitUntilDone:NO];
        }
        else{
            [self segmentListParse:info];
        }
    }
}

-(NSDictionary*)getCacheDownInfo:(NSArray*)array md5LocalText:(NSString*)md5LocalText{
    NSMutableDictionary *retInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [retInfo setObject:md5LocalText forKey:@"LocalText"];
    NSMutableArray *arrayUrl = [NSMutableArray arrayWithCapacity:100];
    videoDuration = -1;
    self.localM3u8Text = nil;[[NSMutableString alloc] initWithString:[NSMutableString stringWithFormat:@"%@",@"#EXTM3U\n\r#EXT-X-VERSION:3\n\r#EXT-X-TARGETDURATION:20\n\r#EXT-X-MEDIA-SEQUENCE:0\n\r"]];
    //判断是否有密码
    if(array.count>0 && false){
        NSDictionary *info = [array objectAtIndex:0];
        NSInteger type = [[info objectForKey:hls_video_des_key_type_key] integerValue];
        NSString *keyUrl =  [info objectForKey:hls_video_Encryption_key_url];
        NSData *keyDes =  [info objectForKey:hls_video_des_key_key];
        if([keyUrl length]>0 && [keyUrl rangeOfString:@"null"].location==NSNotFound){
           NSString *savePathUrl =  [NSString stringWithFormat:@"http://localhost:%d/%@/%@/%@",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,self.m3u8ID,@"key.key"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",M3U8DOWNROOTPATH,self.m3u8ID]]){
                [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",M3U8DOWNROOTPATH,self.m3u8ID] withIntermediateDirectories:NO attributes:nil error:nil];
            }
            NSString *savePath =  [NSString stringWithFormat:@"%@/%@/%@%@",M3U8DOWNROOTPATH,self.m3u8ID,@"key",@".key"];
            [keyDes writeToFile:savePath atomically:YES ];
             NSString *key =  nil;
            if(type == KEY_AES_128){
                key =  [NSString stringWithFormat:@"%@%@\"\n\r",@"#EXT-X-KEY:METHOD=AES-128,URI=\"",savePathUrl];
            }
            else if (type==KEY_SAMPLE_AES){
                key =  [NSString stringWithFormat:@"%@%@\"\n\r",@"#EXT-X-KEY:METHOD=AES-128,URI=\"",savePathUrl];
            }
            [self.localM3u8Text appendString:key];
        }
    }
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        float startTime = [[obj objectForKey:hls_video_des_startTime] floatValue]/1000000;
        float durationTime = [[obj objectForKey:hls_video_des_duration] floatValue]/1000000;
        [arrayUrl addObject:@{M3U8_Encryption_type_Key:[obj objectForKey:hls_video_des_key_type_key],M3U8_Cipher_vi_Key:[obj objectForKey:hls_video_des_vi_key],M3U8_Cipher_Key:[obj objectForKey:hls_video_des_key_key],M3U8_Url_Key:[obj objectForKey:hls_video_url_key],M3U8_Local_Key:[NSString stringWithFormat:@"%@/%@/%lu%@",M3U8DOWNROOTPATH,self.m3u8ID,idx+1,@".ts"],M3U8_DurationTime_Key:@(durationTime)}];
        videoDuration = startTime+durationTime;
        [self.localM3u8Text appendFormat:@"#EXTINF:%f,\n\r",durationTime];
         NSString *strLocalTsPath = [NSString stringWithFormat:@"http://localhost:%d/%@/%@/%ld.ts\n\r",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,self.m3u8ID, idx+1];
        [self.localM3u8Text appendFormat:@"%@",strLocalTsPath];

    }];
    
    [self.localM3u8Text appendString:@"#EXT-X-ENDLIST\n\r"];
    [retInfo setObject:arrayUrl forKey:@"ArrayKey"];
    return retInfo;
}
    
-(void)startToConvertMp4{
    NSMutableArray *aa = [NSMutableArray arrayWithCapacity:11];
    for(int i = 0;i<self.allArrayDown.count;i++){
        [aa addObject:[[self.allArrayDown objectAtIndex:i]objectForKey:M3U8_Local_Key]];
    }
    NSString *savePath = [NSString stringWithFormat:@"%@/%@.mp4",self.saveRootPath,self.m3u8ID];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:UPPROGROESSM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID",[NSNumber numberWithFloat:TsContCatStrarPogress],@"PROGRESS",nil]];
        [self.delegate app_state_change_4:self.m3u8ID parma0:TsContCatStrarPogress];
        [[FFmpegCmd getInstace] addTsConcat:self.m3u8ID tsArray:aa filePath:savePath concatDelegate:self];
        NSString *strLocalTsPath = [NSString stringWithFormat:@"http://localhost:%d/%@/%@.m3u8",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,self.m3u8ID];
       // [[FFmpegCmd getInstace] addTsConcat2:self.m3u8ID m3u8LocalUrl:strLocalTsPath filePath:savePath concatDelegate:self];
    });
}

-(void)reqeustFail:(id)request{
    [[NSNotificationCenter defaultCenter]postNotificationName:DOWNFAILDM3U8 object:[NSDictionary dictionaryWithObjectsAndKeys:self.m3u8ID,@"M3U8ID" ,nil]];
    if (self.isStart) {//缓存失败？
        NSLog(@"%s",__FUNCTION__);
        if ([self.delegate respondsToSelector:@selector(app_state_change_6:)]) {
            [self.delegate app_state_change_6:self.m3u8ID];
        }
    }
}

#pragma mark--VideoPlaylistModel
-(void)m3u8Thread:(NSString*)url{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
    VideoPlaylistModel*  model = [[[VideoPlaylistModel alloc] initWithURL:[NSURL URLWithString:url] localDir:M3U8_DIR_NAME port:LOCAHOSET_SERVICE_PORT videoID:self.m3u8ID  error: &error] autorelease];
    [self pareModel:model];
    [pool release];
}

-(void)pareModel:(VideoPlaylistModel* ) model {
    NSString *error;
    NSData *oldData = [FTWCache objectForKey:self.m3u8ID useKey:YES];
    NSData *oldBaseUrl = [FTWCache objectForKey:[NSString stringWithFormat:@"%@_baseUrl_Key",self.m3u8ID] useKey:YES];
    if (oldData) {
        NSString *strOld = [[[NSString alloc]initWithData:oldData encoding:NSUTF8StringEncoding]autorelease];
        NSString *strUrl = [[[NSString alloc]initWithData:oldBaseUrl encoding:NSUTF8StringEncoding]autorelease];
        if (model.mainMediaPl.originalText) {//&&
            if ([strOld compare:model.mainMediaPl.originalText]!=NSOrderedSame) {//更新数据，线路改变了，删除原来的数据
                [[NSFileManager defaultManager]removeItemAtPath:self.saveRootPath error:nil];
                [[NSFileManager defaultManager]removeItemAtPath:self.tempRootPath error:nil];
            }
        }
        else {//读原来的数据
            model = [[[VideoPlaylistModel alloc] initWithString:strOld baseURL:[NSURL URLWithString:strUrl] localDir:M3U8_DIR_NAME port:LOCAHOSET_SERVICE_PORT videoID:self.m3u8ID error:&error] autorelease];
        }
    }
    [self pareseM3U8PlaylistModel:model];
}

-(void)pareseM3U8PlaylistModel:(VideoPlaylistModel*)model{
    NSMutableArray *arrayUrlList = [NSMutableArray arrayWithCapacity:100];
    if (model.mainMediaPl.localText && model.mainMediaPl.cacheArray.count > 0) {
        [FTWCache setObject:[model.mainMediaPl.originalText dataUsingEncoding:NSUTF8StringEncoding] forKey:self.m3u8ID useKey:YES];
        [FTWCache setObject:[[model.mainMediaPl.baseURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding] forKey:[NSString stringWithFormat:@"%@_baseUrl_Key",self.m3u8ID] useKey:YES];
        [self performSelectorOnMainThread:@selector(segmentListParse:) withObject:@{@"ArrayKey":model.mainMediaPl.cacheArray,@"LocalText":model.mainMediaPl.localText} waitUntilDone:NO];
    }
    else{
        [self performSelectorOnMainThread:@selector(segmentListParse:) withObject:@{@"ArrayKey":arrayUrlList,@"LocalText":@""} waitUntilDone:NO];
    }
}

-(void)segmentListParse:(NSDictionary*)info{
    NSArray *array = [info objectForKey:@"ArrayKey"];
    NSString *localText = [info objectForKey:@"LocalText"];
    if (array.count>0) {
        NSString *localM3u8Path = [NSString stringWithFormat:@"%@/%@.m3u8",M3U8DOWNROOTPATH,self.m3u8ID];
        [self.localM3u8Text writeToFile:localM3u8Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%s  ok",__FUNCTION__);
        self.allArrayDown =  array;
        [self performSelectorOnMainThread:@selector(downInfoCheckAndStart) withObject:nil waitUntilDone:NO];
    }
    else{
        self.isStart = FALSE;
        [mkNetEngine release];mkNetEngine=nil;op=nil;
        [self performSelectorOnMainThread:@selector(requestM3u8Faild) withObject:nil waitUntilDone:NO];
    }
}
//end
@end
