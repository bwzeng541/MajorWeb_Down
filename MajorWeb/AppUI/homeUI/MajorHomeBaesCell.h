//
//  MajorHomeBaesCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/24.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MajorHomeBaesCell : UIView
@property(strong,nonatomic)UILabel *headLabel;
@property(strong,nonatomic)UILabel *rightLabel;
-(void)updateHeadColor:(UIColor*)color;
-(void)updateRightLableState;
@end

NS_ASSUME_NONNULL_END
