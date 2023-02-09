//
//  ApiCoreManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WebConfigItem;
typedef void (^ApiCoreManagerCompletionBlock)(BOOL isSuccess,NSString*url);
@interface ApiCoreManager : NSObject
@property(copy)ApiCoreManagerCompletionBlock completionBlock;
+(ApiCoreManager*)getInstace;
-(void)stopApiReqeust;
-(void)startApiReqeust:(WKWebView*)webView config:(WebConfigItem*)config searchTitle:(NSString*)title urlMedia:(NSString*)urlMedia;
@end
