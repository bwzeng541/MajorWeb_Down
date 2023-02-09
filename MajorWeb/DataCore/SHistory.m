//
//  SHistory.m
//  UrlWebViewForIpad
//
//  Created by Flipped on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SHistory.h"

@implementation SHistory
@synthesize sName;
@synthesize sDate;
- (void) dealloc
{
  NSLog(@"%s",__FUNCTION__);
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.sName forKey:@"sName"];
    [aCoder encodeObject:self.sDate forKey:@"sDate"];
    //    [aCoder encodeObject:self.picData forKey:@"picData"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [[SHistory alloc] init];
	if(self != nil)
    {
        self.sName = [aDecoder decodeObjectForKey:@"sName"];
        self.sDate = [aDecoder decodeObjectForKey:@"sDate"];
        //        self.picData = [aDecoder decodeObjectForKey:@"picData"];
	}
	
	return self;
}
@end
