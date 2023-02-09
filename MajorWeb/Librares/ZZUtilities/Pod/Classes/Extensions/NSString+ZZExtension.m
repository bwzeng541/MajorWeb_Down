//
//  NSString+ZZExtension.m
//  Five
//
//  Created by gluttony on 5/7/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "NSString+ZZExtension.h"

@implementation NSString (ZZExtension)

- (NSString *)ZZURLEncodedString
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault,
        (__bridge CFStringRef)self,
        NULL,
        CFSTR("!*'();:@&=+$,/?%#[]"),
        kCFStringEncodingUTF8);
    return result;
}

- (NSString *)ZZURLDecodedString
{
    NSString *result = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
            kCFAllocatorDefault,
            (__bridge CFStringRef)self,
            CFSTR(""),
            kCFStringEncodingUTF8);
    return result;
}

+ (NSURL *)ZZURLFromURLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
{
    NSURL *URL = nil;
    if ([parameters count]) {
        NSString *encodedParameters =
            [NSString ZZURLEncodedStringFromDictionary:parameters];
        URL = [NSURL
            URLWithString:[URLString
                              stringByAppendingFormat:@"?%@", encodedParameters]];
    }
    else {
        URL = [NSURL URLWithString:URLString];
    }
    return URL;
}

+ (NSString *)ZZURLEncodedStringFromObject:(id)object
{
    NSString *string = object;
    if (![string isKindOfClass:[NSString class]]) {
        string = [NSString stringWithFormat:@"%@", object];
    }
    return [string ZZURLEncodedString];
}

+ (NSString *)ZZURLEncodedStringFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in dictionary) {
        id value = dictionary[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        }
        NSString *part = [NSString stringWithFormat:@"%@=%@",
                                   [key ZZURLEncodedString],
                                   [value ZZURLEncodedString]];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}

+ (NSDictionary *)ZZURLDecodedDictionaryFromString:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *comp in components) {
        NSArray *parts = [comp componentsSeparatedByString:@"="];
        if ([parts count] != 2) {
            continue;
        }
        NSString *key = parts[0];
        NSString *value = parts[1];
        [dict setValue:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
