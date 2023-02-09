//
//  MajorHistoryAndFavoriteCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/7.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSwipeCell.h"
@interface MajorHistoryAndFavoriteCell : RRSwipeCollectionViewCell
-(void)initVideoInfo:(NSString*)titleName url:(NSString*)url time:(NSString*)time base64Png:(NSString*)base64Png;
-(void)updateDelBtn:(BOOL)isShow rect:(CGRect)rect;
@end
