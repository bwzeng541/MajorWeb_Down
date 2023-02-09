//
//  VipWebView.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/4.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VipWebView : UIView
-(id)initWithFrame:(CGRect)frame url:(NSString*)url  buyBlock:(void(^)(NSString *res))buyBlock loginBlock:(void(^)(NSString* resp))loginBlock closeBlock:(void(^)(void))closeBlock;
@end

NS_ASSUME_NONNULL_END
