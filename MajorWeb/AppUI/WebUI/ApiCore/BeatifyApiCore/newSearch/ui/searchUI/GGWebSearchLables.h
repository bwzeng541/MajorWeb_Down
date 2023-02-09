//
//  GGWebSearchLables.h
//  GGBrower
//
//  Created by zengbiwang on 2019/12/13.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol GGWebSearchLablesDelegate <NSObject>
-(void)ggWebSearchLablesClick:(NSString*)words;
@end
@interface GGWebSearchLables : UIView
-(instancetype)initWithFrame:(CGRect)frame    wordArray:(NSArray*)wordArray   delegate:(id<GGWebSearchLablesDelegate>)delegate maxLine:(NSInteger)maxLine;

@end

NS_ASSUME_NONNULL_END
