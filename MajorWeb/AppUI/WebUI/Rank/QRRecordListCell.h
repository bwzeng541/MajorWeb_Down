//
//  QRRecordListCell.h
//  QRTools
//
//  Created by bxing zeng on 2020/5/6.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class QRRecordListCell;
@protocol QRRecordListCellDelegegate <NSObject>
-(void)clickDel:(QRRecordListCell*)cell;
@end
@interface QRRecordListCell : UICollectionViewCell
@property(weak)IBOutlet UILabel *timeLabel;
@property(weak)IBOutlet UILabel *desLabel;
@property(weak)IBOutlet UILabel *centerLabel;
@property(weak)IBOutlet UIButton *btnDel;
@property(weak)IBOutlet UIButton *btnRankDel;
@property(weak)id<QRRecordListCellDelegegate>delegate;
@end

NS_ASSUME_NONNULL_END
