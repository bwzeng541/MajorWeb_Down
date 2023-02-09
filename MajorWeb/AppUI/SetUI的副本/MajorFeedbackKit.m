//
//  MajorFeedbackKit.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorFeedbackKit.h"
#import <BCHybridWebViewFMWK/BCHybridWebView.h>
#import <YWFeedbackFMWK/YWFeedbackKit.h>
#import <YWFeedbackFMWK/YWFeedbackViewController.h>
@interface MajorFeedbackKit()
@property (nonatomic,weak)UIViewController *parentCtrl;
@property (nonatomic, strong) YWFeedbackKit *feedbackKit;
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
    self.feedbackKit = [[YWFeedbackKit alloc] autoInit];
    return self;
}

-(void)openFeedbackViewController:(UIViewController*)ctrl{
    self.feedbackKit.extInfo = @{@"loginTime":[[NSDate date] description],
                                 @"visitPath":@"登陆->关于->反馈",
                                 @"userid":@"yourid",
                                 @"应用自定义扩展信息":@"开发者可以根据需要设置不同的自定义信息，方便在反馈系统中查看"};
    
    __weak typeof(self) weakSelf = self;
    weakSelf.parentCtrl = ctrl;
    [self.feedbackKit makeFeedbackViewControllerWithCompletionBlock:^(YWFeedbackViewController *viewController, NSError *error) {
        if (viewController != nil) {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
            [weakSelf.parentCtrl presentViewController:nav animated:YES completion:nil];
            
            [viewController setCloseBlock:^(UIViewController *aParentController){
                [aParentController dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            /** 使用自定义的方式抛出error时，此部分可以注释掉 */
            NSString *title = [error.userInfo objectForKey:@"msg"]?:@"接口调用失败，请保持网络通畅！";
            //            [[TWMessageBarManager sharedInstance] showMessageWithTitle:title
            //                                                           description:nil
            //                                                                  type:TWMessageBarMessageTypeError];
        }
    }];

}
@end
