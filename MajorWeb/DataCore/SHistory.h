//
//  SHistory.h
//  UrlWebViewForIpad
//
//  Created by Flipped on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHistory : NSObject<NSCoding>
{
    NSString *sName;
    NSString *sDate;
}
@property(nonatomic, strong) NSString *sName;
@property(nonatomic, strong) NSString *sDate;

@end
