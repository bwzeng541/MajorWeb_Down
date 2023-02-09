//
//  MajorZyBridgeNode.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
//一章图分成多个网页解析器
NS_ASSUME_NONNULL_BEGIN
/*
 NSString *basePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/zymywww"];
 NSURL *baseUrl =  [NSURL fileURLWithPath:basePath isDirectory:YES];
 NSString *path = [NSString stringWithFormat:@"%@/index.html",basePath];
 NSString *urt= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
 //  request = [NSMutableURLRequest requestWithURL:urt];
 //  [self.majorWebView loadRequest:request];
 [self.majorWebView loadHTMLString:urt baseURL:[NSURL URLWithString:@"http://www.baidu.com"]];
 */
@interface MajorZyBridgeNode : NSObject
-(void)startWithUrl:(NSString*)webUrl totalBlock:(void(^)(NSInteger totalNo))totalBlock  imageBlock:(void(^)(NSString*imageDom,NSInteger index,NSInteger total))imageBlock;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
