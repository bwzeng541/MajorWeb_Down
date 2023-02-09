#define LABEL_MARGIN 12.0f
#define BOTTOM_MARGIN 8.0f
#define CORNER_RADIUS 8.0f
#define FONT_SIZE 15.f
#define HORIZONTAL_PADDING (8.0*1.5f)
#define VERTICAL_PADDING (6.0*1.5f)

#import "GGSearchSuggestView.h"

@interface GGSearchSuggestView()<UIGestureRecognizerDelegate>
@property(assign)float wordsHeight;
@end

@implementation GGSearchSuggestView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    UITapGestureRecognizer* singleRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    singleRecognizer.delegate = self;
    [self addGestureRecognizer:singleRecognizer];
     return self;
}

-(void)dealloc{
    
}

-(void)updateWords:(NSArray*)array{
     self.backgroundColor = [UIColor clearColor];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.clipsToBounds = YES;
        self.wordsHeight = 0;
       CGSize textSize;
       CGRect previousFrame = CGRectMake(5, 5, 5, 5);
       BOOL isHasPreviousFrame = NO;
       float SCREEN_WIDTH = self.bounds.size.width;
       int i = 0;
        int maxLine=2,currentLine = 0;
       for (NSString *item in array) {
           NSString *text = item;
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
                   self.wordsHeight += textSize.height + BOTTOM_MARGIN;
                   currentLine++;
               }else{
                   //无需换行
                   nowRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
               }
               nowRect.size = textSize;
               btn.frame = CGRectMake(nowRect.origin.x, nowRect.origin.y, nowRect.size.width, nowRect.size.height);
           }else{
               //首行首个关键字
               if (currentLine>=maxLine) {
                   break;
               }
               currentLine++;
               
               btn.frame = CGRectMake(5, 5, textSize.width, textSize.height);
               self.wordsHeight = textSize.height;
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
       if (self.wordsHeight>10) {
           self.wordsHeight+=15;
       }
    [self.delegate ggWebSearchSuggestUpdateFrameClick:self.wordsHeight];
}

-(void)top{
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
  CGPoint touchPoint = [touch locationInView:self];
    return !CGRectContainsPoint([self superview].frame, touchPoint);
}
 
-(void)onBtnClick:(UIButton*)sender{
    [self.delegate ggWebSearchSuggestViewClick:sender.titleLabel.text];
}
@end
