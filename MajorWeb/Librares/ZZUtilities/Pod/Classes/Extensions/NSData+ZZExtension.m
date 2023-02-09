//
//  NSString+ZZExtension.m
//  Five
//
//  Created by gluttony on 5/7/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import "NSData+ZZExtension.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (ZZExtension)

- (NSData *)ZZAES256EncryptWithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));

    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    char byte[] = {
        0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0b,
        0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0b,
    };

    size_t numBytesEncrypted = 0;
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0x0000, keyPtr, kCCKeySizeAES256,
        byte,
        [self bytes], dataLength,
        buffer, bufferSize,
        &numBytesEncrypted);

    if (result == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)ZZAES256DecryptWithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));

    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    char byte[] = {
        0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0b,
        0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0b,
    };

    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0x0000, keyPtr, kCCKeySizeAES256,
        byte,
        [self bytes], dataLength,
        buffer, bufferSize,
        &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end
