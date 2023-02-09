//
//  VideoSortView.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HuanCunDirKey @"HuanCunDirKey"

#define Sort_key_uuid @"key_uuid"
#define Sort_key_name @"key_name"
#define Sort_key_Array @"key_Array"

#define Sort_YYCache_Sort_Value_key @"marjo_video_sort"
NS_ASSUME_NONNULL_BEGIN
@protocol  VideoSortViewDelegate <NSObject>
-(void)click_video_sort_view:(NSString*)key;
@end

@interface VideoSortView : UIView
-(void)updateArray:(NSArray*)sortArray;
-(void)updateSelect:(NSString*)key;
@property(weak,nonatomic)id<VideoSortViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
