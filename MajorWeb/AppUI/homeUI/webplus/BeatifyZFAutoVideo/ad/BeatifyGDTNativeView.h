//
//  BeatifyGDTNativeView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface BeatifyGDTNativeView : UIView
+(void)startBeatifyView:(void(^)(void))willShow willRemove:(void(^)(void))willRemove;
+(void)stopGdtNatiview;
@end

NS_ASSUME_NONNULL_END
