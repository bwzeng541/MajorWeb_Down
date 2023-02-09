//
//  QRSearchCell.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRRecord.h"
NS_ASSUME_NONNULL_BEGIN

@interface QRSearchCell : UICollectionViewCell
-(void)buildItem:(NSDictionary*)item;
@end

NS_ASSUME_NONNULL_END
