//
//  ReadModeWeb.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/29.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
//专门用来请求数据
@protocol ReadModeWebCallBack<NSObject>
-(void)readMoreWebContent:(NSString*)content title:(NSString*)title nextUrl:(NSString*)url;
@end
@interface ReadModeWeb : UIView
-(void)loadUrl:(NSString*)url;
@property(assign)id<ReadModeWebCallBack>contentDelegate;
@end
