//
//  BeatifyAdListView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol   BeatifyAdListViewDelegate <NSObject>
-(void)adList_WillRemove:(BOOL)isReload;
@end

@interface BeatifyAdListView : UIView
@property(weak)id<BeatifyAdListViewDelegate>delegate;

/**
 *  内容视图
 */
@property (nonatomic, strong) UIView *contentView;
/**
 *  按钮高度
 */
@property (nonatomic, assign) CGFloat buttonH;
/**
 *  按钮的垂直方向的间隙
 */
@property (nonatomic, assign) CGFloat buttonMargin;
/**
 *  内容视图的位移
 */
@property (nonatomic, assign) CGFloat contentShift;
/**
 *  动画持续时间
 */
@property (nonatomic, assign) CGFloat animationTime;
/**
 * tableView的高度
 */
@property (nonatomic, assign) CGFloat tableViewH;

/**
 *  展示popView
 *
 *  @param array button的title数组
 */
- (void)showThePopViewWithArray:(NSMutableArray *)array md5:(NSString*)md5;

//写一个展示view的操作




/**
 *  移除popView
 */
- (void)dismissThePopView;




@end

NS_ASSUME_NONNULL_END
