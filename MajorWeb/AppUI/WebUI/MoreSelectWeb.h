//
//  MoreSelectWeb.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/12.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MoreSelectBlock)(id panel);
@interface MoreSelectWeb : UIView
-(id)initWithFrame:(CGRect)frame selectBlock:(MoreSelectBlock)selectBlock;
@end

NS_ASSUME_NONNULL_END
