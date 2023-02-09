//
//  MorePanelCell.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorModeDefine.h"
#import "MajorHomeBaesCell.h"
@class onePanel;
typedef void (^MorePanelCellClick)(WebConfigItem*item,id view);
typedef void (^MorePanelCellOverHeadClick)(id view);

@interface MorePanelCell : MajorHomeBaesCell
-(instancetype)initWithPrivacyFrame:(CGRect)frame morePanelInfo:(morePanelInfo*)panelInfo onePanel:(onePanel*)onePanel;
-(instancetype)initWithFrame:(CGRect)frame morePanelInfo:(morePanelInfo*)panelInfo;
@property(nonatomic,readonly)onePanel *onePanel;
@property(nonatomic,readonly)CGSize panelCellSize;
@property(nonatomic,readonly)NSString *panelDes;
@property(nonatomic,readonly)UIColor *colorTitle;
@property(nonatomic,readonly)NSString *iconUrl;
@property(nonatomic,readonly)NSMutableAttributedString *headerName;
@property(copy)MorePanelCellClick clickBlock;
@property(copy)MorePanelCellOverHeadClick clickOverheadBlock;

-(void)updateDate;
@end
