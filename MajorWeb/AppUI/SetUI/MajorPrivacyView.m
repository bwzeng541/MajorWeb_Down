//
//  MajorPrivacyCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/16.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorPrivacyView.h"
#import "AppDelegate.h"
@interface MajorPrivacyText:UITextView

@end
@implementation MajorPrivacyText

@end

@interface MajorPrivacyView ()<UITextViewDelegate>
@property(nonatomic,strong)UITextView *privacyText;
@end

@implementation MajorPrivacyView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.isUsePopGesture = YES;
    self.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(5, GetAppDelegate.appStatusBarH, 50, 50);
    [btnBack setTitle:@"< 设置" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:btnBack];
    
    UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH, 50)];
    labelDes.text =@"隐私声明";
    labelDes.textColor = [UIColor blackColor];
    labelDes.textAlignment = NSTextAlignmentCenter;
    [self insertSubview:labelDes belowSubview:btnBack];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH+50, MY_SCREEN_WIDTH, 1)];
    [self addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [btnBack addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    
    self.privacyText = [[MajorPrivacyText alloc] initWithFrame:CGRectMake(5, GetAppDelegate.appStatusBarH+55, MY_SCREEN_WIDTH-10, MY_SCREEN_HEIGHT- GetAppDelegate.appStatusBarH-55)];
    if (IF_IPAD) {
        self.privacyText.font = [UIFont systemFontOfSize:24];
    }
    self.privacyText.delegate = self;
    self.privacyText.editable = false;
    [self addSubview:self.privacyText];
    self.privacyText.textColor = [UIColor blackColor];
    self.privacyText.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorPrivacyText" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
    
    return self;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (void)pressBack:(UIButton*)sender{
    [self removeFromSuperview];
 }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
