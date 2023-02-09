//
//  BottommTipsView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/7.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "BottommTipsView.h"
#import "POP.h"
#import "MarjorWebConfig.h"
@interface BottommTipsView()
@property(assign)float barH;
@property(assign)CGRect oldRect;
@property(nonatomic,copy)NSURL *appStoreUrl;
@property(nonatomic,copy)NSURL *sourceUrl;

@end

@implementation BottommTipsView
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame barH:(float)barh appStoreUrl:(NSURL*)url sourceUrl:(NSURL*)sourceUrl des:(NSString*)des{
    self = [super initWithFrame:frame];
    self.appStoreUrl = url;
    self.sourceUrl = sourceUrl;
    self.oldRect = frame;
    self.barH = barh;
    self.backgroundColor = RGBCOLOR(22, 163, 255);
    UILabel *lable = [[UILabel alloc] initWithFrame:self.bounds];
    lable.text = des;
    lable.textAlignment = NSTextAlignmentLeft;
    [self addSubview:lable];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(frame.size.width-100, 0, 100, frame.size.height)];
    [btn setTitle:@"允许" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(openInAppStore) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame des:(NSString*)des{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBCOLOR(22, 163, 255);
    UILabel *lable = [[UILabel alloc] initWithFrame:self.bounds];
    lable.text = des;
    self.oldRect = CGRectMake(0, MY_SCREEN_HEIGHT+50, frame.size.width, frame.size.height);
    lable.textAlignment = NSTextAlignmentLeft;
    lable.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self addSubview:lable];
    return self;
}

-(void)openInAppStore{
    [self pop_removeAllAnimations];
    [[MarjorWebConfig getInstance]removeOpenInAppStoreDisable:[self.sourceUrl host]];
    if (self.openUrlBlock) {
        self.openUrlBlock(self.appStoreUrl);
    }
    [self removeFromSuperview];
}

-(void)showAction
{
    POPBasicAnimation *animFrame = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    animFrame.beginTime = CACurrentMediaTime();
    animFrame.duration = 0.5;
    CGRect rect = CGRectMake(0, self.superview.frame.size.height-self.bounds.size.height-self.barH, self.bounds.size.width, self.bounds.size.height);
    animFrame.toValue=[NSValue valueWithCGRect:rect];
    [self pop_addAnimation:animFrame forKey:nil];
    __weak __typeof(self) weakSelf = self;
    [animFrame setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [weakSelf remveAction];
    }];
}

-(void)remveAction{
    POPBasicAnimation *animFrame = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    animFrame.beginTime = CACurrentMediaTime()+2;
    animFrame.duration = 0.5;
    animFrame.toValue=[NSValue valueWithCGRect:self.oldRect];
    [self pop_addAnimation:animFrame forKey:nil];
    __weak __typeof(self) weakSelf = self;
    [animFrame setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}
@end
