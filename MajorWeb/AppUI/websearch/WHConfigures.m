//
//  WHConfigures.m
//  UrlWebViewForIpad
//
//  Created by Meng Xiangping on 1/9/13.
//
//

#import "WHConfigures.h"
NSString *const kBaiduHomeSearchIPadURL = @"https://www.baidu.com/s?word=%@";
@implementation WHConfigures

+ (NSString *)baiduSearchLink:(NSString *)keyword
{
    return [NSString stringWithFormat:kBaiduHomeSearchIPadURL,keyword];

}

@end
