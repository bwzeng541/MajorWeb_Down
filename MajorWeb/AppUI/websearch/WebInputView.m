//
//  WebInputView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/6.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebInputView.h"
#import "NSObject+UISegment.h"
@interface WebInputView()
@property(strong,nonatomic)NSArray *titleArray;
@end
@implementation WebInputView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBCOLOR(210, 210,210);
    [self initBtn];
    return self;
}

-(void)initBtn{
    self.titleArray = @[@":" ,@"/",@"www.",@"m.",@".com",@".cn",@".net",@"https://"];
    float w = MY_SCREEN_WIDTH/self.titleArray.count;
    NSMutableArray *btnArray = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
    for (NSString *title in self.titleArray) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:btn];
        btn.tag=i++;
        [btn addTarget:self action:@selector(clickChar:) forControlEvents:UIControlEventTouchUpInside];
        [btnArray addObject:btn];
    }
    for (int i = 0; i<btnArray.count; i++) {
        if ( i==0) {
            [NSObject initii:self contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:[btnArray objectAtIndex:i] viSize:CGSizeMake(w, self.frame.size.height) vi2:nil index:i count:btnArray.count];
        }
        else{
            [NSObject initii:self contenSize:CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) vi:[btnArray objectAtIndex:i] viSize:CGSizeMake(w, self.frame.size.height) vi2:[btnArray objectAtIndex:i-1] index:i count:btnArray.count];
        }
    }
}

-(void)clickChar:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(clickCharFromInputView:)]) {
        [self.delegate clickCharFromInputView:[self.titleArray objectAtIndex:sender.tag]];
    }
}
@end
