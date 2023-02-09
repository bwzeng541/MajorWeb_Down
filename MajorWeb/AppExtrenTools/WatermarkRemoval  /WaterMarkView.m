//
//  WaterMarkView.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WaterMarkView.h"
#import "RemoveApiView.h"
#import "MarjorWebConfig.h"
#import "AppDelegate.h"
@interface WaterMarkView(){
    float startY;
}
@property(nonatomic,strong)NSArray *apiArray;
@property(nonatomic,strong)NSMutableArray *apiArrayView;
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)NSTimer *delayTimer;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,assign)NSInteger index;

@end
@implementation WaterMarkView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.isUsePopGesture = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];

    
    self.backgroundColor = [UIColor whiteColor];
    
    //640X482;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, GetAppDelegate.appStatusBarH, 640, 482)];
    [self addSubview:view];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
    imageView.userInteractionEnabled = YES;
    imageView.image = UIImageFromNSBundlePngPath(@"remove_Top");
    [view addSubview:imageView];
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(34, 244, 434, 42)];
    [view addSubview:self.textField];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(501, 244, 84, 42);
    [view addSubview:btn];
    [btn addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
    self.textField.placeholder = @"请粘贴网址";
    __weak typeof(self) weakSelf = self;
    [self.textField setBk_didEndEditingBlock:^(UITextField *v) {
        [weakSelf insertPasteboard:v copyUrl:v.text];
    }];
    [self.textField setBk_didBeginEditingBlock:^(UITextField *v) {
        [weakSelf insertPasteboard:v copyUrl:[UIPasteboard generalPasteboard].string];
    }];
    float scales = MY_SCREEN_WIDTH/640;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scales, scales);
    view.center = CGPointMake(MY_SCREEN_WIDTH/2, GetAppDelegate.appStatusBarH+482*scales/2);
    startY = view.center.y+482*scales/2;
    self.apiArrayView = [NSMutableArray arrayWithCapacity:10];
    self.apiArray = @[@"http://www.yijianjiexi.com",@"https://dy.kukutool.com/",@"http://douyin.shipinjiexi.cn/",@"https://www.videofk.com/",@"http://nopapp.com/Home/DouYin"];
    //app_fanhui.png 7.5 36X25
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"app_fanhui"] forState:UIControlStateNormal];
    [self addSubview:btnClose];
    [btnClose setFrame:CGRectMake(0, 7.5+GetAppDelegate.appStatusBarH, 36, 25)];
    [btnClose addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

-(void)didEnterBack{
    [self.textField resignFirstResponder];

}


-(void)insertPasteboard:(UITextField*)v copyUrl:(NSString*)copyUrl{
    if (!copyUrl) {
        return;
    }
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:copyUrl options:NSMatchingReportProgress range:NSMakeRange(0, copyUrl.length)];
    if(arrayOfAllMatches.count>0)
    {
        copyUrl = [copyUrl substringWithRange:((NSTextCheckingResult*)[arrayOfAllMatches firstObject]).range];
        [MarjorWebConfig isUrlValid:copyUrl callBack:^(BOOL validValue, NSString *result) {
            if (validValue) {
                v.text = result;
            }
        }];
    }
}

-(void)changeDelay{
    if(self.index<self.apiArrayView.count){
        RemoveApiView  *vv=[self.apiArrayView objectAtIndex:self.index];
        vv.hidden = NO;
        [vv start];
        self.index++;
    }
    else{
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    [super removeFromSuperview];
}

-(void)go:(UIButton*)sender{
    [self.textField resignFirstResponder];
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    [self.scrollView removeFromSuperview];self.scrollView = nil;
    [self.apiArrayView removeAllObjects];
    if ([self.textField.text length]>0) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startY, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20)-startY)];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.scrollEnabled = YES;
        float HH = 30;
        float space = 10;
        [self.scrollView setContentSize:CGSizeMake(0, self.apiArray.count*(HH+space))];
        [self.scrollView setContentOffset:CGPointZero];
        [self addSubview:self.scrollView];
        for (int i = 0; i < self.apiArray.count; i++) {
            RemoveApiView *v = [[RemoveApiView alloc] initWithApi:[self.apiArray objectAtIndex:i] searchVideoUrl:self.textField.text];
            [self.apiArrayView addObject:v];
            v.hidden = YES;
            v.frame = CGRectMake(0, i*(HH+space), MY_SCREEN_WIDTH, HH);
            [self.scrollView addSubview:v];
        }
        self.index=0;
        [self changeDelay];
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(changeDelay) userInfo:nil repeats:YES];
    }
}
@end
