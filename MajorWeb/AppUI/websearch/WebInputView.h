//
//  WebInputView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/6.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WebInputViewDelegate <NSObject>
-(void)clickCharFromInputView:(NSString*)str;
@end
@interface WebInputView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
@property(weak)id<WebInputViewDelegate>delegate;
@end
