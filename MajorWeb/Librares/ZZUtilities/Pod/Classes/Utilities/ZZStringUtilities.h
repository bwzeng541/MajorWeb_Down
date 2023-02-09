//
//  ZZStringUtilities.h
//  Five
//
//  Created by gluttony on 5/7/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif

NSString *ZZEcodeURLString(NSString *urlString);

NSString *ZZStringFromBytes(unsigned long long bytes);

BOOL ZZStringIsEmpty(NSString *destString);

NSString *ZZHtmlEntityDecode(NSString *encodedString);

#if defined __cplusplus
};
#endif
