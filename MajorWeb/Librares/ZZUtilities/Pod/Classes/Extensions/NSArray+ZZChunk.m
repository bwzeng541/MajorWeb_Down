#import "NSArray+ZZChunk.h"

@implementation NSArray (ZZChunk)

- (NSArray * (^)(NSUInteger, NSUInteger))slice
{
    return ^id(NSUInteger start, NSUInteger length) {
        NSUInteger const N = self.count;

        if (N == 0)
            return self;

        // forgive
        if (start > N - 1)
            start = N - 1;
        if (start + length > N)
            length = N - start;

        return [self subarrayWithRange:NSMakeRange(start, length)];
    };
}

- (NSArray * (^)(NSUInteger))chunk
{
    return ^(NSUInteger size) {
        NSMutableArray *aa = [NSMutableArray new];
        const NSUInteger n = ceilf((CGFloat)self.count / (CGFloat)size);
        for (int x = 0; x < n; ++x)
            [aa addObject:self.slice(x * size, size)];
        return aa;
    };
}

@end
