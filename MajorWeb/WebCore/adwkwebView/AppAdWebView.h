//
//  AppAdWebView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/10.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AppAdWebViewDelegate<NSObject>
-(void)willRemoveFromSuperView:(BOOL)isMode;
@end
@interface AppAdWebView : UIView
@property(nonatomic,weak)id<AppAdWebViewDelegate>delegate;
-(void)loadUrl:(NSString*)url isNewMode:(BOOL)isNewMode;
@end
