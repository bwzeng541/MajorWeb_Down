//
//  PhotoLinkPlug.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/21.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "PhotoLinkPlug.h"
#import "SavePhotoInfo.h"
#import "UIImage+ThrowScreenTools.h"
#import "DNLAController.h"
#import "HTTPServer.h"
#import "NSString+MKNetworkKitAdditions.h"
@interface PhotoLinkPlug(){
    HTTPServer * httpServer;
    BOOL isStartHttpService;
    NSTimer *checkServerTimer;
    NSInteger changeSpeed;
}
@property(nonatomic,copy)NSString *photoLinkUrl;
@property(nonatomic,strong)YYCache *photoCache;
@property(nonatomic,strong)NSMutableArray *photosArray;
@property(nonatomic,copy)NSString* lookDir;
@property(nonatomic,assign)NSInteger photosIndex;
@property(nonatomic,assign)NSInteger deviceIndex;
@property(nonatomic,strong)NSTimer *changePhotos;
@end
@implementation PhotoLinkPlug

+(PhotoLinkPlug*)PhotoLinkPlug{
    static PhotoLinkPlug *g = nil;
    if (!g) {
        g = [[PhotoLinkPlug alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:PhotoLinkPlugDir ]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:PhotoLinkPlugDir withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    self.photoCache = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/cacheConfig",PhotoLinkPlugDir]];
    return self;
}

-(void)startPhotoServer{
    if (!httpServer) {
        httpServer = [[HTTPServer alloc] init];
        [httpServer setType:@"_http._tcp."];
        [httpServer setPort:PhotoLiknPort];
                NSString *webPath =  PhotoLinkPlugDir;
        [httpServer setDocumentRoot:webPath];
        NSError *error;
        if(![httpServer start:&error])
        {
            isStartHttpService = FALSE;
            NSLog(@"Error starting HTnonatomic, TP Server: %@", error);
        }
        else{
            isStartHttpService = TRUE;
        }
        if (!checkServerTimer) {
            checkServerTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkHttpService) userInfo:nil repeats:YES];
        }
    }
}

- (void)checkHttpService{
    if (httpServer ) {
        if (![httpServer isRunning]) {
            NSError *error;
            if(![httpServer start:&error])
            {
                isStartHttpService = FALSE;
                NSLog(@"PhotoLinkPlug Error starting HTTP Server: %@", error);
            }
            else{
                isStartHttpService = TRUE;
            }
        }
        else {
            NSLog(@"%s PhotoLinkPlug httpService = ok",__FUNCTION__);
        }
    }
    else{
        NSLog(@"%s PhotoLinkPlug httpService = stop",__FUNCTION__);
    }
}

-(void)stopPhotoServer{
    [httpServer stop];
    httpServer = nil;
    [self.changePhotos  invalidate];
    self.changePhotos = nil;
}

-(NSString*)getAssetIcon:(NSString*)dirName{
    NSString *dir =  [PhotoLinkPlugDir stringByAppendingPathComponent :dirName];
    NSArray *array = (NSArray*)[self.photoCache objectForKey:dirName];
     if (array.count>0) {
         SavePhotoInfo *saveInfo =  [array objectAtIndex:0];
         NSString *iconFile =  [dir stringByAppendingPathComponent:saveInfo.iconfileName];
         return iconFile;
     }
    return nil;
}

 

-(void)addAssetToLocal:(NSData*)data  iconImage:(UIImage*)iconImage  assetKey:(NSString*)assetKey extName:(NSString*)extName dirName:(NSString*)dirName {
    NSString *dir =  [PhotoLinkPlugDir stringByAppendingPathComponent :dirName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir ]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:NULL];
        [self.photoCache setObject:[NSArray array] forKey:dirName];
    }
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",[assetKey md5],extName];
    NSString *iconfileName = [NSString stringWithFormat:@"%@_icon.%@",[assetKey md5],extName];
    NSString *filePath = [dir stringByAppendingPathComponent:fileName];
    NSString *iconfilePath = [dir stringByAppendingPathComponent:iconfileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
       [data writeToFile:filePath atomically:YES];
        NSArray *array = (NSArray*)[self.photoCache objectForKey:dirName];
        NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:10];
        if (array.count>0) {//文件名
            [arrayTmp addObjectsFromArray:array];
        }
        SavePhotoInfo *savePhoto = [[SavePhotoInfo alloc] init];
        savePhoto.uuid = assetKey;
        savePhoto.fileName = fileName;
        savePhoto.iconfileName = iconfileName;
        savePhoto.dirName = dirName;
        [arrayTmp addObject:savePhoto];
        [self.photoCache setObject:arrayTmp forKey:dirName];
        NSData *data = UIImageJPEGRepresentation(iconImage, 0.9);
        [data writeToFile:iconfilePath atomically:YES];
    }
}

-(void)removeAssetToLocal:(NSString*)assetKey fileName:(NSString*)fileName  dirName:(NSString*)dirName{
    NSArray *array = (NSArray*)[self.photoCache objectForKey:dirName];
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:10];
    if (array.count>0) {
        [arrayTmp addObjectsFromArray:array];
        for (int i = 0; i < arrayTmp.count; i++) {
           SavePhotoInfo *saveInfo =  [arrayTmp objectAtIndex:i];
            if( [ saveInfo.uuid rangeOfString:assetKey].location!=NSNotFound){
                [arrayTmp removeObjectAtIndex:i];
                NSString *dir =  [PhotoLinkPlugDir stringByAppendingPathComponent :dirName];
                NSString *filePath = [dir stringByAppendingPathComponent:fileName];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[dir stringByAppendingPathComponent:saveInfo.iconfileName] error:nil];
                break;
            }
        }
        [self.photoCache setObject:arrayTmp forKey:dirName];
    }
}

-(NSString*)getAssetToLocal:(NSString*)fileName  dirName:(NSString*)dirName{
    NSString *dir =  [PhotoLinkPlugDir stringByAppendingPathComponent :dirName];
    NSString *filePath = [dir stringByAppendingPathComponent:fileName];
    return filePath;
}

-(void)removeAssetFromDirName:(NSString*)dirName{
    [self stopLinkDir:dirName];
   [[NSFileManager defaultManager] removeItemAtPath:[PhotoLinkPlugDir stringByAppendingPathComponent:dirName] error:nil] ;
    [self.photoCache removeObjectForKey:dirName];
}


-(NSString*)addVideThrow:(NSData*)data  fileName:(NSString*)fileName{
    NSString *file = [PhotoLinkPlugDir stringByAppendingPathComponent:fileName];
    [data writeToFile:file atomically:YES];
    self.photoLinkUrl = [NSString stringWithFormat:@"http://%@:%d/%@",[[UIDevice currentDevice] ipAddressWIFI],PhotoLiknPort,fileName];
    return file;
}

 -(void)startLinkPhotoVideo{
     [[DNLAController getInstance] showSelectDevice:^(NSInteger index) {
         [[UIApplication sharedApplication].keyWindow makeToast:@"投屏播放成功"];
         [[DNLAController getInstance] playWithPhotoUrl:self.photoLinkUrl isPic:false deviceIndex:index];
     }];
}

-(void)startLinkDir:(NSString*)dirName{
    self.lookDir = dirName;
    NSArray *arrayTmp = (NSArray*)[self.photoCache objectForKey:dirName];
    self.photosArray = [NSMutableArray arrayWithCapacity:10];
    [self.changePhotos  invalidate];self.changePhotos = nil;
    for (int i = 0; i < arrayTmp.count; i++) {
      SavePhotoInfo *info =   [arrayTmp objectAtIndex:i];
        NSString *url = [NSString stringWithFormat:@"http://%@:%d/%@/%@",[[UIDevice currentDevice] ipAddressWIFI],PhotoLiknPort,dirName,info.fileName] ;
        [self.photosArray addObject:url];
    }
    [[DNLAController getInstance] showSelectDevice:^(NSInteger index) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"投屏播放成功"];
        [self updateDevice:index];
    }];
}

-(void)changePlaySpeed:(NSInteger)playSpeed{
      changeSpeed = playSpeed;
    if (self.changePhotos) {
        [self.changePhotos invalidate];
        self.changePhotos = [NSTimer scheduledTimerWithTimeInterval:changeSpeed target:self selector:@selector(postPhotoTimer:) userInfo:nil repeats:YES];
    }
}

-(void)updateDevice:(NSInteger)index{
    self.deviceIndex = index;
    self.photosIndex = 0;
    self.changePhotos = [NSTimer scheduledTimerWithTimeInterval:changeSpeed target:self selector:@selector(postPhotoTimer:) userInfo:nil repeats:YES];
    [self postPhotoUrl:0];
}

-(void)postPhotoUrl:(NSInteger)index{
    [[DNLAController getInstance] playWithPhotoUrl:[self.photosArray objectAtIndex:index] isPic:true deviceIndex:self.deviceIndex];
}

-(void)postPhotoTimer:(NSTimer*)timer{
    [self postPhotoUrl:self.photosIndex];
    self.photosIndex = (self.photosIndex+1) % self.photosArray.count;
}

-(void)stopLinkDir:(NSString*)dirName
{
    if (self.lookDir && dirName && [self.lookDir compare:dirName]==NSOrderedSame) {
        [self.changePhotos  invalidate];
        self.changePhotos = nil;
    }
    if (dirName) {
        [self.changePhotos  invalidate];
        self.changePhotos = nil;
    }
}
@end
