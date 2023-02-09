

#import "ZFFloatView.h"
#import "ZFPlayerGestureControl.h"
@protocol ThrowFloatViewDelegate<NSObject>
@optional

-(void)throwSyncContainerViewFrameCallBack;
- (void)throwHiddenCallBack:(BOOL)withAnimated;
-(void)throwFloatClickCallBack;
-(void)throwFloatPanBeganCallBack:(ZFPanDirection)direction ;
-(void)throwFloatPanChangeCallBack:(ZFPanDirection)direction velocity:(CGPoint)location;
-(void)throwFloatPanEndCallBack:(ZFPanDirection)direction ;
-(void)throwFloatFingerMoveOutCallBack:(ZFPanDirection)direction ;
-(void)throwFloatStopCallBack ;
-(void)throwFloatPauseCallBack ;

@end
@interface ThrowFloatView : ZFFloatView
@property(nonatomic,weak)id<ThrowFloatViewDelegate>throwCallBack;
@property(nonatomic,readonly)BOOL isVerySamll;
- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer;
-(void)reSetNormal;
-(void)intoSamll;
@end
