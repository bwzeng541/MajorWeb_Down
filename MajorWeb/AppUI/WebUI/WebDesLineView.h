//
//  WebDesLineView.h
//  WatchApp
//
//  Created by zengbiwang on 2017/11/28.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^WebDesLineViewClickBlock)(NSString*pipeValue);
typedef void (^WebDesLineViewClickIndexBlock)(NSInteger lineNo);
@interface WebDesLineView : UIView
@property(copy)WebDesLineViewClickIndexBlock lineNoPipeBlock;
@property(copy)WebDesLineViewClickBlock linePipeBlock;
-(void)initPipeData:(NSArray*)array;
@end
