//
//  BeatifyWebAdManager.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define WebAdDomCssKey @"css_Key"
#define WebAdDomTimeKey @"time_Key"
@interface BeatifyWebAdManager : NSObject
+(BeatifyWebAdManager*)getInstance;
-(void)addAdDom:(NSString*)url domCss:(NSString*)domCss;
-(void)removeAdDom:(NSString*)url domCss:(NSString*)domCss;
-(NSArray*)getAdDomCssAndTime:(NSString*)url;
-(NSArray*)getAdDomCss:(NSString*)url;
@end

NS_ASSUME_NONNULL_END
