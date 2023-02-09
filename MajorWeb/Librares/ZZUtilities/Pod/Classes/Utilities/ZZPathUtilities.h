//
//  ZZPathUtilities.h
//  Five
//
//  Created by gluttony on 5/9/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif

NSString *ZZPathForBundleResourceWithIntermediate(NSBundle *bundle,
    NSString *intermediate,
    NSString *fileName);

NSString *ZZPathForDocumentsResourceWithIntermediate(NSString *intermediate,
    NSString *fileName);

NSString *ZZPathForLibraryResourceWithIntermediate(NSString *intermediate,
    NSString *fileName);

NSString *ZZPathForCachesResourceWithIntermediate(NSString *intermediate,
    NSString *fileName);

NSString *ZZEnsureDirectoryWithIntermediateExists(
    NSSearchPathDirectory baseDirectory, NSString *intermediate,
    NSString *directoryName);

#if defined __cplusplus
};
#endif