//
//  BottomToolsView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
//底部菜单界面
typedef void (^BottomToolsViewBackClickBack)(void);
typedef void (^BottomToolsViewBackClickNext)(void);
typedef void (^BottomToolsViewAddFavoriteClickNext)(void);
typedef void (^BottomToolsViewReloadUrl)(NSString*url);
typedef void (^BottomToolsViewShowPic)(void);
typedef void (^BottomToolsViewRefresh)(void);
typedef void (^BottomToolsViewClickSearch)(void);
typedef void (^BottomToolsViewBackClickBack)(void);
typedef void (^BottomToolsViewAddWebHome)(void);
typedef void (^BottomToolsViewFanguiyijian)(void);
typedef void (^BottomToolsViewShareWeb)(void);
typedef void (^BottomToolsViewShareApp)(void);
typedef void (^BottomToolsViewPopViewShow)(BOOL isShow);

@interface BottomToolsView : UIView
@property(nonatomic,readonly)UILabel *webTitleLable;
@property(nonatomic,readonly)UIButton *btnGoBack;
@property(copy)BottomToolsViewBackClickNext clickNext;
@property(copy)BottomToolsViewBackClickBack clickBack;
@property(copy)BottomToolsViewAddFavoriteClickNext addFavorite;
@property(copy)BottomToolsViewReloadUrl reloadUrl;;
@property(copy)BottomToolsViewShowPic showPicBlock;;
@property(copy)BottomToolsViewRefresh clickRefresh;
@property(copy)BottomToolsViewClickSearch clickSearch;

@property(copy)BottomToolsViewAddWebHome addWebHome;
@property(copy)BottomToolsViewFanguiyijian feeBack;
@property(copy)BottomToolsViewShareWeb shareWeb;
@property(copy)BottomToolsViewShareApp shareApp;
@property(copy)BottomToolsViewPopViewShow popViewShow;
-(void)initUI;
-(void)showHosirty:(UIButton*)sender;
-(void)showFavorite:(UIButton*)sender;
@end
