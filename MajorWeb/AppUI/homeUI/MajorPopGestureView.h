//
//  MajorPopGestureView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/4.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^MajorPopGestureViewBackBlock)(void);

@interface MajorPopGestureView : UIView
@property (nonatomic,copy)MajorPopGestureViewBackBlock backBlock;
@property (nonatomic, assign, readwrite) BOOL isUsePopGesture;
- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer;
- (BOOL)isValidGesture:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
