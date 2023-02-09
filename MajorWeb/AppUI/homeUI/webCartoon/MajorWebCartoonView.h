//
//  MajorWebCartoonView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/29.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorPopGestureView.h"
NS_ASSUME_NONNULL_BEGIN

@interface MajorWebCartoonView : MajorPopGestureView
-(id)initWithFrame:(CGRect)frame index:(NSInteger)index;
-(void)addDataItem:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll;
-(void)addDataArray:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll;
-(void)beginUrlRequest;
@end

NS_ASSUME_NONNULL_END
