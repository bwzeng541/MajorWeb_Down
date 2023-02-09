//
//  QRMultiView.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#define LABEL_MARGIN 12.0f
#define BOTTOM_MARGIN 8.0f
#define CORNER_RADIUS 8.0f
#define FONT_SIZE 15.f
#define HORIZONTAL_PADDING (8.0*1.5f)
#define VERTICAL_PADDING (6.0*1.5f)

#import "QRMultiView.h"
#import "QRDataManager.h"
 @interface QRMultiView()
@property(strong,nonatomic)RLMResults *dataArray;
@property(assign)NSInteger hotKeyHeight;
@property(assign)float oldheight;
@property(assign)NSInteger maxIndex;
@end
 @implementation QRMultiView

- (void)dealloc{
#ifdef DEBUG
    printf("%s\n",__FUNCTION__);
#endif
}
 -(instancetype)initWithFrame:(CGRect)frame{
     self = [super initWithFrame:frame];
     self.backgroundColor = [UIColor whiteColor];
      return self;
}

-(void)removeFromSuperview{
   NSInteger l = self.dataArray.count - self.maxIndex-1;
    if (l>0) {//删除多余项
        for(NSUInteger i = self.maxIndex+1;i<self.dataArray.count;i++){
            QRSearhWord *v = self.dataArray[i];
            [[QRDataManager shareInstance] delSearchRecord:v.word];
        }
    }
    [super removeFromSuperview];
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
     self.hotKeyHeight = 0;
      CGSize textSize;
     CGRect previousFrame = CGRectMake(5, 5, 5, 5);
     BOOL isHasPreviousFrame = NO;
     float SCREEN_WIDTH = self.bounds.size.width;
     int i = 0;
     int maxLine = 2,currentLine = 0;
     for (QRSearhWord *item in self.dataArray) {
         NSString *text = item.word;
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
         self.maxIndex = btn.tag;
     }
     //self.hotKeyHeight = self.hotKeyHeight ;
      return self.hotKeyHeight+5;
 }

 - (void)onBtnClick:(UIButton *)sender
 {
     if (self.block) {
         self.block([self.dataArray objectAtIndex:sender.tag]);
     }
 }

@end
