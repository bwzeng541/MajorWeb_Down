//
//  ZFBeatifyTableData.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/8/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFTableData : NSObject
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat thumbnail_width;
@property (nonatomic, assign) CGFloat thumbnail_height;
@property (nonatomic, assign) CGFloat video_duration;
@property (nonatomic, assign) CGFloat video_width;
@property (nonatomic, assign) CGFloat video_height;
@property (nonatomic, copy) NSString *thumbnail_url;
@property (nonatomic, copy) NSString *video_url;
@end




NS_ASSUME_NONNULL_END
