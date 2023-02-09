//
//  BeatifySlideView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/11/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifySlideView.h"
#import "UIImage+CWAdditions.h"
//#import "UIImage+BeatfiyImageTools.h"
@interface BeatifySlideView()
@property(nonatomic,strong)NSTimer *changeTimer;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)NSInteger typeIndex;
@property(nonatomic,strong)NSArray *picArray;
@property(nonatomic,strong)NSArray *typeArray;
@property(nonatomic,strong)UIImageView *backgroundView;

@end
@implementation BeatifySlideView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
-(void)removeFromSuperview{
    self.backgroundView =nil;
    self.picArray = nil;
    self.typeArray = nil;
    [self.changeTimer invalidate];self.changeTimer = nil;
    [super removeFromSuperview];
}

-(id)initWithFrame:(CGRect)frame arrayPics:(NSArray*)array{
    self = [super initWithFrame:frame];
    self.picArray = array;
    self.typeArray = @[@"push",@"fade",@"reveal",@"moveIn",@"cube",@"suckEffect",@"oglFlip",@"rippleEffect",@"pageCurl",@"cameraIrisHollowOpen",@"cameraIrisHollowClose",@"pageUnCurl"];
    self.backgroundColor = [UIColor blackColor];
    [self changeImage];
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
    return self;
}

-(void)changeImage{
    if (!self.backgroundView) {
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.backgroundView];
    }
    UIImage *image = [[UIImage imageWithContentsOfFile:[self.picArray objectAtIndex:self.index]] imageByScalingProportionallyToMinimumSize:self.bounds.size];
    self.backgroundView.image  = image;
    self.backgroundView.frame = CGRectMake((self.bounds.size.width-image.size.width)/2, (self.bounds.size.height-image.size.height)/2, image.size.width, image.size.height);
    self.index = (self.index+1)%self.picArray.count;
    
    CATransition *transtion = [[CATransition alloc] init];
    transtion.type = [self.typeArray objectAtIndex:self.typeIndex];
    transtion.subtype = kCATransitionFromBottom;
    transtion.duration = 1;
    transtion.startProgress = 0.1;
    transtion.endProgress = 1.0;
    [self.layer addAnimation:transtion forKey:nil];
    self.typeIndex = (self.typeIndex+1)%self.typeArray.count;
}
@end
