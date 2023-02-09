//
//  AddressToolbarView.h
//  UrlWebViewForIpad
//
//  Created by Flipped on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBarView.h"
#import "PopPromptView.h"

@class PopPromptView;


@protocol AddressToolbarViewDelegate <NSObject>
- (void)loadRequestRefreshFun:(id)addressToolbar;
- (void)cancelToolsFun:(id)addressToolbar;
- (void)loadReqeustFromUrl:(NSString*)url;

- (void)newWebFromToolBar;
- (void)addWebFavritorFromToolBar;
- (void)backWebFromToolBar;
@end

@interface AddressToolbarView : UIView <UITextFieldDelegate, AddressBarViewDelegate,PopPromptViewDelegate> {
    UIImageView *_backImageView;
    AddressBarView *_addressBar;
    UIImageView *textbgImg;
    NSInteger _addressToolbarIndex;
    BOOL _isSelect;
    __weak id<AddressToolbarViewDelegate> _delegate;

    NSString *current_Url;
    NSInteger progressFlag;
    NSTimer *timer;
    
    
    NSString *_previousUrlString;
    NSString *_currentUrlString;
    
    NSString *_reservedUrlString;
    
    UIButton *_btnActionGo;
    UIButton *_btnActionSearch;

    UIButton *_btnRefresh;
    
    UIButton *_btnBack;
    UIButton *_btnFavorite;
    UIButton *_btnNewWeb;

}

@property(nonatomic, strong) UIImageView *backImageView;
@property(nonatomic, strong) AddressBarView *addressBar;
@property(nonatomic) NSInteger addressToolbarIndex;
@property(nonatomic) BOOL isSelect;
@property(nonatomic, weak) id <AddressToolbarViewDelegate> delegate;
@property(nonatomic, strong) UIProgressView *progressBar;
@property(nonatomic, strong) UIImageView *textbgImg;
@property(nonatomic, copy) NSString *current_Url;
@property(nonatomic,weak) UIView *relatedBrowserView;
@property(nonatomic, copy) NSString *previousUrlString;
@property(nonatomic, copy) NSString *currentUrlString;
@property(nonatomic, copy) NSString *reservedUrlString;
@property(nonatomic, weak) TabManager *tabManager;
@property(nonatomic, strong) UIButton *btnActionGo;
@property(nonatomic, strong) UIButton *btnRefresh;
@property(nonatomic, strong) UIButton *btnQRcode;
- (id)initWithFrame:(CGRect)frame tabManager:(id)tabManager;

- (void)layoutAddressToolbarSubviews;

- (void)insertSearchHistory:(NSString *)str;

- (void)updateProcessbar:(float)progress animated:(BOOL)animated;

- (void)showInput;
- (void)enlargeAddressBar:(BOOL)animated;
//切换到主页状态
- (void) enterHomeState:(BOOL) animated;

- (void) promptViewMiss;

- (void) popPrompt:(id)txt showPrompt:(BOOL)showPrompt str:(NSString *)str;

- (void)updateRefreshStatus:(BOOL)isHomePage;

- (void)cancel;
@end
