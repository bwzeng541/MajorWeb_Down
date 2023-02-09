//
//  Record.m
//  UrlWebViewForIpad
//
//  Created by Flipped on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Record.h"
@implementation Record
@synthesize titleNum;
@synthesize titleName;
@synthesize iconStr;
@synthesize titleUrl;
@synthesize typeStr;
@synthesize dateStr;
@synthesize superNum;
@synthesize subNum;
@synthesize dataCount;
@synthesize webUrl;

- (void) dealloc
{
  //NSLog(@"%s",__FUNCTION__);
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.titleNum forKey:@"titleNum"];
    [aCoder encodeObject:self.titleName forKey:@"titleName"];
	[aCoder encodeObject:self.iconStr forKey:@"iconStr"];
	[aCoder encodeObject:self.titleUrl forKey:@"titleUrl"];
    [aCoder encodeObject:self.typeStr forKey:@"typeStr"];
    [aCoder encodeObject:self.dateStr forKey:@"dateStr"];
    [aCoder encodeObject:self.superNum forKey:@"superNum"];
    [aCoder encodeObject:self.subNum forKey:@"subNum"];
    [aCoder encodeObject:self.dataCount forKey:@"dataCount"];
    [aCoder encodeObject:self.webUrl forKey:@"webUrl"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [[Record alloc] init];
	if(self != nil)
    {
        self.titleNum = [aDecoder decodeObjectForKey:@"titleNum"];
        self.titleName = [aDecoder decodeObjectForKey:@"titleName"];
		self.iconStr = [aDecoder decodeObjectForKey:@"iconStr"];
		self.titleUrl = [aDecoder decodeObjectForKey:@"titleUrl"];
        self.typeStr = [aDecoder decodeObjectForKey:@"typeStr"];
        self.dateStr = [aDecoder decodeObjectForKey:@"dateStr"];
        self.superNum = [aDecoder decodeObjectForKey:@"superNum"];
        self.subNum = [aDecoder decodeObjectForKey:@"subNum"];
        self.dataCount = [aDecoder decodeObjectForKey:@"dataCount"];
        self.webUrl = [aDecoder decodeObjectForKey:@"webUrl"];
	}
	
	return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"\n\ttitleNum: %@"
                                       "\n\ttitleName: %@"
                                       "\n\ticonStr: %@"
                                       "\n\ttitleUrl: %@"
                                       "\n\ttypeStr: %@"
                                       "\n\tdateStr: %@"
                                       "\n\tsuperNum: %@"
                                       "\n\tsubNum: %@"
                                       "\n\tdataCount: %@\n\n", titleNum, titleName, iconStr, titleUrl, typeStr, dateStr, superNum, subNum, dataCount];

}

@end


@implementation WebTailorFavoriteRecord
- (void) dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.record forKey:@"record"];
    [aCoder encodeObject:self.key forKey:@"key"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [[WebTailorFavoriteRecord alloc] init];
    if(self != nil)
    {
        self.record = [aDecoder decodeObjectForKey:@"record"];
        self.key = [aDecoder decodeObjectForKey:@"key"];
    }
    
    return self;
}

@end
