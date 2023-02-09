//
//  NSString+ZZExtension.h
//  Five
//
//  Created by gluttony on 5/7/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZZExtension)

- (NSString *)ZZURLEncodedString;
- (NSString *)ZZURLDecodedString;

+ (NSURL *)ZZURLFromURLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters;
+ (NSString *)ZZURLEncodedStringFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)ZZURLDecodedDictionaryFromString:(NSString *)string;

@end
