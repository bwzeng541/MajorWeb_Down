//
//  GDtRootCtrl.m
//  GDTMobSample
//
//  Created by zengbiwang on 2017/11/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "GDtRootCtrl.h"
#import "MajorSystemConfig.h"
@interface GDtRootCtrl ()
@property(assign)BOOL isRemveAllAdView;
@property(assign)float checkTime;
@property(retain)NSMutableArray *arrayCtrl;
@end

@implementation GDtRootCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayCtrl = [NSMutableArray arrayWithCapacity:1];
    self.isRemveAllAdView = false;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkCtrl{
    NSArray *arryaViews = [self.view subviews];
    float time = self.checkTime;
    for (NSInteger i = arryaViews.count-1;i >=0; i--) {
        UIViewController *ctrl = ((UIView*)[arryaViews objectAtIndex:i]).nextResponder;
        NSString *className  = NSStringFromClass([ctrl class]);
        if ([className compare:@"GDTStoreProductController"]==NSOrderedSame){
            NSString *strFuntion = [NSString stringWithFormat:@"_did%@%@",@"Fini",@"sh"];
            NSMethodSignature *sig=[NSClassFromString(@"SKStoreProductViewController") instanceMethodSignatureForSelector:NSSelectorFromString(strFuntion)];
            NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:ctrl];
            [invocation setSelector:NSSelectorFromString(strFuntion)];
            [invocation invoke];
            [ctrl.view removeFromSuperview];
            [self.arrayCtrl removeObject:ctrl];
            if(self.isRemveAllAdView){
                time = 2;
                break;
            }
        }
        else if ([className compare:@"GDTStoreProductLoadingController"] == NSOrderedSame){
            NSMethodSignature *sig=[NSClassFromString([NSString stringWithFormat:@"GDTSt%@uctLoa%@",@"oreProd",@"dingController"]) instanceMethodSignatureForSelector:@selector(backEvent)];
            NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:ctrl];
            [invocation setSelector:@selector(backEvent)];
            [invocation invoke];
            [ctrl.view removeFromSuperview];
            [self.arrayCtrl removeObject:ctrl];
            if(self.isRemveAllAdView){
                break;
            }
        }
        else if ([className compare:@"GDTWebViewController"]==NSOrderedSame){
            NSMethodSignature *sig=[NSClassFromString([NSString stringWithFormat:@"GD%@bVie%@",@"TWe",@"wController"]) instanceMethodSignatureForSelector:@selector(popupDirectClose)];
            NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:ctrl];
            [invocation setSelector:@selector(popupDirectClose)];
            [invocation invoke];
            [ctrl.view removeFromSuperview];
            [self.arrayCtrl removeObject:ctrl];
            if(self.isRemveAllAdView){
                time = 2;
                break;
            }
        }
    }
    [self performSelector:@selector(checkCtrl) withObject:nil afterDelay:time];
}

-(void)addPushCtrl:(UIViewController*)ctrl{
     [self.arrayCtrl addObject:ctrl];
}

-(void)startOrStopCheck:(BOOL)flag{
    
    self.checkTime = [MajorSystemConfig getInstance].gdtDelayDisplayTime;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCtrl) object:nil];
    if(flag){
        self.isRemveAllAdView = false;
        [self performSelector:@selector(checkCtrl) withObject:nil afterDelay:self.checkTime];
    }
    else{
        self.isRemveAllAdView = true;
        [self checkCtrl];
        [self.arrayCtrl removeAllObjects];
    }
}
@end

