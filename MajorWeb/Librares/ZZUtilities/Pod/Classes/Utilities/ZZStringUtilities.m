//
//  ZZStringUtilities.m
//  Five
//
//  Created by gluttony on 5/7/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "ZZStringUtilities.h"

NSString *ZZEcodeURLString(NSString *urlString)
{
    NSString *encodedUrlString = nil;
    encodedUrlString =
        [urlString stringByReplacingOccurrencesOfString:@"^"
                                             withString:@"%5E"];
    return encodedUrlString;
}

NSString *ZZStringFromBytes(unsigned long long bytes)
{
    static const void *sOrdersOfMagnitude[] = { @"bytes",
        @"KB",
        @"MB",
        @"GB" };

    // Determine what magnitude the number of bytes is by shifting off 10 bits at
    // a time
    // (equivalent to dividing by 1024).
    unsigned long magnitude = 0;
    unsigned long long highbits = bytes;
    unsigned long long inverseBits = ~((unsigned long long)0x3FF);
    while ((highbits & inverseBits) && magnitude + 1 < (sizeof(sOrdersOfMagnitude) / sizeof(void *))) {
        // Shift off an order of magnitude.
        highbits >>= 10;
        magnitude++;
    }

    if (magnitude > 0) {
        unsigned long long dividend = 1024 << (magnitude - 1) * 10;
        double result = ((double)bytes / (double)(dividend));
        return [NSString
            stringWithFormat:@"%.0f %@", result, sOrdersOfMagnitude[magnitude]];
    }
    else {
        // We don't need to bother with dividing bytes.
        return [NSString
            stringWithFormat:@"%lld %@", bytes, sOrdersOfMagnitude[magnitude]];
    }
}

NSString *ZZHtmlEntityDecode(NSString *encodedString)
{
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return encodedString;
}

BOOL ZZStringIsEmpty(NSString *destString)
{
    if (destString == nil ||
        [[destString stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]]
            isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
