//
//  MajorZyCookie.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/9.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZyCookie.h"

@implementation MajorZyCookie

+(NSHTTPCookie*)getReadModeCookie{
NSHTTPCookie *cookie1 = [NSHTTPCookie cookieWithProperties:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"m.zymk.cn", NSHTTPCookieDomain,
                          @"/", NSHTTPCookiePath,
                          @"readmode",  NSHTTPCookieName,
                          @"1",  NSHTTPCookieVersion,
                          @"3", NSHTTPCookieValue,
                          @"FALSE",NSHTTPCookieSecure,
                          [[NSDate date]dateByAddingYears:1], NSHTTPCookieExpires,
                          nil]];
    return cookie1;
}

+(void)delCookie{
    if (@available(iOS 9.0, *)) {
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                             for (WKWebsiteDataRecord *record  in records) {
                                 //取消备注，可以针对某域名清除，否则是全清
                                 if ([record.displayName containsString:@"zymk"]) {
                                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                               forDataRecords:@[record]
                                                                            completionHandler:^{
                                                                                NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                            }];
                                 }
                                 }
                                 
                         }];
    } else {
        // Fallback on earlier versions
    }
}
@end
