

#import "GGWebSearchView.h"
#import "GGWebSearchLables.h"
@interface GGWebSearchView()<GGWebSearchLablesDelegate>
@property(assign)float startOffsetY;
@property(assign)float wordsHeight;
@property(assign)GGSearchType searchType;
@property(assign)NSInteger maxLine;
@property(copy)NSArray *wordArray;
@property(strong)GGWebSearchLables *searchLables;
@property(weak)id<GGWebSearchViewDelegate>delegate;
@end
@implementation GGWebSearchView
 
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame  type:(GGSearchType)type  wordArray:(NSArray*)wordArray title:(NSString*)title delegate:(id<GGWebSearchViewDelegate>)delegate maxLine:(NSInteger)maxLine{
    self = [super initWithFrame:frame];
    self.searchType = type;
    self.delegate  = delegate;
    self.wordArray = wordArray;
    self.maxLine = maxLine;
    UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    desLabel.text = title;
    desLabel.font = [UIFont boldSystemFontOfSize:20];
    desLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:desLabel];
    self.startOffsetY = desLabel.frame.origin.y+desLabel.frame.size.height+5;
    float hh = [self initLabel];
    if (hh<=1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.startOffsetY, frame.size.width, 40)];
        [self addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:20];
        label.backgroundColor = [UIColor grayColor];
        label.text =  @"没有搜索记录";label.hidden = YES;
        self.wordsHeight+=label.frame.origin.y+label.frame.size.height;
        self.searchLables.hidden = YES;
    }
    else{
       self.searchLables.frame = CGRectMake(self.searchLables.frame.origin.x, self.startOffsetY, self.searchLables.frame.size.width, self.searchLables.frame.size.height);
        self.wordsHeight = self.searchLables.frame.origin.y+self.searchLables.frame.size.height;
    }
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width,self.wordsHeight);
    return self;
}

- (float )initLabel
{
    self.searchLables= [[GGWebSearchLables alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0) wordArray:self.wordArray delegate:self maxLine:self.maxLine];
    [self addSubview:self.searchLables];
    return self.searchLables.frame.size.height;
}

-(void)ggWebSearchLablesClick:(NSString*)word{
    [self.delegate ggWebSearchViewClick:word type:self.searchType];
}
@end
