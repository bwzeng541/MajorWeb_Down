
#import "AddressBarView.h"
#import "WebInputView.h"
#ifndef ADDRESS_BAR_VIEW
#define ADDRESS_BAR_VEW

#define URL_PADDING 6.0f
#define URL_Length 36.0f
#endif

@interface AddressBarView()<WebInputViewDelegate>
{
    BOOL _isCancelTouch;
    float _currentSliderValue;
    float _oldSilderValue;
}

@property(nonatomic, strong) UIView *leftContainer;
@property(nonatomic, strong) UIView *rightContainer;
@end

@implementation AddressBarView

@synthesize oldText;
@synthesize editDelegate;

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderStyle = UITextBorderStyleNone;
        self.dk_textColorPicker = DKColorPickerWithKey(ADDRESSTEXT);
        self.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
        self.returnKeyType = UIReturnKeyGo;
        self.keyboardType = UIKeyboardTypeEmailAddress;
        self.keyboardAppearance = UIKeyboardTypeASCIICapable;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        NSString *imageName = @"Brower.bundle/topsstb_B";
        UIImageView *searchLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        self.leftView = searchLeft;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        self.font = [UIFont systemFontOfSize:15];
        

        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor colorWithHexString:@"dfdfdf"].CGColor;
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        
        WebInputView *iii =  [[WebInputView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        self.inputAccessoryView = iii;
        [iii setDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeyBoardStyle) name:@"browser_openNightMode" object:nil];
    }
    return self;
}


//- (BOOL) canBecomeFirstResponder
//{
//    return YES;
//}
//
//- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
//{
//    [self becomeFirstResponder];
//    if ( [UIMenuController sharedMenuController] ) {
//        [UIMenuController sharedMenuController].menuVisible = NO;
//    }
//    return YES;
//}


- (UITextRange*) textRangeFromNSRange:(NSRange )range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    return textRange;
}

- (NSRange) selectedRange:(UITextField *)textField
{
    UITextPosition* beginning = textField.beginningOfDocument;
    UITextRange* selectedRange = textField.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

-(NSString*)getNoBlank:(NSString*)str{
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];//英文空格
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];//中文空格
    return str;
}

-(void)clickCharFromInputView:(NSString*)str{
    NSMutableString *strNew = [NSMutableString stringWithCapacity:100];
    if (self.text) {
        self.text = [self getNoBlank:self.text];
        [strNew appendString:self.text];
    }
    NSRange selectRange = [self selectedRange:self];
    NSInteger insertPos = selectRange.location+selectRange.length;
    NSInteger startPos = insertPos;
    NSString *tt = [self getNoBlank:str];
    NSString *value = [tt stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSInteger length = [value length];
    
    if (selectRange.length==0) {//没有选择
        [strNew insertString:value atIndex:insertPos];
    }
    else{
        [strNew replaceCharactersInRange:selectRange withString:value];
    }
    if (selectRange.location==0) {
        startPos=length;
    }
    else{
        startPos=selectRange.location+length;
    }
    NSArray *arraySubView = [self subviews];
    UIScrollView *vv = nil;
    CGPoint offset = CGPointZero;
    for (int i = 0; i < arraySubView.count; i++) {
        if( [[arraySubView objectAtIndex:i]isKindOfClass:[UIScrollView class] ]){
            vv = [arraySubView objectAtIndex:i];
            offset = vv.contentOffset;
            break;
        }
    }
    self.text = strNew;
    UITextRange *textRange = [self textRangeFromNSRange:NSMakeRange(startPos, 0)];
    self.selectedTextRange = textRange;
    if (vv) {
        [vv setContentOffset:offset];
    }
}

-(void)changeKeyBoardStyle
{
    self.dk_textColorPicker = DKColorPickerWithKey(ADDRESSTEXT);
    NSString *imageName = @"Brower.bundle/topsstb_B";
    UIImageView *searchLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.leftView = searchLeft;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    
}


- (void)cleanText
{
    self.text = @"";
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    if (![self.oldText isEqualToString:self.text]) {
        self.oldText = self.text;
        //        [self.editDelegate editChange:self];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        return CGRectMake(bounds.origin.x + 30, bounds.origin.y, bounds.size.width-URL_Length - 30, bounds.size.height);
    }
    else
    {
        return CGRectMake(bounds.origin.x + 30, bounds.origin.y+URL_PADDING, bounds.size.width-URL_Length, bounds.size.height);
    }
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(self.frame.size.width - 32, self.frame.size.height / 2 - 16, 32, 32);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        return CGRectMake(bounds.origin.x + 30, bounds.origin.y, bounds.size.width - URL_Length*3, bounds.size.height);
    }
    else
    {
        return CGRectMake(bounds.origin.x + 30, bounds.origin.y+URL_PADDING, bounds.size.width - URL_Length, bounds.size.height);
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        return CGRectMake(bounds.origin.x + 30, bounds.origin.y, bounds.size.width - URL_Length, bounds.size.height);
    }
    else
    {
        return CGRectMake(bounds.origin.x + 30, bounds.origin.y + URL_PADDING, bounds.size.width - URL_Length, bounds.size.height);
    }
}

//-(CGRect)placeholderRectForBounds:(CGRect)bounds
//{
//  CGRect iconRect = [super placeholderRectForBounds:bounds];
//  iconRect.origin.x += 24;// 右偏10
//  return iconRect;
//}

-(CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 10;// 右偏10
    return iconRect;
}

#pragma mark TSSlider Touch delegate

- (void)addRange:(id)sender offset:(NSInteger)offset
{
    UITextRange *trange = self.selectedTextRange;
    
    UITextPosition* start = [self positionFromPosition:trange.start inDirection:UITextLayoutDirectionRight offset:offset];
    
    if (start)
    {
        [self setSelectedTextRange:[self textRangeFromPosition:start toPosition:start]];
    }
}

- (void)subRange:(id)sender offset:(NSInteger)offset
{
    UITextRange *trange = self.selectedTextRange;
    
    UITextPosition* start = [self positionFromPosition:trange.start inDirection:UITextLayoutDirectionLeft offset:offset];
    
    if (start)
    {
        [self setSelectedTextRange:[self textRangeFromPosition:start toPosition:start]];
    }
}

- (void)sliderValueChange:(id)sender
{
    [self unmarkText];
    NSString *t = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.text = t;
    int c = round(fabsf((_currentSliderValue - _oldSilderValue)));
    _currentSliderValue = [(UISlider*)sender value];
    if ((_isCancelTouch || c == 0) && (_currentSliderValue >= 5 && _currentSliderValue <= ([self sliderMaxLength] - 5))) {
        return;
    }
    
    if (_currentSliderValue < 5) {
        [self subRange:nil offset:1];
        return;
    }
    
    if (_currentSliderValue > ([self sliderMaxLength] - 5)) {
        [self addRange:nil offset:1];
        return;
    }
    
    BOOL direction = NO;
    NSInteger index = round(fabsf((_currentSliderValue - _oldSilderValue)));
    if (_currentSliderValue >= _oldSilderValue) {
        direction = YES;
        _oldSilderValue = _currentSliderValue;
    }
    else if (_currentSliderValue < _oldSilderValue)
    {
        _oldSilderValue = _currentSliderValue;
    }
    
    if (direction) {
        [self addRange:nil offset:index];
    }
    else
    {
        [self subRange:nil offset:index];
    }
    //[self setSelectedWithDirection:direction];
    //self.selectedTextRange = NSMakeRange([self selectedRange].location, 1);
}

-(float) sliderMaxLength
{
    return 100.0f;
}

@end
