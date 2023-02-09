//
//  PromptView.h
//  WatchApp
//
//  Created by zengbiwang on 2018/6/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Record;
typedef void (^PromptBlock)(Record *record);
@interface PromptView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
-(NSInteger)updateHotsArray:(NSArray*)arrayHots;
@property(copy)PromptBlock block;
@end
