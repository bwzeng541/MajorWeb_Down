//
//  MajorCartoonCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/29.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCartoonItem.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MajorCartoonCellDelegate <NSObject>
-(BOOL)isCanReqeustAdCell:(NSIndexPath*)indexPath;
-(void)saveCartoonImageSize:(NSString*)uuid imageSize:(CGSize)imageSize;
@end
@interface MajorCartoonCell : UICollectionViewCell
@property(nonatomic,readonly)WebCartoonItem *cartoonItem;
@property(nonatomic,readonly)NSIndexPath *indexPath;
-(void)configWithConfig:(WebCartoonItem*)config index:(NSInteger)index tableView:(id)tabelView;
 @property(weak,nonatomic)id<MajorCartoonCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
