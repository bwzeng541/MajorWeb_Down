//
//  MajorPopGestureView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/4.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorPopGestureView.h"

@interface MajorPopGestureView ()<UIGestureRecognizerDelegate>
{
    
    UIPanGestureRecognizer *panGestureRecognizer;
}
@property (nonatomic,assign)CGPoint startCenter;
@property (nonatomic,assign)NSTimeInterval velocityTime;
@end

@implementation MajorPopGestureView
@synthesize isUsePopGesture = _isUsePopGesture;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
        
    return self;
}
    
-(void)setIsUsePopGesture:(BOOL)isUsePopGesture{
    _isUsePopGesture = isUsePopGesture;
    if (!isUsePopGesture) {
        [self removeGestureRecognizer:panGestureRecognizer];
        panGestureRecognizer = nil;
    }
    else if(isUsePopGesture && !panGestureRecognizer){
            panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doMoveAction:)];
            panGestureRecognizer.delegate=self;
            [self addGestureRecognizer:panGestureRecognizer];
    }
}
    


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    if(self.frame.origin.x>0)return false;
    return YES;
}


- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.startCenter = self.center;
            self.velocityTime = [[NSDate date] timeIntervalSince1970];
        }
        case UIGestureRecognizerStateChanged: {
            [self updateMove:recognizer];
        } break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            [self updatePlayViewPos];
        }
            break;
        default: break;
    }
}

-(void)updateMove:(UIPanGestureRecognizer*)recognizer{
    if (![self isValidGesture:[recognizer locationInView:self]]) {
        return;
    }
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    CGFloat x = fabs(velocity.x);
    CGFloat y = fabs(velocity.y);
    if (x<y) {//只能水平移动
        return;
    }
    CGPoint point = [recognizer translationInView:self];
    CGRect rect =  CGRectMake(self.frame.origin.x+point.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height) ;
    if (rect.origin.x<0) {
        rect.origin = CGPointMake(0, rect.origin.y);
    }
    recognizer.view.frame = rect;
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

- (BOOL)isValidGesture:(CGPoint)point{
    return true;
}

- (void)updatePlayViewPos{
    CGFloat time = ([[NSDate date] timeIntervalSince1970]-self.velocityTime);
    float speed = (self.center.x - self.startCenter.x) / time;
    self.userInteractionEnabled = NO;
    CGRect rect=self.frame;
    BOOL isRemove;
    if (speed>500 || self.frame.origin.x>MY_SCREEN_WIDTH/2) {
        isRemove = true;
        rect.origin = CGPointMake(MY_SCREEN_WIDTH, rect.origin.y);
    }
    else{
        isRemove = false;
        rect.origin =CGPointMake(0, rect.origin.y);
    }
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = rect;
    }completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        if (isRemove) {
            if (self.backBlock) {
                self.backBlock();
            }
            else{
                [self removeFromSuperview];
            }
        }
    }];
}

@end
