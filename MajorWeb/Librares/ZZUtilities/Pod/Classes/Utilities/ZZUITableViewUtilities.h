//
//  ZZUITableViewUtilities.h
//  SpaceManager
//
//  Created by gluttony on 9/23/14.
//  Copyright (c) 2014 dashi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kZZTableSectionName;
extern NSString *const kZZTableSectionValue;
extern NSString *const kZZTableCellName;
extern NSString *const kZZTableCellValue;
extern NSString *const kZZTableCellType;
extern NSString *const kZZTableCellTouchable;
extern NSString *const kZZTableCellAction;

typedef NS_ENUM(NSUInteger, ZZTableViewCellType) {
    ZZTableViewCellTypeDefault,
    ZZTableViewCellTypeText,
    ZZTableViewCellTypeImage,
    ZZTableViewCellTypeSwitch,
    ZZTableViewCellTypeArrow
};

#if defined __cplusplus
extern "C" {
#endif

NSString *ZZReadableCellType(ZZTableViewCellType cellType);

#if defined __cplusplus
};
#endif
