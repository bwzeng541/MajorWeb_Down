//
//  NSString+ZZExtension.h
//  Five
//
//  Created by gluttony on 5/7/14.
//  Copyright (c) 2014 app111. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ZZExtension)

- (NSData *)ZZAES256EncryptWithKey:(NSString *)key;
- (NSData *)ZZAES256DecryptWithKey:(NSString *)key;

@end
