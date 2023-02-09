//
//  UcTableViewCell.h
//  WatchApp
//
//  Created by zengbiwang on 2018/4/27.
//  Copyright © 2018年 cxh. All rights reserved.
//
#if DoNotKMPLayerCanShareVideo
#else
#import <UIKit/UIKit.h>
#define UcBtnTitleChangeNotifi @"UcBtnTitleChangeNotifi"
//0,播放 1删除 ，2 暂停，3 开始下载
typedef BOOL (^UcTableViewCellClickBlock)(NSInteger type,NSString *uuir);
typedef BOOL (^UcTableViewGetEditBlock)(void);
typedef NSDictionary* (^UcTableViewPlayValueBlock)(NSString *uuir);
typedef void (^UcTableViewCellPlayBlock)(NSString *path,NSString*name,NSString *uuid);
typedef void (^UcTableViewCellSaveBlock)(NSString *path,NSString*name,NSString *uuid);
typedef void (^UcTableViewCellReDownBlock)(NSString *url,NSString*name,NSString *uuid);
typedef void (^UcTableViewCellDelBlock)(NSString *uuid);
typedef void (^UcTableViewCellJionDirBlock)(NSString *uuid);
@interface UcTableViewCell : UITableViewCell
-(void)initCellInfo:(NSDictionary*)info;
-(void)updateBtnEdit:(BOOL)flag;
-(void)tryPlay;
@property(copy)UcTableViewCellSaveBlock saveBlock;
@property(copy)UcTableViewCellPlayBlock playBlock;
@property(copy)UcTableViewCellClickBlock clickBlock;
@property(copy)UcTableViewCellReDownBlock reDownBlock;
@property(copy)UcTableViewPlayValueBlock playValueBlock;
@property(copy)UcTableViewCellDelBlock delValueBlock;
@property(copy)UcTableViewCellJionDirBlock jionDirBlock;
@property(copy)UcTableViewGetEditBlock getEditBlock;
@end
#endif

