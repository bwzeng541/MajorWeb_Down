//
//  MarjorCartoonLayout.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/2.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MarjorCartoonLayoutDelegate <NSObject>
-(CGSize)carToonItemSize:(NSInteger)index;
-(NSInteger)carToonItemNumber;
@end
@interface MarjorCartoonLayout : UICollectionViewFlowLayout
@property(weak,nonatomic)id<MarjorCartoonLayoutDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
