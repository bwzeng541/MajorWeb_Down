//
//  SSDjsView.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "SSDjsView.h"

@interface SSDjsView(){
    UIImageView *imageView;
}
@property(nonatomic,strong)NSTimer *autoDisplayTimer;
@property(assign)NSInteger currentTime;
@end
@implementation SSDjsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews{
    if(!imageView)
    {
        self.userInteractionEnabled = NO;
        self.currentTime = 15;
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"video_ad_djs" ofType:@"png"]]];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        UILabel *label = [[UILabel alloc] init];
        label.tag = 1234567;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        label.text = [NSString stringWithFormat:@"%ds跳过",self.currentTime];
        if(!self.autoDisplayTimer){
            self.autoDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDisplayTimer:) userInfo:nil repeats:YES];
        }
    }
    
}

-(void)updateDisplayTimer:(NSTimer*)timer{
    UILabel *label = [self viewWithTag:1234567];
    self.currentTime--;
    if (label) {
        label.text= [NSString stringWithFormat:@"%ds跳过",self.currentTime];
    }
    if (self.currentTime<=0) {
        [self.autoDisplayTimer invalidate];
        self.autoDisplayTimer=nil;
        if(self.autoRemove){
            self.autoRemove();
        }
    }
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    [self.autoDisplayTimer invalidate];
    self.autoDisplayTimer=nil;
    self.autoRemove = nil;
    [super removeFromSuperview];
}
@end
