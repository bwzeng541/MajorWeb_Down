//
//  WebGeneralTools.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/4.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebGeneralTools.h"
#import "NSObject+UISegment.h"
#import "VipPayPlus.h"
@implementation WebGeneralTools

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(@"Menu.bundle/tool_b")];
    backImageView.frame = self.bounds;
    [self addSubview:backImageView];
    //33X158
    UIButton *btn1 = [self createBtn:@"添加收藏" action:@selector(addf1:)];
   // UIButton *btn2 = [self createBtn:@"屏蔽此网站广告" action:@selector(addf2:)];
    UIButton *btn3 = [self createBtn:@"添加到文件夹" action:@selector(addf3:)];
    UIButton *btn4 = [self createBtn:@"查看收藏" action:@selector(addf4:)];
    float w = IF_IPAD?160:80;
    [NSObject initii:self contenSize:frame.size vi:btn1 viSize:CGSizeMake(w, frame.size.height) vi2:nil index:0 count:3];
   // [NSObject initii:self contenSize:frame.size vi:btn2 viSize:CGSizeMake(w, frame.size.height) vi2:btn1 index:1 count:3];
    [NSObject initii:self contenSize:frame.size vi:btn3 viSize:CGSizeMake(w, frame.size.height) vi2:btn1 index:2 count:3];
    [NSObject initii:self contenSize:frame.size vi:btn4 viSize:CGSizeMake(w, frame.size.height) vi2:btn3 index:3 count:3];
    return self;
}

-(void)addf1:(UIButton*)sender{
    if (self.addFavoriteBlock) {
        self.addFavoriteBlock();
    }
}

-(void)addf2:(UIButton*)sender{
    if (self.webSubmitBlock) {
        [[VipPayPlus getInstance] showWithUrlAndFeeAlter:self.webSubmitBlock()];
    }
}

-(void)addf3:(UIButton*)sender{
    if (self.addHomeBlock) {
        self.addHomeBlock();
    }
}

-(void)addf4:(UIButton*)sender{
    if (self.getRedBagBlock) {
        self.getRedBagBlock();
    }
}

-(UIButton*)createBtn:(NSString*)title action:(nonnull SEL)action{
    UIButton *btnAddFa = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddFa addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnAddFa];
    btnAddFa.titleLabel.font=[UIFont systemFontOfSize:IF_IPAD?20:14];
    [btnAddFa setTitle:title forState:UIControlStateNormal];
    [btnAddFa setTitleColor:RGBCOLOR(16, 195, 71) forState:UIControlStateNormal];
    return btnAddFa;
}
@end
