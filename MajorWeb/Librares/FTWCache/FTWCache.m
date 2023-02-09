//
//  FTWCache.m
//  FTW
//
//  Created by Soroush Khanlou on 6/28/12.
//  Copyright (c) 2012 FTW. All rights reserved.
//

#import "FTWCache.h"
#import "NSData+AES256.h"
static NSTimeInterval cacheTime =  (double)60480000;
//static NSTimeInterval cacheTime =  (double)120;
@implementation FTWCache

+ (void) resetCache {
    [[NSFileManager defaultManager] removeItemAtPath:[FTWCache cacheDirectory] error:nil];
}

+ (NSString*) cacheDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"FTWCaches"];
    return cacheDirectory;
}

+ (NSData*) objectForKey:(NSString*)key useKey:(BOOL)isUesKey{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:key];
    
    if ([fileManager fileExistsAtPath:filename])
    {
        NSDate *modificationDate = [[fileManager attributesOfItemAtPath:filename error:nil] objectForKey:NSFileModificationDate];
        if (fabs([modificationDate timeIntervalSinceNow]) > cacheTime) {
            [fileManager removeItemAtPath:filename error:nil];
        } else {
            NSData *dataNew;
            NSData *data = [NSData dataWithContentsOfFile:filename];
            dataNew = data;
            if (isUesKey) {
               dataNew = [data AES256DecryptWithKey:AppAESKey];
            }
            return dataNew;
        }
    }
    return nil;
}


+ (void) removeObject:(NSString*)key{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:key];
    [fileManager removeItemAtPath:filename error:nil];
}


+ (void) setObject:(NSData*)data forKey:(NSString*)key useKey:(BOOL)isUesKey{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:key];
    
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:self.cacheDirectory isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSError *error;
    @try {
        NSData *dataNew = data;
        if (isUesKey) {
            dataNew = [data AES256EncryptWithKey:AppAESKey];
        }
        [dataNew writeToFile:filename options:NSDataWritingAtomic error:&error];
    }
    @catch (NSException * e) {
        //TODO: error handling maybe
    }
}

+ (NSString*)encryptWithKey:(NSString*)str{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataNew = [data AES256EncryptWithKey:AppAESKey];
    NSString *encryRet = [dataNew description];
    encryRet = [encryRet stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    encryRet = [encryRet stringByReplacingOccurrencesOfString:@"<" withString:@"_"];
    encryRet = [encryRet stringByReplacingOccurrencesOfString:@">" withString:@"_"];
    return encryRet;
}

+(NSData*)encryptWithKeyNomarl:(NSString *)str{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataNew = [data AES256EncryptWithKey:AppAESKey];
    return dataNew;
}
//
+ (NSString*)decryptWithKey:(NSData*)data{
    NSData *dataNew = [data AES256DecryptWithKey:AppAESKey];
    NSString *decryRet = [[[NSString alloc]initWithData:dataNew encoding:NSUTF8StringEncoding] autorelease];
    return decryRet;
}

+ (NSData*)decryptWithKeyToData:(NSData*)data{
    NSData *dataNew = [data AES256DecryptWithKey:AppAESKey];
    return dataNew;
}


@end
