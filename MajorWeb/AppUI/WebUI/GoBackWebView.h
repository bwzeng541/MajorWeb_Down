//
//  GoBackWebView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/10.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^GoBackWebViewClose)(void);
typedef void (^GoBackWebViewClick)(NSString*url);

@interface GoBackWebView : UIView
@property(copy)GoBackWebViewClose closeBlock;
@property(copy)GoBackWebViewClick clickBlock;
-(instancetype)initWithFrame:(CGRect)frame bottomOffsetY:(float)bottomOffsetY;
@end
