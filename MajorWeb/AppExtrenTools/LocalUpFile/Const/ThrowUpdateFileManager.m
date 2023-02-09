//
//  ThrowUpdateFileManager.m
//  WatchApp
//
//  Created by zengbiwang on 2017/9/26.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "ThrowUpdateFileManager.h"
#import "SGWiFiUploadManager.h"
#import "DateTools.h"
//#import "ShareKeyManager.h"
//#import "NSString+MJExtension.h"

@interface ThrowUpdateFileManager(){

}
@property(retain)NSMutableArray *arrayList;
@end

@implementation ThrowUpdateFileManager


+(ThrowUpdateFileManager*)getInstance{
    static ThrowUpdateFileManager *g = NULL;
    if (!g) {
        g = [[ThrowUpdateFileManager alloc]init];
    }
    return g;
}

-(id)init{
    self = [super init];
    [self getDocumentDirectoryVideo];
     return self;
}

-(void)delFile:(NSString*)filePath
{
    
}


-(NSArray*)getAllVideoFile
{
    return [self getDocumentDirectoryVideo];
}

-(NSArray*)getShareVideoFile{
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:1];
    return arrayTmp;
}

-(void)delVideoFromAllFile:(NSInteger)index
{
   NSDictionary *dicInfo =  [self.arrayList objectAtIndex:index];
   NSString *strDirPath = [dicInfo objectForKey:Local_DirPath];
   NSString *strFileName = [dicInfo objectForKey:Local_FileName];
    
    NSRange range = [strFileName rangeOfString:@"upload_wifi/"];
    if (range.location != NSNotFound) {
#if DoNotKMPLayerCanShareVideo
#else
     //   NSString *uuid = [strFileName substringFromIndex:range.location+5];
       // [[ShareKeyManager getInstance] removeShareState:uuid];
#endif
    }
   [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/%@",strDirPath,strFileName] error:NULL];
   [self.arrayList removeObjectAtIndex:index];
}

//所有文件
-(NSArray*)getDocumentDirectoryVideo{
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"upload_wifi"];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator;
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    //NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    NSString *fileName = nil;
    while((fileName=[myDirectoryEnumerator nextObject])!=nil)
        
    {
        NSString *strFile =   [fileName.pathExtension lowercaseString];
        
        //WMV，AVI，MKV，RMVB，RM，XVID，MP4，3GP，MPG
        if ([strFile rangeOfString:@"mp4"].location != NSNotFound || [strFile rangeOfString:@"mov"].location != NSNotFound ||
            [strFile rangeOfString:@"wmv"].location != NSNotFound || [strFile rangeOfString:@"avi"].location != NSNotFound ||
            [strFile rangeOfString:@"mkv"].location != NSNotFound || [strFile rangeOfString:@"rmvb"].location != NSNotFound ||
            [strFile rangeOfString:@"rm"].location != NSNotFound || [strFile rangeOfString:@"xvid"].location != NSNotFound ||
            [strFile rangeOfString:@"3gp"].location != NSNotFound || [strFile rangeOfString:@"mpg"].location != NSNotFound ) {
            
            NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:fileName,Local_FileName,path,Local_DirPath, nil];
            [arrayTmp addObject:dicInfo];
        }
    }
    self.arrayList = arrayTmp;
    return self.arrayList;
}
@end
