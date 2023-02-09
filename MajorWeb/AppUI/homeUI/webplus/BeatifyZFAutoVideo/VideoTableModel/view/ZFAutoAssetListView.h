//
//  ZFAutoAssetListView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZFAutoAssetListViewDelegate <NSObject>
-(void)clickAssetListView:(NSInteger)pos;
-(void)removeAssetListView;
@end
@interface ZFAutoAssetListView : UIView
@property(weak)id<ZFAutoAssetListViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
