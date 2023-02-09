#import <Foundation/Foundation.h>

@interface NSArray (ZZChunk)

- (NSArray * (^)(NSUInteger start, NSUInteger length))slice;
- (NSArray * (^)(NSUInteger))chunk;

@end
