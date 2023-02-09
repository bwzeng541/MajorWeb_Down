//
//  MajorAppTjCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/12/24.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorHomeBaesCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^MajorAppTjCellClick)(NSString *url,id view);
typedef void (^MajorAppTjCellSearch)(NSString *name);

typedef void (^MajorAppTjCellPlayRecord)(void);
typedef void (^MajorAppTjCellWebHistory)(void);
typedef void (^MajorAppTjCellMyFaritive)(void);
typedef void (^MajorAppTjCellHelp)(void);
 
@interface MajorAppTjCell : MajorHomeBaesCell
@property (copy)MajorAppTjCellClick clickTjCellBlock;
@property (copy)MajorAppTjCellSearch clickSearch;
@property (copy)MajorAppTjCellPlayRecord playRecord;
@property (copy)MajorAppTjCellWebHistory webHistory;
@property (copy)MajorAppTjCellMyFaritive myFaritive;
@property (copy)MajorAppTjCellHelp  help;
@property(nonatomic,readonly)float cellSizeH;
@end

NS_ASSUME_NONNULL_END
