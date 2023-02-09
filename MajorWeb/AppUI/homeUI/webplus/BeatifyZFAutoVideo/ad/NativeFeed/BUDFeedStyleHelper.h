//
//  BUDFeedStyleHelper.h
//  BUDemo
//
//  Created by carl on 2017/12/29.
//  Copyright © 2017年 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BUDFeedStyleHelper : NSObject
+ (NSAttributedString *)titleAttributeText:(NSString *)text scale:(float)scale;
+ (NSAttributedString *)subtitleAttributeText:(NSString *)text scale:(float)scale;
+ (NSAttributedString *)infoAttributeText:(NSString *)text scale:(float)scale;
@end
