//
//  BeatifyAnimationDelegate.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/10.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BeatifyStartAnimationDelegate<NSObject>

@optional
- (void)animationDidStop:(CAAnimation *)anim;

@end

@interface BeatifyAnimationDelegate : CABasicAnimation <CAAnimationDelegate>
@property (nonatomic,weak) id<BeatifyStartAnimationDelegate> ledDelegate;
@end

NS_ASSUME_NONNULL_END
