//
//  WebCtrlCore.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentWebView.h"
//create  ContentWebView
@interface WebCtrlCore : NSObject
-(ContentWebView*)createNewWebView:(WebConfigItem*)webConfig arrayBack:(NSArray**)array;
-(void)removeContentWebView:(ContentWebView*)v;
-(void)updateFrontWebView:(ContentWebView*)v;
-(void)updateBackWebView:(ContentWebView*)v;
-(void)clearAllWeb;
-(void)initData;
-(NSArray*)getAlllLocalMarkWeb;
@end
