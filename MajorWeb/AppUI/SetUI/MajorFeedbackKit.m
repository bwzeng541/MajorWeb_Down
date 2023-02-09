//
//  MajorFeedbackKit.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorFeedbackKit.h"
//#import <BCHybridWebViewFMWK/BCHybridWebView.h>
//#import <YWFeedbackFMWK/YWFeedbackKit.h>
//#import <YWFeedbackFMWK/YWFeedbackViewController.h>
#import "AppDelegate.h"
#import "YSCHUDManager.h"
#import "UIAlertView+NSCookbook.h"
static BOOL isShowTishi = true;
//@interface YWFeedbackViewController(Extensions111)
//-(void)rightItemAction;
//@end

@implementation MajorFeedbackKit(Extensions111)

@end

@interface MajorFeedbackKit()
@property (nonatomic,assign)BOOL isAutoShow;
@property (nonatomic,weak)UIViewController *parentCtrl;
//@property (nonatomic, strong) YWFeedbackKit *feedbackKit;
@end
@implementation MajorFeedbackKit
+(MajorFeedbackKit*)getInstance{
    static MajorFeedbackKit*g = NULL;
    if (!g) {
        g = [[MajorFeedbackKit alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
  //  self.feedbackKit = [[YWFeedbackKit alloc] autoInit];
    return self;
}

-(void)openFeedbackViewController:(UIViewController*)ctrl{
    [self showRightAction:ctrl isShowAction:NO];
}

-(void)showRightAction:(UIViewController*)ctrl isShowAction:(BOOL)isShowAction{
    
//    self.feedbackKit.extInfo = @{@"loginTime":[[NSDate date] description],
//                                 @"visitPath":@"登陆->关于->反馈",
//                                 @"userid":@"yourid",
//                                 @"应用自定义扩展信息":@"开发者可以根据需要设置不同的自定义信息，方便在反馈系统中查看"};
//
//    __weak typeof(self) weakSelf = self;
//    weakSelf.parentCtrl = ctrl;
//    [self.feedbackKit makeFeedbackViewControllerWithCompletionBlock:^(YWFeedbackViewController *viewController, NSError *error) {
//        if (viewController != nil) {
//
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
//            [weakSelf.parentCtrl presentViewController:nav animated:YES completion:^{
//                if (isShowAction) {
//                        [YSCHUDManager showHUDOnKeyWindow];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [YSCHUDManager hideHUDOnKeyWindow];
//                        [viewController rightItemAction];
//                    });
//                }
//                else{
//                    [YSCHUDManager hideHUDOnKeyWindow];
//                }
//            }];
//
//            [viewController setCloseBlock:^(UIViewController *aParentController){
//                [aParentController dismissViewControllerAnimated:YES completion:^{
//                    self.isAutoShow = false;
//                }];
//            }];
//        } else {
//            self.isAutoShow = false;
//            /** 使用自定义的方式抛出error时，此部分可以注释掉 */
//            NSString *title = [error.userInfo objectForKey:@"msg"]?:@"接口调用失败，请保持网络通畅！";
//            //            [[TWMessageBarManager sharedInstance] showMessageWithTitle:title
//            //                                                           description:nil
//            //                                                                  type:TWMessageBarMessageTypeError];
//        }
//    }];
}

-(void)showAtler{
    __weak __typeof(self)weakSelf = self;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:@"客服人员已经回复你的留言，你可以点击查看~"
                              delegate:nil
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"查看", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {
            if (!self.isAutoShow) {
                self.isAutoShow = true;
                [weakSelf showRightAction:GetAppDelegate.getRootCtrlView.nextResponder isShowAction:YES];
            }
        }
    }];
}
-(void)updateUnreadCount{
//    __weak __typeof(self)weakSelf = self;
//    [self.feedbackKit getUnreadCountWithCompletionBlock:^(NSInteger unreadCount, NSError *error) {
//        if (unreadCount>0 && !self.isAutoShow && isShowTishi) {
//            [weakSelf showAtler];
//            isShowTishi=false;
//        }
//    }];
}
@end
