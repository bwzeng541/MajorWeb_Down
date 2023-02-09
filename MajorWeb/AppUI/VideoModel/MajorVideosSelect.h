//
//  MajorVideosSelect.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/19.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MajorVideosSelectDelegate<NSObject>
-(void)marjor_select_video_url:(NSString*)videosUrl;
@end
@interface MajorVideosSelect : UIViewController
@property(weak)id<MajorVideosSelectDelegate>delegate;
-(void)updateVideoArray:(NSArray*)videoArray;
-(void)updateSelectUrl:(NSString*)videoUrl;
-(void)updateFrame:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END
