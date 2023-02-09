//
//  WebPushView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MajorPopGestureView.h"
NS_ASSUME_NONNULL_BEGIN

@interface WebPushView : MajorPopGestureView
+(BOOL)isShow;
-(void)addDataItem:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll;
-(void)addDataArray:(id)item isRemoveOldAll:(BOOL)isRemoveOldAll;
-(void)loadHome;
@end

NS_ASSUME_NONNULL_END
