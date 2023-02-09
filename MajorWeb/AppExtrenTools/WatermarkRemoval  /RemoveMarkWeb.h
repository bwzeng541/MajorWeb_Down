//
//  RemoveMarkWeb.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/25.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebViewBase.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^RemoveMarkWebMsgBlock)(NSString *videoUrl,NSString*referrer);
@interface RemoveMarkWeb : WebViewBase
-(id)initWithUrl:(NSString*)url searchUrl:(NSString*)searchUrl waitView:(UIView*)waitView;
@property(copy)RemoveMarkWebMsgBlock removeMarkMsgBlock;
-(void)startDelay:(float)delayTime;
@end

NS_ASSUME_NONNULL_END
