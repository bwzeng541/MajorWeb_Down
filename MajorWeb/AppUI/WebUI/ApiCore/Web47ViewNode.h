//
//  Web47ViewNode.h
//  WatchApp
//
//  Created by zengbiwang on 2017/4/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewBase.h"
#import "Toast+UIView.h"
@interface Web47ViewNode : WebViewBase
@property(nonatomic,copy)NSString *iosUserAnget;
@property(nonatomic,copy)NSString *realUrl;
@property(nonatomic,copy)NSString *htmlUrl;
@property(nonatomic,assign)BOOL  isGoToBatchPip;
@property(nonatomic,assign)BOOL isNoPcWeb;
-(id)initWithUrl:(NSString*)url firstVideo:(NSString*)firstVideo showName:(NSString*)showName pareApihttp:(NSString*)apiHttp htmlBody:(NSString*)htmlBody isShowFailMsg:(BOOL)f forceUrl47Node:(BOOL)_f isDirectApi:(BOOL)isDirectApi isBatch:(BOOL)isBatch;
@end
