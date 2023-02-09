//
//  MajorHomeBaesCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/24.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorLifeCell.h"
#import "MajorWebCartoonView.h"
#import "WebCartoonManager.h"
#import "AppDelegate.h"
#import "MainMorePanel.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "MajorCartoonCtrl.h"
#import "WebViewLivePlug.h"
#import "MarjorWebConfig.h"
#import "JsServiceManager.h"
#import "MajorPermissions.h"
#define MajorLifeCell_LivePlug @"MajorLifeCell_LivePlug"
@interface MajorLifeCell()
@property(nonatomic,assign)float cellSizeH;
@end

@implementation MajorLifeCell

-(void)updateHeadColor:(UIColor*)color{
    
}

-(void)updateRightLableState{
    
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    float w = 9;
    /*
    self.cellSizeH = 60;
    float w = frame.size.width;
    UIButton *btnZhibo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnZhibo setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_2btn") forState:UIControlStateNormal];
    [self addSubview:btnZhibo];
    [btnZhibo addTarget:self action:@selector(btn1Event:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnMv = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMv setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_1btn") forState:UIControlStateNormal];
    [self addSubview:btnMv];
    [btnMv addTarget:self action:@selector(btn2Event:) forControlEvents:UIControlEventTouchUpInside];
    btnMv.hidden = YES;
#ifdef DEBUG
    [JsServiceManager getInstance].isWebJsSuccess = true;
#endif
    [RACObserve([JsServiceManager getInstance], isWebJsSuccess) subscribeNext:^(id x) {
        if ([JsServiceManager getInstance].isWebJsSuccess) {
            btnMv.hidden = NO;
        }
    }];
    
    //按比例计算
    [btnZhibo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(w/2);
        make.bottom.equalTo(self);
        make.top.equalTo(self).mas_offset(10);
    }];
    
    [btnMv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.mas_equalTo(w/2);
        make.bottom.equalTo(self);
        make.top.equalTo(self).mas_offset(10);
    }];*/
    self.cellSizeH = 0*(w/2)*(100.0/320)+10;
    self.bounds = CGRectMake(0, 0, w, self.cellSizeH);
    
    return self;
}


-(void)btn2Event:(UIButton*)sender{
    
    [MajorPermissions playClickPerMissions:MajorLifeCell_LivePlug pressmission:^(BOOL isSuccess) {
        if (isSuccess) {
            [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
            UIView *view = [GetAppDelegate getRootCtrlView];
            WebViewLivePlug *v = [view viewWithTag:TmpTopViewTag];
            if (!v) {
                v = [[WebViewLivePlug alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
                [view addSubview:v];
                v.tag = TmpTopViewTag;
            }
        }}];
}

-(void)btn1Event:(UIButton*)sender{
    morePanelInfo *onePanelC = [MainMorePanel getInstance].morePanel.morePanel.lastObject;
    onePanel *onePanel = [[MainMorePanel getInstance].arraySort.arraySort objectAtIndex:[onePanelC.type intValue]];
    [MarjorWebConfig getInstance].webItemArray = onePanel.array;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:[onePanel.array objectAtIndex:0]];
}

@end
