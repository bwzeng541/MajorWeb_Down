//
//  TmpSetView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/10.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "TmpSetView.h"
#import "HuanCunCtrl.h"
static TmpSetView *tmpSetView = nil;
static UIView *tmpSetParentView = nil;
@interface TmpSetView()<HuanCunCtrlDelegate>
@property(nonatomic,strong)HuanCunCtrl *hcCtrl;
@end
@implementation TmpSetView

+(void)hidenTmpSetView{
    RemoveViewAndSetNil(tmpSetView);
}

+(BOOL)isShowState{
    return tmpSetParentView?true:false;
}

+(void)showTmpSetView:(UIView*)parentView{
    if (!tmpSetView) {
        tmpSetParentView = parentView;
        tmpSetView = [[TmpSetView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)];
        if (tmpSetParentView) {
            [tmpSetParentView addSubview:tmpSetView];
        }
        else{
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:tmpSetView];
        }
    }
}

-(void)hc_back_Event{
    [self removeFromSuperview];
}

-(void)removeFromSuperview{
    tmpSetView = nil;
    tmpSetParentView = nil;
    [self.hcCtrl.view removeFromSuperview];
    self.hcCtrl = nil;
    [super removeFromSuperview];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.isUsePopGesture = YES;
    self.hcCtrl = [[NSClassFromString(DOWNAPICONFIG.msgapp3) alloc] initWithNibName:DOWNAPICONFIG.msgapp3 bundle:nil];
    self.hcCtrl.delegate = self;
    [self addSubview:self.hcCtrl.view];
    [self.hcCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    return self;
}

- (BOOL)isValidGesture:(CGPoint)point{
    if (point.y<MY_SCREEN_HEIGHT-100) {
        return true;
    }
    return false;
}

@end
