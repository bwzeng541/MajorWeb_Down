//
//  ThrowUpdateFileManager.h
//  WatchApp
//
//  Created by zengbiwang on 2017/9/26.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#define Local_DirPath @"dirPath"
#define Local_FileName @"fileName"
@interface ThrowUpdateFileManager : NSObject
+(ThrowUpdateFileManager*)getInstance;
-(void)delFile:(NSString*)filePath;

-(NSArray*)getAllVideoFile;
-(void)delVideoFromAllFile:(NSInteger)index;

-(NSArray*)getShareVideoFile;
@end
