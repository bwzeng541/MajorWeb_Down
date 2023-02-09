//
//  BottommTipsView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/7.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BottommTipsViewBlock)(NSURL *openUrl);
@interface BottommTipsView : UIView
-(instancetype)initWithFrame:(CGRect)frame barH:(float)barh appStoreUrl:(NSURL*)url sourceUrl:(NSURL*)sourceUrl des:(NSString*)des;
-(instancetype)initWithFrame:(CGRect)frame  des:(NSString*)des;
-(void)showAction;
-(void)remveAction;
@property(copy)BottommTipsViewBlock openUrlBlock;
@end
