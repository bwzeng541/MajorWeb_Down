//
//  GDtRootCtrl.m
//  GDTMobSample
//
//  Created by zengbiwang on 2017/11/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "GDtInterstitialRootCtrl.h"
#import "MajorSystemConfig.h"
@interface GDtInterstitialRootCtrl ()
@property(assign)BOOL isRemveAllAdView;
@property(assign)float checkTime;
@property(retain)NSMutableArray *arrayCtrl;
@end

@implementation GDtInterstitialRootCtrl
-(void)addPushCtrl:(UIViewController*)ctrl{
    [super addPushCtrl:ctrl];
}

-(void)startOrStopCheck:(BOOL)flag{
    self.checkTime = [MajorSystemConfig getInstance].gdtDelayDisplayTime/2.0;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCtrl) object:nil];
        if(!flag){
            self.isRemveAllAdView = false;
            [self checkCtrl];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCtrl) object:nil];
            //[self performSelector:@selector(checkCtrl) withObject:nil afterDelay:self.checkTime];
        }
        else{
            self.isRemveAllAdView = true;
            [self checkCtrl];
            //[self.arrayCtrl removeAllObjects];
        }
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
        else if ([className compare:@"GDTInterstitialOver8Dialog"]==NSOrderedSame){
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

-(void)notifiClose:(UIViewController*)ctrl{//关闭GDTInterstitialOver8Dialog的ctrl
    
}
@end

