//
//  QRMultiView.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRRecord.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^QRMultiViewBlock)(QRSearhWord *word);
@interface QRMultiView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
-(NSInteger)updateHotsArray:(NSArray*)arrayHots;
@property(copy)QRMultiViewBlock block;
@end

NS_ASSUME_NONNULL_END
