//
//  ContentWebView+PlayLocalCaches.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/9.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "ContentWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentWebView (PlayLocalCaches)
-(BOOL)isPlayCacheFileSuccess:(NSString*)url title:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
