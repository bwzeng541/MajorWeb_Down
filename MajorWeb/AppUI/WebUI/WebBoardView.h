//
//  WebBoardView.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

//所有 ContentWebView 试图放在这个界面上，可以选择展示的界面
typedef void (^WebBoardViewPopBlock)(UIView *webView);
typedef void (^WebBoardViewDelBlock)(UIView *webView);
typedef void (^WebBoardViewClearBlock)(void);
typedef void (^WebBoardViewBackHomeBlock)(void);

@interface WebBoardView : UIView
@property(nonatomic,readonly)NSMutableArray *childrenArray;
@property(copy)WebBoardViewPopBlock popWebViewBlock;
@property(copy)WebBoardViewDelBlock delWebViewBlock;
@property(copy)WebBoardViewClearBlock clearAllBlock;
@property(copy)WebBoardViewBackHomeBlock backHomeBlock;
-(void)updateChlidWeb:(NSArray*)array popWeb:(UIView*)webView;
-(void)addOneWeb:(UIView*)webViwe;
-(void)updateIsSize:(CGSize)size;
-(void)loadSnycMarkFromLocal:(NSArray*)array;
@end
