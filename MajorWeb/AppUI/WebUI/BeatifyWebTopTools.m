//
//  BeatifyWebTopTools.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyWebTopTools.h"

@implementation BeatifyWebTopTools

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)initUI{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];

    [self addSubview:btn];[btn setTitle:@"< 网站-首页" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBackHome:) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(self);
        make.left.equalTo(self).mas_offset(5);
        make.width.mas_equalTo(95);
    }];
   
    UIButton *btnSumbit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSumbit.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:btnSumbit]; btnSumbit.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];


    [btnSumbit addTarget:self action:@selector(clickSearch:) forControlEvents:UIControlEventTouchUpInside];
    [btnSumbit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.equalTo(self);
        make.right.equalTo(self).mas_offset(-5);
        make.width.mas_equalTo(70);
    }];[btnSumbit setTitle:@"搜索视频" forState:UIControlStateNormal];
    
    UIButton *btnAdlist = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdlist.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:btnAdlist];[btnAdlist setTitle:@"网址排行" forState:UIControlStateNormal];
    [btnAdlist mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.equalTo(self);
        make.right.equalTo(btnSumbit.mas_left).mas_offset(-20);
        make.width.mas_equalTo(70);
    }];btnAdlist.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    [btnAdlist addTarget:self action:@selector(clickWebRank:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)clickSearch:(id)sender{
    if ([self.delegate respondsToSelector:@selector(top_clickWebHostSearchVideo)]) {
        [self.delegate top_clickWebHostSearchVideo];
    }
}

-(void)clickBackHome:(id)sender{
    if ([self.delegate respondsToSelector:@selector(top_clickWebHostUrl)]) {
        [self.delegate top_clickWebHostUrl];
    }
}

-(void)clickWebRank:(id)sender{
    if ([self.delegate respondsToSelector:@selector(top_clickWebHostWebRank)]) {
        [self.delegate top_clickWebHostWebRank];
    }
}
@end
