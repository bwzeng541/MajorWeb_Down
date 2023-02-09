//
//  AppVipBuyCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/12/24.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "AppVipBuyCtrl.h"
#import "NewVipPay.h"
#import "AppDelegate.h"
@interface AppVipBuyCtrl ()
@property(weak)IBOutlet UIButton *btn1;
@property(weak)IBOutlet UIButton *btn2;
@property(weak)IBOutlet UILabel *labelName;
@property(weak)IBOutlet UILabel *labelTime;
@property(weak)IBOutlet UIButton *btnBack;
@property(strong,nonatomic)UIAlertController*alert;
@end

@implementation AppVipBuyCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelName.text = @"";
    self.labelTime.text = @"";
    // Do any additional setup after loading the view from its nib.
    @weakify(self)
    [RACObserve([NewVipPay getInstance], vipData) subscribeNext:^(id x) {
        @strongify(self)
        self.labelTime.text = [NSString stringWithFormat:@"会员结束时间%@",x];
        self.labelName.text = [NSString stringWithFormat:@"会员账号%@",[[NewVipPay getInstance]getAccount]];
    }];
    
    [RACObserve([NewVipPay getInstance], account) subscribeNext:^(id x) {
        @strongify(self)
        self.labelName.text = [NSString stringWithFormat:@"会员账号%@",[NewVipPay getInstance].account];
    }];
}


-(IBAction)pressLogin:(id)sender{
    [self go:false];
}

-(IBAction)pressReg:(id)sender{
    [self go:true];
}

-(void)go:(BOOL)isReg{
    NSString *account = nil;
    NSString *password = nil;
    if (!isReg) {
         account = [[NewVipPay getInstance] getAccount];
         password = [[NewVipPay getInstance] password];
    }
    __weak typeof(self) weakself = self;
    self.alert = [UIAlertController alertControllerWithTitle:@"请输入账号和密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]removeObserver:weakself name:UITextFieldTextDidChangeNotification object:nil];
    }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = [[[self.alert textFields]firstObject]text];
        NSString *password = [[[self.alert textFields]lastObject]text];
        if(isReg){
            [[NewVipPay getInstance] regSever:name password:password];
        }
        else{
            [[NewVipPay getInstance] loginSever:name password:password isShowMsg:YES];
        }
        [[NSNotificationCenter defaultCenter]removeObserver:weakself name:UITextFieldTextDidChangeNotification object:nil];
    }];
    
    // 先冻结 “好的” 按钮，需要用户输入用户名和密码后再启用
    if (account && password) {
        [defaultAction setEnabled:YES];
    }
    else{
        [defaultAction setEnabled:NO];
    }
    
    [self.alert addAction:cancleAction];
    [self.alert addAction:defaultAction];
    
    // 添加文本输入框
    [self.alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入电话号码";
        if (account) {
            textField.text = account;
        }
        [[NSNotificationCenter defaultCenter]addObserver:weakself selector:@selector(handleTextFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    }];
    
    // 添加密码输入框
    [self.alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入密码";
        if (password) {
            textField.text = password;
        }
        [textField setSecureTextEntry:NO];
    }];
    UIPopoverPresentationController *popover = self.alert.popoverPresentationController;
    if (popover) {
        popover.sourceView = weakself.view;
        popover.sourceRect = CGRectMake(0, 0,400, 200);
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
   [GetAppDelegate.window.rootViewController presentViewController:self.alert animated:YES completion:nil];
}

- (void)handleTextFieldDidChanged:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.alert;
    if (alertController) {
        UITextField *textField = alertController.textFields.firstObject;
        UITextField *sencodField = alertController.textFields.lastObject;

        UIAlertAction *action  = alertController.actions.lastObject;
       NSInteger lenght1 = [[textField.text
                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
        NSInteger lenght2 = [[sencodField.text
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
        action.enabled = (lenght2 >0 && lenght1>0 && action> 0);
    }
}

-(IBAction)pressBack:(id)sender{
    [self.delegate willRemove];
}


@end
