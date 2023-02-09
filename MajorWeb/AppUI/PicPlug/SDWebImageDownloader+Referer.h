//
//  vvvvvv.h
//  WatchApp
//
//  Created by zengbiwang on 2018/7/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"
@interface SDWebImageDownloader (Referer)
- (nullable SDWebImageDownloadToken *)downloadImageWithURL:(nullable NSURL *)url refer:(NSString*)refer 
                                                   options:(SDWebImageDownloaderOptions)options
                                                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                                 completed:(nullable SDWebImageDownloaderCompletedBlock)completedBlock;
@end
