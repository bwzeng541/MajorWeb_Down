//
//  MajorHomeBaesCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/24.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorHotCell.h"
#import "WebPushView.h"
#import "WebPushManager.h"
#import "AppDelegate.h"
#import "MainMorePanel.h"
#import "MajorPermissions.h"
#import "MajorSystemConfig.h"
#import "ZFAutoPlayerViewController.h"
#define MajorHotCell_key @"majorHotCell_meinv"
#define MajorZhiboCell_key @"majorHotCell_zhibo"
@interface MajorHotCell()<ZFAutoPlayerViewControllerDelegate>
@property(strong)ZFAutoPlayerViewController *autoPlayerCtrl;
@property(nonatomic,assign)float cellSizeH;
@end

@implementation MajorHotCell

-(void)updateHeadColor:(UIColor*)color{
    
}

-(void)updateRightLableState{
    
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    float w = 9;
    /*
    self.cellSizeH = 60;
    //320*120
    UIButton *btnZhibo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnZhibo setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_zhibo") forState:UIControlStateNormal];
    [self addSubview:btnZhibo];
    [btnZhibo addTarget:self action:@selector(btn1Event:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnMv = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMv setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_meinv") forState:UIControlStateNormal];
    [self addSubview:btnMv];
    [btnMv addTarget:self action:@selector(btn2Event:) forControlEvents:UIControlEventTouchUpInside];
    
    //按比例计算
    float w = frame.size.width;
    [btnZhibo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(w/2);
        make.top.bottom.equalTo(self);
    }];
    
    [btnMv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.mas_equalTo(w/2);
        make.top.bottom.equalTo(self);
    }];*/
    self.cellSizeH = 0*(w/2)*(120.0/320);
    self.bounds = CGRectMake(0, 0, w, self.cellSizeH);
    return self;
}


-(void)btn2Event:(UIButton*)sender{
    [MajorPermissions playClickPerMissions:MajorHotCell_key pressmission:^(BOOL isSuccess) {
        if (isSuccess) {
            //[MobClick event:@"meinv_btn"];
            UIViewController *controller = [[NSClassFromString(@"PinUpController") alloc] initWithNibName:@"PinUpController" bundle:nil];
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:controller animated:YES completion:nil];
        }
    }];
}

-(WebPushView*)createWebPushAndView{
    UIView *view = [GetAppDelegate getRootCtrlView];
    WebPushView *v = [view viewWithTag:TmpTopViewTag];
    if (!v) {
        v = [[WebPushView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        [view addSubview:v];
        v.tag = TmpTopViewTag;
    }
    return v;
}

-(void)btn1Event:(UIButton*)sender{
    __weak __typeof__(self) weakSelf = self;
    [MajorPermissions playClickPerMissions:MajorZhiboCell_key pressmission:^(BOOL isSuccess) {
        if (isSuccess) {
            //[MobClick event:@"zhibo_btn"];
            [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
            self.autoPlayerCtrl=  [[ZFAutoPlayerViewController alloc] init];
            self.autoPlayerCtrl.delegate = self;
            self.autoPlayerCtrl.view.frame = CGRectMake(0, 0,[MajorSystemConfig getInstance].appSize.width,[MajorSystemConfig getInstance].appSize.height);
            [self.autoPlayerCtrl initUI];
            [[GetAppDelegate getRootCtrlView] addSubview: self.autoPlayerCtrl.view];
            
//            [[WebPushManager getInstance] showDateBlock:^(NSArray * _Nonnull ret) {
//                [[weakSelf createWebPushAndView] addDataArray:ret isRemoveOldAll:YES];
//            } updateBlock:^(WebPushItem * _Nonnull item, BOOL isRemoveOldAll) {
//                [[weakSelf createWebPushAndView] addDataItem:item isRemoveOldAll:isRemoveOldAll];
//            } startHomeBlock:^{
//                huyaNodeInfo *node =  [[MainMorePanel getInstance].morePanel.huyaurl objectAtIndex:0];
//                [[weakSelf createWebPushAndView] loadHome];
//                [[WebPushManager getInstance] startWithUrlUsrOldBlock:node.url ];
//            } falidBlock:^{
//                
//            }];
        }
    }];
}

@end
