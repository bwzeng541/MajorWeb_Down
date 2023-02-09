//
//  WebPushCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebPushItem.h"
@class  BUNativeAdRelatedView;
NS_ASSUME_NONNULL_BEGIN
@interface WebPushCell : UITableViewCell
-(void)initWithItem:(WebPushItem*)item;
@end

NS_ASSUME_NONNULL_END
