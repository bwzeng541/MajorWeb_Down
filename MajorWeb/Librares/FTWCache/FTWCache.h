//
//  FTWCache.h
//  FTW
//
//  Created by Soroush Khanlou on 6/28/12.
//  Copyright (c) 2012 FTW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTWCache : NSObject

+ (void) resetCache;

+ (void) removeObject:(NSString*)key;
+ (void) setObject:(NSData*)data forKey:(NSString*)key useKey:(BOOL)isUesKey;
+ (id) objectForKey:(NSString*)key useKey:(BOOL)isUesKey;
+ (NSString*) cacheDirectory ;
+ (NSString*)encryptWithKey:(NSString*)str;
+ (NSString*)decryptWithKey:(NSData*)data;
+ (NSData*)encryptWithKeyNomarl:(NSString*)str;
+ (NSData*)decryptWithKeyToData:(NSData*)data;
@end
