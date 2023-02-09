//
//  ModifyDetailCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ModifyDetailCell.h"
#import "MainMorePanel.h"
#import "MarjorWebConfig.h"
@interface ModifyDetailCell()
@property(nonatomic,strong)IBOutlet UIButton *btnDel;
@property(nonatomic,strong)IBOutlet UIButton *btnModfiy;
@property(nonatomic,strong)IBOutlet UILabel *showLabelName;
@property(nonatomic,strong)IBOutlet UILabel *showLabelUrl;
@property(nonatomic,assign)NSInteger currentIndex ;
@property(strong,nonatomic)WebConfigItem *configItem;
@property(nonatomic,weak)id<WebConfigItemDelegate> delegate ;
@end

@implementation ModifyDetailCell

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)updateConfigItem:(WebConfigItem*)configItem index:(NSInteger)index delegate:(id<WebConfigItemDelegate>)delegate{
    self.currentIndex = index;
    self.delegate = delegate;
    self.configItem = configItem;
    self.showLabelName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:self.showLabelName.font.pointSize];
    self.showLabelUrl.text = configItem.url;
    self.showLabelName.text = configItem.name;
}

-(IBAction)pressDes:(UIButton*)sender{
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [wself.delegate syncWebConfigItemDelData:nil index:wself.currentIndex];
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(IBAction)pressModfiy:(UIButton*)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改该项" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.text =  textField.placeholder =  wself.configItem.name;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.text =  textField.placeholder = wself.configItem.url;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField1 = alertController.textFields.firstObject;
        __block NSString*nameText = envirnmentNameTextField1.text;
        
        UITextField *envirnmentNameTextField2 = [alertController.textFields objectAtIndex:1];
        __block NSString*urlText = envirnmentNameTextField2.text;
        [MarjorWebConfig isUrlValid:urlText callBack:^(BOOL validValue, NSString *result) {
            if (validValue && [nameText length]>1) {
                [wself modifyNew:nameText url:result];
            }
            else{
                [[[UIApplication sharedApplication] keyWindow] makeToast:@"输入不合法" duration:2 position:@"center"];
            }
        }];
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(void)modifyNew:(NSString*)name url:(NSString*)url{
    self.configItem.name = name;
    self.configItem.url = url;
    self.showLabelUrl.text = url;
    self.showLabelName.text = name;
    [self.delegate syncWebConfigItemData:self.configItem index:self.currentIndex];
}

@end
