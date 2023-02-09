//
//  MajorAppTiCellChild1.h
//  MajorWeb
//
//  Created by zengbiwang on 2020/4/2.
//  Copyright © 2020 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^MajorAppTiCellChild1PlayRecord)(void);
typedef void (^MajorAppTiCellChild1WebHistory)(void);
typedef void (^MajorAppTiCellChild1MyFaritive)(void);
typedef void (^MajorAppTiCellChild1ZhiBo)(void);
typedef void (^MajorAppTiCellChild1Help)(void);
typedef void (^MajorAppTiCellChild1Share)(void);
typedef void (^MajorAppTiCellChild1Search)(void);
typedef void (^MajorAppTiCellChild1Regites)(void);

@interface MajorAppTiCellChild1 : UIView
@property(copy)MajorAppTiCellChild1PlayRecord playRecord;
@property(copy)MajorAppTiCellChild1WebHistory webHistory;
@property(copy)MajorAppTiCellChild1MyFaritive myFaritive;
@property(copy)MajorAppTiCellChild1ZhiBo zhibo;
@property(copy)MajorAppTiCellChild1Share share;
@property(copy)MajorAppTiCellChild1Help help;
@property(copy)MajorAppTiCellChild1Search search;
@property(copy)MajorAppTiCellChild1Regites registe;
@end

NS_ASSUME_NONNULL_END
