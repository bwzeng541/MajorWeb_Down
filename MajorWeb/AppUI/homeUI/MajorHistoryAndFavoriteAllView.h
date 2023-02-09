//
//  MajorHistoryAndFavoriteAllView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/31.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorPopGestureView.h"

typedef void (^MajorHistoryAndFavoriteAllViewSelectBlock)(NSString *url,NSString *name);

@interface MajorHistoryAndFavoriteAllView : MajorPopGestureView
-(instancetype)initWithFrame:(CGRect)frame array:(NSArray*)list type:(MajorShowAllContentType)contentType;
@property(nonatomic,readonly)MajorShowAllContentType contentType;
@property(copy)MajorHistoryAndFavoriteAllViewSelectBlock liveClickBlock;
 @end
