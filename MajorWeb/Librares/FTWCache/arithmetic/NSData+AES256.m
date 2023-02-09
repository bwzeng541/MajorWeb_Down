//
//  NSData+AES256.m
//  AES
//
//  Created by Henry Yu on 2009/06/03.
//  Copyright 2010 Sevensoft Technology Co., Ltd.(http://www.sevenuc.com)
//  All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "NSData+AES256.h"
@implementation NSData (AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
 
	void *Encodebuffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  Encodebuffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:Encodebuffer length:numBytesEncrypted freeWhenDone:YES];
	}
	
	free(Encodebuffer); //free the buffer;
    Encodebuffer = NULL;
	return nil;
}

- (NSData *)AES128DecryptWithKeyFix: (NSString *)key{
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    void *Decryptbuffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyData.bytes, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          Decryptbuffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:Decryptbuffer length:numBytesDecrypted freeWhenDone:YES];
    }
    
    free(Decryptbuffer); //free the buffer;
    Decryptbuffer = NULL;
    return nil;
}

- (NSData*)DecryptWithKey:(NSString*)key keyLength:(NSInteger)keyLength{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[keyLength+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    
   
    void *Decryptbuffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, keyLength,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          Decryptbuffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:Decryptbuffer length:numBytesDecrypted freeWhenDone:YES];
    }
    
    free(Decryptbuffer); //free the buffer;
    Decryptbuffer = NULL;
    return nil;
}

- (NSData *)AES256DecryptWithKey: (NSString *)key {
    return [self DecryptWithKey:key keyLength:kCCKeySizeAES256];
}


- (NSData *)AES128DecryptWithKey: (NSString *)key{
    return [self DecryptWithKey:key keyLength:kCCKeySizeAES128];
}


@end
