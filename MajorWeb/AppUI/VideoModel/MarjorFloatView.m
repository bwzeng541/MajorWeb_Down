//
//  MarjorFloatView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MarjorFloatView.h"
#import "AppDelegate.h"
#import "MajorSystemConfig.h"
@interface MarjorFloatView()
@property(assign)BOOL isVerySamll;
@property (nonatomic) ZFPanDirection panDirection;
@property (nonatomic) ZFPanMovingDirection panMovingDirection;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic,assign)BOOL isCanMove;
@property (nonatomic,assign)CGPoint startCenter;
@property (nonatomic,assign)NSTimeInterval velocityTime;

@end

@implementation MarjorFloatView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
}
-(void)initilize{
    [super initilize];
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired =1;
    singleTapGesture.numberOfTouchesRequired  =1;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired =2;
    doubleTapGesture.numberOfTouchesRequired =1;
    [self addGestureRecognizer:doubleTapGesture];
    [self addGestureRecognizer:singleTapGesture];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    self.isCanMove =true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portraitSlilderChangeState:) name:@"PortraitSlilderChangeState" object:nil];
 }

-(void)handleDoubleTap:(UIGestureRecognizer*)recognizer{
    NSLog(@"handleDoubleTap");
    if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatPauseCallBack)]) {
            [self.marjorCallBack marjorFloatPauseCallBack];
        }
}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(void)portraitSlilderChangeState:(NSNotification*)object{
    self.isCanMove = ![object.object boolValue];
}

-(void)reSetNormal{
    self.isVerySamll = false;
}
//回到顶部
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    //if (self.singleTapped) self.singleTapped(self);
    if (self.isVerySamll) {
        CGFloat nw = MY_SCREEN_WIDTH;
        CGFloat nh = nw * 9/16;
        CGFloat nx = MY_SCREEN_WIDTH - nw;
        self.frame = CGRectMake(nx, [MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height, nw, nh);
        GetAppDelegate.videoPlayMode = 0;
        self.isVerySamll = false;
        if ([self.marjorCallBack respondsToSelector:@selector(marjorSyncContainerViewFrameCallBack)]) {
            [self.marjorCallBack marjorSyncContainerViewFrameCallBack];
        }
        if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatClickCallBack)]) {
            [self.marjorCallBack marjorFloatClickCallBack];
        }
    }
    else{
        if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatClickCallBack)]) {
            [self.marjorCallBack marjorFloatClickCallBack];
        }
    }
}

- (void)doMoveAction:(UIPanGestureRecognizer *)pan {
    CGPoint translate = [pan translationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    //NSLog(@"velocity = %f",velocity.y);
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.panMovingDirection = ZFPanMovingDirectionUnkown;
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            self.startCenter = self.center;
            self.velocityTime = [[NSDate date] timeIntervalSince1970];
            if (x > y) {
                self.panDirection = ZFPanDirectionH;
            } else {
                self.panDirection = ZFPanDirectionV;
            }
            if(self.panDirection == ZFPanDirectionH && !self.isVerySamll){//回调改变时间
                if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatPanBeganCallBack:)]) {
                    [self.marjorCallBack marjorFloatPanBeganCallBack:self.panDirection];
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_panDirection) {
                case ZFPanDirectionH: {
                    if (translate.x > 0) {
                        self.panMovingDirection = ZFPanMovingDirectionRight;
                    } else if (translate.y < 0) {
                        self.panMovingDirection = ZFPanMovingDirectionLeft;
                    }
                }
                    break;
                case ZFPanDirectionV: {
                    [self doMoveViewAction :pan];
                    
                    CGRect v = self.frame;
                    if(v.origin.y<[MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height)
                        self.frame = CGRectMake(self.frame.origin.x,[MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height, self.frame.size.width, self.frame.size.height);
                    if ([self.marjorCallBack respondsToSelector:@selector(marjorSyncContainerViewFrameCallBack)]) {
                        [self.marjorCallBack marjorSyncContainerViewFrameCallBack];
                    }
                }
                    break;
                case ZFPanDirectionUnknown:
                    break;
            }
            if(self.panDirection == ZFPanDirectionH  && !self.isVerySamll){//回调改变时间
                if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatPanChangeCallBack:velocity:)]) {
                    [self.marjorCallBack marjorFloatPanChangeCallBack:self.panDirection velocity:velocity];
                }
            }
            else{
                CGRect v = self.frame;
                if(v.origin.y>[MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height)
                [self doMoveViewAction:pan];
            }
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (self.panDirection == ZFPanDirectionH  && !self.isVerySamll) {
                //回调出
                if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatPanEndCallBack:)]) {
                    [self.marjorCallBack marjorFloatPanEndCallBack:self.panDirection];
                }
            }
            else{
                [self updateSamll];
            }
            [self updatePlayViewPos];
        }
            break;
        default:
            break;
    }
}

- (void)updatePlayViewPos{
    if (GetAppDelegate.videoPlayMode==0) {
        CGFloat time = ([[NSDate date] timeIntervalSince1970]-self.velocityTime);
        float speed = (self.center.y - self.startCenter.y) / time;
        if (speed<-1000) {
            CGRect rect = self.frame;
            rect.origin.y = -rect.size.height;
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = rect;
                self.userInteractionEnabled = NO;
            }completion:^(BOOL finished) {
                self.userInteractionEnabled = YES;
                if ([self.marjorCallBack respondsToSelector:@selector(marjorFloatStopCallBack)]) {
                    [self.marjorCallBack marjorFloatStopCallBack];
                }
            }];
            NSLog(@"speed = %f move exit",speed);
        }
        else{
            NSLog(@"move no");
            CGRect v = self.frame;
            if ((fabs(speed)>900 && speed<0) || v.origin.y<[MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height) {
                [UIView animateWithDuration:0.3 animations:^{
                    if (v.origin.y < [MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height) {
                        self.center = CGPointMake(self.center.x, [MajorSystemConfig getInstance].bannerAdRect.origin.y+[MajorSystemConfig getInstance].bannerAdRect.size.height+v.size.height/2);
                    }
                    else{
                        self.center = self.startCenter;
                    }
                    self.userInteractionEnabled = NO;
                }completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                }];
            }
        }
    }
}

- (void)doMoveViewAction:(UIPanGestureRecognizer *)recognizer {
    /// The position where the gesture is moving in the self.view.
    
    CGPoint translation = [recognizer translationInView:self.parentView];
    CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x,
                                    recognizer.view.center.y + translation.y);
    
    // Limited screen range:
    // Top margin limit.
    float offsetY = 0,mm = recognizer.view.frame.size.height/2 + self.safeInsets.top;
    if (GetAppDelegate.videoPlayMode==0) {
        offsetY= -(mm+self.bounds.size.height/2);
    }
    newCenter.y = MAX(mm+offsetY, newCenter.y);
    
    // Bottom margin limit.
    newCenter.y = MIN(self.parentView.frame.size.height - self.safeInsets.bottom - recognizer.view.frame.size.height/2, newCenter.y);
    
    // Left margin limit.
    newCenter.x = MAX(recognizer.view.frame.size.width/2, newCenter.x);
    
    // Right margin limit.
    newCenter.x = MIN(self.parentView.frame.size.width - recognizer.view.frame.size.width/2,newCenter.x);
    
    // Set the center point.
    recognizer.view.center = newCenter;
    
    // Set the gesture coordinates to 0, otherwise it will add up.
    [recognizer setTranslation:CGPointZero inView:self.parentView];
}

-(void)updateSamll{
    float y = self.center.y;
    
    if (y>MY_SCREEN_HEIGHT/2)
    {
    }
    else{
    
    }
}

-(void)intoSamll{
    CGFloat nw = MY_SCREEN_WIDTH/2;
    CGFloat nh = nw * 9/16;
    CGFloat nx = (MY_SCREEN_WIDTH - nw)/2;
    CGFloat ny = MY_SCREEN_HEIGHT - nh*2;
    if (!self.isVerySamll) {
        GetAppDelegate.videoPlayMode = 1;
        self.isVerySamll = true;
        self.frame = CGRectMake( nx, ny, nw, nh);
        if ([self.marjorCallBack respondsToSelector:@selector(marjorHiddenCallBack:)]) {
            [self.marjorCallBack marjorHiddenCallBack:true];
        }
        if ([self.marjorCallBack respondsToSelector:@selector(marjorSyncContainerViewFrameCallBack)]) {
            [self.marjorCallBack marjorSyncContainerViewFrameCallBack];
        }
        [self removeFromSuperview];
        self.parentView = [UIApplication sharedApplication].keyWindow;
    }
}
@end
