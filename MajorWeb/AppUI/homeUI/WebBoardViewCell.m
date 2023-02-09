//
//  WebBoardViewCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/30.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebBoardViewCell.h"
#import "WebBoardView.h"
#import "MajorModeDefine.h"
#import "MarjorWebConfig.h"
@interface WebBoardViewCell()
@property(nonatomic,strong)UIImageView *imageView;
@end
@implementation WebBoardViewCell
-(void)addWebClidView:(UIView*)view{
    WebBoardView*m = (WebBoardView*)view;
    [self addSubview:view];
    float startx = self.imageView.frame.origin.x+self.imageView.frame.size.width+5;
    m.frame = CGRectMake(startx, 45, self.bounds.size.width-startx, self.bounds.size.height-60);
    [m updateIsSize:m.bounds.size];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}
-(void)initWebBoarViewCell{
    //122X171
    
    UILabel *label = [[UILabel alloc]init];
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(20);
        make.height.mas_equalTo(30);
        make.top.equalTo(self).mas_offset(10);
        make.width.mas_equalTo(self);
    }];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"标签管理" ;
    label.textColor = [UIColor blackColor];
    self.headLabel = label;
    if (IF_IPHONE) {
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16*AppScaleIphoneH];
    }
    else{
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:24*AppScaleIpadH];
    }
    
    float w = 122,h=171;
    if (IF_IPHONE) {
        w/=2;h/=2;
    }
    self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AppMain.bundle/new_web"]];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.frame = CGRectMake(20, (self.bounds.size.height-h)/2+30, w, h);
    [self addSubview:self.imageView];
    [self.imageView bk_whenTapped:^{
        WebConfigItem *item = [[WebConfigItem alloc] init];
        item.url = @"https://cpu.baidu.com/1022/ac797dc4/i?scid=15951";
        [MarjorWebConfig getInstance].webItemArray = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
