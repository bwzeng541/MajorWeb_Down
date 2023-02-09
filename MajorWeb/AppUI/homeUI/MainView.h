//
//  MainView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/26.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WebConfigItem;
typedef void (^MainViewSearchBlock)(WebConfigItem *webConfig);
@interface MainView : UIView
@property(nonatomic,copy)MainViewSearchBlock searchBlock;
-(void)initUI;
-(void)updateWebBoardView:(UIView*)webBoardView;
-(void)loadSnycMarkFromLocal:(NSArray*)array;
-(void)updateHisotryAndFavorite;
@end
