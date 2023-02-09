//
//  PopPromptView.h
//  UrlWebViewForIpad
//
//  Created by Flipped on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserView;
@class PopPromptView;
@class TabManager;

@protocol PopPromptViewDelegate <NSObject>

- (void)promptViewWillDissmiss:(PopPromptView *)promptView isChangeAddressTool:(BOOL)isChange;
- (void)promptViewBecomeFirstResponder;
- (void)promptClickUrl:(NSString*)url;
- (void)promptCopyUrl;
- (void)promptEditUrl;
- (void)promptStartDragg;

@end

@interface PopPromptView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_myTableView;
    NSMutableArray *_dataArray;
}
@property(nonatomic, strong) UITableView *myTableView;
@property(nonatomic, strong) NSMutableArray *dataArray;

@property(nonatomic, weak) id <PopPromptViewDelegate> delegate;
@property(nonatomic) BOOL isHideRecommend;
- (id)initWithFrame:(CGRect)frame tabManager:(id)tabManager;
- (void)changeAutoFrame:(float)height;
- (void)getDataArray:(NSString *)str Cate:(BOOL)sender;
- (void)rearrangeViews;
- (void)show;

- (void)hide;

@end
