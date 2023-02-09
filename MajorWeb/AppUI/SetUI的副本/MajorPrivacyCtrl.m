//
//  MajorPrivacyCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/16.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorPrivacyCtrl.h"

@interface MajorPrivacyText:UITextView

@end
@implementation MajorPrivacyText

@end

@interface MajorPrivacyCtrl ()<UITextViewDelegate>
@property(nonatomic,strong)UITextView *privacyText;
@end

@implementation MajorPrivacyCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(5, STATUSBAR_HEIGHT, 50, 50);
    [btnBack setTitle:@"< 设置" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnBack];
    
    UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, MY_SCREEN_WIDTH, 50)];
    labelDes.text =@"隐私声明";
    labelDes.textColor = [UIColor blackColor];
    labelDes.textAlignment = NSTextAlignmentCenter;
    [self.view insertSubview:labelDes belowSubview:btnBack];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT+50, MY_SCREEN_WIDTH, 1)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [btnBack addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    
    self.privacyText = [[MajorPrivacyText alloc] initWithFrame:CGRectMake(5, STATUSBAR_HEIGHT+55, MY_SCREEN_WIDTH-10, MY_SCREEN_HEIGHT- STATUSBAR_HEIGHT-55)];
    if (IF_IPAD) {
        self.privacyText.font = [UIFont systemFontOfSize:24];
    }
    self.privacyText.delegate = self;
    self.privacyText.editable = false;
    [self.view addSubview:self.privacyText];
    self.privacyText.textColor = [UIColor blackColor];
    self.privacyText.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MajorPrivacyText" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
    
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   

}

- (void)pressBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
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
