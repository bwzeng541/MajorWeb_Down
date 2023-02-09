//
//  ZZUITableViewUtilities.m
//  SpaceManager
//
//  Created by gluttony on 9/23/14.
//  Copyright (c) 2014 dashi. All rights reserved.
//

#import "ZZUITableViewUtilities.h"

NSString *const kZZTableSectionName = @"kZZTableSectionName";
NSString *const kZZTableSectionValue = @"kZZTableSectionValue";
NSString *const kZZTableCellName = @"kZZTableCellName";
NSString *const kZZTableCellValue = @"kZZTableCellValue";
NSString *const kZZTableCellType = @"kZZTableCellType";
NSString *const kZZTableCellTouchable = @"kZZTableCellTouchable";
NSString *const kZZTableCellAction = @"kZZTableCellAction";

NSString *ZZReadableCellType(ZZTableViewCellType cellType)
{
    NSString *readableCellType = nil;
    switch (cellType) {
    case ZZTableViewCellTypeDefault:
        readableCellType = @"ZZTableViewCellTypeDefault";
        break;
    case ZZTableViewCellTypeText:
        readableCellType = @"ZZTableViewCellTypeText";
        break;
    case ZZTableViewCellTypeImage:
        readableCellType = @"ZZTableViewCellTypeImage";
        break;
    case ZZTableViewCellTypeSwitch:
        readableCellType = @"ZZTableViewCellTypeSwitch";
        break;
    case ZZTableViewCellTypeArrow:
        readableCellType = @"ZZTableViewCellTypeArrow";
        break;
    default:
        [NSException raise:@"Invalid cell type"
                    format:@"Unknown cell type %d", (int)cellType];
        break;
    }
    return readableCellType;
}
