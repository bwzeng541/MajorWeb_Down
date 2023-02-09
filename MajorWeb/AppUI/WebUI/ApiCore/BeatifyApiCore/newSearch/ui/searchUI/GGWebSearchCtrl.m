//
//  GGWebSearchCtrl.m
//  GGBrower
//
//  Created by zengbiwang on 2019/12/12.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "GGWebSearchCtrl.h"
#import "BlocksKit+UIKit.h"
#import "NSObject+UISegment.h"
#import "GGWebSearchView.h"
#import "GGWebSearchLables.h"
#import "GGSearchSuggestView.h"
@interface GGWebSearchCtrl ()<GGWebSearchViewDelegate,GGWebSearchLablesDelegate,GGSearchSuggestViewDelegate,UITextFieldDelegate>
@property(weak)IBOutlet UILabel *topLabelDes;
@property(weak)IBOutlet UILabel *titleLabelDes;
@property(weak)IBOutlet UIView *topView;
@property(strong)NSMutableArray *hostArrayData;
@property(weak)IBOutlet UIView *suggestSearchView;
@property(weak)IBOutlet UIView *searchParentView1;
@property(weak)IBOutlet UIView *searchView1;
@property(weak)IBOutlet UIView *searchView11;
@property(weak)IBOutlet UIView *searchLabel1;
@property(weak)IBOutlet UITextField *searchTextFiled1;
@property(weak)IBOutlet UIImageView *searchImageView1;
@property(weak)IBOutlet UIButton *closeBtn;
@property(weak)IBOutlet UIView *mainSearchView;
@property(strong) UIView *typeView;
@property(strong) UIScrollView *searchViews;
@property(assign) GGSearchType searchType;
@property(strong)GGSearchSuggestView *suggestView;
@property(strong)NSMutableDictionary *searchHistoryInfo;
@end

@implementation GGWebSearchCtrl

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return true;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return true;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self startToSearch:textField.text   type:self.searchType];
    [textField resignFirstResponder];
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [self updateSuggest:textField.text];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   self.titleLabelDes.text = self.topLabelDes.text = @"电影搜索";
    self.searchTextFiled1.placeholder = @"电影搜索--请输入内容";
    self.searchTextFiled1.delegate = self;
    ((UILabel*)self.searchLabel1).text = @"搜索历史";
    [self.closeBtn setTitle:@"< 返回" forState:UIControlStateNormal];
 
    self.searchParentView1.hidden = self.searchView1.hidden = YES;
    self.mainSearchView.hidden = NO;
    [self.closeBtn addTarget:self action:@selector(pressRemove:) forControlEvents:UIControlEventTouchUpInside];
    [self pressRemove:nil];
    [self updateSuggestSearchView:0];
    self.hostArrayData = [NSMutableArray arrayWithCapacity:10];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped:)];
        [self.view addGestureRecognizer:tap];
}

-(void)updateSuggest:(NSString*)keywords{
    if (self.searchParentView1.hidden) {
        return;
    }
        __weak typeof(self) weakSelf = self;
        dispatch_async(
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           @autoreleasepool {
                               NSString *urlString = [NSString
                                                      stringWithFormat:@"http://suggestion.baidu.com/"
                                                      @"su?wd=%@&p=3&cb=window.bdsug.su",
                                                      [keywords
                                                       stringByAddingPercentEscapesUsingEncoding:
                                                       NSUTF8StringEncoding]];
                               NSError *error = NULL;
                               NSURL *url = [NSURL URLWithString:urlString];
                               NSData *data =
                               [[NSData alloc] initWithContentsOfURL:url
                                                             options:NSDataReadingMappedIfSafe
                                                               error:&error];
                               if (error) {
                                   //如果读取失败，应该将之前的搜索记录也清除掉
                                   //[self.dataArray removeAllObjects];
                               } else {
                                   NSStringEncoding gbkEncoding =
                                   CFStringConvertEncodingToNSStringEncoding(
                                                                             kCFStringEncodingGB_18030_2000);
                                   NSString *jsonString =
                                   [[NSString alloc] initWithData:data
                                                         encoding:gbkEncoding];
                                   if (jsonString.length > 0) {
                                       error = nil;
                                       NSString *urlRegex = @"s:\\[\"(.*)\"\\]";
                                       NSRegularExpression *regex = [NSRegularExpression
                                                                     regularExpressionWithPattern:
                                                                     urlRegex options:NSRegularExpressionCaseInsensitive
                                                                     error:&error];
                                       NSTextCheckingResult *match = [regex
                                                                      firstMatchInString:jsonString
                                                                      options:NSMatchingReportProgress
                                                                      range:NSMakeRange(0, [jsonString length])];
                                      
                                       if (match) {
                                           NSRange firstRange = [match rangeAtIndex:1];
                                           NSString *matchedString =
                                           [jsonString substringWithRange:firstRange];
                                           NSArray *arr_hot = [matchedString componentsSeparatedByString:@"\",\""];
                                           [weakSelf.hostArrayData removeAllObjects];
                                           for (NSString *str in arr_hot) {
                                               [weakSelf.hostArrayData addObject:str];
                                           }
                                           //NIDPRINT(@"keyword %@ matchedString = %@",keywords,matchedString);
                                       }
                                   }
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self updateTableAndHostFrame];
                               });
                           }
                       });
 }

-(void)ggWebSearchSuggestViewClick:(NSString *)words{
    self.searchTextFiled1.text = words;
}

-(void)ggWebSearchSuggestUpdateFrameClick:(float)height{
    [self updateSuggestSearchView:height];
}

-(void)updateTableAndHostFrame{
    if (!self.suggestView) {
        self.suggestView = [[GGSearchSuggestView alloc] initWithFrame:CGRectMake(0, 0, self.suggestSearchView.bounds.size.width, 0)];
        [self.suggestSearchView addSubview:self.suggestView];
        self.suggestView.delegate = self;
        [self.suggestView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.suggestSearchView);
        }];
    }
    [self.suggestView updateWords:self.hostArrayData];
}

-(void)updateSuggestSearchView:(float)hh{
      [self.suggestSearchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.searchParentView1);
        make.top.equalTo(self.searchParentView1.mas_bottom).mas_offset(38);
        make.height.mas_equalTo(hh);
    }];
}

-(void)pressRemove:(id)sender{
    [self.delegate ggWebSearch:[NSArray array] titles:[NSArray array] word:@"" isSearch:NO];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!self.typeView) {
        CGSize typeSize = CGSizeMake(self.mainSearchView.bounds.size.width, 32);
        CGSize btnSize = CGSizeMake( 32*3, 32);//247*64
        self.typeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, typeSize.width, typeSize.height)];
        [self.mainSearchView addSubview:self.typeView];
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.typeView addSubview:btn1];
        [btn1 addTarget:self action:@selector(pressType1:) forControlEvents:UIControlEventTouchUpInside];
        [btn1 setTitle:@"网页搜索" forState:UIControlStateNormal];
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
              [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
              [self.typeView addSubview:btn2];
              [btn2 addTarget:self action:@selector(pressType2:) forControlEvents:UIControlEventTouchUpInside];
              [btn2 setTitle:@"电影搜索" forState:UIControlStateNormal];
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
              [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
              [self.typeView addSubview:btn3];
              [btn3 addTarget:self action:@selector(pressType3:) forControlEvents:UIControlEventTouchUpInside];
              [btn3 setTitle:@"图片搜索" forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"gg_seach_chose"] forState:UIControlStateNormal];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"gg_seach_chose"] forState:UIControlStateNormal];
        [btn3 setBackgroundImage:[UIImage imageNamed:@"gg_seach_chose"] forState:UIControlStateNormal];
        [btn3.titleLabel setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:15]];
        [btn2.titleLabel setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:15]];
        [btn1.titleLabel setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:15]];
        [NSObject initiiWithFrame:self.typeView contenSize:typeSize vi:btn1 viSize:btnSize vi2:nil index:0 count:3];
        [NSObject initiiWithFrame:self.typeView contenSize:typeSize vi:btn2 viSize:btnSize vi2:btn1 index:1 count:3];
        [NSObject initiiWithFrame:self.typeView contenSize:typeSize vi:btn3 viSize:btnSize vi2:btn2 index:2 count:3];
        [self initAllSearchView];
        [self pressType2:nil];
    }
}

-(NSMutableDictionary*)addOrUpdateSearchInfo:(NSMutableDictionary*)oldInfo word:(NSString*)word key:(NSString*)key{
    if (!oldInfo) {
        oldInfo = [NSMutableDictionary dictionary];
        [oldInfo setValue:[NSMutableArray arrayWithCapacity:1] forKey:@"wordArraykey"];
    }
    else{
        NSMutableArray *arrry = [NSMutableArray arrayWithArray:[oldInfo objectForKey:@"wordArraykey"]] ;
        BOOL isAdd = true;
        for (int i = 0; i < arrry.count; i++) {
            NSString *sgr = [arrry objectAtIndex:i];
            if ([sgr compare:word]==NSOrderedSame) {
                isAdd = false;
                break;
            }
        }
        if (isAdd) {
            if (arrry.count>=100) {//删除最后一个
                [arrry removeLastObject];
            }
            [arrry insertObject:word atIndex:0];
            [oldInfo setValue:arrry forKey:@"wordArraykey"];
        }
    }
    [self.searchHistoryInfo setValue:oldInfo forKey:key];
    [self.searchHistoryInfo writeToFile:GGWebSearchInfoPath atomically:YES];
    return oldInfo;
}

-(NSString*)getTitleFromKey:(NSString*)key{
    if ([key integerValue]==GGSearch_Html) {
        return  @"网页搜索";
    }
    else if ([key integerValue]==GGSearch_Video){
        return  @"视频搜索";
    }
    else if ([key integerValue]==GGSearch_Pic){
           return @"图片搜索";
       }
    return @"unKnow";
}

-(GGWebSearchView*)createSearchView:(NSString*)key array:(NSArray*)wordsarray{
    GGWebSearchView *vv = [[GGWebSearchView alloc] initWithFrame:CGRectMake(0, 0, self.searchViews.bounds.size.width, 0) type:(GGSearchType)[key integerValue] wordArray:wordsarray title:[self getTitleFromKey:key] delegate:self maxLine:2];
    [self.searchViews addSubview:vv];
    return vv;
}

-(void)initAllSearchView{
     self.searchHistoryInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    NSDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:GGWebSearchInfoPath];
    if (info) {
        [self.searchHistoryInfo setDictionary:info];
    }
    else{
        [self addOrUpdateSearchInfo:nil word:nil key:[NSString stringWithFormat:@"%d",GGSearch_Html]];
        [self addOrUpdateSearchInfo:nil word:nil key:[NSString stringWithFormat:@"%d",GGSearch_Video]];
        [self addOrUpdateSearchInfo:nil word:nil key:[NSString stringWithFormat:@"%d",GGSearch_Pic]];
    }
    float startY  = self.typeView.frame.origin.y+self.typeView.frame.size.height+45;
    self.searchViews = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startY, self.mainSearchView.frame.size.width, self.mainSearchView.frame.size.height-startY)];
    self.searchViews.backgroundColor = [UIColor whiteColor];
    [self.mainSearchView addSubview:self.searchViews];
    self.searchViews.scrollEnabled = NO;
    [self.searchViews setContentSize:CGSizeMake(0, 0)];
    GGWebSearchView *v1= [self createSearchView:[NSString stringWithFormat:@"%d",GGSearch_Html] array:[[self.searchHistoryInfo objectForKey:[NSString stringWithFormat:@"%d",GGSearch_Html]]objectForKey:@"wordArraykey"]];
    GGWebSearchView *v2= [self createSearchView:[NSString stringWithFormat:@"%d",GGSearch_Video] array:[[self.searchHistoryInfo objectForKey:[NSString stringWithFormat:@"%d",GGSearch_Video]]objectForKey:@"wordArraykey"]];
    GGWebSearchView *v3= [self createSearchView:[NSString stringWithFormat:@"%d",GGSearch_Pic] array:[[self.searchHistoryInfo objectForKey:[NSString stringWithFormat:@"%d",GGSearch_Pic]]objectForKey:@"wordArraykey"]];
    float offsetY = 30;
    v2.frame = CGRectMake(0, v1.frame.origin.y+v1.frame.size.height+offsetY, v2.frame.size.width, v2.frame.size.height);
    v3.frame = CGRectMake(0, v2.frame.origin.y+v2.frame.size.height+offsetY, v3.frame.size.width, v3.frame.size.height);
    float totalH = v3.frame.size.height+v3.frame.origin.y;
    if (totalH>self.searchViews.bounds.size.height) {
        self.searchViews.scrollEnabled = YES;
        [self.searchViews setContentSize:CGSizeMake(0, totalH)];
    }
}

-(void)updateSearchLabels{
    self.searchParentView1.hidden = NO;
    self.searchTextFiled1.text = nil;
    self.searchParentView1.hidden = self.searchView1.hidden = NO;
    self.mainSearchView.hidden = YES;
    [[self.searchView11 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    GGWebSearchLables *v = [[GGWebSearchLables alloc] initWithFrame:CGRectMake(0, 0, self.searchView11.frame.size.width, 0) wordArray:[[self.searchHistoryInfo objectForKey:[NSString stringWithFormat:@"%d",self.searchType]]objectForKey:@"wordArraykey"] delegate:self maxLine:7];
    [self.searchView11 addSubview:v];
    [self.searchTextFiled1 becomeFirstResponder];
}

-(void)pressType1:(id)sender{
    self.searchType= GGSearch_Html;
    ((UILabel*)self.searchLabel1).text =  @"网页搜索历史";
    [self updateSearchLabels];
}

-(void)pressType2:(id)sender{
    self.searchType= GGSearch_Video;
    ((UILabel*)self.searchLabel1).text =  @"视频搜索历史";
    [self updateSearchLabels];
}

-(void)pressType3:(id)sender{
    self.searchType= GGSearch_Pic;
    ((UILabel*)self.searchLabel1).text = @"图片搜索历史";
    [self updateSearchLabels];
}

    //点击事件
-(void)viewTapped:(UIGestureRecognizer *)gesture
{
        self.searchParentView1.hidden = self.searchView1.hidden = YES;
        self.mainSearchView.hidden = NO;
        self.searchParentView1.hidden = YES;
        [self updateSuggestSearchView:0];
        [self.searchTextFiled1 resignFirstResponder];
    [self.delegate ggWebSearch:[NSArray array] titles:[NSArray array] word:@"" isSearch:NO];
}

-(void)ggWebSearchLablesClick:(NSString*)words{
    self.searchTextFiled1.text = words;
    [self ggWebSearchViewClick:words type:self.searchType];
}

 
-(void)ggWebSearchViewClick:(NSString*)word type:(GGSearchType)type{
    [self startToSearch:word   type:type];
}


-(void)startToSearch:(NSString*)word   type:(GGSearchType)type{
    if ([word length]>=1 && [[word
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]!=0) {
        NSString *key = [NSString stringWithFormat:@"%d",type];
        [self addOrUpdateSearchInfo:[self.searchHistoryInfo objectForKey:key] word:word key:key];
        NSString *copyWord = [word copy];
        word = [word
                stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
         [self.delegate ggWebSearch:[NSArray array] titles:[NSArray array]   word:copyWord isSearch:YES];
    }
    else{
        
    }
}
@end
