//
//  SavePhotoInfo.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "SavePhotoInfo.h"

@implementation SavePhotoInfo
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.dirName = [aDecoder decodeObjectForKey:@"dirName"];
        self.iconfileName = [aDecoder decodeObjectForKey:@"iconfileName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.dirName forKey:@"dirName"];
    [aCoder encodeObject:self.iconfileName forKey:@"iconfileName"];
}
@end
