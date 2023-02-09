//
//  AppDelegate.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MajorMain;
@class WebDesListView;
@class FileWebDownLoader;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic,assign)BOOL isGdtNativewShow;
@property (nonatomic,assign)BOOL isOldFullScreen;
@property (nonatomic,assign)BOOL isFullScreen;

@property (strong, nonatomic) FileWebDownLoader *fileWebDown;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign)UIInterfaceOrientationMask supportRotationDirection;
@property (nonatomic,assign)BOOL isOpen;
-(void)showLocalNotifi:(NSString*)msg;
-(void)showWebBoardView;
-(void)showAppHomeView;
-(void)updateHisotryAndFavorite;
-(void)setStatusBarBackgroundColor:(UIColor *)color;
-(void)addSpotlightItem:(NSArray*)item;
-(void)addSpotlight:(NSString*)title des:(NSString*)des key:(NSString*)key url:(NSString*)url;
-(UIView*)getRootCtrlView;
- (void)setEveryDataLocadNotifi:(NSString *)timeStr textArray:(NSArray*)testArray;
- (void)cancelAllLocadNotifi;
@property(assign,nonatomic)BOOL isProxyState;
@property(assign,nonatomic)NSInteger appJumpValue;

@property(copy,nonatomic)NSString* penFromSpotLightUrl;
@property(nonatomic,assign)NSInteger isAppTipsViewTop;//-1未知 0上面，1下面

@property(assign,nonatomic)float appStatusBarH;
@property(assign,nonatomic)BOOL isPressShare;
@property(nonatomic,strong)WebDesListView *globalWebDesList;
@property(nonatomic,assign)NSInteger videoPlayMode;//0=顶部播放,1小模式播放,2全屏播放
@property(nonatomic,assign)BOOL isHistoryUpdate;
@property(nonatomic,assign)BOOL isVideoHistoryUpdate;
@property(nonatomic,assign)BOOL isUserMainHomeUpdate;
@property(nonatomic,assign)BOOL isUpateJsChange;
@property(nonatomic,assign)BOOL isFavoriteUpdate;
@property(nonatomic,assign)BOOL isCanCreateNewWeb;
@property(nonatomic,assign)NSInteger totalWebOpen;
@property(nonatomic,assign)BOOL isClickWebEvent;

@property(nonatomic,copy)NSString *readBodyReturn;

//@property(nonatomic,assign)BOOL isMajorMainShouldAutorotate;
@property(nonatomic,assign)BOOL backGroundDownMode;
//首页弹出广告是否观看
@property(nonatomic,assign)BOOL isWatchHomeVideo;
@end

