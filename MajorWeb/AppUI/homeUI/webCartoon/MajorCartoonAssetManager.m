//
//  MajorCartoonAssetManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/1.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorCartoonAssetManager.h"
#import "WebCartoonItem.h"
#import "YBImageBrowserDownloader.h"
#import "UIImage+webCartoonTools.h"
@interface MajorCartoonAssetManager()
{
    __weak id downloadToken;
    NSMutableDictionary *wecCattoonInfo;
    NSMutableArray *keyArray;
    BOOL isStart;
}
@property(copy,nonatomic)NSString *donwUUID;
@end
@implementation MajorCartoonAssetManager
+(MajorCartoonAssetManager*)getInstance{
    static MajorCartoonAssetManager*g = NULL;
    if (!g) {
        g = [[MajorCartoonAssetManager alloc] init];
    }
    return g;
}

-(BOOL)addAssetInfo:(WebCartoonItem*)item{
    return false;
    if( [item tryToLoaclFile])return false;
    if (!wecCattoonInfo) {
        wecCattoonInfo = [NSMutableDictionary dictionaryWithCapacity:10];
        keyArray = [NSMutableArray arrayWithCapacity:10];
    }
    if (![wecCattoonInfo objectForKey:item.uuid]) {
        [wecCattoonInfo setObject:item forKey:item.uuid];
        [keyArray addObject:item.uuid];
        [self startDown];
        return true;
    }
    return true;
}

-(void)clearAllAsset{
    [self cancelDownLoad];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startDown) object:nil];
    [wecCattoonInfo removeAllObjects];
    [keyArray removeAllObjects];
    isStart = false;
}

-(void)startDown{
    if (!isStart && keyArray.count>0) {
        isStart = true;
       WebCartoonItem *downItem =  [wecCattoonInfo objectForKey:[keyArray firstObject]] ;
        [self.delegate beginCartoonAsset:downItem];
        self.donwUUID = downItem.uuid;
        downloadToken = [YBImageBrowserDownloader downloadWebImageWithUrl:[NSURL URLWithString:downItem.picUrl] referer:NULL options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
         } success:^(UIImage * _Nullable image, NSData * _Nullable data, BOOL finished) {
           // NSLog(@"SDWebImageDownloaderProgressiveDownload success %d",finished);
             if (finished) {
                 dispatch_async(dispatch_get_global_queue(0, 0), ^{
                     [image saveImageToPath:downItem.filePath];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self cancelDownFormUUID:self.donwUUID];
                         [[NSNotificationCenter defaultCenter]postNotificationName:self.donwUUID object:@{@"imageKey":image,@"finshState":@(finished)}];
                     });
                 });
             }
             else {
               //  [[NSNotificationCenter defaultCenter]postNotificationName:self.donwUUID object:@{@"imageSizeKey":image,@"finshState":@(finished)}];

                 [[NSNotificationCenter defaultCenter]postNotificationName:self.donwUUID object:@{@"imageKey":image,@"finshState":@(finished)}];
             }
        } failed:^(NSError * _Nullable error, BOOL finished) {
            [[NSNotificationCenter defaultCenter]postNotificationName:self.donwUUID object:@{@"errorKey":@(0)}];
            [self cancelDownFormUUID:self.donwUUID];
        }];
    }
}

-(void)cancelDownLoad{
    if (downloadToken) {
        [YBImageBrowserDownloader cancelTaskWithDownloadToken:downloadToken];
        downloadToken = NULL;
    }
}

-(void)cancelDownFormUUID:(NSString*)uuid{
    [self cancelDownLoad];
    [self removeFormUUID:uuid];
    isStart = false;
    [self performSelector:@selector(startDown) withObject:nil afterDelay:0.5];
}

-(void)removeFormUUID:(NSString*)uuid{
    [keyArray removeObject:uuid];
    [wecCattoonInfo removeObjectForKey:uuid];
}

-(void)removeAssetInfo:(WebCartoonItem*)item{
    if ([self.donwUUID isEqualToString:item.uuid]) {
        [self cancelDownFormUUID:item.uuid];
    }
    else{
        [self removeFormUUID:item.uuid];
    }
}
@end
