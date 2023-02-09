//
//  PromptView.m
//  WatchApp
//
//  Created by zengbiwang on 2018/6/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#define LABEL_MARGIN 12.0f
#define BOTTOM_MARGIN 8.0f
#define CORNER_RADIUS 8.0f
#define FONT_SIZE 15.f
#define HORIZONTAL_PADDING (8.0*1.5f)
#define VERTICAL_PADDING (6.0*1.5f)

#import "PromptView.h"
#import "Record.h"
@interface PromptView()
@property(copy,nonatomic)NSArray *dataArray;
@property(assign)NSInteger hotKeyHeight;
@property(assign)float oldheight;
@end

@implementation PromptView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
     return self;
}

-(NSInteger)updateHotsArray:(NSArray*)arrayHots{
    self.dataArray = arrayHots;
   return  [self getHotKeyHeightWithArray];
}


- (NSInteger)getHotKeyHeightWithArray
{
    self.hotKeyHeight = [self initLabel];
    return self.hotKeyHeight;
}

- (NSInteger )initLabel
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize textSize;
    CGRect previousFrame = CGRectMake(5, 5, 5, 5);
    BOOL isHasPreviousFrame = NO;
    float SCREEN_WIDTH = self.bounds.size.width;
    int i = 0;
    int maxLine = 2,currentLine = 0;
    self.hotKeyHeight = 0;
    for (Record *item in self.dataArray) {
        NSString *text = item.titleName;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        textSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FONT_SIZE],NSFontAttributeName,nil]
                                      context:nil].size;
        textSize.width = textSize.width + 8;
        textSize.height = textSize.height + 4;
        if (isHasPreviousFrame) {
            //非首行首个关键字
            CGRect nowRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + textSize.width + LABEL_MARGIN > SCREEN_WIDTH - 20) {
                //需换行
                if (currentLine>=maxLine) {
                    break;
                }
                nowRect.origin = CGPointMake(5, previousFrame.origin.y + textSize.height + BOTTOM_MARGIN);
                self.hotKeyHeight += textSize.height + BOTTOM_MARGIN;
                currentLine++;
            }else{
                //无需换行
                nowRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
            }
            nowRect.size = textSize;
            btn.frame = nowRect;
        }else{
            //首行首个关键字
            if (currentLine>=maxLine) {
                break;
            }
            currentLine++;
            btn.frame = CGRectMake(5, 5, textSize.width, textSize.height);
            self.hotKeyHeight = textSize.height;
        }
        btn.tag = i++;
        previousFrame = btn.frame;
        isHasPreviousFrame = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blackColor];
        [btn setTitle:text forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:CORNER_RADIUS];
        [btn.layer setBorderColor:[UIColor clearColor].CGColor];
        [btn.layer setBorderWidth:1];
        [self addSubview:btn];
    }
    //self.hotKeyHeight = self.hotKeyHeight ;
    return self.hotKeyHeight;
}

- (void)onBtnClick:(UIButton *)sender
{
    if (self.block) {
        self.block([self.dataArray objectAtIndex:sender.tag]);
    }
}
@end
