//
//  GGToolBarTopView.m
//  GGBrower
//
//  Created by zengbiwang on 2019/12/16.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "AddressToolBarTopView.h"
#import "UIView+BlocksKit.h"
@implementation AddressToolBarTopView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    UIButton *btnBottom = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:btnBottom];
    [btnBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
     [btnBottom addTarget:self action:@selector(emptyDo:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
       [self addSubview:btn];
    [btn setTitle:@"复制网址"  forState:UIControlStateNormal];
       [btn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.bottom.equalTo(self);
           make.left.equalTo(self).mas_offset(20);
           make.width.mas_equalTo(100);
       }];
       [btn addTarget:self action:@selector(clickCopy:) forControlEvents:UIControlEventTouchUpInside];
       [btn setBackgroundColor:RGBCOLOR(65, 65, 65)];
    [btn setTintColor:[UIColor whiteColor]];
    
       UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeSystem];
          [self addSubview:btnEdit];
          [btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.bottom.equalTo(self);
              make.width.mas_equalTo(100);
              make.left.equalTo(btn.mas_right).mas_offset(20);
          }];
    [btnEdit setTitle:@"编辑网址" forState:UIControlStateNormal];
          [btnEdit addTarget:self action:@selector(clickEdit:) forControlEvents:UIControlEventTouchUpInside];
    [btnEdit setBackgroundColor:RGBCOLOR(65, 65, 65)];
    [btnEdit setTintColor:[UIColor whiteColor]];
    
    return self;
}
 
-(void)emptyDo:(id)sender{
    
}

-(void)clickCopy:(id)sender{
    self.copyWeb();
}

-(void)clickEdit:(id)sender{
    self.editWeb();
}
@end
