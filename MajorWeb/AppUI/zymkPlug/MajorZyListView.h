//
//  MajorZyListView.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/9.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorPopGestureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MajorZyListView : MajorPopGestureView
-(instancetype)initWithFrame:(CGRect)frame showName:(NSString*)showName array:(NSArray*)listArray dataSource:(NSString*)dataSource isPage:(BOOL)isPage closeBlcok:(void(^)(void))closeBlock;
-(void)loadHistroyUrl:(NSString*)url;
@end

NS_ASSUME_NONNULL_END
