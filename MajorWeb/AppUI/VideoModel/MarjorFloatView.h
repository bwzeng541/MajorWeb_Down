//
//  MarjorFloatView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "ZFFloatView.h"
#import "ZFPlayerGestureControl.h"
@protocol MarjorFloatViewDelegate<NSObject>
@optional
-(void)marjorSyncContainerViewFrameCallBack;
- (void)marjorHiddenCallBack:(BOOL)withAnimated;
-(void)marjorFloatClickCallBack;
-(void)marjorFloatPanBeganCallBack:(ZFPanDirection)direction ;
-(void)marjorFloatPanChangeCallBack:(ZFPanDirection)direction velocity:(CGPoint)location;
-(void)marjorFloatPanEndCallBack:(ZFPanDirection)direction ;
-(void)marjorFloatFingerMoveOutCallBack:(ZFPanDirection)direction ;
-(void)marjorFloatStopCallBack ;
-(void)marjorFloatPauseCallBack ;

@end
@interface MarjorFloatView : ZFFloatView
@property(nonatomic,weak)id<MarjorFloatViewDelegate>marjorCallBack;
@property(nonatomic,readonly)BOOL isVerySamll;
- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer;
-(void)reSetNormal;
-(void)intoSamll;
@end
