//
//  BeatifyAnimationDelegate.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/10.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyAnimationDelegate.h"

@implementation BeatifyAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([self.ledDelegate respondsToSelector:@selector(animationDidStop:)]) {
        [self.ledDelegate animationDidStop:anim];
    }
}

- (void)setLedDelegate:(id<BeatifyStartAnimationDelegate>)ledDelegate {
    _ledDelegate = ledDelegate;
    self.delegate = self;
    
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

@end
