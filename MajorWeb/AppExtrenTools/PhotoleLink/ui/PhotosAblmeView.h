//
//  PhotosAblmeView.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PhotosAblmeViewDelegate <NSObject>
-(void)photos_ablme_add:(NSInteger)index;
-(void)photos_ablme_exce:(BOOL)isPlay index:(NSInteger)index;
@end
@interface PhotosAblmeView : UIView
@property(weak,nonatomic)id<PhotosAblmeViewDelegate>delegate;
-(void)updateUUID:(NSString*)uuid index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
