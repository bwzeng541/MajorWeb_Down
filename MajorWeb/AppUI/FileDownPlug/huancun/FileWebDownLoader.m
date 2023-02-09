//
//  FileWebDownLoader.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "FileWebDownLoader.h"
#import "GCDWebDAVServer.h"
#import "GCDWebServerErrorResponse.h"

@interface FileWebDownLoader()
{
    NSMutableDictionary *uuidInfo;
}
@end
@implementation FileWebDownLoader
- (instancetype)initWithUploadDirectory:(NSString*)path{
    self = [super initWithUploadDirectory:path];
    self.allowedFileExtensions = @[@"mp4"];
    uuidInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    return self;
}

-(void)initUUidInfo:(NSArray*)array{
    id object = nil;
    for (NSInteger i=0; i < array.count; i++) {
        object = [array objectAtIndex:i];
        if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSClassFromString(@"GuanliNSDictionary") class]]) {
            NSString *_uuid  = [object objectForKey:StateUUIDKEY];
            [uuidInfo setObject:object forKey:_uuid];
        }
    }
}

-(BOOL)isDownFile:(NSString*)key{
    NSDictionary*info = [uuidInfo objectForKey:key];
    if (info) {
        id value1 = [info objectForKey:M3U8_DOWN_FINIHES];
        id value2 = [info objectForKey:ALONE_DOWN_FINIHES];
        if (value1) {
            return [value1 boolValue];
        }
        return [value2 boolValue];
    }
    return true;
}

-(NSString*)fileName:(NSString*)key{
    NSDictionary*info = [uuidInfo objectForKey:key];
    NSString *name1 = [info objectForKey:ALONE_VIDEO_SHOW_NAME];
    NSString *name2 = [info objectForKey:M3U8_VIDEO_FILE_NAME];
    NSString *file = name1?name1:name2;
    return file;
}

- (BOOL)shouldUploadFileAtPath:(NSString*)path withTemporaryFile:(NSString*)tempPath {
    return NO;
}

- (BOOL)shouldMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    return NO;
}

- (BOOL)shouldDeleteItemAtPath:(NSString*)path {
    return NO;
}

- (BOOL)shouldCreateDirectoryAtPath:(NSString*)path {
    return NO;
}

- (GCDWebServerResponse*)listDirectory:(GCDWebServerRequest*)request {
    NSString* relativePath = [[request query] objectForKey:@"path"];
    //if ([relativePath compare:@"/"]==NSOrderedSame) {
    [uuidInfo removeAllObjects];
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[[AppWtManager getInstanceAndInit]getWtCallBack:DOWNAPICONFIG.msgappf10]];
    [dataArray addObjectsFromArray:[[AppWtManager getInstanceAndInit]getWtCallBack:DOWNAPICONFIG.msgappf14]];
    [self initUUidInfo:dataArray];
    //}
    NSString* absolutePath = [self.uploadDirectory stringByAppendingPathComponent:relativePath];
    BOOL isDirectory = NO;
    if (![self _checkSandboxedPath:absolutePath] || ![[NSFileManager defaultManager] fileExistsAtPath:absolutePath isDirectory:&isDirectory]) {
        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_NotFound message:@"\"%@\" does not exist", relativePath];
    }
    if (!isDirectory) {
        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_BadRequest message:@"\"%@\" is not a directory", relativePath];
    }
    
    NSString* directoryName = [absolutePath lastPathComponent];
    if (!self.allowHiddenItems && [directoryName hasPrefix:@"."]) {
        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"Listing directory name \"%@\" is not allowed", directoryName];
    }
    
    NSError* error = nil;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:&error];
    if (contents == nil) {
        return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError underlyingError:error message:@"Failed listing directory \"%@\"", relativePath];
    }
    
    NSMutableArray* array = [NSMutableArray array];
    for (NSString* item in [contents sortedArrayUsingSelector:@selector(localizedStandardCompare:)]) {
        if (self.allowHiddenItems || ![item hasPrefix:@"."]) {
            NSString *key = [item stringByDeletingPathExtension];
            NSString *showName = [self fileName:key];
            NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[absolutePath stringByAppendingPathComponent:item] error:NULL];
            NSString* type = [attributes objectForKey:NSFileType];
            if ([key rangeOfString:@"videoSortTable"].location==NSNotFound && [key rangeOfString:@"urluuidconfig"].location==NSNotFound) {
                if ([type isEqualToString:NSFileTypeRegular] && [self _checkFileExtension:item]) {
                    if([self isDownFile:key])
                        [array addObject:@{
                                           @"path" : [relativePath stringByAppendingPathComponent:item],
                                           @"name" : showName?showName:item,
                                           @"size" : (NSNumber*)[attributes objectForKey:NSFileSize]
                                           }];
                } else if ([type isEqualToString:NSFileTypeDirectory]) {
                    if([self isDownFile:key])
                        [array addObject:@{
                                           @"path" : [[relativePath stringByAppendingPathComponent:item] stringByAppendingString:@"/"],
                                           @"name" : showName?showName:item
                                           }];
                }
            }
        }
    }
    return [GCDWebServerDataResponse responseWithJSONObject:array];
}
@end
