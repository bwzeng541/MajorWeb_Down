//
//  ZZPathUtilities.m
//  Five
//
//  Created by gluttony on 5/9/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "ZZPathUtilities.h"
#import "ZZConstants.h"
#import "NimbusCore.h"

NSString *ZZPathForBundleResourceWithIntermediate(NSBundle *bundle,
    NSString *intermediate,
    NSString *fileName)
{
    NSString *relativePath = intermediate ? [intermediate stringByAppendingPathComponent:fileName]
                                          : fileName;
    return NIPathForBundleResource(bundle, relativePath);
}

NSString *ZZPathForDocumentsResourceWithIntermediate(NSString *intermediate,
    NSString *fileName)
{
    NSString *relativePath = intermediate ? [intermediate stringByAppendingPathComponent:fileName]
                                          : fileName;
    return NIPathForDocumentsResource(relativePath);
}

NSString *ZZPathForLibraryResourceWithIntermediate(NSString *intermediate,
    NSString *fileName)
{
    NSString *relativePath = intermediate ? [intermediate stringByAppendingPathComponent:fileName]
                                          : fileName;
    return NIPathForLibraryResource(relativePath);
}

NSString *ZZPathForCachesResourceWithIntermediate(NSString *intermediate,
    NSString *fileName)
{
    NSString *relativePath = intermediate ? [intermediate stringByAppendingPathComponent:fileName]
                                          : fileName;
    return NIPathForCachesResource(relativePath);
}

void ZZEnsureCachesDirectoryExist(NSString *cachesDirectoryName)
{
    NSString *cachesPath = NIPathForCachesResource(cachesDirectoryName);
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachesPath
                                             isDirectory:&isDir]) {
        NIDWARNING(@"File %@ exists", cachesPath);
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:cachesPath error:&error];
        if (error) {
            NIDERROR(@"error = %@", error);
        }
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachesPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cachesPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NIDERROR(@"error = %@", error);
        }
    }
}

NSString *ZZEnsureDirectoryWithIntermediateExists(
    NSSearchPathDirectory baseDirectory, NSString *intermediate,
    NSString *directoryName)
{
    NSString *fullPath;
    switch (baseDirectory) {
    case NSDocumentDirectory:
        fullPath = ZZPathForDocumentsResourceWithIntermediate(intermediate, directoryName);
        break;
    case NSLibraryDirectory:
        fullPath = ZZPathForLibraryResourceWithIntermediate(intermediate, directoryName);
        break;
    case NSCachesDirectory:
        fullPath = ZZPathForCachesResourceWithIntermediate(intermediate, directoryName);
        break;
    default:
        break;
    }
    if (fullPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                NIDERROR(@"error = %@", error);
            }
        }
    }

    return fullPath;
}
