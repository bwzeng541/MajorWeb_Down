//
//  MajorHomeBaesCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/24.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorNovelCell.h"
#import "MajorWebCartoonView.h"
#import "WebCartoonManager.h"
#import "AppDelegate.h"
#import "MainMorePanel.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "MajorCartoonCtrl.h"
#import "MajorZyCartoonPlug.h"
#import "MajorPermissions.h"
#define MajorNovel_ZyCartoonPlug @"MajorNovel_ZyCartoonPlug"
#define MajorNovel_ZyNeiHanPlug @"MajorNovel_Neihan_Btn"
@interface MajorNovelCell()
@property(nonatomic,assign)float cellSizeH;
@end

@implementation MajorNovelCell

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
    [btnZhibo setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_neihan") forState:UIControlStateNormal];
    [self addSubview:btnZhibo];
    [btnZhibo addTarget:self action:@selector(btn1Event:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnMv = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMv setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_manhua") forState:UIControlStateNormal];
    [self addSubview:btnMv];
    [btnMv addTarget:self action:@selector(btn2Event:) forControlEvents:UIControlEventTouchUpInside];
    
    //按比例计算
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
    self.cellSizeH = 0*(w/2)*(100.0/320);
    self.bounds = CGRectMake(0, 0, w, self.cellSizeH);
    
    return self;
}

-(void)btn2Event:(UIButton*)sender{
    [MajorPermissions playClickPerMissions:MajorNovel_ZyCartoonPlug pressmission:^(BOOL isSuccess) {
        if (isSuccess) {
            [[[GetAppDelegate getRootCtrlView] viewWithTag:TmpTopViewTag] removeFromSuperview];
            UIView *view = [GetAppDelegate getRootCtrlView];
            MajorZyCartoonPlug *v = [view viewWithTag:TmpTopViewTag];
            if (!v) {
                v = [[MajorZyCartoonPlug alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
                [view addSubview:v];
                v.tag = TmpTopViewTag;
            }
        }
    }];
}

-(void)btn1Event:(UIButton*)sender{
        [MajorPermissions playClickPerMissions:MajorNovel_ZyNeiHanPlug pressmission:^(BOOL isSuccess) {
        if (isSuccess) {
            if([MainMorePanel getInstance].morePanel.manhuaurl.count>0){
                //[MobClick event:@"neihan_btn"];
                MajorCartoonCtrl *ctrl = [[MajorCartoonCtrl alloc] initWithNibName:nil bundle:nil];
                ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
                [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:ctrl animated:YES completion:nil];
            }        }
    }];
}

@end
