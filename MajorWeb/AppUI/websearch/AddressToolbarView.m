//
//  AddressToolbarView.m
//  UrlWebViewForIpad
//
//  Created by Flipped on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AddressToolbarView.h"
#import "AppDelegate.h"
#import "FileCache.h"
#import "PopPromptView.h"
#import "SqliteInterface.h"
#import <CoreGraphics/CoreGraphics.h>
#import "WHConfigures.h"
#import "MarjorWebConfig.h"
#import "ZYInputAlertView.h"
#define kAddressButtonBackward @"backward"
#define kAddressButtonForward @"forward"
#define kAddressButtonHome @"home"
#define kAddressButtonBookmark @"bookmark"
#define kAddressButtonFavorite @"favorite"

#define kAddressButtonStatusNormal @"normal"
#define kAddressButtonStatusNormalLarge @"normal_large"
#define kAddressButtonStatusDisabled @"disabled"
#define kAddressButtonStatusDisabledLarge @"disabled_large"
#define kAddressButtonStatusHighlighted @"highlighted"
#define kAddressButtonStatusHighlightedLarge @"highlighted_large"

#define kViewStateHome 1
#define kViewStateDetail 2

#define CGRectSetX(rect,x) rect = CGRectMake(x, rect.origin.y,rect.size.width,rect.size.height)


@implementation UITextField (TKCategory)

- (void) selectTextAtRange:(NSRange)range{
    UITextPosition *start = [self positionFromPosition:[self beginningOfDocument] offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    [self setSelectedTextRange:[self textRangeFromPosition:start toPosition:end]];
}

@end

@interface AddressToolbarView ()
//展开地址栏
 - (void)lessenAddressBar;
@property(nonatomic,assign) BOOL isEnlarged;
@property(nonatomic,assign) int  viewState;
@end

@implementation AddressToolbarView {
  // status
  CGRect _originalFrame;
  PopPromptView *_promptView;
  UIView *_popViewMenu;
    BOOL  _isFocu;
}

@synthesize addressBar = _addressBar;
@synthesize backImageView = _backImageView;
@synthesize addressToolbarIndex = _addressToolbarIndex;
@synthesize isSelect = _isSelect;
@synthesize delegate = _delegate;
@synthesize textbgImg = _textbgImg;
@synthesize current_Url = _current_Url;
@synthesize previousUrlString = _previousUrlString;
@synthesize currentUrlString = _currentUrlString;
@synthesize reservedUrlString = _reservedUrlString;
@synthesize progressBar = _progressBar;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    [_promptView removeFromSuperview];_promptView = nil;
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame tabManager:(id)tabManager{
  self = [super initWithFrame:frame];
  if (self) {
    self.tabManager = tabManager;
    _backImageView = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:_backImageView];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(viewNavBarImage)
                                                   name:@"browser_openNightMode"
                                                 object:nil];
    

//      UIButton *_btnBack;
//      UIButton *_btnFavorite;
//      UIButton *_btnNewWeb;
      _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
      [_btnBack setTitle:@"返回" forState:UIControlStateNormal];
      [_btnBack setImage:[UIImage imageNamed:@"Brower.bundle/b_back"] forState:UIControlStateNormal];
      _btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
      [_btnFavorite setImage:[UIImage imageNamed:@"Brower.bundle/bq_add"] forState:UIControlStateNormal];
      _btnNewWeb = [UIButton buttonWithType:UIButtonTypeCustom];
      [_btnNewWeb setTitle:@"新建" forState:UIControlStateNormal];
      [_btnNewWeb.titleLabel setFont:[UIFont systemFontOfSize:14]];
      [_btnNewWeb setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [_btnBack addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
      [_btnNewWeb addTarget:self action:@selector(clickOpenNew:) forControlEvents:UIControlEventTouchUpInside];
      [_btnFavorite addTarget:self action:@selector(clickFavorite:) forControlEvents:UIControlEventTouchUpInside];

      _btnActionSearch = [UIButton buttonWithType:UIButtonTypeCustom];
      [_btnActionSearch setTitle:@"搜索" forState:UIControlStateNormal];
      [_btnActionSearch.titleLabel setFont:[UIFont systemFontOfSize:16]];
      [_btnActionSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [_btnActionSearch addTarget:self action:@selector(actionBtnGoClicked) forControlEvents:UIControlEventTouchUpInside];

      [self addSubview:_btnActionSearch];
      [self addSubview:_btnBack];
      [self addSubview:_btnFavorite];
      [self addSubview:_btnNewWeb];

    self.addressBar = [[AddressBarView alloc]
        initWithFrame:CGRectMake(282, 6, 580, 32.0f)]; //输入框
    self.addressBar.tag = 1;
    self.addressBar.delegate = self;
    self.addressBar.editDelegate = self;
    self.addressBar.dk_textColorPicker = DKColorPickerWithKey(ADDRESSTEXT);
    [self addSubview:self.addressBar];
      [self viewNavBarImage];
    UIImage *img_qr = [UIImage imageNamed:@"ewm"];
    _btnQRcode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnQRcode setImage:img_qr forState:UIControlStateNormal];
    [_btnQRcode setImage:img_qr forState:UIControlStateHighlighted];
//    _btnQRcode.frame = CGRectMake(MY_SCREEN_WIDTH - 45, 0, img_qr.size.width,
//                                  img_qr.size.height);
//    [_btnQRcode addTarget:theApp.nbrowserViewController
//                   action:@selector(scanQRcodeAction:)
//         forControlEvents:UIControlEventTouchUpInside];
    _btnQRcode.showsTouchWhenHighlighted = NO;
    _btnQRcode.alpha = 0;
    [self.addressBar addSubview:_btnQRcode];

    self.progressBar = [[UIProgressView alloc]
        initWithFrame:CGRectMake(0, self.frame.size.height - 2,
                                 self.frame.size.width, 2)];
    self.progressBar.progressTintColor =
        RGBCOLOR(26, 149, 251); // ProgressTintColor;
            
    self.progressBar.trackTintColor = [UIColor clearColor];
    self.progressBar.alpha = 0;
    self.progressBar.hidden = NO;
    [self addSubview:self.progressBar];

    _btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
      _btnRefresh.frame = CGRectMake(MY_SCREEN_WIDTH, 5, 32, 32);
    [_btnRefresh setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/NavRefresh_2")
                 forState:UIControlStateNormal];
    [_btnRefresh setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/NavRefresh_1")
                 forState:UIControlStateHighlighted];
    [_btnRefresh addTarget:self
                    action:@selector(refresh)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnRefresh];


    _btnActionGo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 32)];
    [_btnActionGo setTitle:@"取消" forState:UIControlStateNormal];
    [_btnActionGo.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_btnActionGo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnActionGo addTarget:self
                     action:@selector(cancel)
           forControlEvents:UIControlEventTouchUpInside];
 
    _btnActionGo.alpha = 0;
 
  //    [_btnActionGo dk_setTitleColorPicker:DKColorPickerWithKey(BTNSUBTITLE) forState:UIControlStateNormal];
  //  _btnActionGo.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_btnActionGo];

    self.previousUrlString = @"";
    self.currentUrlString = @"";
    self.reservedUrlString = @"";
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(changeAutoFrame:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(hideKeyboard)
               name:UIKeyboardWillHideNotification
             object:nil];
      [[NSNotificationCenter defaultCenter]
  addObserver:self
  selector:@selector(didChangeAutoFrame)
  name:UIKeyboardDidShowNotification
  object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(getFocus)
               name:kNOTIFICATION_ADDRESSTEXT_GETFOCUS
             object:nil];
    [self enterHomeState:NO];
  }
  return self;
}

-(void)viewNavBarImage
{
    BOOL isNight = false;
    NSAttributedString *searchP = [[NSAttributedString alloc] initWithString:@"搜索或输入网址"
                                                                  attributes:@{
                                                                               NSForegroundColorAttributeName : (isNight ? RGBCOLOR(98, 98, 98) :RGBCOLOR(0, 0, 0)),
                                                                               NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                               }
                                   
                                   
                                   ];

    
    self.addressBar.attributedPlaceholder = searchP;
}

- (void)getFocus {
//    if (false) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    }
//    [UIView animateWithDuration:kAnimateDuration animations:^{
//        [theApp.nbrowserViewController setupAddressBar];
//    } completion:^(BOOL finished) {
//        [self.addressBar becomeFirstResponder];
//    }];
}

-(void)clickBack:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(backWebFromToolBar)]) {
        [self.delegate backWebFromToolBar];
    }
}

-(void)clickOpenNew:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(newWebFromToolBar)]) {
        [self.delegate newWebFromToolBar];
    }
}

-(void)clickFavorite:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(addWebFavritorFromToolBar)]) {
        [self.delegate addWebFavritorFromToolBar];
    }

}

- (void)showInput{
    [self.addressBar becomeFirstResponder];
}

- (void)changeAutoFrame:(NSNotification *)notif {
  NSDictionary *info = [notif userInfo];
  NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGFloat keyboardHeight = [value CGRectValue].size.height;
  [_promptView changeAutoFrame:keyboardHeight];
}

- (void)hideKeyboard {
[self popSystem];
  [_promptView changeAutoFrame:0];
}

-(void)didChangeAutoFrame{
    //[self.addressBar performSelector:@selector(selectAll:) withObject: self.addressBar];
}

- (void)popPrompt:(id)txt showPrompt:(BOOL)showPrompt str:str {
  if (_promptView == nil) {
    float y =  self.frame.origin.y + self.frame.size.height;
    _promptView = [[PopPromptView alloc]
        initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, 768 - y)
           tabManager:self.tabManager];
    [self.relatedBrowserView addSubview:_promptView];
    _promptView.delegate = self;
    _promptView.alpha = 0;
  }

  _btnRefresh.alpha = 0;
  _promptView.alpha = 1;
  [self.relatedBrowserView bringSubviewToFront:_promptView];

  if (showPrompt) {
    [_promptView show];
  } else {
    [_promptView hide];
  }
    if (str) {
        [_promptView getDataArray:str Cate:YES];
    }
}

- (void)enterHomeState:(BOOL)animated {
  _viewState = kViewStateHome;
  self.addressBar.text = @"";
  [self layoutSubviews];
}

- (void)refresh {
  [self.delegate loadRequestRefreshFun:self];
}

- (void)cancel {
  if (_viewState == kViewStateHome) {
      [_addressBar cleanText];
  }
  [self lessenAddressBar];
  [self promptViewMiss];
  if (_viewState != kViewStateHome) {
    //[self.addressBar setText:[self.tabManager.selectedTab title]];
  }
  [self layoutSubviews];
    if ([self.delegate respondsToSelector:@selector(cancelToolsFun:)]){
        [self.delegate cancelToolsFun:self];
    }
}
- (void)actionBtnGoClicked {
    if ([self.addressBar.text length]>0) {
        [self textFieldShouldReturn:self.addressBar];
    }
}

- (void)deleteFun {
  self.addressBar.text = @"";
  self.current_Url = @"";
}

- (void)enlargeAddressBar:(BOOL)animated{
  [self.superview bringSubviewToFront:self];

  self.progressBar.alpha = 0;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animated?0.2:0
                   animations:^{
                     weakSelf.btnActionGo.alpha = 1;
                     weakSelf.addressBar.enlarged = YES;
                     weakSelf.isEnlarged = YES;
                     [self layoutSubviews];
                   }];
}

- (void)lessenAddressBar {
    __weak typeof(self) weakSelf = self;
  [self.addressBar resignFirstResponder];
  self.progressBar.alpha = 0.5;
  [UIView animateWithDuration:0.2
      animations:^{
        weakSelf.btnActionGo.alpha = 0;
          if (weakSelf.viewState == kViewStateDetail) {
          weakSelf.btnRefresh.alpha = 1;
        }
        weakSelf.addressBar.background =
            [weakSelf.addressBar.background stretchableImageWithLeftCapWidth:20
                                                            topCapHeight:0];
        weakSelf.addressBar.enlarged = NO;

          weakSelf.isEnlarged = NO;
        [self layoutSubviews];

      }
      completion:^(BOOL finished){

      }];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat margin = 10;
  CGFloat nav_Y = 6.0;
  CGFloat centerY = _isEnlarged ? self.frame.size.height / 2 : self.frame.size.height / 2 + nav_Y;

  _btnActionGo.center =
      CGPointMake(self.frame.size.width, self.frame.size.height / 2);
  if (_isEnlarged == YES) {
    self.backImageView.frame =
        CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _btnActionGo.center = CGPointMake(_btnActionGo.frame.size.width/2,
        centerY);
      _btnBack.frame = CGRectMake(1, _btnActionGo.frame.origin.y, 25, 19);
      _btnFavorite.frame = CGRectMake(_btnBack.frame.origin.x+_btnBack.frame.size.width+3,  _btnActionGo.frame.origin.y, 25, 19);
      _btnActionSearch.frame = CGRectMake(self.frame.size.width-42, 0, 40, 19);
      
    self.addressBar.frame = CGRectMake(
        _btnActionGo.frame.origin.x+_btnActionGo.frame.size.width+5, nav_Y, _btnActionSearch.frame.origin.x-(_btnActionGo.frame.origin.x+_btnActionGo.frame.size.width+15),
        self.addressBar.frame.size.height);
    _btnRefresh.alpha = 0;
      _btnQRcode.alpha = 0;
      CGRectSetX(_btnQRcode.frame, self.addressBar.frame.size.width + 35);
	  float y =  self.frame.origin.y + self.frame.size.height;
	  _promptView.frame = CGRectMake(0, y, self.frame.size.width, MY_SCREEN_HEIGHT-y);
      
      _btnNewWeb.center = CGPointMake(_btnNewWeb.center.x, _addressBar.center.y);
      _btnBack.center = CGPointMake(_btnBack.center.x, _addressBar.center.y);
      _btnFavorite.center = CGPointMake(_btnFavorite.center.x, _addressBar.center.y);
      _btnActionSearch.center = CGPointMake(_btnActionSearch.center.x, _addressBar.center.y);
      _btnActionSearch.alpha =1;
      _btnNewWeb.alpha = _btnBack.alpha = _btnFavorite.alpha = 0;
  } else {
    self.backImageView.frame =
        CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (_viewState == kViewStateHome) {
      _btnRefresh.alpha = 0;
      self.addressBar.frame =
          CGRectMake(70, nav_Y, self.frame.size.width - 16, 32);
      self.addressBar.background =
          [self.addressBar.background stretchableImageWithLeftCapWidth:20
                                                          topCapHeight:0];
      CGRectSetX(_btnQRcode.frame, self.addressBar.frame.size.width - 35);
      _btnQRcode.alpha = 1;
    } else {
      self.addressBar.frame = CGRectMake(
          90, nav_Y, self.frame.size.width - _btnRefresh.frame.size.width - 16-120,
          32);
      _btnRefresh.frame = CGRectMake(
          self.addressBar.frame.origin.x + self.addressBar.frame.size.width,
          self.addressBar.frame.origin.y, _btnRefresh.frame.size.width,
          _btnRefresh.frame.size.height);
           _btnNewWeb.frame = CGRectMake(_btnRefresh.frame.origin.x+_btnRefresh.frame.size.width+8,  _btnActionGo.frame.origin.y, 30, 19);
        _btnBack.frame = CGRectMake(15, _btnActionGo.frame.origin.y, 25, 19);
        _btnFavorite.frame = CGRectMake(_btnBack.frame.origin.x+_btnBack.frame.size.width+10,  _btnActionGo.frame.origin.y, 25, 19);
      _btnQRcode.alpha = 0;
        _btnNewWeb.center = CGPointMake(_btnNewWeb.center.x, _addressBar.center.y);
        _btnBack.center = CGPointMake(_btnBack.center.x, _addressBar.center.y);
        _btnFavorite.center = CGPointMake(_btnFavorite.center.x, _addressBar.center.y);
        _btnNewWeb.alpha = _btnBack.alpha = _btnFavorite.alpha = 1;
        _btnActionSearch.alpha =0;
    }
    self.progressBar.frame =
        CGRectMake(0, self.frame.size.height - 2, self.frame.size.width, 2);
  }
}

- (void)updateProcessbar:(float)progress animated:(BOOL)animated {
  if (progress == 1.0) {
    [self.progressBar setProgress:progress animated:animated];
    [UIView animateWithDuration:1.0
        animations:^{
          self.progressBar.alpha = 0;
        }
        completion:^(BOOL finished) {
          if (finished) {
            [self.progressBar setProgress:0.0 animated:NO];
          }
        }];
  } else {
    if (self.progressBar.alpha < 1.0) {
      self.progressBar.alpha = 1.0;
    }
    [self.progressBar setProgress:progress
                         animated:(progress > self.progressBar.progress) && animated];
  }
}

- (void)promptViewMiss {
  _promptView.alpha = 0;
  [self resignFirstResponder];
}

- (void)promptCopyUrl{
    [[UIPasteboard generalPasteboard] setString:_addressBar.text];
    [[UIApplication sharedApplication].keyWindow makeToast:@"拷贝成功" duration:1.5 position:@"center"];
}

- (void)promptEditUrl{
    __weak typeof(self) weakSelf = self;
    ZYInputAlertView *alertView = [ZYInputAlertView alertView];
    alertView.placeholder = _addressBar.text;
    alertView.inputTextView.text = _addressBar.text;
    alertView.alertViewDesLabel.text = @"编辑网址";
    alertView.alertViewDesLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18];
    
    [alertView confirmBtnClickBlock:^(NSString *inputString) {
        weakSelf.addressBar.text = inputString;
        weakSelf.current_Url = inputString;
        [weakSelf.addressBar becomeFirstResponder];
        [weakSelf actionBtnGoClicked];
    }];
    alertView.conCancleBtn.hidden = alertView.confirmWebBtn.hidden = NO;
    alertView.confirmBtn.hidden = YES;
    alertView.frame = CGRectMake(0, GetAppDelegate.appStatusBarH, MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT-GetAppDelegate.appStatusBarH);
    [alertView setNeedsLayout];
    [alertView show];
    [alertView.conCancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [alertView.confirmWebBtn setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)promptViewWillDissmiss:(PopPromptView *)promptView
           isChangeAddressTool:(BOOL)isChange {
  if (isChange) {
    [self lessenAddressBar];
  }
  [self promptViewMiss];
}

- (void)promptStartDragg
{
    if (self.addressBar.isFirstResponder) {
        [self.addressBar resignFirstResponder];
    }
}

- (void)promptClickUrl:(NSString*)url{
    if ([self.delegate respondsToSelector:@selector(loadReqeustFromUrl:)]) {
        [self.delegate loadReqeustFromUrl:url];
    }
}

- (void)promptViewBecomeFirstResponder {
  [self.addressBar resignFirstResponder];
}

- (void)layoutAddressToolbarSubviews {
}

-(void)copyEvent{
    [[UIPasteboard generalPasteboard] setString:_addressBar.text];
    [self popSystem];
}
-(void)delEvent{
    _addressBar.text = @"";
    [self popSystem];
}
-(void)ztEvent{
    _addressBar.text = [UIPasteboard generalPasteboard].string;
    [self popSystem];
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  [self popPrompt:textField showPrompt:YES str:@""];
  return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kNOTIFICATION_CANCEL_FAVWEBSITE
                    object:nil];
    [self enlargeAddressBar:true];
    _isFocu = true;
    self.isSelect = _isFocu;
   // [self popPrompt:textField showPrompt:YES str:self.current_Url];
    [self popPrompt:textField showPrompt:YES str:@""];
  self.addressBar.text = self.previousUrlString = self.currentUrlString =
      self.current_Url;

  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  NSLog(@"text view did select");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.addressBar performSelector:@selector(selectAll:) withObject:nil afterDelay:0.f];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    });
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self.addressBar resignFirstResponder];
    [textField selectTextAtRange:NSMakeRange(0, 0)];
  self.currentUrlString = self.addressBar.text;
  if (!_previousUrlString) {
    _previousUrlString = @"";
  }
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self editChange:textField
      suggestedLength:[str length]
                  str:str
               isLast:(range.length == 1 && range.location == 0 &&
                       string.length == 0)];

  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!textField.text || [textField.text compare:@""]==NSOrderedSame) {
        return false;
    }
  [self promptViewMiss];
  [self.addressBar resignFirstResponder];
    [self popSystem];
  NSString *tempUrl = [_currentUrlString
      stringByTrimmingCharactersInSet:[NSCharacterSet
                                          whitespaceAndNewlineCharacterSet]];
  NSString *regex = [NSString
      stringWithFormat:
          @"%@%@%@%@%@%@%@%@%@%@", @"^((https|http|ftp|rtsp|mms)?://)",
          @"?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?",
          @"(([0-9]{1,3}\\.){3}[0-9]{1,3}", @"|", @"([0-9a-zA-Z_!~*'()-]+\\.)*",
          @"([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\.", @"[a-zA-Z]{2,6})",
          @"(:[0-9]{1,4})?", @"((/?)|",
          @"(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"];
  if (tempUrl.length > 0) {
      [[MarjorWebConfig getInstance] addSearchHots:tempUrl];
    if ([tempUrl isMatchedByRegex:regex] || [tempUrl hasPrefix:@"http://"] ||
        [tempUrl hasPrefix:@"https://"]) {
      if (![tempUrl hasPrefix:@"http://"] && ![tempUrl hasPrefix:@"https://"]) {
        tempUrl = [@"http://" stringByAppendingString:tempUrl];
      }

      tempUrl =
          (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
              kCFAllocatorDefault, (CFStringRef)tempUrl,
              (CFStringRef) @"!$&'()*+,-./:;=?@_~%#[]", NULL,
              kCFStringEncodingUTF8));

        //回调出去
        [self promptClickUrl:tempUrl];
     } else {
      NSString *keywords = [tempUrl
          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      NSString *urlStr = [WHConfigures baiduSearchLink:keywords];
        //回调出去
         [self promptClickUrl:urlStr];
        //
    }
  }
  [self lessenAddressBar];

  return YES;
}

- (void)insertSearchHistory:(NSString *)str {
  [[SqliteInterface sharedSqliteInterface] setupDB:@"MAIN.sqlite"];
  [[SqliteInterface sharedSqliteInterface] connectDB];
  FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
  NSString *selectSql =
      @"SELECT count(*) AS titleCount FROM sHistory WHERE sName = ? ";
  FMResultSet *rs = [dbo executeQuery:selectSql, str];
  int count = 0;
  NSString *strDate = [FileCache getNowDate];
  while ([rs next]) {
    count = [rs intForColumn:@"titleCount"];
  }

  if (count == 0) {
    [dbo executeUpdate:@"INSERT INTO sHistory (sName,sDate) VALUES (?,?)", str,
                       strDate];
  } else {
    [dbo executeUpdate:@"UPDATE sHistory SET sDate = ? WHERE sName = ? ",
                       strDate, str];
  }
  [[SqliteInterface sharedSqliteInterface] closeDB];
}

#pragma mark NewTextField Delegate

//
- (void)popSystem{
    _isFocu = NO;
    self.isSelect = _isFocu;
    [_popViewMenu removeFromSuperview];_popViewMenu = nil;
}

- (void)editChange:(UITextField *)sender
   suggestedLength:(NSInteger)length
               str:(NSString *)str
            isLast:(BOOL)isLast {
  if (sender.tag == 1) {
    if (isLast) {
      [self popPrompt:sender showPrompt:YES str:@""];
    } else {
      if ([str length] > 0) {
        [self popPrompt:sender showPrompt:YES str:str];
      } else {
        [self popPrompt:sender showPrompt:YES str:str];
      }
    }
  }
}

- (void)searchEditChange:(UITextField *)sender {
}

#pragma mark -UpdateRefreshStauts
- (void)updateRefreshStatus:(BOOL)isHomePage {
  _viewState = isHomePage ? kViewStateHome : kViewStateDetail;
  _btnRefresh.alpha = !isHomePage;
  [self layoutSubviews];
}

@end
