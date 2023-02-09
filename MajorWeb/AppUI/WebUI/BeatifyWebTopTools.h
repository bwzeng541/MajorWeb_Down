//
//  BeatifyWebTopTools.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BeatifyWebTopToolsDelegate <NSObject>
-(void)top_clickWebHostUrl;
-(void)top_clickWebHostWebRank;
-(void)top_clickWebHostSearchVideo;
@end
@interface BeatifyWebTopTools : UIView
@property(weak)id<BeatifyWebTopToolsDelegate>delegate;
-(void)initUI;
@end

NS_ASSUME_NONNULL_END
