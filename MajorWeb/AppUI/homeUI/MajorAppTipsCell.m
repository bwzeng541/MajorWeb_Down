//
//  MajorAppTipsView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/25.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorAppTipsCell.h"
@interface MajorAppTipsCell()
@property(nonatomic,assign)float cellSizeH;
@end

@implementation MajorAppTipsCell


-(id)initTextType:(NSInteger)type frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, frame.size.height-20)];
    [self addSubview:vv];
    float h = (vv.frame.size.height)/3;
  
    if (type==0) {
       
        [self addLableApp:@"      注意事项：" msg:@"无法启动时，请删除APP，再重新下载，设置信任" frame:CGRectMake(0, 0, self.bounds.size.width, h) parentView:vv textColor:RGBCOLOR(255, 0, 0)];
        [self addLableApp:@"      下载地址：" msg:@"请在safari浏览器打开max77.cn下载app" frame:CGRectMake(0, h, self.bounds.size.width, h)parentView:vv textColor:RGBCOLOR(255, 0, 0)];
        [self addLableApp:@"      添加客服：" msg:@"微信号：maxboss911       QQ：2407155485" frame:CGRectMake(0, h*2, self.bounds.size.width, h)parentView:vv textColor:RGBCOLOR(255, 0, 0)];
     }
    else{
        UILabel *label = [[UILabel alloc]init];
        self.headLabel = label;
        [self addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"相关提示" ;
        label.textColor = [UIColor blackColor];
        if (IF_IPHONE) {
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16*AppScaleIphoneH];
        }
        else{
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:24*AppScaleIpadH];
        }
        float lableh = 50;
        if (IF_IPHONE) {
            lableh/=2;
        }
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(20);
            make.height.mas_equalTo(lableh);
            make.top.equalTo(self).mas_offset(10);
            make.width.mas_equalTo(self);
        }];
        self.headLabel = label;
        lableh+=10;
         [self addLableApp:@"      声明：" msg:@"不提供任何的电影,小说,漫画等资源" frame:CGRectMake(0, lableh, self.bounds.size.width, h) parentView:vv textColor:RGBCOLOR(255, 0, 0)];
        [self addLableApp:@"      速度：" msg:@"视频太慢，小说，漫画打不开请换一个网站观看" frame:CGRectMake(0,lableh+ h, self.bounds.size.width, h)parentView:vv textColor:RGBCOLOR(255, 0, 0)];
        [self addLableApp:@"      优势：" msg:@"我们针对用户提供的网站，对网站进行优化展示" frame:CGRectMake(0, lableh+h*2, self.bounds.size.width, h)parentView:vv textColor:RGBCOLOR(255, 0, 0)];
    }
    return self;
}

-(void)addLableApp:(NSString*)title msg:(NSString*)msg frame:(CGRect)frame parentView:(UIView*)view textColor:(UIColor*)textColor{
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   %@",title,msg]];
    NSRange rangeHeader = NSMakeRange(0, [title length]);
    NSRange rangeDes = NSMakeRange(rangeHeader.length, [msg length]+3);
    float fontSize ;
    if (!IF_IPAD) {
        fontSize = 12*AppScaleIphoneH;
    }
    else{
        fontSize = 11*AppScaleIphoneH;
    }
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize]
                    range:rangeHeader];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:RGBCOLOR(0, 0, 0)
                    range:rangeHeader];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:fontSize*0.9]
                    range:rangeDes];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:textColor
                    range:rangeDes];
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
    [view addSubview:label1];
    label1.attributedText = attrStr;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.textColor = textColor;
   
}
@end
