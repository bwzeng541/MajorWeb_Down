//
//  MarjorNewSortView.h
//  MajorWeb
//
//  Created by zengbiwang on 2020/4/3.
//  Copyright © 2020 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class WebConfigItem;
typedef void (^MarjorNewSortViewClick)(WebConfigItem*item,id view);
@interface MarjorNewSortView : UIView
-(void)updateSortData:(NSArray*)array;
@property(copy)MarjorNewSortViewClick clickBlock;
@end

NS_ASSUME_NONNULL_END
