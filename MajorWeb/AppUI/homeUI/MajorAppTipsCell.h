//
//  MajorAppTipsView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/25.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorHomeBaesCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface MajorAppTipsCell : MajorHomeBaesCell
-(id)initTextType:(NSInteger)type frame:(CGRect)frame;
@property(nonatomic,readonly)float cellSizeH;
@end

NS_ASSUME_NONNULL_END