//
//  ModifyDetailCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class WebConfigItem;
@protocol WebConfigItemDelegate <NSObject>
-(void)syncWebConfigItemData:(WebConfigItem*)item index:(NSInteger)index;
-(void)syncWebConfigItemDelData:(WebConfigItem*)item index:(NSInteger)index;
@end
@interface ModifyDetailCell : UICollectionViewCell
-(void)updateConfigItem:(WebConfigItem*)configItem index:(NSInteger)index delegate:(id<WebConfigItemDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
