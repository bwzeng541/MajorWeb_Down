//
//  NSData+AES256.h
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

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey: (NSString *)key;
- (NSData *)AES128DecryptWithKey: (NSString *)key;

//以上四个函数，加解密有问题，不能修改，会造成所有app加解密出问题
/* 不能使用
 [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
 NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
 CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
 keyData.bytes
 */
 //正确解密方式
- (NSData *)AES128DecryptWithKeyFix: (NSString *)key;
@end
